// Этапы анкеты (SPEC §5). Порядок = порядок показа. Правит главный агент.
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

enum OnboardingStep {
  profile,
  body,
  bodyPhotos,
  skin,
  health,
  goals,
  schedule,
  nutrition,
  training,
  finance,
  character,
  permissions;

  String title(AppLocalizations l) => switch (this) {
        profile => l.onbStepProfile,
        body => l.onbStepBody,
        bodyPhotos => l.onbStepBodyPhotos,
        skin => l.onbStepSkin,
        health => l.onbStepHealth,
        goals => l.onbStepGoals,
        schedule => l.onbStepSchedule,
        nutrition => l.onbStepNutrition,
        training => l.onbStepTraining,
        finance => l.onbStepFinance,
        character => l.onbStepCharacter,
        permissions => l.onbStepPermissions,
      };

  SysGlyph get glyph => switch (this) {
        profile => SysGlyph.status,
        body => SysGlyph.dumbbell,
        bodyPhotos => SysGlyph.star,
        skin => SysGlyph.sparkle,
        health => SysGlyph.heart,
        goals => SysGlyph.crown,
        schedule => SysGlyph.clock,
        nutrition => SysGlyph.nutrition,
        training => SysGlyph.sword,
        finance => SysGlyph.wallet,
        character => SysGlyph.shield,
        permissions => SysGlyph.info,
      };
}
