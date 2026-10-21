// Синхронизация шагов: счётчик устройства → StepLogs → SectionQuestHooks.stepsUpdated.
import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../domain/quests/section_hooks.dart';
import '../models/daily.dart';
import '../models/enums.dart';
import 'activity_api.dart';
import 'step_repository.dart';

/// Опрос «сегодня» при старте, при возврате на передний план и раз в [interval], пока приложение активно.
/// Подключение: `ref.read(stepSyncProvider).start()` после запуска приложения (см. activity_providers.dart).
class StepSync with WidgetsBindingObserver {
  StepSync({
    required this.counter,
    required StepRepository repository,
    required this.hooks,
    DateTime Function()? clock,
    this.interval = const Duration(minutes: 5),
  })  : _repo = repository,
        _clock = clock ?? DateTime.now;

  final StepCounter counter;
  final StepRepository _repo;
  final SectionQuestHooks hooks;
  final DateTime Function() _clock;
  final Duration interval;

  Timer? _timer;
  bool _started = false;
  Future<StepDay?>? _inFlight;

  /// Последнее отправленное в квесты значение (день → шаги), чтобы не дёргать движок без изменений.
  DateTime? _reportedDay;
  int? _reportedSteps;

  void start() {
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    unawaited(syncToday());
  }

  void dispose() {
    if (_started) WidgetsBinding.instance.removeObserver(this);
    _started = false;
    _timer?.cancel();
    _timer = null;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => unawaited(syncToday()));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _startTimer();
        unawaited(syncToday());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _timer = null;
      case AppLifecycleState.inactive:
        break;
    }
  }

  /// Опросить счётчик за сегодня [полночь, сейчас), записать и сообщить квестам.
  /// null — счётчика нет или нет доступа. Параллельные вызовы объединяются.
  Future<StepDay?> syncToday() => _inFlight ??= _sync().whenComplete(() => _inFlight = null);

  Future<StepDay?> _sync() async {
    try {
      if (!await counter.isAvailable()) return null;
      final now = _clock();
      final day = localDay(now);
      final value = await counter.query(day, now);
      if (value == null) return null;
      await _repo.upsert(StepDay(day: day, steps: value.steps, distanceM: value.distanceM, floors: value.floors),
          counter.kind);
      await _report(day, now);
      return value;
    } catch (e, st) {
      debugPrint('StepSync: $e\n$st');
      return null;
    }
  }

  /// Ручной ввод шагов за день [day] (по умолчанию — сегодня).
  Future<void> saveManual(int steps, {DateTime? day}) async {
    final now = _clock();
    final d = localDay(day ?? now);
    await _repo.upsert(StepDay(day: d, steps: steps < 0 ? 0 : steps), StepSourceKind.manual);
    if (d == localDay(now)) await _report(d, now);
  }

  Future<void> _report(DateTime day, DateTime now) async {
    final best = await _repo.bestOf(day);
    if (best == null) return;
    if (_reportedDay == day && _reportedSteps == best.steps) return;
    _reportedDay = day;
    _reportedSteps = best.steps;
    try {
      await hooks.stepsUpdated(stepsToday: best.steps, at: now);
    } catch (e) {
      debugPrint('StepSync hooks: $e');
    }
  }
}
