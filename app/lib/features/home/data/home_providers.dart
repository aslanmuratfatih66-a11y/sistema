// Провайдеры главного экрана: часы, локальные отметки ежедневных квестов.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Источник текущего времени (в тестах подменяется фиксированным).
final homeNowSourceProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Текущее время, обновляется раз в минуту (на границе минуты).
final homeClockProvider = NotifierProvider<HomeClock, DateTime>(HomeClock.new);

class HomeClock extends Notifier<DateTime> {
  Timer? _timer;

  @override
  DateTime build() {
    final now = ref.watch(homeNowSourceProvider);
    final t = now();
    _timer?.cancel();
    // Дотикать до начала следующей минуты, дальше — раз в минуту.
    final toNextMinute = Duration(seconds: 60 - t.second, milliseconds: -t.millisecond);
    _timer = Timer(toNextMinute, () {
      state = now();
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => state = now());
    });
    ref.onDispose(() => _timer?.cancel());
    return t;
  }
}

/// Локальные отметки ежедневных квестов (id → выполнен). Пока только UI.
final dailyQuestChecksProvider =
    NotifierProvider<DailyQuestChecks, Map<String, bool>>(DailyQuestChecks.new);

class DailyQuestChecks extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() => const {};

  void set(String id, bool done) => state = {...state, id: done};
}
