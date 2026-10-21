import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/questionnaire_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/discipline/app_blocker.dart';
import 'package:sistema/domain/discipline/discipline_hook.dart';
import 'package:sistema/domain/discipline/discipline_l10n.dart';
import 'package:sistema/domain/discipline/discipline_rules.dart';
import 'package:sistema/l10n/app_localizations_ru.dart';
import 'package:sistema/l10n/app_localizations_tr.dart';

import '../../helpers/test_db.dart';

Future<void> _schedule(AppDatabase db, {required int wake, required int bed}) async {
  await db.into(db.scheduleSettings).insertOnConflictUpdate(ScheduleSettingsCompanion.insert(
        id: 'main',
        updatedAt: DateTime.utc(2026, 10, 21),
        deviceId: await db.deviceId(),
        wakeMinute: Value(wake),
        bedMinute: Value(bed),
      ));
}

void main() {
  test('загрузка контекста: без данных — значения по умолчанию', () async {
    final db = memoryDb();
    addTearDown(db.close);
    expect(await DisciplineContextLoader(db).load(), DisciplineContext.fallback);
  });

  test('загрузка контекста из расписания и анкеты', () async {
    final db = memoryDb();
    addTearDown(db.close);
    await _schedule(db, wake: 330, bed: 1290);
    final q = QuestionnaireRepository(db);
    await q.write(QuestionnaireSection.training, {'level': 'intermediate', 'minutesPerDay': 20});
    await q.write(QuestionnaireSection.health, {'injuries': 'спина'});
    expect(
      await DisciplineContextLoader(db).load(),
      const DisciplineContext(
        level: TrainingLevel.intermediate,
        minutesPerDay: 20,
        wakeMinute: 330,
        bedMinute: 1290,
        hasInjuries: true,
      ),
    );
  });

  test('источник квестов обновляет контекст при изменении анкеты', () async {
    final db = memoryDb();
    addTearDown(db.close);
    final source = DisciplineQuestSource(db);
    addTearDown(source.dispose);
    final day = DateTime(2026, 10, 21);
    // До загрузки — безопасный контекст по умолчанию.
    expect(source(day).length, 3);
    await source.start();
    expect(source.context.level, isNull);

    await QuestionnaireRepository(db).write(QuestionnaireSection.training, {'level': 'advanced'});
    for (var i = 0; i < 50 && source.context.level != TrainingLevel.advanced; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(source.context.level, TrainingLevel.advanced);
    final workout = source(day).singleWhere((q) => q.title.key == DisciplineQuestKeys.workout);
    expect(workout.title.params['minutes'], 20);
  });

  test('названия квестов: ru/tr, чужой ключ → null', () {
    final ru = AppLocalizationsRu();
    final tr = AppLocalizationsTr();
    final qs = disciplineQuests(DateTime(2026, 10, 21), ctx: DisciplineContext.fallback);
    expect(disciplineQuestTitle(ru, qs[0].title.key!, qs[0].title.params), 'Подъём в 06:00');
    expect(disciplineQuestTitle(ru, qs[1].title.key!, qs[1].title.params), 'Доп. тренировка: 10 мин');
    expect(disciplineQuestTitle(ru, qs[2].title.key!, qs[2].title.params), 'Отбой в 22:00');
    expect(disciplineQuestTitle(tr, DisciplineQuestKeys.walk, const {'minutes': 20}), 'Sakin yürüyüş: 20 dk');
    expect(disciplineQuestTitle(ru, 'other', const {}), isNull);
    for (final r in DisciplineReason.values) {
      expect(disciplineReasonLabel(ru, r), isNotEmpty);
    }
    for (final e in DisciplineExit.values) {
      expect(disciplineExitLabel(tr, e), isNotEmpty);
    }
  });

  test('заглушка блокировщика ничего не делает', () async {
    const b = NoopAppBlocker();
    expect(await b.isAvailable(), isFalse);
    await b.blockFrom(DateTime(2026), DateTime(2026, 1, 2));
    await b.unblock();
  });
}
