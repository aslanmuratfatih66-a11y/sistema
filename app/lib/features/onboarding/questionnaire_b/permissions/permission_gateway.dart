import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

/// Ключи разрешений (совпадают с ключами раздела permissions).
enum AppPermission { notifications, motion, locationAlways, camera, microphone, mediaLibrary, alarms }

/// Состояние разрешения на устройстве.
enum PermissionState {
  granted,
  denied,

  /// Отказано навсегда — запросить снова нельзя, только через настройки.
  permanentlyDenied,
  unavailable,
}

/// Узкий интерфейс над системными разрешениями (для тестов подменяется фейком).
abstract interface class PermissionGateway {
  Future<PermissionState> status(AppPermission p);

  /// Запрос у системы. Для [AppPermission.locationAlways] — сначала «при использовании», затем «всегда».
  Future<PermissionState> request(AppPermission p);

  Future<bool> openSettings();
}

/// Реализация на permission_handler.
class PermissionHandlerGateway implements PermissionGateway {
  PermissionHandlerGateway({required this.isIos});

  final bool isIos;

  ph.Permission? _native(AppPermission p) => switch (p) {
        AppPermission.notifications => ph.Permission.notification,
        AppPermission.motion => isIos ? ph.Permission.sensors : ph.Permission.activityRecognition,
        AppPermission.locationAlways => ph.Permission.locationAlways,
        AppPermission.camera => ph.Permission.camera,
        AppPermission.microphone => ph.Permission.microphone,
        AppPermission.mediaLibrary => isIos ? ph.Permission.mediaLibrary : null,
        // iOS AlarmKit — нативный код на этапе будильника.
        AppPermission.alarms => isIos ? null : ph.Permission.scheduleExactAlarm,
      };

  static PermissionState _map(ph.PermissionStatus s) {
    if (s.isGranted || s.isLimited || s.isProvisional) return PermissionState.granted;
    if (s.isPermanentlyDenied) return PermissionState.permanentlyDenied;
    return PermissionState.denied;
  }

  @override
  Future<PermissionState> status(AppPermission p) async {
    final n = _native(p);
    if (n == null) return PermissionState.unavailable;
    try {
      return _map(await n.status);
    } catch (e) {
      debugPrint('permission status ${p.name}: $e');
      return PermissionState.unavailable;
    }
  }

  @override
  Future<PermissionState> request(AppPermission p) async {
    final n = _native(p);
    if (n == null) return PermissionState.unavailable;
    try {
      if (p == AppPermission.locationAlways) {
        // iOS/Android требуют сначала «при использовании», затем «всегда».
        final whenInUse = await ph.Permission.locationWhenInUse.request();
        if (!whenInUse.isGranted) return _map(whenInUse);
      }
      return _map(await n.request());
    } catch (e) {
      debugPrint('permission request ${p.name}: $e');
      return PermissionState.unavailable;
    }
  }

  @override
  Future<bool> openSettings() => ph.openAppSettings();
}

/// Веб и прочие платформы: системных запросов нет.
class UnavailablePermissionGateway implements PermissionGateway {
  const UnavailablePermissionGateway();

  @override
  Future<PermissionState> status(AppPermission p) async => PermissionState.unavailable;

  @override
  Future<PermissionState> request(AppPermission p) async => PermissionState.unavailable;

  @override
  Future<bool> openSettings() async => false;
}

final permissionGatewayProvider = Provider<PermissionGateway>((ref) {
  if (kIsWeb) return const UnavailablePermissionGateway();
  return switch (defaultTargetPlatform) {
    TargetPlatform.iOS => PermissionHandlerGateway(isIos: true),
    TargetPlatform.android => PermissionHandlerGateway(isIos: false),
    _ => const UnavailablePermissionGateway(),
  };
});
