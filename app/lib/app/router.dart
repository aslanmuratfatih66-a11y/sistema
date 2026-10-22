// Роутер приложения. Правит только главный агент.
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/body/body_screen.dart';
import '../features/discipline/discipline_screen.dart';
import '../features/home/home_screen.dart';
import '../features/day_summary/day_summary_screen.dart';
import '../features/health/health_screen.dart';
import '../features/levels/level_path_screen.dart';
import '../features/more/more_screen.dart';
import '../features/onboarding/onboarding_progress.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/onboarding/onboarding_step.dart';
import '../features/onboarding/step_edit_screen.dart';
import '../features/plan/plan_screen.dart';
import '../features/quests/outcomes/outcome_windows_host.dart';
import '../features/quests/quests_screen.dart';
import '../features/reminders/reminder_settings_screen.dart';
import '../features/schedule/schedule_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shop/shop_tab_screen.dart';
import '../features/walks/walks_screen.dart';
import '../features/ai_journal/ai_journal_screen.dart';
import '../features/auth/account_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/chat/live_talk_screen.dart';
import '../features/learning/learning_screen.dart';
import '../features/workouts/workouts_screen.dart';
import '../features/alarm/alarm_ring_screen.dart';
import '../features/alarm/alarms_screen.dart';
import '../features/blocker/blocked_screen.dart';
import '../features/blocker/blocker_setup_screen.dart';
import '../features/finance/finance_screen.dart';
import '../features/finance_input/bank_sources_screen.dart';
import '../features/finance_input/receipt_input_screen.dart';
import '../features/finance_input/statement_import_screen.dart';
import '../features/market/market_screen.dart';
import 'app_shell.dart';
import 'routes.dart';

export 'routes.dart';

GoRouter buildRouter(OnboardingProgress onboarding) => GoRouter(
      initialLocation: Routes.status,
      refreshListenable: onboarding,
      redirect: (context, state) {
        final loc = state.matchedLocation;
        final inOnboarding = loc == Routes.onboarding;
        if (!onboarding.completed && !inOnboarding) return Routes.onboarding;
        if (onboarding.completed && inOnboarding) return Routes.plan;
        return null;
      },
      routes: [
        GoRoute(path: Routes.onboarding, builder: (_, _) => const OnboardingScreen()),
        GoRoute(path: Routes.plan, builder: (_, _) => const PlanScreen()),
        GoRoute(path: Routes.schedule, builder: (_, _) => const ScheduleScreen()),
        GoRoute(path: Routes.reminders, builder: (_, _) => const ReminderSettingsScreen()),
        GoRoute(path: Routes.discipline, builder: (_, _) => const DisciplineScreen()),
        GoRoute(path: Routes.body, builder: (_, _) => const BodyScreen()),
        GoRoute(path: Routes.workouts, builder: (_, _) => const WorkoutsScreen()),
        GoRoute(path: Routes.walks, builder: (_, _) => const WalksScreen()),
        GoRoute(path: Routes.account, builder: (_, _) => const AccountScreen()),
        GoRoute(path: Routes.chat, builder: (_, _) => const ChatScreen()),
        GoRoute(path: Routes.talk, builder: (_, _) => const LiveTalkScreen()),
        GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
        GoRoute(path: Routes.levels, builder: (_, _) => const LevelPathScreen()),
        GoRoute(path: Routes.daySummary, builder: (_, _) => const DaySummaryScreen()),
        GoRoute(path: Routes.learning, builder: (_, _) => const LearningScreen()),
        GoRoute(path: Routes.aiJournal, builder: (_, _) => const AiJournalScreen()),
        GoRoute(path: Routes.finance, builder: (_, _) => const FinanceScreen()),
        GoRoute(
          path: Routes.financeReceipt,
          builder: (_, state) => ReceiptInputScreen(mode: state.uri.queryParameters['mode']),
        ),
        GoRoute(path: Routes.financeBanks, builder: (_, _) => const BankSourcesScreen()),
        GoRoute(path: Routes.financeStatement, builder: (_, _) => const StatementImportScreen()),
        GoRoute(path: Routes.market, builder: (_, _) => const MarketScreen()),
        GoRoute(path: Routes.blocker, builder: (_, _) => const BlockerSetupScreen()),
        GoRoute(path: Routes.blocked, builder: (_, state) => BlockedScreen(app: state.uri.queryParameters['app'])),
        GoRoute(path: Routes.alarms, builder: (_, _) => const AlarmsScreen()),
        GoRoute(path: Routes.alarmRing, builder: (_, state) => AlarmRingScreen(alarmId: state.uri.queryParameters['id'])),
        GoRoute(
          path: Routes.editStepPattern,
          builder: (_, state) {
            final step = OnboardingStep.values.asNameMap()[state.pathParameters['step']];
            return step == null ? const SizedBox.shrink() : StepEditScreen(step: step);
          },
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => OutcomeWindowsHost(child: AppShell(shell: shell)),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.status, builder: (_, _) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.quests, builder: (_, _) => const QuestsScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.health, builder: (_, _) => const HealthScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.shop, builder: (_, _) => const ShopTabScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.more, builder: (_, _) => const MoreScreen()),
            ]),
          ],
        ),
      ],
    );
