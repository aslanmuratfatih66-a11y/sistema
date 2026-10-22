// Dart-сторона канала "sistema/blocker" (Android: BlockerChannel.kt / BlockerService.kt).
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Установленное приложение с ярлыком в лаунчере.
@immutable
class LaunchableApp {
  const LaunchableApp({required this.packageName, required this.label, this.icon});

  final String packageName;
  final String label;

  /// Иконка PNG (~48 px) или null.
  final Uint8List? icon;
}

/// Попытка открыть заблокированное приложение, записанная сервисом.
@immutable
class NativeBlockAttempt {
  const NativeBlockAttempt(this.appId, this.at);
  final String appId;
  final DateTime at;
}

/// Тексты оверлея и уведомления сервиса — уже локализованные.
@immutable
class BlockerTexts {
  const BlockerTexts({
    required this.title,
    required this.body,
    required this.button,
    required this.notificationTitle,
    required this.notificationBody,
  });

  final String title;
  final String body;
  final String button;
  final String notificationTitle;
  final String notificationBody;

  Map<String, String> toMap() => {
        'title': title,
        'body': body,
        'button': button,
        'notificationTitle': notificationTitle,
        'notificationBody': notificationBody,
      };
}

/// Состояние нативного расписания.
@immutable
class NativeBlockerStatus {
  const NativeBlockerStatus({this.fromMs, this.untilMs, this.running = false, this.appCount = 0});
  final int? fromMs;
  final int? untilMs;
  final bool running;
  final int appCount;
}

/// Обёртка над MethodChannel. Ошибки платформы (нет реализации, iOS) — «нет доступа/пусто».
class BlockerChannel {
  const BlockerChannel([this._channel = const MethodChannel(name)]);

  static const name = 'sistema/blocker';

  final MethodChannel _channel;

  Future<T?> _call<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('blocker.$method: ${e.code} ${e.message}');
      return null;
    }
  }

  Future<bool> hasUsageAccess() async => await _call<bool>('hasUsageAccess') ?? false;

  Future<void> openUsageAccessSettings() => _call<void>('openUsageAccessSettings');

  Future<bool> canDrawOverlays() async => await _call<bool>('canDrawOverlays') ?? false;

  Future<void> openOverlaySettings() => _call<void>('openOverlaySettings');

  Future<List<LaunchableApp>> listLaunchableApps({bool icons = true}) async {
    final raw = await _call<List<Object?>>('listLaunchableApps', {'icons': icons}) ?? const [];
    final out = <LaunchableApp>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final pkg = item['package'];
      if (pkg is! String || pkg.isEmpty) continue;
      final label = item['label'];
      final icon = item['icon'];
      out.add(LaunchableApp(
        packageName: pkg,
        label: label is String && label.isNotEmpty ? label : pkg,
        icon: icon is Uint8List ? icon : null,
      ));
    }
    out.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return out;
  }

  /// Блокировать [appIds] с [from] до [until]. [repeatDaily] — сервис сам переносит окно на сутки вперёд,
  /// пока Dart не вызовет [clear] (на случай, если приложение не открывали днём).
  Future<void> setSchedule({
    required List<String> appIds,
    required DateTime from,
    required DateTime until,
    required BlockerTexts texts,
    bool repeatDaily = true,
  }) =>
      _call<void>('setSchedule', {
        'appIds': appIds,
        'fromMs': from.millisecondsSinceEpoch,
        'untilMs': until.millisecondsSinceEpoch,
        'texts': texts.toMap(),
        'repeatDaily': repeatDaily,
      });

  Future<void> clear() => _call<void>('clear');

  Future<NativeBlockerStatus> status() async {
    final raw = await _call<Map<Object?, Object?>>('status');
    if (raw == null) return const NativeBlockerStatus();
    int? n(Object? v) => v is num ? v.toInt() : null;
    return NativeBlockerStatus(
      fromMs: n(raw['fromMs']),
      untilMs: n(raw['untilMs']),
      running: raw['running'] == true,
      appCount: n(raw['appCount']) ?? 0,
    );
  }

  /// Забрать накопленные сервисом попытки (очередь очищается).
  Future<List<NativeBlockAttempt>> drainAttempts() async {
    final raw = await _call<List<Object?>>('drainAttempts') ?? const [];
    final out = <NativeBlockAttempt>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final app = item['appId'];
      final at = item['at'];
      if (app is String && at is num) {
        out.add(NativeBlockAttempt(app, DateTime.fromMillisecondsSinceEpoch(at.toInt())));
      }
    }
    return out;
  }
}
