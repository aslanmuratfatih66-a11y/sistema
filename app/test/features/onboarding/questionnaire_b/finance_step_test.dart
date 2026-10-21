import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_b/finance_step.dart';

import '../../../helpers/test_db.dart';
import 'qb_harness.dart';

void main() {
  testWidgets('добавление и удаление дохода пишет корректный JSON', (tester) async {
    final db = memoryDb();
    final controller = await pumpStep(tester, db, const FinanceStep());
    expect(controller.canProceed, isTrue);

    var data = await readSection(tester, db, QuestionnaireSection.finance);
    expect(data['currencies'], ['RUB']);

    await tapKey(tester, 'qbFinanceAdd_incomes');
    await tester.enterText(
      find.descendant(of: find.byKey(const ValueKey('qbFinanceAmount')), matching: find.byType(TextField)),
      '15000',
    );
    await tester.pump();
    await tapKey(tester, 'qbFinanceSave');

    data = await readSection(tester, db, QuestionnaireSection.finance);
    final incomes = data['incomes'] as List;
    expect(incomes, hasLength(1));
    final income = incomes.single as Map;
    expect(income['id'], isA<String>());
    expect((income['id'] as String).isNotEmpty, isTrue);
    expect(income['kind'], 'stipend');
    expect(income['amount'], 15000);
    expect(income['currency'], 'RUB');
    expect(income.containsKey('title'), isTrue);
    expect(income.containsKey('dayOfMonth'), isTrue);

    // Валюта в использовании; RUB остаётся всегда.
    await tester.ensureVisible(find.text('USD').first);
    await tester.tap(find.text('USD').first);
    await settle(tester);
    data = await readSection(tester, db, QuestionnaireSection.finance);
    expect(data['currencies'], ['RUB', 'USD']);

    await tapKey(tester, 'qbFinanceDelete_${income['id']}');
    data = await readSection(tester, db, QuestionnaireSection.finance);
    expect(data['incomes'], isEmpty);

    await disposeTree(tester);
    await db.close();
  });

  testWidgets('долг сохраняет направление и null-срок', (tester) async {
    final db = memoryDb();
    await pumpStep(tester, db, const FinanceStep());

    await tapKey(tester, 'qbFinanceAdd_debts');
    await tester.tap(find.text('МНЕ ДОЛЖНЫ'));
    await tester.pump();
    await tapKey(tester, 'qbFinanceSave');

    final data = await readSection(tester, db, QuestionnaireSection.finance);
    final debt = (data['debts'] as List).single as Map;
    expect(debt['direction'], 'oweMe');
    expect(debt['dueDate'], isNull);
    expect(debt.containsKey('dueDate'), isTrue);
    expect(debt['currency'], 'RUB');

    await disposeTree(tester);
    await db.close();
  });
}
