// Реализации LiveActivityService (SPEC §8.12): iOS — ActivityKit через канал `sistema/live`,
// Android — постоянное уведомление (flutter_local_notifications) вместо Live Activity.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../l10n/app_localizations.dart';
import 'live_api.dart';
import 'live_codec.dart';

/// iOS: ActivityKit (ios/Runner/LiveActivityChannel.swift).
class ChannelLiveActivityService implements LiveActivityService {
  ChannelLiveActivityService({MethodChannel? channel}) : _channel = channel ?? const MethodChannel(liveChannelName);

  final MethodChannel _channel;

  @override
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } on PlatformException catch (e) {
      debugPrint('LiveActivity: isSupported: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<String?> start(LiveKind kind, LiveState state) async {
    try {
      return await _channel.invokeMethod<String>('start', {'kind': kind.name, ...liveStateToArgs(state)});
    } on PlatformException catch (e) {
      debugPrint('LiveActivity: start: $e');
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  @override
  Future<void> update(String id, LiveState state) => _call('update', {'id': id, ...liveStateToArgs(state)});

  @override
  Future<void> end(String id) => _call('end', {'id': id});

  Future<void> _call(String method, Map<String, Object?> args) async {
    try {
      await _channel.invokeMethod<void>(method, args);
    } on PlatformException catch (e) {
      debugPrint('LiveActivity: $method: $e');
    } on MissingPluginException {
      // Нет нативной части (тест/другая платформа).
    }
  }
}

/// Содержимое постоянного уведомления Android.
@immutable
class LiveNotification {
  const LiveNotification({
    required this.id,
    required this.title,
    required this.body,
    this.endsAt,
    this.progressPercent,
  });

  final int id;
  final String title;
  final String body;

  /// Обратный отсчёт (хронометр уведомления).
  final DateTime? endsAt;

  /// 0…100; null — без полосы прогресса.
  final int? progressPercent;
}

/// Показ/снятие уведомлений (отделено от плагина ради тестов).
abstract interface class LiveNotifier {
  Future<bool> enabled();
  Future<void> show(LiveNotification n, {required String channelName, required String channelDescription});
  Future<void> cancel(int id);
}

/// Базовый id уведомлений Live (у напоминаний id — хэши FNV, совпадение практически исключено).
const liveNotificationBaseId = 0x7F11000;

int liveNotificationId(LiveKind kind) => liveNotificationBaseId + kind.index;

String _km(double m) => (m / 1000).toStringAsFixed(2);

String _pace(double secPerKm) {
  final s = secPerKm.round();
  return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Текст уведомления: заголовок, подзаголовок (следующее действие), дистанция и темп.
LiveNotification buildLiveNotification(LiveKind kind, LiveState s, AppLocalizations l) {
  final kindLabel = switch (kind) {
    LiveKind.walk => l.livWalk,
    LiveKind.quest => l.livQuest,
    LiveKind.workout => l.livWorkout,
  };
  final stats = <String>[
    if (s.distanceM case final d? when d.isFinite && d >= 0) '${_km(d)} ${l.livKm}',
    if (s.paceSecPerKm case final p? when p.isFinite && p > 0 && p < 3600) '${_pace(p)} ${l.livPerKm}',
  ];
  final body = [
    if (stats.isNotEmpty) stats.join(' · '),
    if (s.subtitle.trim().isNotEmpty) s.subtitle.trim(),
  ].join('\n');
  final title = s.title.trim().isEmpty ? kindLabel : s.title.trim();
  final progress = s.progress;
  return LiveNotification(
    id: liveNotificationId(kind),
    title: title,
    body: body,
    endsAt: s.endsAt,
    progressPercent: progress == null || !progress.isFinite ? null : (progress.clamp(0.0, 1.0) * 100).round(),
  );
}

/// Android: постоянное уведомление вместо Live Activity. id = имя вида (walk/quest/workout).
class NotificationLiveActivityService implements LiveActivityService {
  NotificationLiveActivityService({required this._l10n, LiveNotifier? notifier})
      : _notifier = notifier ?? LocalLiveNotifier();

  final Future<AppLocalizations> Function() _l10n;
  final LiveNotifier _notifier;

  @override
  Future<bool> isSupported() async {
    try {
      return await _notifier.enabled();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<String?> start(LiveKind kind, LiveState state) async {
    if (!await isSupported()) return null;
    await _show(kind, state);
    return kind.name;
  }

  @override
  Future<void> update(String id, LiveState state) async {
    final kind = _kind(id);
    if (kind != null) await _show(kind, state);
  }

  @override
  Future<void> end(String id) async {
    final kind = _kind(id);
    if (kind == null) return;
    try {
      await _notifier.cancel(liveNotificationId(kind));
    } on PlatformException catch (e) {
      debugPrint('LiveNotification: cancel: $e');
    }
  }

  LiveKind? _kind(String id) => LiveKind.values.where((k) => k.name == id).firstOrNull;

  Future<void> _show(LiveKind kind, LiveState state) async {
    final l = await _l10n();
    try {
      await _notifier.show(
        buildLiveNotification(kind, state, l),
        channelName: l.livChannelName,
        channelDescription: l.livChannelDesc,
      );
    } on PlatformException catch (e) {
      debugPrint('LiveNotification: show: $e');
    }
  }
}

/// flutter_local_notifications. Плагин инициализирует LocalReminderScheduler (main) — здесь не
/// инициализируем повторно, чтобы не перезаписать обработчики нажатий напоминаний.
class LocalLiveNotifier implements LiveNotifier {
  LocalLiveNotifier({FlutterLocalNotificationsPlugin? plugin}) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'sistema_live';

  final FlutterLocalNotificationsPlugin _plugin;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  @override
  Future<bool> enabled() async => await _android?.areNotificationsEnabled() ?? false;

  @override
  Future<void> show(LiveNotification n, {required String channelName, required String channelDescription}) async {
    final android = _android;
    if (android == null) return;
    final ends = n.endsAt;
    final timer = ends != null && ends.isAfter(DateTime.now());
    final progress = n.progressPercent;
    await android.show(
      id: n.id,
      title: n.title,
      body: n.body,
      notificationDetails: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        icon: '@mipmap/ic_launcher',
        importance: Importance.low,
        priority: Priority.low,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        silent: true,
        playSound: false,
        enableVibration: false,
        showWhen: timer,
        when: timer ? ends.millisecondsSinceEpoch : null,
        usesChronometer: timer,
        chronometerCountDown: timer,
        showProgress: progress != null,
        maxProgress: 100,
        progress: progress ?? 0,
        category: AndroidNotificationCategory.progress,
        visibility: NotificationVisibility.public,
        styleInformation: BigTextStyleInformation(n.body),
      ),
    );
  }

  @override
  Future<void> cancel(int id) async => _android?.cancel(id: id);
}
