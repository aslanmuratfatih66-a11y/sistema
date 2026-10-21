import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'capability_service.dart';
import 'certificate_status.dart';

/// HealthKit на iOS не работает без платного аккаунта (SPEC §3). Код за флагом.
const bool healthKitEnabled = false;

/// Реализация [CapabilityService]: статическая матрица возможностей по платформе
/// (SPEC §3) + дата истечения профиля подписи из нативного канала.
class PlatformCapabilityService implements CapabilityService {
  PlatformCapabilityService({
    MethodChannel? channel,
    DateTime Function()? now,
    this.platformOverride,
    bool? isWeb,
  })  : _channel = channel ?? const MethodChannel(channelName),
        now = now ?? DateTime.now,
        _isWeb = isWeb ?? kIsWeb;

  static const String channelName = 'sistema/platform';
  static const String methodGetProvisioningInfo = 'getProvisioningInfo';

  final MethodChannel _channel;

  /// Часы (внедряются в тестах).
  final DateTime Function() now;
  /// Принудительная платформа (тесты); иначе defaultTargetPlatform.
  final TargetPlatform? platformOverride;
  final bool _isWeb;

  /// Возможности iOS (бесплатный Apple ID, Sideloadly).
  static const Set<Capability> iosCapabilities = {
    Capability.localNotifications,
    Capability.motionSteps,
    if (healthKitEnabled) Capability.healthKit,
    Capability.backgroundLocation,
    Capability.walkingRoutes,
    Capability.voiceDucking,
    Capability.nowPlaying,
    Capability.liveActivity,
    Capability.widgets,
    Capability.appIntents,
    Capability.urlScheme,
    Capability.secureStorage,
    Capability.camera,
    Capability.barcodeScanner,
    Capability.alarm, // AlarmKit, с фолбэком на уведомления
  };

  /// Возможности Android — ограничений нет.
  static const Set<Capability> androidCapabilities = {
    Capability.localNotifications,
    Capability.motionSteps,
    Capability.healthConnect,
    Capability.backgroundLocation,
    Capability.walkingRoutes,
    Capability.voiceDucking,
    Capability.nowPlaying,
    Capability.remotePush,
    Capability.liveActivity, // ongoing notification
    Capability.widgets,
    Capability.appIntents, // Shortcuts / Tiles
    Capability.urlScheme,
    Capability.secureStorage,
    Capability.camera,
    Capability.barcodeScanner,
    Capability.alarm,
    Capability.appBlocking,
    Capability.bankNotifications,
    Capability.overlay,
  };

  /// Прочие платформы (тесты на десктопе, web): только базовое.
  static const Set<Capability> otherCapabilities = {
    Capability.localNotifications,
  };

  String get _platform {
    if (_isWeb) return 'other';
    return switch (platformOverride ?? defaultTargetPlatform) {
      TargetPlatform.iOS => 'ios',
      TargetPlatform.android => 'android',
      _ => 'other',
    };
  }

  static Set<Capability> capabilitiesFor(String platform) => switch (platform) {
        'ios' => iosCapabilities,
        'android' => androidCapabilities,
        _ => otherCapabilities,
      };

  @override
  Future<DeviceCapabilities> load() async {
    final platform = _platform;
    final expiresAt = platform == 'other' ? null : await _readProvisioningExpiry();
    return DeviceCapabilities(
      platform: platform,
      available: capabilitiesFor(platform),
      provisioningExpiresAt: expiresAt,
    );
  }

  /// Статус сертификата на текущий момент по часам сервиса.
  CertificateStatus? certificateStatus(DeviceCapabilities caps) =>
      CertificateStatus.from(caps.provisioningExpiresAt, now());

  Future<DateTime?> _readProvisioningExpiry() async {
    try {
      final info = await _channel.invokeMapMethod<String, Object?>(methodGetProvisioningInfo);
      final raw = info?['expiresAt'];
      if (raw is! String || raw.isEmpty) return null;
      return DateTime.tryParse(raw);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    } catch (_) {
      // Неожиданный формат ответа — не роняем приложение.
      return null;
    }
  }
}
