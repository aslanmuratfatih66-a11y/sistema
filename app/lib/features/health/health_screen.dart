// Вкладка «Здоровье» (решение владельца 2026-10-22, docs/navigation.md): переключатель
// Питание · Тренировки · Тело · Прогулки. Разделы — те же экраны, встроенные без своей шапки.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../body/body_screen.dart';
import '../home/widgets/switch_tab_view.dart';
import '../nutrition/nutrition_screen.dart';
import '../walks/walks_screen.dart';
import '../workouts/workouts_screen.dart';

enum HealthSection { nutrition, workouts, body, walks }

/// Выбранный раздел. Быстрые действия главного экрана выставляют его перед переходом на вкладку.
final healthSectionProvider = NotifierProvider<HealthSectionState, HealthSection>(HealthSectionState.new);

class HealthSectionState extends Notifier<HealthSection> {
  @override
  HealthSection build() => HealthSection.nutrition;

  void set(HealthSection v) => state = v;
}

class HealthScreen extends ConsumerWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return SwitchTabView<HealthSection>(
      key: const Key('health-tab'),
      title: l.navHealth,
      glyph: SysGlyph.heart,
      choices: [
        SysChoice(HealthSection.nutrition, l.navNutrition),
        SysChoice(HealthSection.workouts, l.setWorkouts),
        SysChoice(HealthSection.body, l.healthBody),
        SysChoice(HealthSection.walks, l.setWalks),
      ],
      value: ref.watch(healthSectionProvider),
      onChanged: ref.read(healthSectionProvider.notifier).set,
      builder: (s) => switch (s) {
        HealthSection.nutrition => const NutritionScreen(),
        HealthSection.workouts => const WorkoutsScreen(),
        HealthSection.body => const BodyScreen(),
        HealthSection.walks => const WalksScreen(),
      },
    );
  }
}
