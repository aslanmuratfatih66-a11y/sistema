// Будильник-квест (SPEC §8.11, §6): следит за таблицей Alarms, режимом дисциплины и расписанием,
// перепланирует нативные будильники и открывает экран задания при звонке.
// Запуск — main (после runApp): `unawaited(container.read(alarmSyncProvider).start())`.
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/app.dart' show routerProvider;
import '../../app/routes.dart';
import '../../domain/discipline/discipline_rules.dart';
import '../../domain/quests/quest_api.dart';
import '../db/database.dart';
import 'alarm_api.dart';
import 'alarm_repository.dart';

/// Адрес экрана звонка.
String alarmRingLocation(String alarmId) => Uri(path: Routes.alarmRing, queryParameters: {'id': alarmId}).toString();

/// Открыть экран звонка, если будильник звонит (холодный старт из full-screen intent / уведомления / AlarmKit).
/// Возвращает true, если был переход.
Future<bool> openPendingAlarmRing(AlarmScheduler scheduler, void Function(String location) go) async {
  try {
    final ring = await scheduler.pendingRing();
    if (ring == null) return false;
    go(alarmRingLocation(ring.alarmId));
    return true;
  } catch (e) {
    debugPrint('openPendingAlarmRing: $e');
    return false;
  }
}

class AlarmSync with WidgetsBindingObserver {
  AlarmSync({
    required AppDatabase db,
    required this._scheduler,
    required this._quests,
    required this._go,
    this._currentLocation,
  })  : _db = db,
        _repo = AlarmRepository(db);

  final AppDatabase _db;
  final AlarmRepository _repo;
  final AlarmScheduler _scheduler;
  final QuestService _quests;
  final void Function(String location) _go;
  final String? Function()? _currentLocation;

  final _subs = <StreamSubscription<Object?>>[];
  Timer? _debounce;
  Timer? _daily;
  bool _started = false;
  bool? _discipline;
  int _wakeMinute = DisciplineRules.wakeMinute;

  Future<void> start() async {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _subs
      ..add(_repo.watchAll().listen((_) => _schedule()))
      ..add(_quests.watchPlayer().map((p) => p.disciplineActive).distinct().listen((active) {
        _discipline = active;
        _schedule();
      }, onError: (Object e) => debugPrint('AlarmSync: player: $e')))
      ..add((_db.select(_db.scheduleSettings)..where((t) => t.deletedAt.isNull())).watch().listen((rows) {
        final usual = rows.isEmpty ? 7 * 60 : rows.first.wakeMinute;
        final target = DisciplineRules.targetWake(usual);
        if (target != _wakeMinute) {
          _wakeMinute = target;
          _schedule();
        }
      }))
      ..add(_scheduler.rings.listen(_openRing));
    // Повторы: раз в 6 ч продлеваем горизонт (если приложение долго открыто).
    _daily = Timer.periodic(const Duration(hours: 6), (_) => _schedule());
    _schedule();
    // Роутер готов после первого кадра.
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(checkPending()));
  }

  void _openRing(AlarmRing ring) {
    final loc = alarmRingLocation(ring.alarmId);
    if (_currentLocation?.call() == loc) return;
    _go(loc);
  }

  /// Звонит ли будильник — открыть экран задания.
  Future<void> checkPending() async {
    final ring = await _scheduler.pendingRing().catchError((Object e) {
      debugPrint('AlarmSync: pending: $e');
      return null;
    });
    if (ring != null) _openRing(ring);
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => unawaited(resync()));
  }

  /// Привести будильник дисциплины в соответствие режиму и перепланировать всё.
  Future<void> resync() async {
    try {
      final d = _discipline;
      if (d != null) await _repo.ensureDisciplineAlarm(active: d, wakeMinute: _wakeMinute);
      await _scheduler.sync(await _repo.all());
    } catch (e, st) {
      debugPrint('AlarmSync: sync: $e\n$st');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    // Фоновые изоляты/синхронизация могли поменять строки; звонок мог начаться, пока приложение спало.
    _schedule();
    unawaited(checkPending());
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _debounce?.cancel();
    _daily?.cancel();
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
  }
}

final alarmSyncProvider = Provider<AlarmSync>((ref) {
  final s = AlarmSync(
    db: ref.watch(databaseProvider),
    scheduler: ref.watch(alarmSchedulerProvider),
    quests: ref.watch(questServiceProvider),
    go: (loc) => ref.read(routerProvider).go(loc),
    currentLocation: () {
      try {
        return ref.read(routerProvider).routerDelegate.currentConfiguration.uri.toString();
      } catch (_) {
        return null;
      }
    },
  );
  ref.onDispose(s.dispose);
  return s;
});
