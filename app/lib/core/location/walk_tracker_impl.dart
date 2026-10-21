// WalkTracker: поток позиций (geolocator в фоне) → WalkSession → периодическое сохранение в Walks;
// восстановление незавершённой прогулки после перезапуска (на паузе); finish → WalkSummary с ккал.
import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/walks/walk_api.dart';
import '../db/database.dart';
import '../notifications/reminder_texts.dart';
import 'geolocator_location_service.dart';
import 'plan_codec.dart';
import 'walk_kcal.dart';
import 'walk_repository.dart';
import 'walk_session.dart';

/// Источник точек; подписка — на старт/продолжение, отписка — на финиш.
typedef FixSource = Stream<LocationFix> Function();

class GeolocatorWalkTracker implements WalkTracker {
  GeolocatorWalkTracker({
    required WalkRepository repository,
    required FixSource positions,
    DateTime Function()? clock,
    this.saveEvery = const Duration(seconds: 20),
    this.tick = const Duration(seconds: 1),
    this.restoreWithin = const Duration(hours: 12),
  })  : _repo = repository,
        // ignore: prefer_initializing_formals
        _positions = positions,
        _clock = clock ?? DateTime.now;

  final WalkRepository _repo;
  final FixSource _positions;
  final DateTime Function() _clock;

  /// Как часто писать прогресс в БД (по приходу точек).
  final Duration saveEvery;

  /// Период обновления прогресса без точек (время/темп); null — без таймера (тесты).
  final Duration? tick;

  /// Незавершённая прогулка старше этого не восстанавливается.
  final Duration restoreWithin;

  final _ctrl = StreamController<WalkProgress>.broadcast();
  WalkSession? _session;
  String? _walkId;
  StreamSubscription<LocationFix>? _sub;
  Timer? _ticker;
  DateTime? _lastSave;
  Future<void> _saving = Future.value();

  DateTime _now() => _clock();

  WalkSession? get session => _session;
  String? get walkId => _walkId;

  @override
  bool get isActive => _session != null;

  @override
  Stream<WalkProgress> get progress async* {
    final s = _session;
    if (s != null) yield s.snapshot(_now());
    yield* _ctrl.stream;
  }

  void _emit() {
    final s = _session;
    if (s != null && !_ctrl.isClosed) _ctrl.add(s.snapshot(_now()));
  }

  /// Поднять незавершённую прогулку из Walks (вызвать при запуске приложения). Прогулка — на паузе.
  Future<bool> restore() async {
    if (_session != null) return true;
    final row = await _repo.unfinished(notBefore: _now().subtract(restoreWithin));
    if (row == null || _session != null) return false;
    final payload = decodePayload(row.payload);
    final s = WalkSession(startedAt: row.startedAt, plan: decodeRoutePlan(payload['plan']), routeId: row.routeId);
    final along = payload['alongM'];
    s.restore(
      distanceM: row.distanceM,
      activeSeconds: row.activeSeconds,
      track: decodeTrack(row.track),
      alongM: along is num ? along.toDouble() : null,
    );
    for (final e in (payload['segments'] as List?) ?? const []) {
      if (e is Map && e['i'] is int && e['m'] is num && e['s'] is num) {
        s.segmentStats[e['i'] as int] = (m: (e['m'] as num).toDouble(), s: (e['s'] as num).toDouble());
      }
    }
    _session = s;
    _walkId = row.id;
    _emit();
    return true;
  }

  @override
  Future<void> start({RoutePlan? plan, String? routeId}) async {
    if (_session != null) return; // один трекинг на приложение
    final now = _now();
    final s = WalkSession(startedAt: now, plan: plan, routeId: routeId)..run(now);
    _session = s;
    _walkId = await _repo.start(startedAt: now, routeId: routeId, payload: _payload(s));
    _lastSave = now;
    _listen();
    _emit();
  }

  @override
  Future<void> pause() async {
    final s = _session;
    if (s == null || s.paused) return;
    s.pause(_now());
    _emit();
    await _save();
  }

  @override
  Future<void> resume() async {
    final s = _session;
    if (s == null || !s.paused) return;
    s.run(_now());
    _listen();
    _emit();
    await _save();
  }

  @override
  Future<WalkSummary?> finish() async {
    final s = _session;
    final id = _walkId;
    if (s == null) return null;
    await _stopListening();
    final now = _now();
    s.pause(now);
    s.closeTrack();
    final active = s.elapsed(now).inSeconds;
    final w = await _repo.weightForKcal();
    final kcal = walkKcal(distanceM: s.distanceM, activeSeconds: active, weightKg: w.kg);
    _session = null;
    _walkId = null;
    // Последний снимок уже при isActive == false — подписчики (Live Activity) закрываются.
    if (!_ctrl.isClosed) _ctrl.add(s.snapshot(now));
    await _saving;
    if (id != null) {
      await _repo.save(
        id,
        distanceM: s.distanceM,
        activeSeconds: active,
        track: s.track,
        payload: {..._payload(s), 'weightKg': w.kg, 'weightAssumed': w.assumed},
        kcal: kcal,
        finishedAt: now,
      );
    }
    return WalkSummary(
      walkId: id ?? '',
      startedAt: s.startedAt,
      finishedAt: now,
      distanceM: s.distanceM,
      activeSeconds: active,
      kcal: kcal,
    );
  }

  void _listen() {
    if (_sub != null) return;
    _sub = _positions().listen(_onFix, onError: (Object e) => debugPrint('walk tracker: $e'));
    final t = tick;
    if (t != null) _ticker ??= Timer.periodic(t, (_) => _emit());
  }

  Future<void> _stopListening() async {
    _ticker?.cancel();
    _ticker = null;
    final sub = _sub;
    _sub = null;
    await sub?.cancel();
  }

  void _onFix(LocationFix fix) {
    final s = _session;
    if (s == null) return;
    final now = _now();
    s.addFix(fix, now);
    _emit();
    final last = _lastSave;
    if (last == null || now.difference(last) >= saveEvery) unawaited(_save());
  }

  Future<void> _save() {
    final s = _session;
    final id = _walkId;
    if (s == null || id == null) return _saving;
    final now = _now();
    _lastSave = now;
    final distance = s.distanceM;
    final active = s.elapsed(now).inSeconds;
    final track = List<List<num>>.of(s.track);
    final payload = _payload(s);
    return _saving = _saving.then((_) async {
      try {
        await _repo.save(id, distanceM: distance, activeSeconds: active, track: track, payload: payload);
      } catch (e) {
        debugPrint('walk save: $e');
      }
    });
  }

  static Map<String, Object?> _payload(WalkSession s) {
    final plan = s.plan;
    return {
      if (plan != null) 'plan': encodeRoutePlan(plan),
      if (s.matcher != null) 'alongM': s.matcher!.alongM,
      'segments': [
        for (final e in s.segmentStats.entries)
          {
            'i': e.key,
            if (plan != null && e.key < plan.segments.length) 'mode': plan.segments[e.key].mode.name,
            'm': e.value.m,
            's': e.value.s,
            if (e.value.m >= 10) 'pace': e.value.s / e.value.m * 1000,
          },
      ],
      'paused': s.paused,
    };
  }

  /// Остановить поток и закрыть (прогулка в БД остаётся незавершённой и восстановится).
  Future<void> dispose() async {
    await _stopListening();
    await _saving;
    await _ctrl.close();
  }
}

/// Трекер для main: geolocator + тексты уведомления на языке профиля + восстановление прогулки.
Future<GeolocatorWalkTracker> createWalkTracker(AppDatabase db) async {
  final tracker = GeolocatorWalkTracker(
    repository: WalkRepository(db),
    positions: () async* {
      final l = await reminderL10n(db);
      yield* geolocatorFixes((title: l.locNotifTitle, text: l.locNotifText, channel: l.locNotifChannel));
    },
  );
  try {
    await tracker.restore();
  } catch (e) {
    debugPrint('walk restore: $e');
  }
  return tracker;
}
