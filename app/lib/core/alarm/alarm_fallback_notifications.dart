// Фолбэк будильника на iOS (SPEC §8.11): серия громких уведомлений через flutter_local_notifications.
// Плагин инициализирует LocalReminderScheduler (main) — здесь только планирование, свой диапазон id
// и свой payload `alarm:<alarmId>:<ms>`. Нажатие → Routes.alarmRing (см. alarmIdFromPayload).
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'alarm_api.dart';
import 'alarm_schedule.dart';

/// Диапазон id: [-0x61000000, -0x60000000) — не пересекается с окном напоминаний [0, 2^31)
/// и сообщениями ИИ [-2^30, 0).
const _idBase = -0x60000000;
const _payloadPrefix = 'alarm:';

/// Канал Android (на Android фолбэк не используется — звонит AlarmRingService; канал для единообразия).
const alarmNotificationChannel = 'sistema_alarm';

/// Свой звук (≤30 с, в бандле Runner / Library/Sounds). null — системный.
const String? _iosSound = null;

int _fnv(String s) {
  var h = 0x811C9DC5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xFFFFFFFF;
  }
  return h;
}

int _id(String key, int k) => _idBase - ((_fnv(key) & 0xFFFFF) * 16 + k);

bool _ours(int id) => id < _idBase + 1 && id >= _idBase - 0x1000000;

/// id будильника из payload уведомления фолбэка; null — не наше уведомление.
String? alarmIdFromPayload(String? payload) {
  if (payload == null || !payload.startsWith(_payloadPrefix)) return null;
  final rest = payload.substring(_payloadPrefix.length);
  final i = rest.lastIndexOf(':');
  final id = i < 0 ? rest : rest.substring(0, i);
  return id.isEmpty ? null : id;
}

AlarmRing? _ringFromPayload(String? payload) {
  final id = alarmIdFromPayload(payload);
  if (id == null) return null;
  final ms = int.tryParse(payload!.substring(payload.lastIndexOf(':') + 1));
  return AlarmRing(alarmId: id, firedAt: ms == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(ms));
}

class AlarmFallbackNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();

  /// Основная серия (AlarmKit недоступен): 15 уведомлений через 40 с.
  static const _count = 15;
  static const _step = Duration(seconds: 40);

  /// Страховка при AlarmKit: 10 уведомлений через 45 с, с задержкой 3 мин (если звонок выключили «Стопом»).
  static const _backupCount = 10;
  static const _backupStep = Duration(seconds: 45);
  static const _backupDelay = Duration(minutes: 3);

  IOSFlutterLocalNotificationsPlugin? get _iosImpl =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  AndroidFlutterLocalNotificationsPlugin? get _androidImpl =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<bool?> notificationsEnabled() async {
    try {
      final ios = _iosImpl;
      if (ios != null) return (await ios.checkPermissions())?.isEnabled;
      return await _androidImpl?.areNotificationsEnabled();
    } on PlatformException {
      return null;
    }
  }

  Future<void> requestNotifications() async {
    try {
      final ios = _iosImpl;
      if (ios != null) {
        await ios.requestPermissions(alert: true, sound: true, badge: true);
        return;
      }
      await _androidImpl?.requestNotificationsPermission();
    } on PlatformException catch (e) {
      debugPrint('AlarmFallback: permission: $e');
    }
  }

  /// Перепланировать серии: всё наше снимается, ставятся серии для [entries].
  /// [backupOnly] — AlarmKit звонит сам, серия — страховка с задержкой.
  Future<void> schedule(List<AlarmPlanEntry> entries, {required bool backupOnly, required String body, required DateTime now}) async {
    try {
      for (final p in await _plugin.pendingNotificationRequests()) {
        if (_ours(p.id) && alarmIdFromPayload(p.payload) != null) await _plugin.cancel(id: p.id);
      }
      final seen = <String>{};
      for (final e in entries) {
        if (!seen.add(e.key)) continue;
        final count = backupOnly ? _backupCount : _count;
        final step = backupOnly ? _backupStep : _step;
        final start = backupOnly ? e.at.add(_backupDelay) : e.at;
        for (var k = 0; k < count; k++) {
          final at = start.add(step * k);
          if (!at.isAfter(now.add(const Duration(seconds: 2)))) continue;
          await _plugin.zonedSchedule(
            id: _id(e.key, k),
            scheduledDate: tz.TZDateTime.from(at, tz.local),
            notificationDetails: _details(e.alarmId),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            title: e.title,
            body: k == 0 && !backupOnly ? e.body : '${e.body}\n$body',
            payload: '$_payloadPrefix${e.alarmId}:${e.at.millisecondsSinceEpoch}',
          );
        }
      }
    } on PlatformException catch (e) {
      debugPrint('AlarmFallback: schedule: $e');
    } catch (e) {
      // Плагин не инициализирован (tz.local не задан) — фолбэк недоступен.
      debugPrint('AlarmFallback: schedule failed: $e');
    }
  }

  /// Снять серию будильника (запланированные и уже показанные).
  Future<void> cancelAlarm(String alarmId) async {
    try {
      for (final p in await _plugin.pendingNotificationRequests()) {
        if (_ours(p.id) && alarmIdFromPayload(p.payload) == alarmId) await _plugin.cancel(id: p.id);
      }
      for (final a in await _plugin.getActiveNotifications()) {
        final id = a.id;
        if (id != null && _ours(id) && alarmIdFromPayload(a.payload) == alarmId) await _plugin.cancel(id: id);
      }
    } on PlatformException catch (e) {
      debugPrint('AlarmFallback: cancel: $e');
    }
  }

  /// Приложение открыто нажатием на уведомление серии.
  Future<AlarmRing?> launchAlarm() async {
    try {
      final d = await _plugin.getNotificationAppLaunchDetails();
      if (d?.didNotificationLaunchApp != true) return null;
      return _ringFromPayload(d?.notificationResponse?.payload);
    } on PlatformException {
      return null;
    }
  }

  NotificationDetails _details(String alarmId) => NotificationDetails(
        android: const AndroidNotificationDetails(
          alarmNotificationChannel,
          'Alarm',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBanner: true,
          presentList: true,
          presentSound: true,
          sound: _iosSound,
          threadIdentifier: 'alarm:$alarmId',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      );
}
