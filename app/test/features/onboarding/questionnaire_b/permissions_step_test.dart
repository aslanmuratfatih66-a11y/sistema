import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/capabilities/capability_service.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/features/onboarding/questionnaire_b/permissions/permission_gateway.dart';
import 'package:sistema/features/onboarding/questionnaire_b/permissions_step.dart';

import '../../../helpers/test_db.dart';
import 'qb_harness.dart';

class FakeGateway implements PermissionGateway {
  FakeGateway({required this.statuses, required this.results});

  final Map<AppPermission, PermissionState> statuses;
  final Map<AppPermission, PermissionState> results;
  final List<AppPermission> requested = [];
  int settingsOpened = 0;

  @override
  Future<PermissionState> status(AppPermission p) async => statuses[p] ?? PermissionState.denied;

  @override
  Future<PermissionState> request(AppPermission p) async {
    requested.add(p);
    final r = results[p] ?? PermissionState.denied;
    statuses[p] = r;
    return r;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return true;
  }
}

const _androidCaps = DeviceCapabilities(platform: 'android', available: {
  Capability.localNotifications,
  Capability.motionSteps,
  Capability.backgroundLocation,
  Capability.camera,
  Capability.alarm,
});

void main() {
  testWidgets('granted/denied/skipped/unavailable пишутся в раздел permissions', (tester) async {
    final db = memoryDb();
    final gateway = FakeGateway(
      statuses: {AppPermission.notifications: PermissionState.granted},
      results: {
        AppPermission.motion: PermissionState.granted,
        AppPermission.camera: PermissionState.permanentlyDenied,
        AppPermission.microphone: PermissionState.unavailable,
        AppPermission.alarms: PermissionState.denied,
      },
    );
    await pumpStep(tester, db, const PermissionsStep(), overrides: [
      permissionGatewayProvider.overrideWithValue(gateway),
      deviceCapabilitiesProvider.overrideWith((ref) async => _androidCaps),
    ]);

    // Перепроверка при открытии: уже выданное — granted; медиатека на Android — unavailable.
    var data = await readSection(tester, db, QuestionnaireSection.permissions);
    expect(data['notifications'], 'granted');
    expect(data['mediaLibrary'], 'unavailable');
    expect(find.byKey(const ValueKey('qbPermRow_mediaLibrary')), findsNothing);

    // По одному: сейчас — движение.
    expect(find.byKey(const ValueKey('qbPermCurrent_motion')), findsOneWidget);
    expect(find.byKey(const ValueKey('qbPermCurrent_camera')), findsNothing);
    await tapKey(tester, 'qbPermAllow_motion');
    await tapKey(tester, 'qbPermLater_locationAlways');
    await tapKey(tester, 'qbPermAllow_camera');
    await tapKey(tester, 'qbPermAllow_microphone');
    await tapKey(tester, 'qbPermAllow_alarms');

    data = await readSection(tester, db, QuestionnaireSection.permissions);
    expect(data, {
      'notifications': 'granted',
      'motion': 'granted',
      'locationAlways': 'skipped',
      'camera': 'denied',
      'microphone': 'unavailable',
      'mediaLibrary': 'unavailable',
      'alarms': 'denied',
    });
    expect(gateway.requested, [
      AppPermission.motion,
      AppPermission.camera,
      AppPermission.microphone,
      AppPermission.alarms,
    ]);

    // Отказ навсегда → «Открыть настройки».
    await tapKey(tester, 'qbPermSettings_camera');
    expect(gateway.settingsOpened, 1);

    await disposeTree(tester);
    await db.close();
  });

  testWidgets('без возможностей (веб/прочие) всё unavailable и запросов нет', (tester) async {
    final db = memoryDb();
    final gateway = FakeGateway(statuses: {}, results: {});
    await pumpStep(tester, db, const PermissionsStep(), overrides: [
      permissionGatewayProvider.overrideWithValue(gateway),
      deviceCapabilitiesProvider.overrideWith(
        (ref) async => const DeviceCapabilities(platform: 'other', available: {}),
      ),
    ]);

    final data = await readSection(tester, db, QuestionnaireSection.permissions);
    expect(data, {for (final p in AppPermission.values) p.name: 'unavailable'});
    expect(gateway.requested, isEmpty);

    await disposeTree(tester);
    await db.close();
  });
}
