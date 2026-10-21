import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/data/questionnaire_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/step_scope.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

/// Рендерит шаг анкеты как в хосте: StepScope + прокрутка.
Future<StepController> pumpStep(
  WidgetTester tester,
  AppDatabase db,
  Widget step, {
  List<Override> overrides = const [],
}) async {
  final controller = StepController(editing: false);
  await tester.pumpWidget(ProviderScope(
    overrides: [databaseProvider.overrideWithValue(db), ...overrides],
    child: MaterialApp(
      theme: buildSystemTheme(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('ru'),
      home: Scaffold(
        body: StepScope(
          controller: controller,
          child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: step),
        ),
      ),
    ),
  ));
  await settle(tester);
  return controller;
}

/// Даёт отработать Drift (реальная асинхронность) и перерисовывает.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
    await tester.pump();
  }
  await tester.pump(const Duration(milliseconds: 300));
}

Future<Map<String, Object?>> readSection(WidgetTester tester, AppDatabase db, QuestionnaireSection s) async {
  await settle(tester);
  return (await tester.runAsync(() => QuestionnaireRepository(db).read(s)))!;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await settle(tester);
}

Future<void> disposeTree(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}
