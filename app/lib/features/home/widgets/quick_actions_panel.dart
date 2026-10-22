// Быстрые действия главного экрана (docs/navigation.md): +250 мл воды сразу, остальное —
// переход во вкладку «Здоровье» на нужный раздел (одно нажатие).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../health/health_screen.dart';
import '../../nutrition/nutrition_providers.dart';

class QuickActionsPanel extends ConsumerWidget {
  const QuickActionsPanel({super.key});

  static const _waterMl = 250;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);

    void open(HealthSection s) {
      ref.read(healthSectionProvider.notifier).set(s);
      context.go(Routes.health);
    }

    Future<void> water() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      await ref.read(waterRepositoryProvider).add(_waterMl);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l.homeQuickWaterAdded)));
    }

    return Row(
      key: const Key('home-quick-actions'),
      children: [
        _QuickButton(
          key: const Key('quick-water'),
          glyph: SysGlyph.water,
          color: SysColors.water,
          label: l.nutWaterAdd(_waterMl),
          onTap: water,
        ),
        const SizedBox(width: 8),
        _QuickButton(
          key: const Key('quick-food'),
          glyph: SysGlyph.nutrition,
          color: SysColors.calories,
          label: l.homeQuickFood,
          onTap: () => open(HealthSection.nutrition),
        ),
        const SizedBox(width: 8),
        _QuickButton(
          key: const Key('quick-workout'),
          glyph: SysGlyph.dumbbell,
          color: SysColors.accentLight,
          label: l.homeQuickWorkout,
          onTap: () => open(HealthSection.workouts),
        ),
        const SizedBox(width: 8),
        _QuickButton(
          key: const Key('quick-walk'),
          glyph: SysGlyph.walk,
          color: SysColors.success,
          label: l.homeQuickWalk,
          onTap: () => open(HealthSection.walks),
        ),
      ],
    );
  }
}

class _QuickButton extends StatelessWidget {
  const _QuickButton({super.key, required this.glyph, required this.color, required this.label, required this.onTap});

  final SysGlyph glyph;
  final Color color;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: SysPressable(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 64),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: SysColors.accent.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(SysDims.radius),
                border: Border.all(color: color.withValues(alpha: .45)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SysIcon(glyph, size: 22, color: color),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SysText.caption.copyWith(color: SysColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
