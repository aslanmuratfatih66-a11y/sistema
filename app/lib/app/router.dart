// Роутер приложения. Правит только главный агент.
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/body/body_screen.dart';
import '../features/discipline/discipline_screen.dart';
import '../features/home/home_screen.dart';
import '../features/nutrition/nutrition_screen.dart';
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
import '../features/shop/shop_screen.dart';
import '../features/walks/walks_screen.dart';
import '../features/workouts/workouts_screen.dart';
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
              GoRoute(path: Routes.nutrition, builder: (_, _) => const NutritionScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.shop, builder: (_, _) => const ShopScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.more, builder: (_, _) => const SettingsScreen()),
            ]),
          ],
        ),
      ],
    );
