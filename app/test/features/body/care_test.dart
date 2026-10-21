import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/section_hooks.dart';
import 'package:sistema/features/body/data/care_repository.dart';
import 'package:sistema/features/body/domain/care_template.dart';

import '../../helpers/test_db.dart';

class _FakeHooks extends NoopSectionQuestHooks {
  final done = <CareRoutine>[];

  @override
  Future<void> careRoutineDone(CareRoutine routine, {DateTime? at}) async => done.add(routine);
}

final _tuesday = DateTime(2026, 10, 20);
final _wednesday = DateTime(2026, 10, 21);

void main() {
  group('шаблон по анкете', () {
    test('тип кожи из ответов', () {
      expect(CareProfile.from(const {'oilyByNoon': 'all'}, const []).skinType, SkinType.oily);
      expect(CareProfile.from(const {'oilyByNoon': 'tzone'}, const []).skinType, SkinType.combination);
      expect(CareProfile.from(const {'oilyByNoon': 'no', 'tightness': 'often'}, const []).skinType, SkinType.dry);
      expect(CareProfile.from(const {'oilyByNoon': 'no', 'tightness': 'never'}, const []).skinType, SkinType.normal);
      expect(CareProfile.from(const {}, const []).skinType, SkinType.unknown);
      expect(CareProfile.from(const {'reactions': ' щиплет '}, const []).sensitive, isTrue);
      expect(CareProfile.from(const {'reactions': ''}, const []).sensitive, isFalse);
    });

    test('без целей — базовый уход', () {
      const t = CareTemplate(CareProfile());
      expect(t.items(CareRoutine.morning, _tuesday), [CareItemKeys.cleanse, CareItemKeys.moisturize, CareItemKeys.sunscreen]);
      expect(t.items(CareRoutine.evening, _tuesday),
          [CareItemKeys.removeSunscreen, CareItemKeys.cleanse, CareItemKeys.moisturize]);
    });

    test('цели: отёки, прыщи, чёрные точки; отшелушивание по дням', () {
      final t = CareTemplate(CareProfile.from(
        const {'oilyByNoon': 'all'},
        const [GoalKind.swelling, GoalKind.acne, GoalKind.blackheads],
      ));
      expect(t.items(CareRoutine.morning, _tuesday).first, CareItemKeys.coldRinse);
      expect(t.items(CareRoutine.evening, _tuesday), [
        CareItemKeys.removeSunscreen,
        CareItemKeys.cleanse,
        CareItemKeys.exfoliate,
        CareItemKeys.acneCare,
        CareItemKeys.moisturize,
        CareItemKeys.handsOff,
      ]);
      expect(t.items(CareRoutine.evening, _wednesday), isNot(contains(CareItemKeys.exfoliate)));
    });

    test('чувствительная кожа — отшелушивание только по пятницам', () {
      final t = CareTemplate(CareProfile.from(const {'reactions': 'краснеет'}, const [GoalKind.blackheads]));
      expect(t.items(CareRoutine.evening, _tuesday), isNot(contains(CareItemKeys.exfoliate)));
      expect(t.items(CareRoutine.evening, DateTime(2026, 10, 23)), contains(CareItemKeys.exfoliate));
    });
  });

  group('отметки и закрытие рутины', () {
    late AppDatabase db;
    setUp(() => db = memoryDb());
    tearDown(() => db.close());

    test('хук вызывается один раз, когда закрыт последний пункт', () async {
      final hooks = _FakeHooks();
      final service = CareService(CareRepository(db), hooks);
      const items = [CareItemKeys.cleanse, CareItemKeys.moisturize];
      Future<bool> toggle(String key, bool done) =>
          service.toggle(day: _tuesday, routine: CareRoutine.morning, itemKey: key, done: done, items: items);

      expect(await toggle(CareItemKeys.cleanse, true), isFalse);
      expect(hooks.done, isEmpty);
      expect(await toggle(CareItemKeys.moisturize, true), isTrue);
      expect(hooks.done, [CareRoutine.morning]);

      // Повторная отметка уже отмеченного — без хука.
      expect(await toggle(CareItemKeys.moisturize, true), isFalse);
      expect(hooks.done, hasLength(1));

      // Снять и снова поставить: строка «воскресает» (уникальный ключ), рутина закрыта снова.
      expect(await toggle(CareItemKeys.cleanse, false), isFalse);
      final marks = await CareRepository(db).marks(_tuesday);
      expect(marks, {(routine: CareRoutine.morning, itemKey: CareItemKeys.moisturize)});
      expect(await toggle(CareItemKeys.cleanse, true), isTrue);
      expect(hooks.done, hasLength(2));
      final rows = await db.select(db.careChecks).get();
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.deletedAt == null), isTrue);
    });

    test('отметки по дням и рутинам независимы', () async {
      final repo = CareRepository(db);
      await repo.setDone(_tuesday, CareRoutine.morning, CareItemKeys.cleanse, true);
      await repo.setDone(_tuesday.add(const Duration(hours: 15)), CareRoutine.evening, CareItemKeys.cleanse, true);
      expect(await repo.marks(_tuesday), hasLength(2));
      expect(await repo.marks(_wednesday), isEmpty);
    });
  });
}
