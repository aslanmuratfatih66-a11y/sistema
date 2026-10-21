import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/onboarding/questionnaire_a/profile_step.dart';
import 'package:sistema/features/onboarding/step_scope.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../../helpers/test_db.dart';

void main() {
  testWidgets('ввод имени разблокирует «Далее» и сохраняется в профиль', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final controller = StepController(editing: false);
    addTearDown(controller.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StepScope(controller: controller, child: const ProfileStep()),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('ИМЯ'), findsOneWidget);
    expect(controller.canProceed, isFalse);

    await tester.enterText(find.byType(TextField).first, 'Мурат');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.canProceed, isTrue);

    final profile = await tester.runAsync(() => ProfileRepository(db).get());
    expect(profile?.name, 'Мурат');
    expect(profile?.timezone, startsWith('UTC'));

    await tester.enterText(find.byType(TextField).first, '  ');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.canProceed, isFalse);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
