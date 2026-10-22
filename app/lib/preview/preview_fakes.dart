// Заглушки нативных сервисов для веб-предпросмотра (lib/main_preview.dart). В релиз не попадают:
// lib/main.dart эту папку не импортирует.
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../core/alarm/alarm_api.dart';
import '../core/db/database.dart';
import '../core/location/walk_repository.dart';
import '../core/models/enums.dart';
import '../core/notifications/local_reminder_scheduler.dart';
import '../core/notifications/notification_api.dart';
import '../core/security/app_lock.dart';
import '../domain/walks/walk_api.dart';
import '../features/learning/learning_logic.dart';
import '../features/learning/learning_repository.dart';

/// Точка «дома» для карты и прогулок в предпросмотре (Москва, Парк Горького).
const previewHome = GeoPoint(55.7299, 37.6031);

/// Уведомления: ничего не планирует, пишет в консоль.
class PreviewReminderScheduler implements ReminderScheduler, ReminderPermissionProbe {
  @override
  Future<void> init({required Future<void> Function(ReminderResponse) onResponse}) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<ReminderPermissionState> permissionState() async =>
      const ReminderPermissionState(notifications: true, exactAlarms: true);

  @override
  Future<void> sync(List<ReminderRequest> upcoming, ReminderPrefs prefs, {required DateTime now}) async {}

  @override
  Future<void> cancelInstance(String instanceId) async {}

  @override
  Future<void> showNow({required String title, required String body}) async =>
      debugPrint('Предпросмотр, уведомление: $title — $body');
}

/// Будильник: «доступен», ничего не ставит; звонок не приходит (экран звонка — по ссылке /alarm/ring?id=…).
class PreviewAlarmScheduler implements AlarmScheduler {
  final _rings = StreamController<AlarmRing>.broadcast();

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> sync(List<AlarmRow> alarms) async {}

  @override
  Future<AlarmRing?> pendingRing() async => null;

  @override
  Stream<AlarmRing> get rings => _rings.stream;

  @override
  Future<void> stop(String alarmId) async {}
}

/// Вход по Face ID/PIN выключен.
class PreviewAppLock implements AppLock {
  @override
  Future<AppLockMode> mode() async => AppLockMode.off;

  @override
  Future<void> setMode(AppLockMode mode, {String? pin}) async {}

  @override
  Future<bool> unlock({required String reason}) async => true;
}

/// Геолокация: всегда разрешена, стоим в [previewHome].
class PreviewLocationService implements LocationService {
  const PreviewLocationService();

  @override
  Future<LocationAccess> access() async => LocationAccess.always;

  @override
  Future<LocationAccess> requestWhenInUse() async => LocationAccess.always;

  @override
  Future<LocationAccess> requestAlways() async => LocationAccess.always;

  @override
  Future<LocationFix?> current() async => LocationFix(point: previewHome, at: DateTime.now(), accuracyM: 5);
}

/// Маршруты без MapKit/OSRM: круг заданной длины, прямая до места, два выдуманных магазина.
class PreviewRouteService implements RouteService {
  const PreviewRouteService();

  @override
  Future<RoutePlan?> loop(GeoPoint start, double targetM) async {
    const n = 24;
    final r = targetM / (2 * math.pi);
    final points = [
      for (var i = 0; i <= n; i++) _offset(start, r * math.sin(2 * math.pi * i / n), r * (1 - math.cos(2 * math.pi * i / n))),
    ];
    return RoutePlan(
      points: points,
      distanceM: targetM,
      durationS: (targetM / 1.4).round(),
      segments: [
        WalkSegment(mode: WalkMode.walk, fromM: 0, toM: targetM * 0.3),
        WalkSegment(mode: WalkMode.brisk, fromM: targetM * 0.3, toM: targetM * 0.8),
        WalkSegment(mode: WalkMode.walk, fromM: targetM * 0.8, toM: targetM),
      ],
      cues: [
        const RouteCue(atM: 0, turn: RouteTurn.start),
        RouteCue(atM: targetM / 4, turn: RouteTurn.left, street: 'Пушкинская наб.'),
        RouteCue(atM: targetM / 2, turn: RouteTurn.left),
        RouteCue(atM: targetM, turn: RouteTurn.arrive),
      ],
    );
  }

  @override
  Future<RoutePlan?> toPlace(GeoPoint start, GeoPoint to) async {
    final d = _distance(start, to);
    return RoutePlan(
      points: [start, to],
      distanceM: d,
      durationS: (d / 1.4).round(),
      kind: 'place',
      cues: [const RouteCue(atM: 0, turn: RouteTurn.start), RouteCue(atM: d, turn: RouteTurn.arrive)],
    );
  }

  @override
  Future<List<Place>> nearby(GeoPoint start, PlaceCategory category, {int limit = 5}) async {
    final places = [
      Place(name: 'Пятёрочка', point: _offset(start, 250, 120), distanceM: 280, address: 'ул. Крымский Вал, 3'),
      Place(name: 'ВкусВилл', point: _offset(start, -300, 380), distanceM: 480, address: 'Ленинский пр., 4'),
    ];
    return places.take(limit).toList();
  }
}

GeoPoint _offset(GeoPoint p, double eastM, double northM) => GeoPoint(
      p.lat + northM / 111320,
      p.lon + eastM / (111320 * math.cos(p.lat * math.pi / 180)),
    );

double _distance(GeoPoint a, GeoPoint b) {
  final dy = (a.lat - b.lat) * 111320;
  final dx = (a.lon - b.lon) * 111320 * math.cos(a.lat * math.pi / 180);
  return math.sqrt(dx * dx + dy * dy);
}

/// Прогулка «понарошку»: 1,4 м/с по маршруту (или по прямой), итог пишется в Walks — виден в истории.
class PreviewWalkTracker implements WalkTracker {
  PreviewWalkTracker(this._repo);

  final WalkRepository _repo;
  final _progress = StreamController<WalkProgress>.broadcast();
  Timer? _timer;
  RoutePlan? _plan;
  String? _walkId;
  DateTime? _startedAt;
  int _seconds = 0;
  bool _paused = false;
  final _track = <List<num>>[];

  @override
  bool get isActive => _walkId != null;

  @override
  Stream<WalkProgress> get progress => _progress.stream;

  double get _distance => _seconds * 1.4;

  GeoPoint _position() {
    final pts = _plan?.points;
    if (pts == null || pts.length < 2) return _offset(previewHome, 0, _distance);
    final k = ((_distance / (_plan!.distanceM <= 0 ? 1 : _plan!.distanceM)) * (pts.length - 1)).floor();
    return pts[k.clamp(0, pts.length - 1)];
  }

  void _emit() {
    final plan = _plan;
    final pos = _position();
    _progress.add(WalkProgress(
      elapsed: Duration(seconds: _seconds),
      distanceM: _distance,
      position: LocationFix(point: pos, at: DateTime.now(), accuracyM: 5, speedMps: _paused ? 0 : 1.4),
      paceSecPerKm: _seconds < 10 ? null : 1000 / 1.4,
      mode: WalkMode.walk,
      routeProgress: plan == null || plan.distanceM <= 0 ? null : (_distance / plan.distanceM).clamp(0, 1).toDouble(),
      paused: _paused,
    ));
  }

  @override
  Future<void> start({RoutePlan? plan, String? routeId}) async {
    _plan = plan;
    _seconds = 0;
    _paused = false;
    _track.clear();
    _startedAt = DateTime.now();
    _walkId = await _repo.start(startedAt: _startedAt!, routeId: routeId, payload: const {'preview': true});
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_paused) return;
      _seconds++;
      final p = _position();
      if (_seconds % 5 == 0) _track.add([p.lat, p.lon, DateTime.now().millisecondsSinceEpoch ~/ 1000]);
      _emit();
    });
    _emit();
  }

  @override
  Future<void> pause() async {
    _paused = true;
    _emit();
  }

  @override
  Future<void> resume() async {
    _paused = false;
    _emit();
  }

  @override
  Future<WalkSummary?> finish() async {
    final id = _walkId;
    final started = _startedAt;
    _timer?.cancel();
    _walkId = null;
    if (id == null || started == null) return null;
    final now = DateTime.now();
    final kcal = _distance / 1000 * 50;
    await _repo.save(id,
        distanceM: _distance, activeSeconds: _seconds, track: List.of(_track), payload: const {'preview': true}, kcal: kcal, finishedAt: now);
    return WalkSummary(walkId: id, startedAt: started, finishedAt: now, distanceM: _distance, activeSeconds: _seconds, kcal: kcal);
  }
}

/// Курсы без сервера ИИ: план и уроки из шаблона.
class PreviewLearningApi implements LearningApi {
  const PreviewLearningApi();

  @override
  Future<({String title, List<({String title, String goal})> lessons})> outline({
    required String topic,
    required String lang,
    required int lessons,
  }) async {
    final tr = lang == 'tr';
    return (
      title: topic,
      lessons: [
        for (var i = 1; i <= lessons; i++)
          (title: tr ? '$topic: ders $i' : '$topic: урок $i', goal: tr ? 'Ana fikri anlamak' : 'Понять главную идею'),
      ],
    );
  }

  @override
  Future<({String title, List<LessonBlock> blocks, List<QuizQuestion> quiz})> lesson({
    required String topic,
    required String title,
    required String goal,
    required String lang,
    required int index,
  }) async {
    final tr = lang == 'tr';
    return (
      title: title,
      blocks: [
        LessonBlock('p', tr
            ? 'Bu, önizleme için örnek bir derstir. Gerçek içerik sunucudaki yapay zekâ tarafından oluşturulur.'
            : 'Это пример урока для предпросмотра. Настоящий текст пишет ИИ на сервере.'),
        LessonBlock('tip', tr ? 'Her gün biraz — en iyi yöntem.' : 'Понемногу каждый день — лучший способ.'),
      ],
      quiz: [
        QuizQuestion(
          q: tr ? 'Öğrenmenin en iyi yolu nedir?' : 'Как лучше учиться?',
          options: tr ? ['Her gün biraz', 'Ayda bir kez çok'] : ['Понемногу каждый день', 'Раз в месяц и много'],
          answer: 0,
        ),
      ],
    );
  }
}
