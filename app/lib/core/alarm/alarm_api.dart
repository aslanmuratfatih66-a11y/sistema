// Будильник-квест (SPEC §8.11) — КОНТРАКТ каркаса этапа 7. Реализация — сабагент E:
// iOS — AlarmKit (канал sistema/alarm, ios/Runner/AlarmKitChannel.swift), фолбэк — серия громких уведомлений;
// Android — AlarmManager.setAlarmClock + full-screen intent (AlarmChannel.kt, AlarmReceiver.kt).
// Выключение — только заданием (приседания по акселерометру / скан QR), экран Routes.alarmRing.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';

/// Сработавший будильник, который ещё не выключен заданием.
class AlarmRing {
  const AlarmRing({required this.alarmId, required this.firedAt});

  final String alarmId;
  final DateTime firedAt;
}

abstract interface class AlarmScheduler {
  /// Может ли платформа ставить настоящие будильники (AlarmKit авторизован / точные будильники Android).
  Future<bool> isAvailable();

  /// Запросить разрешения (AlarmKit, SCHEDULE_EXACT_ALARM, full-screen intent).
  Future<bool> requestPermission();

  /// Перепланировать все включённые будильники на ближайшие срабатывания.
  Future<void> sync(List<AlarmRow> alarms);

  /// Будильник, который звонит или открыл приложение (холодный старт из full-screen intent / уведомления).
  Future<AlarmRing?> pendingRing();

  /// Сработавшие во время работы приложения.
  Stream<AlarmRing> get rings;

  /// Остановить звук после выполнения задания.
  Future<void> stop(String alarmId);
}

final alarmSchedulerProvider = Provider<AlarmScheduler>((ref) => throw UnimplementedError('alarmSchedulerProvider (E)'));
