import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/routes.dart';
import 'app/service_factory.dart';
import 'core/activity/activity_api.dart';
import 'core/activity/activity_providers.dart';
import 'core/activity/channel_step_counter.dart';
import 'core/capabilities/capability_service.dart';
import 'core/capabilities/platform_capability_service.dart';
import 'core/db/database.dart';
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
import 'features/character/voice/flutter_tts_service.dart';
import 'features/onboarding/onboarding_progress.dart';

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
  final container = ProviderContainer(overrides: [
    capabilityServiceProvider.overrideWithValue(PlatformCapabilityService()),
    databaseProvider.overrideWithValue(db),
    onboardingProgressProvider.overrideWithValue(onboarding),
    ttsServiceProvider.overrideWithValue(FlutterTtsService()),
    questServiceProvider.overrideWithValue(quests),
    reminderSchedulerProvider.overrideWithValue(scheduler),
    sectionQuestHooksProvider.overrideWithValue(QuestSectionHooks(quests)),
    stepCounterProvider.overrideWithValue(ChannelStepCounter()),
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
  // Шаги: опрос при старте, возврате и раз в 5 мин → StepLogs → квесты шагов.
  container.read(stepSyncProvider).start();
  unawaited(initBackgroundRefresh().catchError((Object e) => debugPrint('initBackgroundRefresh: $e')));

  runApp(UncontrolledProviderScope(container: container, child: const SistemaApp()));
}
