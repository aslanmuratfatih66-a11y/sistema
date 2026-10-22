// Локальные уведомления сообщений Системы (SPEC §9.5): свой канал «Сообщения Системы» и свой диапазон id
// (отрицательные: окно квестов — [0, 2^31)). Плагин инициализирует LocalReminderScheduler.init —
// здесь только канал и планирование; нажатия на наши уведомления парсер окна игнорирует (другой payload).
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../l10n/app_localizations.dart';
import 'reminder_window.dart' show fnv1a32;

const aiMessagesChannelId = 'sistema_ai'; // совпадает с android.notification.channel_id в FCM (сервер)

/// Запланированное сообщение (ИИ или шаблон).
@immutable
class AiPlanned {
  const AiPlanned({required this.key, required this.at, required this.title, required this.body, this.questRef, this.sound});

  /// Стабильный ключ: id сообщения сервера или 'tpl:<вид>:<время>'.
  final String key;
  final DateTime at;
  final String title;
  final String body;
  final String? questRef;

  /// Имя звукового файла (голос персонажа), null — стандартный.
  final String? sound;

  int get id => aiNotificationId(key);

  String get payload => jsonEncode({
        'v': 'ai',
        'k': key,
        'q': ?questRef,
        't': at.millisecondsSinceEpoch,
        'h': fnv1a32('$title|$body|${sound ?? ''}'),
      });
}

/// Диапазон id сообщений: [-2^30, -1].
int aiNotificationId(String key) => -1 - (fnv1a32('ai#$key') & 0x3FFFFFFF);

bool _isOurs(int id, String? payload) {
  if (id >= 0 || payload == null) return false;
  try {
    final m = jsonDecode(payload);
    return m is Map && m['v'] == 'ai';
  } catch (_) {
    return false;
  }
}

/// questRef из нашей нагрузки (для отмены упрёка).
String? aiPayloadQuestRef(String? payload) {
  try {
    final m = jsonDecode(payload ?? '');
    return m is Map && m['v'] == 'ai' && m['q'] is String ? m['q'] as String : null;
  } catch (_) {
    return null;
  }
}

bool get _supported =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

/// iOS держит ≤64 запланированных на приложение; окно квестов берёт до 60.
const _iosLimit = 64;

class AiMessageScheduler {
  AiMessageScheduler({this.maxOwn = 16});

  /// Максимум своих запланированных (на iOS ещё ограничено свободным местом из 64).
  final int maxOwn;
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _channel = false;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  Future<void> _ensureChannel(AppLocalizations l) async {
    if (_channel) return;
    await _android?.createNotificationChannel(AndroidNotificationChannel(
      aiMessagesChannelId,
      l.msgChannelName,
      description: l.msgChannelDesc,
      importance: Importance.high,
    ));
    _channel = true;
  }

  /// Привести наши запланированные уведомления к [plan] (по возрастанию времени).
  Future<void> sync(List<AiPlanned> plan, AppLocalizations l) async {
    if (!_supported) return;
    await _ensureChannel(l);
    final pending = await _plugin.pendingNotificationRequests();
    final ours = {for (final p in pending) if (_isOurs(p.id, p.payload)) p.id: p.payload};
    var cap = maxOwn;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final free = _iosLimit - (pending.length - ours.length);
      if (free < cap) cap = free < 0 ? 0 : free;
    }
    final want = {for (final p in plan.take(cap)) p.id: p};
    for (final id in ours.keys) {
      if (want[id]?.payload != ours[id]) await _plugin.cancel(id: id);
    }
    final exact = await _android?.canScheduleExactNotifications() ?? false;
    for (final p in want.values) {
      if (ours[p.id] == p.payload) continue;
      await _schedule(p, l, exact);
    }
  }

  Future<void> _schedule(AiPlanned p, AppLocalizations l, bool exact) async {
    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        aiMessagesChannelId,
        l.msgChannelName,
        channelDescription: l.msgChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(p.body),
        sound: p.sound == null ? null : RawResourceAndroidNotificationSound(p.sound),
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        sound: p.sound,
        threadIdentifier: 'sistema_ai',
      ),
    );
    Future<void> run(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id: p.id,
          scheduledDate: tz.TZDateTime.from(p.at, tz.local),
          notificationDetails: details,
          androidScheduleMode: mode,
          title: p.title,
          body: p.body,
          payload: p.payload,
        );
    try {
      await run(exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle);
    } on PlatformException catch (e) {
      if (!exact) rethrow;
      debugPrint('AiMessageScheduler: exact failed: $e');
      await run(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  /// Снять наши уведомления (запланированные и показанные) по экземпляру квеста.
  Future<void> cancelQuest(String instanceId) async {
    if (!_supported) return;
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (p.id < 0 && aiPayloadQuestRef(p.payload) == instanceId) await _plugin.cancel(id: p.id);
    }
    try {
      for (final a in await _plugin.getActiveNotifications()) {
        final id = a.id;
        if (id != null && id < 0 && aiPayloadQuestRef(a.payload) == instanceId) await _plugin.cancel(id: id);
      }
    } on PlatformException catch (e) {
      debugPrint('AiMessageScheduler: active: $e');
    }
  }

  Future<void> cancelAll() async {
    if (!_supported) return;
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (_isOurs(p.id, p.payload)) await _plugin.cancel(id: p.id);
    }
  }
}
