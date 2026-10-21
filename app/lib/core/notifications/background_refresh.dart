// Фоновое обновление окна уведомлений (SPEC §7): BGAppRefresh на iOS, WorkManager на Android.
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import 'local_reminder_scheduler.dart';
import 'notification_api.dart';

/// Вызывается из main один раз при запуске. iOS: обработчик уже зарегистрирован в AppDelegate,
/// здесь ставится BGAppRefreshTaskRequest (частоту решает система). Android: раз в 15 мин (минимум).
Future<void> initBackgroundRefresh() async {
  if (kIsWeb || !(defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS)) {
    return;
  }
  await Workmanager().initialize(callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    backgroundRefreshTaskId,
    backgroundRefreshTaskId,
    frequency: const Duration(minutes: 15),
    initialDelay: const Duration(minutes: 15),
    existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
  );
}

/// Точка входа фоновой задачи: своя БД → tick (провалы, штрафы) → уведомления о последствиях → окно.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    try {
      await runReminderBackground((c) => c.refresh());
      return true;
    } catch (e, st) {
      debugPrint('callbackDispatcher($task): $e\n$st');
      return false;
    }
  });
}
