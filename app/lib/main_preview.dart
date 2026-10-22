// Режим предпросмотра в браузере: `flutter run -d chrome -t lib/main_preview.dart` (из app/).
// Рамки iPhone 15 Pro / Pixel 9 / Galaxy S25 (device_preview), заглушки нативных функций, демо-данные.
// Горячие клавиши — PreviewDevices.help. В релизную сборку телефона не попадает: там точка входа lib/main.dart,
// которая не импортирует ни device_preview, ни lib/preview/.
import 'dart:js_interop';

import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/service_factory.dart';
import 'core/alarm/alarm_api.dart';
import 'core/capabilities/capability_service.dart';
import 'core/capabilities/preview_capability_service.dart';
import 'core/db/database.dart';
import 'core/location/walk_repository.dart';
import 'core/notifications/notification_api.dart';
import 'core/security/app_lock.dart';
import 'domain/quests/quest_api.dart';
import 'domain/quests/quest_section_hooks.dart';
import 'domain/quests/section_hooks.dart';
import 'domain/walks/walk_api.dart';
import 'features/finance/finance_providers.dart';
import 'features/finance_input/bank_inbox_service.dart';
import 'features/learning/learning_repository.dart';
import 'features/onboarding/onboarding_progress.dart';
import 'preview/demo_data.dart';
import 'preview/preview_devices.dart';
import 'preview/preview_fakes.dart';

Future<void> main() async {
  DevicePreview.enable(enabled: true);
  final devices = PreviewDevices(DevicePreview.controller);
  await devices.init(android: const String.fromEnvironment('PREVIEW_PLATFORM') == 'android');

  final db = AppDatabase();
  final demo = DemoData(db);
  await demo.seedIfNeeded();
  final onboarding = await OnboardingProgress.load(db);
  final quests = await createQuestService(db, watch: true);

  // Как в lib/main.dart, но всё нативное — заглушки (lib/preview/preview_fakes.dart).
  // Без переопределения остаются «недоступные» реализации по умолчанию: шаги, TTS, распознавание речи,
  // музыка, Live Activity/виджеты, блокировщик (Noop), ИИ («не вошли» → шаблоны), синхронизация.
  final container = ProviderContainer(overrides: [
    capabilityServiceProvider.overrideWithValue(PreviewCapabilityService(platformOf: () => devices.platform)),
    databaseProvider.overrideWithValue(db),
    onboardingProgressProvider.overrideWithValue(onboarding),
    questServiceProvider.overrideWithValue(quests),
    reminderSchedulerProvider.overrideWithValue(PreviewReminderScheduler()),
    sectionQuestHooksProvider.overrideWithValue(QuestSectionHooks(quests)),
    routeServiceProvider.overrideWithValue(const PreviewRouteService()),
    locationServiceProvider.overrideWithValue(const PreviewLocationService()),
    walkTrackerProvider.overrideWithValue(PreviewWalkTracker(WalkRepository(db))),
    learningRepositoryProvider.overrideWith((ref) => LearningRepository(
          ref.watch(databaseProvider),
          const PreviewLearningApi(),
          clock: ref.watch(learningClockProvider),
        )),
    ...financeOverrides,
    appLockProvider.overrideWithValue(PreviewAppLock()),
    bankTxRemoverProvider.overrideWith((ref) => ref.read(financeRepositoryProvider).removeTransaction),
    alarmSchedulerProvider.overrideWithValue(PreviewAlarmScheduler()),
  ]);

  devices
    ..onPlatformChanged = (() => container.invalidate(deviceCapabilitiesProvider))
    ..onReset = () async {
      await demo.clear();
      await db.close();
      _reloadPage(); // main засеет заново
    };

  runApp(UncontrolledProviderScope(container: container, child: const _PreviewApp()));
}

@JS('window.location.reload')
external void _reloadPage();

/// Язык — из симуляции device_preview (Alt+L), поверх языка профиля. Вход по Face ID/PIN выключен.
class _PreviewApp extends StatelessWidget {
  const _PreviewApp();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: DevicePreview.controller.simulationListenable,
        builder: (context, sim, _) => SistemaApp(locale: sim?.locales?.firstOrNull),
      );
}
