import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_b/nutrition_step.dart';
import 'package:sistema/features/onboarding/questionnaire_b/schedule_step.dart';
import 'package:sistema/features/onboarding/questionnaire_b/training_step.dart';

import '../../../helpers/test_db.dart';
import 'qb_harness.dart';

void main() {
  testWidgets('питание: магазины — стабильные ключи + свой вариант текстом', (tester) async {
    final db = memoryDb();
    await pumpStep(tester, db, const NutritionStep());

    await tester.ensureVisible(find.text('Магнит'));
    await tester.tap(find.text('Магнит'));
    await settle(tester);
    final other = find.widgetWithText(TextField, 'Другое (через запятую)');
    await tester.ensureVisible(other);
    await tester.enterText(other, 'Fix Price, Светофор');
    await tester.tap(find.text('1500'));
    await settle(tester);

    final data = await readSection(tester, db, QuestionnaireSection.nutrition);
    expect(data['stores'], ['magnit', 'Fix Price', 'Светофор']);
    expect(data['waterNowMl'], 1500);

    await disposeTree(tester);
    await db.close();
  });

  testWidgets('тренировки: место дом, «нет инвентаря» исключает остальное, дни', (tester) async {
    final db = memoryDb();
    await pumpStep(tester, db, const TrainingStep());

    for (final t in ['Гантели', 'Нет инвентаря', 'Ср', 'Пн']) {
      await tester.ensureVisible(find.text(t));
      await tester.tap(find.text(t));
      await settle(tester);
    }
    final data = await readSection(tester, db, QuestionnaireSection.training);
    expect(data['place'], 'home');
    expect(data['equipment'], ['none']);
    expect(data['days'], [1, 3]);

    await disposeTree(tester);
    await db.close();
  });

  testWidgets('расписание рендерится', (tester) async {
    final db = memoryDb();
    await pumpStep(tester, db, const ScheduleStep());
    expect(find.textContaining('Система построит день'), findsOneWidget);
    await disposeTree(tester);
    await db.close();
  });
}
