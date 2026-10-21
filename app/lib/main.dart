import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/live_bridge.dart';
import 'app/routes.dart';
import 'app/service_factory.dart';
import 'core/activity/activity_api.dart';
import 'core/activity/activity_providers.dart';
import 'core/activity/channel_step_counter.dart';
import 'core/audio/audio_api.dart';
import 'core/audio/audio_providers.dart';
import 'core/capabilities/capability_service.dart';
import 'core/capabilities/platform_capability_service.dart';
import 'core/db/database.dart';
import 'core/live/live_api.dart';
import 'core/live/live_providers.dart';
import 'core/location/geolocator_location_service.dart';
import 'core/location/walk_tracker_impl.dart';
import 'core/sync/sync_api.dart';
import 'core/sync/sync_providers.dart';
import 'core/notifications/background_refresh.dart';
import 'core/notifications/local_reminder_scheduler.dart';
import 'core/notifications/notification_api.dart';
import 'core/notifications/reminder_coordinator.dart';
import 'core/notifications/reminder_prefs_repository.dart';
import 'core/notifications/reminder_texts.dart';
import 'core/voice/tts_service.dart';
import 'domain/quests/quest_api.dart';
import 'domain/quests/quest_section_hooks.dart';
import 'domain/quests/section_hooks.dart';
import 'domain/walks/walk_api.dart';
import 'features/character/voice/flutter_tts_service.dart';
import 'features/onboarding/onboarding_progress.dart';
import 'features/onboarding/questionnaire_a/data/photo_repository.dart';
import 'features/walks/data/walk_route_service.dart';
import 'features/workouts/workouts_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final onboarding = await OnboardingProgress.load(db);
  final quests = await createQuestService(db, watch: true);
  try {
    await importAcceptedPlanIfMissing(db, quests);
  } catch (e) {
    debugPrint('importAcceptedPlanIfMissing: $e');
  }
  final scheduler = LocalReminderScheduler(l10n: () => reminderL10n(db));
  final walkTracker = await createWalkTracker(db);
  final container = ProviderContainer(overrides: [
    capabilityServiceProvider.overrideWithValue(PlatformCapabilityService()),
    databaseProvider.overrideWithValue(db),
    onboardingProgressProvider.overrideWithValue(onboarding),
    ttsServiceProvider.overrideWithValue(FlutterTtsService()),
    questServiceProvider.overrideWithValue(quests),
    reminderSchedulerProvider.overrideWithValue(scheduler),
    sectionQuestHooksProvider.overrideWithValue(QuestSectionHooks(quests)),
    stepCounterProvider.overrideWithValue(ChannelStepCounter()),
    voicePrompterProvider.overrideWith((ref) => buildVoicePrompter(ref, voice: () => ref.read(workoutVoiceProfileProvider))),
    musicControllerProvider.overrideWith(buildMusicController),
    routeServiceProvider.overrideWith(buildWalkRouteService),
    locationServiceProvider.overrideWithValue(const GeolocatorLocationService()),
    walkTrackerProvider.overrideWithValue(walkTracker),
    liveActivityServiceProvider.overrideWithValue(createLiveActivityService(l10n: () => reminderL10n(db))),
    widgetSyncProvider.overrideWithValue(createWidgetSync(l10n: () => reminderL10n(db))),
    ...syncOverrides(readPhoto: (rel) async {
      final f = await PhotoStorage().resolve(rel);
      return await f.exists() ? f.readAsBytes() : null;
    }),
  ]);

  final prefs = ReminderPrefsRepository(db);
  final reminders = ReminderCoordinator(
    quests: quests,
    scheduler: scheduler,
    loadPrefs: prefs.load,
    prefsChanges: prefs.watch(),
    l10n: () => reminderL10n(db),
    // Кнопки уведомлений в фоне писали через своё соединение — потоки этого не видели.
    onResume: () async => db.markTablesUpdated(db.allTables),
    onOpen: (_) => container.read(routerProvider).go(Routes.quests),
  );
  // Разрешение на уведомления спрашивает экран напоминаний, не старт.
  await scheduler.init(onResponse: reminders.handleResponse);
  unawaited(reminders.start());
  // Виджеты из «Статуса», вода из виджета/App Intent, прогулка → Live Activity (после init уведомлений).
  LiveBridge(container, () => reminderL10n(db)).start();
  // Синхронизация с сервером: создание сервиса запускает таймер и слежение за аккаунтом.
  container.read(syncServiceProvider);
  // Шаги: опрос при старте, возврате и раз в 5 мин → StepLogs → квесты шагов.
  container.read(stepSyncProvider).start();
  unawaited(initBackgroundRefresh().catchError((Object e) => debugPrint('initBackgroundRefresh: $e')));

  runApp(UncontrolledProviderScope(container: container, child: const SistemaApp()));
}
