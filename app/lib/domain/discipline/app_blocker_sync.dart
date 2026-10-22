// Связка режима дисциплины и блокировщика (SPEC §6, §8.6): режим включён → blockFrom(отбой → подъём),
// выключен → unblock. Android: попытки из нативной очереди → BlockAttempts (+ штраф за повторные).
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../quests/quest_api.dart';
import 'app_blocker.dart';
import 'app_blocker_catalog.dart';
import 'app_blocker_channel.dart';
import 'app_blocker_repository.dart';
import 'app_blocker_window.dart';
import 'discipline_hook.dart';
import 'discipline_rules.dart';

/// Запускается в main: `container.read(disciplineBlockerSyncProvider).start()`.
class DisciplineBlockerSync with WidgetsBindingObserver {
  DisciplineBlockerSync({
    required AppDatabase db,
    required QuestService quests,
    required this._blocker,
    this._channel = const BlockerChannel(),
    this._clock = DateTime.now,
    String? platform,
  })  : _db = db,
        _quests = quests,
        _platform = platform ?? _currentPlatform(),
        _repo = AppBlockerRepository(db, quests: quests);

  final AppDatabase _db;
  final QuestService _quests;
  final AppBlocker _blocker;
  final BlockerChannel _channel;
  final DateTime Function() _clock;
  final String _platform;
  final AppBlockerRepository _repo;

  final _subs = <StreamSubscription<Object?>>[];
  Timer? _rollover;
  bool _started = false;

  bool? _active;
  DisciplineContext? _ctx;
  List<String> _appIds = const [];
  bool _appsReady = false;

  /// Последнее применённое состояние ('off' или окно+список) — чтобы не дёргать канал без изменений.
  String? _applied;
  Future<void> _queue = Future.value();

  static String _currentPlatform() =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS ? BlockerPlatformKey.ios : BlockerPlatformKey.android;

  bool get _isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  void start() {
    if (_started) return;
    _started = true;
    _subs
      ..add(_quests.watchPlayer().listen((p) {
        if (_active == p.disciplineActive) return;
        _active = p.disciplineActive;
        _schedule();
      }, onError: (Object e) => debugPrint('blocker sync: player $e')))
      ..add(DisciplineContextLoader(_db).watch().listen((c) {
        if (_ctx == c) return;
        _ctx = c;
        _schedule();
      }, onError: (Object e) => debugPrint('blocker sync: context $e')))
      ..add(_repo.watchApps(_platform).listen((rows) {
        final ids = [for (final r in rows) if (r.enabled) r.appId]..sort();
        if (_appsReady && listEquals(ids, _appIds)) return;
        _appIds = ids;
        _appsReady = true;
        _schedule();
      }, onError: (Object e) => debugPrint('blocker sync: apps $e')));
    WidgetsBinding.instance.addObserver(this);
    unawaited(drainAttempts());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(drainAttempts());
      _schedule(force: true);
    }
  }

  void _schedule({bool force = false}) {
    if (force) _applied = null;
    _queue = _queue.then((_) => _apply()).catchError((Object e) => debugPrint('blocker sync: $e'));
  }

  Future<void> _apply() async {
    final active = _active;
    final ctx = _ctx;
    if (active == null || ctx == null || !_appsReady) return;
    _rollover?.cancel();
    _rollover = null;
    if (!active) {
      if (_applied == 'off') return;
      await _blocker.unblock();
      _applied = 'off';
      return;
    }
    final now = _clock();
    final w = disciplineBlockWindow(now, usualBedMinute: ctx.bedMinute, usualWakeMinute: ctx.wakeMinute);
    final key = '${w.from.millisecondsSinceEpoch}-${w.until.millisecondsSinceEpoch}-${_appIds.join(',')}';
    if (_applied != key) {
      await _blocker.blockFrom(w.from, w.until, appIds: _appIds);
      _applied = key;
    }
    // После подъёма — перейти к следующей ночи.
    final wait = w.until.difference(now) + const Duration(minutes: 1);
    _rollover = Timer(wait.isNegative ? const Duration(minutes: 1) : wait, () => _schedule());
  }

  /// Android: забрать попытки из очереди сервиса → BlockAttempts (+ штраф с 3-й за ночь).
  Future<void> drainAttempts() async {
    if (!_isAndroid) return;
    final attempts = await _channel.drainAttempts();
    if (attempts.isEmpty) return;
    final ctx = _ctx ?? await DisciplineContextLoader(_db).load();
    for (final a in attempts) {
      var night = disciplineBlockWindow(a.at, usualBedMinute: ctx.bedMinute, usualWakeMinute: ctx.wakeMinute);
      if (!night.contains(a.at)) {
        // Расписание сменилось после попытки — считаем по календарным суткам.
        final day = DateTime(a.at.year, a.at.month, a.at.day);
        night = BlockWindow(day, DateTime(day.year, day.month, day.day + 1));
      }
      try {
        await _repo.recordAttempt(a.appId, at: a.at, night: night);
      } catch (e) {
        debugPrint('blocker sync: attempt $e');
      }
    }
  }

  void dispose() {
    _rollover?.cancel();
    for (final s in _subs) {
      unawaited(s.cancel());
    }
    _subs.clear();
    if (_started) WidgetsBinding.instance.removeObserver(this);
    _started = false;
  }
}

final disciplineBlockerSyncProvider = Provider<DisciplineBlockerSync>((ref) {
  final sync = DisciplineBlockerSync(
    db: ref.watch(databaseProvider),
    quests: ref.watch(questServiceProvider),
    blocker: ref.watch(appBlockerProvider),
  );
  ref.onDispose(sync.dispose);
  return sync;
});

/// Блокировка сейчас: режим дисциплины включён и время внутри окна (сохранённого blockFrom или
/// вычисленного по расписанию — если синхронизация ещё не успела отработать).
Future<BlockWindow?> currentBlockWindow({
  required AppDatabase db,
  required QuestService quests,
  DateTime? now,
}) async {
  final t = now ?? DateTime.now();
  PlayerSnapshot player;
  try {
    player = await quests.watchPlayer().first.timeout(const Duration(seconds: 5));
  } catch (_) {
    return null;
  }
  if (!player.disciplineActive) return null;
  final stored = await BlockWindowStore.read(db);
  if (stored != null && stored.contains(t)) return stored;
  final ctx = await DisciplineContextLoader(db).load();
  final w = disciplineBlockWindow(t, usualBedMinute: ctx.bedMinute, usualWakeMinute: ctx.wakeMinute);
  return w.contains(t) ? w : null;
}

/// Минуты окна режима для текста статуса.
({int bed, int wake}) disciplineBlockMinutes(DisciplineContext ctx) =>
    (bed: DisciplineRules.targetBed(ctx.bedMinute), wake: DisciplineRules.targetWake(ctx.wakeMinute));
