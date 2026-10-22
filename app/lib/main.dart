import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/live_bridge.dart';
import 'app/routes.dart';
import 'app/service_factory.dart';
import 'core/data/user_setting_store.dart';
import 'domain/day_modes/day_modes.dart';
import 'features/day_summary/day_summary_screen.dart' show daySummaryReminderPrefix;
import 'features/habits/habit_repository.dart';
import 'core/activity/activity_api.dart';
import 'core/activity/activity_providers.dart';
import 'core/activity/channel_step_counter.dart';
import 'core/ai/ai_api.dart';
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
import 'core/alarm/alarm_api.dart';
import 'core/alarm/alarm_sync.dart';
import 'core/alarm/channel_alarm_scheduler.dart';
import 'core/notifications/ai_messages_sync.dart';
import 'core/security/app_lock.dart';
import 'core/security/app_lock_impl.dart';
import 'app/reminder_filters.dart';
import 'core/notifications/notification_api.dart';
import 'core/notifications/reminder_coordinator.dart';
import 'core/notifications/reminder_prefs_repository.dart';
import 'core/notifications/reminder_texts.dart';
import 'core/voice/speech_input.dart';
import 'core/voice/tts_service.dart';
import 'core/voice/voice_providers.dart';
import 'domain/discipline/app_blocker.dart';
import 'domain/discipline/app_blocker_impl.dart';
import 'domain/discipline/app_blocker_sync.dart';
import 'domain/quests/quest_api.dart';
import 'domain/quests/quest_section_hooks.dart';
import 'domain/quests/section_hooks.dart';
import 'domain/walks/walk_api.dart';
import 'features/character/system_overlay_controller.dart';
import 'features/finance/finance_providers.dart';
import 'features/finance_input/bank_inbox_service.dart';
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
    httpAiGatewayOverride,
    characterTtsProvider.overrideWith(buildServerTts),
    speechInputProvider.overrideWith((ref) => SttSpeechInput()),
    // Этап 7: финансы (журнал операций, курсы, советник бюджета), вход по Face ID/PIN, блокировка, будильник.
    ...financeOverrides,
    appLockProvider.overrideWith((ref) => ref.watch(appLockImplProvider)),
    bankTxRemoverProvider.overrideWith((ref) => ref.read(financeRepositoryProvider).removeTransaction),
    appBlockerProvider.overrideWith((ref) => createPlatformAppBlocker(ref.watch(databaseProvider))),
    alarmSchedulerProvider.overrideWithValue(createAlarmScheduler(db: db, l10n: () => reminderL10n(db))),
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
    onOpen: (id) => container.read(routerProvider).go(switch (id) {
          _ when id.startsWith(financeReminderPrefix) => Routes.finance,
          _ when id.startsWith(daySummaryReminderPrefix) => Routes.daySummary,
          _ => Routes.quests,
        }),
    templateFilter: reminderTemplateFilter(db),
    // Режимы дня сдвигают квесты с занятости до проверки просрочек; серии привычек — бонусы.
    beforeTick: (now) async {
      await DayModesService(db).apply(now);
      await HabitRepository(UserSettingStore(db), quests).checkMilestones(now);
    },
  );
  // Разрешение на уведомления спрашивает экран напоминаний, не старт.
  await scheduler.init(onResponse: reminders.handleResponse);
  unawaited(reminders.start());
  // Сообщения Системы наперёд (этап 6): пачка с сервера → локальные уведомления, облачко персонажа.
  unawaited(container.read(aiMessageSyncProvider).start());
  // Этап 8: персонаж поверх других приложений (Android, по настройке и разрешению).
  container.read(systemOverlayControllerProvider).start();
  // Виджеты из «Статуса», вода из виджета/App Intent, прогулка → Live Activity (после init уведомлений).
  LiveBridge(container, () => reminderL10n(db)).start();
  // Синхронизация с сервером: создание сервиса запускает таймер и слежение за аккаунтом.
  container.read(syncServiceProvider);
  // Шаги: опрос при старте, возврате и раз в 5 мин → StepLogs → квесты шагов.
  container.read(stepSyncProvider).start();
  // Этап 7: блокировка после отбоя следует за режимом дисциплины.
  container.read(disciplineBlockerSyncProvider).start();
  // Этап 7: уведомления/SMS банков (Android) → входящие → операции.
  unawaited(startBankInbox(container));
  unawaited(initBackgroundRefresh().catchError((Object e) => debugPrint('initBackgroundRefresh: $e')));

  runApp(UncontrolledProviderScope(container: container, child: const SistemaApp(appLock: true)));
  // Будильники: планирование по таблице и дисциплине; звонящий будильник → экран задания.
  unawaited(container.read(alarmSyncProvider).start());
}
