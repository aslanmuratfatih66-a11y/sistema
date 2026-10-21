import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/capabilities/capability_service.dart';
import 'package:sistema/core/capabilities/platform_capability_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(PlatformCapabilityService.channelName);
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void mockChannel(Future<Object?>? Function(MethodCall call)? handler) =>
      messenger.setMockMethodCallHandler(channel, handler);

  tearDown(() {
    mockChannel(null);
    debugDefaultTargetPlatformOverride = null;
  });

  test('iOS: матрица SPEC §3 и дата профиля', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    mockChannel((call) async {
      expect(call.method, 'getProvisioningInfo');
      return {'expiresAt': '2026-10-28T08:00:00Z'};
    });
    final caps = await PlatformCapabilityService(isWeb: false).load();
    expect(caps.platform, 'ios');
    expect(caps.provisioningExpiresAt, DateTime.utc(2026, 10, 28, 8));
    for (final c in [
      Capability.healthKit,
      Capability.remotePush,
      Capability.appBlocking,
      Capability.bankNotifications,
      Capability.overlay,
      Capability.healthConnect,
    ]) {
      expect(caps.has(c), isFalse, reason: '$c');
    }
    for (final c in [
      Capability.localNotifications,
      Capability.motionSteps,
      Capability.backgroundLocation,
      Capability.walkingRoutes,
      Capability.liveActivity,
      Capability.widgets,
      Capability.appIntents,
      Capability.alarm,
      Capability.barcodeScanner,
    ]) {
      expect(caps.has(c), isTrue, reason: '$c');
    }
    expect(healthKitEnabled, isFalse);
  });

  test('Android: всё, кроме HealthKit; профиля нет', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    mockChannel((call) async => {'expiresAt': null});
    final caps = await PlatformCapabilityService(isWeb: false).load();
    expect(caps.platform, 'android');
    expect(caps.provisioningExpiresAt, isNull);
    expect(caps.has(Capability.healthKit), isFalse);
    for (final c in [
      Capability.healthConnect,
      Capability.remotePush,
      Capability.appBlocking,
      Capability.bankNotifications,
      Capability.overlay,
      Capability.alarm,
    ]) {
      expect(caps.has(c), isTrue, reason: '$c');
    }
  });

  test('PlatformException → null, без падения', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    mockChannel((call) async => throw PlatformException(code: 'boom'));
    final caps = await PlatformCapabilityService(isWeb: false).load();
    expect(caps.platform, 'ios');
    expect(caps.provisioningExpiresAt, isNull);
  });

  test('MissingPluginException (нет обработчика) → null', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    final caps = await PlatformCapabilityService(isWeb: false).load();
    expect(caps.provisioningExpiresAt, isNull);
  });

  test('мусорная дата → null', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    mockChannel((call) async => {'expiresAt': 'не дата'});
    final caps = await PlatformCapabilityService(isWeb: false).load();
    expect(caps.provisioningExpiresAt, isNull);
  });

  test('внедрённые часы → certificateStatus', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    mockChannel((call) async => {'expiresAt': '2026-10-24T12:00:00'});
    final service = PlatformCapabilityService(isWeb: false, now: () => DateTime(2026, 10, 21, 10));
    final status = service.certificateStatus(await service.load())!;
    expect(status.daysLeft, 3);
  });
}
