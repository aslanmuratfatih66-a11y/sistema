import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/onboarding/onboarding_progress.dart';
import 'package:sistema/features/onboarding/onboarding_screen.dart';
import 'package:sistema/features/onboarding/onboarding_step.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

void main() {
  Future<OnboardingProgress> pump(WidgetTester tester, AppDatabase db, OnboardingProgress progress) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        onboardingProgressProvider.overrideWithValue(progress),
      ],
      child: const MaterialApp(
        locale: Locale('ru'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: OnboardingScreen(),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 400));
    return progress;
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  testWidgets('окно-приглашение → «Принять» → этап 1/12, прогресс сохраняется в БД', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final progress = await tester.runAsync(() => OnboardingProgress.load(db));
    await pump(tester, db, progress!);

    expect(find.text('Вы получили право стать Игроком'), findsOneWidget);
    await tester.tap(find.text('ПРИНЯТЬ'));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ЭТАП 1/12'), findsOneWidget);

    await tester.runAsync(() => progress.goTo(OnboardingStep.goals.index));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('ЭТАП 7/12'), findsOneWidget);

    final reloaded = await tester.runAsync(() => OnboardingProgress.load(db));
    expect(reloaded!.introSeen, isTrue);
    expect(reloaded.step, OnboardingStep.goals);
    await unmount(tester);
  });
}
