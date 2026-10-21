import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema/app/routes.dart';
import 'package:sistema/core/data/profile_repository.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/features/plan/plan_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../../helpers/test_db.dart';

Future<void> _seed(AppDatabase db) async {
  await ProfileRepository(db).update(ProfilesCompanion(
    sex: const Value('male'),
    birthDate: Value(DateTime(1996, 1, 1)),
    heightCm: const Value(180),
    activityLevel: const Value('moderate'),
  ));
  await db.into(db.bodyMeasurements).insert(BodyMeasurementsCompanion.insert(
        id: newId(),
        updatedAt: DateTime.now().toUtc(),
        deviceId: await db.deviceId(),
        measuredAt: DateTime.now().toUtc(),
        weightKg: const Value(80),
      ));
}

void main() {
  testWidgets('есть профиль и замер → «Принять» пишет acceptedAt и ведёт на статус', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = memoryDb();
    addTearDown(db.close);
    await tester.runAsync(() => _seed(db));

    final router = GoRouter(
      initialLocation: Routes.plan,
      routes: [
        GoRoute(path: Routes.plan, builder: (_, _) => const PlanScreen()),
        GoRoute(path: Routes.status, builder: (_, _) => const Text('status-page')),
      ],
    );
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp.router(
        theme: buildSystemTheme(),
        routerConfig: router,
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    expect(find.text('ПЛАН СОСТАВЛЕН', findRichText: true).evaluate().isNotEmpty ||
        find.textContaining('План составлен').evaluate().isNotEmpty, isTrue);
    // Данных хватает — калории посчитаны, предупреждения «заполните» нет.
    expect(find.textContaining('ккал'), findsWidgets);
    expect(find.textContaining('заполните'), findsNothing);
    final accept = find.text('ПРИНЯТЬ');
    await tester.scrollUntilVisible(accept, 300, scrollable: find.byType(Scrollable).first);
    expect(accept, findsOneWidget);

    await tester.tap(accept);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    final rows = await db.select(db.plans).get();
    expect(rows, hasLength(1));
    expect(rows.single.acceptedAt, isNotNull);
    expect(rows.single.source, 'local');
    expect(find.text('status-page'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  });
}
