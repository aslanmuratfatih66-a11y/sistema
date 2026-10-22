// Координатор напоминаний (SPEC §7): связывает движок квестов и планировщик уведомлений.
// Триггеры: старт, возврат на передний план, изменения квестов (сегодня/завтра), минутный tick, кнопки уведомлений.
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import 'notification_api.dart';
import 'reminder_texts.dart';

class ReminderCoordinator with WidgetsBindingObserver {
  ReminderCoordinator({
    required this._quests,
    required this._scheduler,
    required this._loadPrefs,
    required this._l10n,
    this._prefsChanges,
    DateTime Function()? clock,
    this.horizon = const Duration(hours: 24),
    this.debounce = const Duration(seconds: 1),
    this.tickInterval = const Duration(minutes: 1),
    this.observeLifecycle = true,
    this._foreground = true,
    this.onResume,
    this.onOpen,
    this.templateFilter,
  }) : _clock = clock ?? DateTime.now;

  final QuestService _quests;
  final ReminderScheduler _scheduler;
  final Future<ReminderPrefs> Function() _loadPrefs;
  final Future<AppLocalizations> Function() _l10n;
  final Stream<ReminderPrefs>? _prefsChanges;
  final DateTime Function() _clock;

  /// Насколько вперёд брать квесты для окна.
  final Duration horizon;
  final Duration debounce;
  final Duration tickInterval;
  final bool observeLifecycle;

  /// Возврат на передний план: например, `db.markTablesUpdated(...)` — кнопки в фоне писали через своё соединение.
  final Future<void> Function()? onResume;

  /// Нажатие на само уведомление (не на кнопку).
  final void Function(String instanceId)? onOpen;

  /// Правка запросов окна перед планированием (например, убрать шаблонный упрёк, если есть упрёк ИИ).
  final Future<List<ReminderRequest>> Function(List<ReminderRequest> requests)? templateFilter;

  bool _foreground;
  bool _started = false;
  bool _disposed = false;
  Timer? _ticker;
  Timer? _debounceTimer;
  DateTime? _watchedDay;
  final _subs = <StreamSubscription<Object?>>[];
  final _daySubs = <StreamSubscription<Object?>>[];
  Future<void> _chain = Future.value();

  bool get isForeground => _foreground;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    if (observeLifecycle) WidgetsBinding.instance.addObserver(this);
    _subs.add(_quests.outcomes.listen(_onOutcome, onError: _log));
    final prefs = _prefsChanges;
    if (prefs != null) _subs.add(prefs.skip(1).listen((_) => scheduleSync(), onError: _log));
    _watchDays();
    _ticker = Timer.periodic(tickInterval, (_) => _onMinute());
    await refresh();
  }

  Future<void> dispose() async {
    _disposed = true;
    if (observeLifecycle && _started) WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    _debounceTimer?.cancel();
    for (final s in [..._subs, ..._daySubs]) {
      await s.cancel();
    }
    _subs.clear();
    _daySubs.clear();
  }

  /// Проверка движка по времени и полное перепланирование окна.
  Future<void> refresh() async {
    await _tick();
    await syncNow();
  }

  /// Отложенная (debounce) синхронизация: несколько изменений подряд — одна синхронизация.
  void scheduleSync() {
    if (_disposed) return;
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounce, () => unawaited(syncNow()));
  }

  /// Синхронизация окна; вызовы выполняются по очереди.
  Future<void> syncNow() => _chain = _chain.then((_) => _sync());

  Future<void> _sync() async {
    if (_disposed) return;
    try {
      final now = _clock();
      final prefs = await _loadPrefs();
      final l = await _l10n();
      final items = await _quests.upcoming(now, horizon);
      var requests = [
        for (final q in items) ?reminderRequestFor(l, q),
      ];
      if (templateFilter != null) requests = await templateFilter!(requests);
      await _scheduler.sync(requests, prefs, now: now);
    } catch (e, st) {
      _log(e, st);
    }
  }

  Future<void> _tick() async {
    try {
      final outcomes = await _quests.tick(_clock());
      // На переднем плане последствия показывают системные окна; иначе — уведомлением.
      if (!_foreground && outcomes.isNotEmpty) await _notify(outcomes);
    } catch (e, st) {
      _log(e, st);
    }
  }

  Future<void> _notify(List<GameOutcome> outcomes) async {
    final l = await _l10n();
    for (final n in outcomeNotices(l, outcomes)) {
      await _scheduler.showNow(title: n.title, body: n.body);
    }
  }

  Future<void> _onMinute() async {
    if (_disposed) return;
    _watchDays();
    await _tick();
    scheduleSync();
  }

  /// Подписка на квесты сегодня и завтра; при смене дня — переподписка.
  void _watchDays() {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    if (_watchedDay == today) return;
    _watchedDay = today;
    for (final s in _daySubs) {
      unawaited(s.cancel());
    }
    _daySubs
      ..clear()
      ..add(_quests.watchDay(today).listen((_) => scheduleSync(), onError: _log))
      ..add(_quests.watchDay(DateTime(today.year, today.month, today.day + 1))
          .listen((_) => scheduleSync(), onError: _log));
  }

  void _onOutcome(GameOutcome o) {
    final closed = switch (o) {
      QuestCompleted(:final quest) => quest.instanceId,
      QuestRefused(:final quest) => quest.instanceId,
      BossResult(:final quest) => quest.instanceId,
      _ => null,
    };
    // Упрёк и повторы снимаются только при закрытии игроком; провал движком упрёк оставляет.
    if (closed != null) unawaited(_scheduler.cancelInstance(closed).catchError(_log));
    scheduleSync();
  }

  /// Нажатие в уведомлении (передний план или фоновый isolate).
  Future<void> handleResponse(ReminderResponse r) async {
    // Не квест (напоминания финансов 'fin:…'): кнопки только закрывают уведомление.
    if (r.instanceId.startsWith('fin:')) {
      if (r.action == ReminderAction.open) {
        onOpen?.call(r.instanceId);
      } else {
        await _scheduler.cancelInstance(r.instanceId);
      }
      return;
    }
    try {
      switch (r.action) {
        case ReminderAction.done:
          await _scheduler.cancelInstance(r.instanceId);
          await _quests.complete(r.instanceId, at: _clock());
        case ReminderAction.snooze10:
          await _quests.snooze(r.instanceId, at: _clock());
        case ReminderAction.open:
          onOpen?.call(r.instanceId);
          return;
      }
    } catch (e, st) {
      _log(e, st); // квест уже закрыт / лимит откладываний — окно всё равно пересчитаем
    }
    await syncNow();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _foreground = true;
        unawaited(_onResumed());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _foreground = false;
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _onResumed() async {
    try {
      await onResume?.call();
    } catch (e, st) {
      _log(e, st);
    }
    _watchDays();
    await refresh();
  }

  static void _log(Object e, [StackTrace? st]) => debugPrint('ReminderCoordinator: $e${st == null ? '' : '\n$st'}');
}
