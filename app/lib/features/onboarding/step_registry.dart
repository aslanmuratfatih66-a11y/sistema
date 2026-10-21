// Сопоставление этапа анкеты и виджета шага. Правит главный агент.
import 'package:flutter/widgets.dart';

import 'onboarding_step.dart';
import 'questionnaire_a/body_photos_step.dart';
import 'questionnaire_a/body_step.dart';
import 'questionnaire_a/goals_step.dart';
import 'questionnaire_a/health_step.dart';
import 'questionnaire_a/profile_step.dart';
import 'questionnaire_a/skin_step.dart';
import 'questionnaire_b/character_step.dart';
import 'questionnaire_b/finance_step.dart';
import 'questionnaire_b/nutrition_step.dart';
import 'questionnaire_b/permissions_step.dart';
import 'questionnaire_b/schedule_step.dart';
import 'questionnaire_b/training_step.dart';

Widget buildStepContent(OnboardingStep step) => switch (step) {
      OnboardingStep.profile => const ProfileStep(),
      OnboardingStep.body => const BodyStep(),
      OnboardingStep.bodyPhotos => const BodyPhotosStep(),
      OnboardingStep.skin => const SkinStep(),
      OnboardingStep.health => const HealthStep(),
      OnboardingStep.goals => const GoalsStep(),
      OnboardingStep.schedule => const ScheduleStep(),
      OnboardingStep.nutrition => const NutritionStep(),
      OnboardingStep.training => const TrainingStep(),
      OnboardingStep.finance => const FinanceStep(),
      OnboardingStep.character => const CharacterStep(),
      OnboardingStep.permissions => const PermissionsStep(),
    };
