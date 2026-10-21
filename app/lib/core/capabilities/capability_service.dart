// КАРКАС: интерфейс и провайдеры. Реализацию (платформенный канал, нативный код)
// пишет сабагент E. Публичное API сохранить.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Возможности, которые могут быть недоступны на устройстве (SPEC §3).
/// Недоступные фичи UI скрывает, а не ломает.
enum Capability {
  localNotifications,
  motionSteps, // CoreMotion / датчик шагов
  healthKit, // iOS: всегда false (флаг healthKitEnabled=false)
  healthConnect,
  backgroundLocation,
  walkingRoutes, // MapKit / карты Android
  voiceDucking,
  nowPlaying,
  remotePush, // iOS без платного аккаунта: false
  liveActivity,
  widgets,
  appIntents,
  urlScheme,
  secureStorage,
  camera,
  barcodeScanner,
  alarm, // AlarmKit / AlarmManager
  appBlocking, // только Android
  bankNotifications, // только Android
  overlay, // только Android
}

/// Снимок возможностей + данные о подписи.
class DeviceCapabilities {
  const DeviceCapabilities({
    required this.platform,
    required this.available,
    this.provisioningExpiresAt,
  });

  /// 'ios' / 'android' / 'other'
  final String platform;
  final Set<Capability> available;

  /// Дата истечения профиля подписи (iOS sideload, из embedded.mobileprovision).
  /// null — профиля нет (Android, App Store, симулятор).
  final DateTime? provisioningExpiresAt;

  bool has(Capability c) => available.contains(c);
}

abstract interface class CapabilityService {
  Future<DeviceCapabilities> load();
}

/// Переопределяется в main/тестах. Реализация по умолчанию — от сабагента E.
final capabilityServiceProvider = Provider<CapabilityService>(
  (ref) => throw UnimplementedError('capabilityServiceProvider не переопределён'),
);

final deviceCapabilitiesProvider = FutureProvider<DeviceCapabilities>(
  (ref) => ref.watch(capabilityServiceProvider).load(),
);
