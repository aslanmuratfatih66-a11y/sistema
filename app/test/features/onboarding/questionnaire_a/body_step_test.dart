import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/onboarding/questionnaire_a/body_step.dart';
import 'package:sistema/features/onboarding/step_scope.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../../helpers/test_db.dart';

void main() {
  testWidgets('обхваты свёрнуты и необязательны: «Далее» доступно только с ростом и весом', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final controller = StepController(editing: false);
    addTearDown(controller.dispose);
    await tester.binding.setSurfaceSize(const Size(400, 2000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: StepScope(controller: controller, child: const BodyStep()),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    expect(controller.canProceed, isFalse);
    // Секция обхватов свёрнута: видны только рост и вес.
    expect(find.text('ОБХВАТЫ — ЕСЛИ ЗНАЕТЕ'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));

    await tester.enterText(find.byType(TextField).at(0), '180');
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.canProceed, isFalse);
    await tester.enterText(find.byType(TextField).at(1), '75');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));
    expect(controller.canProceed, isTrue);

    // Раскрыть обхваты: поля и подсказки «как мерить» появляются, пустые не мешают.
    await tester.tap(find.text('ОБХВАТЫ — ЕСЛИ ЗНАЕТЕ'));
    await tester.pump(const Duration(milliseconds: 200));
    expect(find.byType(TextField), findsNWidgets(7));
    expect(find.textContaining('Талия — по самому узкому месту'), findsOneWidget);
    expect(controller.canProceed, isTrue);

    final profile = await tester.runAsync(() => ProfileRepository(db).get());
    expect(profile?.heightCm, 180);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
