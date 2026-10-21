import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/audio/audio_api.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/walks/walk_api.dart';
import 'package:sistema/features/walks/domain/geo.dart';
import 'package:sistema/features/walks/walks_screen.dart';
import 'package:sistema/features/walks/widgets/walk_map.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../../helpers/test_db.dart';

const start = GeoPoint(55.7558, 37.6173);

class FakeLocation implements LocationService {
  @override
  Future<LocationAccess> access() async => LocationAccess.whenInUse;
  @override
  Future<LocationAccess> requestWhenInUse() async => LocationAccess.whenInUse;
  @override
  Future<LocationAccess> requestAlways() async => LocationAccess.always;
  @override
  Future<LocationFix?> current() async => LocationFix(point: start, at: DateTime(2026, 10, 21));
}

class FakeRoutes implements RouteService {
  final loops = <double>[];
  final toPlaces = <GeoPoint>[];

  RoutePlan _plan(String kind, double d) => RoutePlan(
        points: [start, destination(start, 0, d / 2), start],
        distanceM: d,
        durationS: (d / 1.4).round(),
        segments: [
          WalkSegment(mode: WalkMode.walk, fromM: 0, toM: d / 2),
          WalkSegment(mode: WalkMode.brisk, fromM: d / 2, toM: d),
        ],
        cues: [const RouteCue(atM: 0, turn: RouteTurn.start), RouteCue(atM: d, turn: RouteTurn.arrive)],
        kind: kind,
      );

  @override
  Future<RoutePlan?> loop(GeoPoint s, double targetM) async {
    loops.add(targetM);
    return _plan('loop', targetM);
  }

  @override
  Future<RoutePlan?> toPlace(GeoPoint s, GeoPoint to) async {
    toPlaces.add(to);
    return _plan('toPlace', 450);
  }

  @override
  Future<List<Place>> nearby(GeoPoint s, PlaceCategory category, {int limit = 5}) async => [
        Place(name: category == PlaceCategory.water ? 'Вода тут' : 'Пятёрочка', point: destination(start, 90, 300), distanceM: 300),
      ];
}

class FakeTracker implements WalkTracker {
  final controller = StreamController<WalkProgress>.broadcast();
  final log = <String>[];
  RoutePlan? startedPlan;
  String? routeId;
  bool active = false;

  @override
  bool get isActive => active;

  @override
  Stream<WalkProgress> get progress => controller.stream;

  @override
  Future<void> start({RoutePlan? plan, String? routeId}) async {
    log.add('start');
    startedPlan = plan;
    this.routeId = routeId;
    active = true;
  }

  @override
  Future<void> pause() async => log.add('pause');

  @override
  Future<void> resume() async => log.add('resume');

  @override
  Future<WalkSummary?> finish() async {
    log.add('finish');
    active = false;
    return WalkSummary(
      walkId: 'w1',
      startedAt: DateTime(2026, 10, 21, 9),
      finishedAt: DateTime(2026, 10, 21, 9, 30),
      distanceM: 2500,
      activeSeconds: 1800,
      kcal: 140,
    );
  }
}

class FakeVoice implements VoicePrompter {
  final said = <String>[];

  @override
  Future<void> say(String text, {required String languageCode, bool interrupt = false}) async => said.add(text);

  @override
  Future<void> stop() async {}
}

class _Env {
  final db = memoryDb();
  final routes = FakeRoutes();
  final tracker = FakeTracker();
  final voice = FakeVoice();

  Widget app({PlaceCategory? shop, bool withTracker = true}) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          locationServiceProvider.overrideWithValue(FakeLocation()),
          routeServiceProvider.overrideWithValue(routes),
          if (withTracker) walkTrackerProvider.overrideWithValue(tracker),
          voicePrompterProvider.overrideWithValue(voice),
          walkMapTilesProvider.overrideWithValue(false),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('ru'),
          home: WalksScreen(shop: shop),
        ),
      );
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await tester.pump();
  }
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _dispose(WidgetTester tester, AppDatabase db) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
  await tester.runAsync(db.close);
}

Future<void> _tap(WidgetTester tester, Key key) async {
  await tester.ensureVisible(find.byKey(key));
  await tester.pump();
  await tester.tap(find.byKey(key));
  await _settle(tester);
}

void main() {
  testWidgets('круг: построение, старт, прогресс с голосом, пауза, финиш', (tester) async {
    final env = _Env();
    await tester.pumpWidget(env.app());
    await _settle(tester);
    expect(find.byKey(const Key('wlk-history-empty')), findsOneWidget);

    // По времени: 45 мин.
    await tester.tap(find.text('МИНУТЫ'));
    await _settle(tester);
    await tester.tap(find.text('45 мин'));
    await _settle(tester);
    await _tap(tester, const Key('wlk-build'));
    expect(env.routes.loops.single, closeTo(45 * 60 * 1.4, 1e-6));
    expect(find.byKey(const Key('wlk-route')), findsOneWidget);
    expect(find.text('Ускорение'), findsOneWidget); // легенда отрезков

    await _tap(tester, const Key('wlk-start'));
    expect(env.tracker.log, ['start']);
    expect(env.tracker.startedPlan?.kind, 'loop');
    expect(env.tracker.routeId, isNotNull);
    expect(find.byKey(const Key('wlk-active')), findsOneWidget);

    env.tracker.controller.add(WalkProgress(
      elapsed: const Duration(minutes: 5, seconds: 7),
      distanceM: 812,
      position: LocationFix(point: start, at: DateTime(2026, 10, 21)),
      paceSecPerKm: 375,
      segmentIndex: 0,
      mode: WalkMode.walk,
      nextCue: const RouteCue(atM: 900, turn: RouteTurn.left, street: 'Арбат'),
      metersToNextCue: 88,
    ));
    await _settle(tester);
    expect(find.text('0.81 км'), findsOneWidget);
    expect(find.text('05:07'), findsOneWidget);
    expect(find.text('6:15'), findsOneWidget);
    expect(find.text('Налево · через 88 м · Арбат'), findsOneWidget);
    expect(env.voice.said, ['Начинаем прогулку. Иди спокойным шагом']);

    env.tracker.controller.add(const WalkProgress(
      elapsed: Duration(minutes: 6),
      distanceM: 870,
      segmentIndex: 1,
      mode: WalkMode.brisk,
      nextCue: RouteCue(atM: 900, turn: RouteTurn.left),
      metersToNextCue: 30,
    ));
    await _settle(tester);
    expect(env.voice.said.last, 'Поверни налево и ускорься');

    await _tap(tester, const Key('wlk-pause'));
    expect(env.tracker.log.last, 'pause');
    await _tap(tester, const Key('wlk-finish'));
    expect(env.tracker.log.last, 'finish');
    expect(find.byKey(const Key('wlk-summary')), findsOneWidget);
    expect(find.text('140 ккал'), findsOneWidget);
    expect(find.byKey(const Key('wlk-setup')), findsOneWidget);

    await _dispose(tester, env.db);
  });

  testWidgets('«Магазин рядом» из маршрута: вода → маршрут до места', (tester) async {
    final env = _Env();
    await tester.pumpWidget(env.app(shop: PlaceCategory.water));
    await _settle(tester);
    expect(find.byKey(const Key('wlk-shop-sheet')), findsOneWidget);
    expect(find.text('Вода тут'), findsOneWidget);
    await tester.tap(find.byKey(const Key('wlk-place-0')));
    await _settle(tester);
    expect(find.byKey(const Key('wlk-shop-sheet')), findsNothing);
    expect(env.routes.toPlaces, hasLength(1));
    expect(find.byKey(const Key('wlk-route')), findsOneWidget);
    expect(find.text('0.45 км · ~5 мин'), findsOneWidget);
    expect(WalksScreen.shopFromQuery({'shop': '1'}), PlaceCategory.grocery);
    expect(WalksScreen.shopFromQuery({'shop': 'water'}), PlaceCategory.water);
    expect(WalksScreen.shopFromQuery({}), isNull);
    await _dispose(tester, env.db);
  });

  testWidgets('история из Walks; без трекера — кнопки старта выключены', (tester) async {
    final env = _Env();
    await tester.runAsync(() async {
      await env.db.into(env.db.walks).insert(WalksCompanion.insert(
            id: 'w-old',
            updatedAt: DateTime(2026, 10, 20, 8, 40),
            deviceId: 'dev',
            startedAt: DateTime(2026, 10, 20, 8),
            finishedAt: Value(DateTime(2026, 10, 20, 8, 40)),
            distanceM: const Value(3210),
            activeSeconds: const Value(2400),
          ));
      // Незавершённая — не в истории.
      await env.db.into(env.db.walks).insert(WalksCompanion.insert(
            id: 'w-open',
            updatedAt: DateTime(2026, 10, 21),
            deviceId: 'dev',
            startedAt: DateTime(2026, 10, 21),
          ));
    });
    await tester.pumpWidget(env.app(withTracker: false));
    await _settle(tester);
    expect(find.byKey(const Key('wlk-history-w-old')), findsOneWidget);
    expect(find.byKey(const Key('wlk-history-w-open')), findsNothing);
    expect(find.text('3.21 км'), findsOneWidget);
    expect(find.byKey(const Key('wlk-no-tracker')), findsOneWidget);
    await _dispose(tester, env.db);
  });
}
