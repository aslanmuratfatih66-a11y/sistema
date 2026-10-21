import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_b/character_step.dart';

import '../../../helpers/test_db.dart';
import 'qb_harness.dart';

void main() {
  testWidgets('архетип обязателен; мат только в жёстком режиме и сбрасывается при смене', (tester) async {
    final db = memoryDb();
    final controller = await pumpStep(tester, db, const CharacterStep());

    // По умолчанию архетип не выбран — дальше нельзя.
    expect(controller.canProceed, isFalse);
    var data = await readSection(tester, db, QuestionnaireSection.character);
    expect(data['motivation'], 'normal');
    expect(data['profanityAllowed'], false);
    expect(find.byKey(const ValueKey('qbProfanitySwitch')), findsNothing);

    await tapKey(tester, 'qbArchetype_grimSwordsman');
    expect(controller.canProceed, isTrue);
    data = await readSection(tester, db, QuestionnaireSection.character);
    expect(data['archetype'], 'grimSwordsman');
    expect((data['voice'] as String).startsWith('grimSwordsman.'), isTrue);

    // Переключатель мата появляется только при harsh.
    await tapKey(tester, 'qbMotivation_strict');
    expect(find.byKey(const ValueKey('qbProfanitySwitch')), findsNothing);
    await tapKey(tester, 'qbMotivation_harsh');
    expect(find.byKey(const ValueKey('qbProfanitySwitch')), findsOneWidget);
    await tapKey(tester, 'qbProfanitySwitch');
    data = await readSection(tester, db, QuestionnaireSection.character);
    expect(data['motivation'], 'harsh');
    expect(data['profanityAllowed'], true);

    // Смена режима сбрасывает мат.
    await tapKey(tester, 'qbMotivation_soft');
    expect(find.byKey(const ValueKey('qbProfanitySwitch')), findsNothing);
    data = await readSection(tester, db, QuestionnaireSection.character);
    expect(data['motivation'], 'soft');
    expect(data['profanityAllowed'], false);

    // Смена архетипа меняет голос на голос нового архетипа.
    await tapKey(tester, 'qbArchetype_animeGirl');
    data = await readSection(tester, db, QuestionnaireSection.character);
    expect(data['archetype'], 'animeGirl');
    expect((data['voice'] as String).startsWith('animeGirl.'), isTrue);

    await disposeTree(tester);
    await db.close();
  });
}
