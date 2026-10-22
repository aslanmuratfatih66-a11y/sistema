// Маленький индикатор синхронизации (точка): off — серая, idle — зелёная, syncing — крутится,
// offline — жёлтая, error — красная. Нажатие — экран аккаунта (если onTap не задан).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/sync/sync_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key, this.size = 10, this.onTap});

  final double size;
  final VoidCallback? onTap;

  static Color colorOf(SyncPhase p) => switch (p) {
        SyncPhase.off => SysColors.textInactive,
        SyncPhase.idle => SysColors.success,
        SyncPhase.syncing => SysColors.accentLight,
        SyncPhase.offline => SysColors.gold,
        SyncPhase.error => SysColors.danger,
      };

  static String labelOf(AppLocalizations l, SyncPhase p) => switch (p) {
        SyncPhase.off => l.synStatusOff,
        SyncPhase.idle => l.synStatusIdle,
        SyncPhase.syncing => l.synStatusSyncing,
        SyncPhase.offline => l.synStatusOffline,
        SyncPhase.error => l.synStatusError,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final phase = ref.watch(syncStatusProvider.select((s) => s.value?.phase)) ?? SyncPhase.off;
    final color = colorOf(phase);
    final Widget dot = phase == SyncPhase.syncing
        ? SysLoader(size: size, color: color)
        : Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [if (phase != SyncPhase.off) BoxShadow(color: color.withValues(alpha: .6), blurRadius: 6)],
            ),
          );
    return Semantics(
      label: labelOf(l, phase),
      button: true,
      child: Tooltip(
        message: labelOf(l, phase),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap ?? () => context.push(Routes.account),
          child: SizedBox.square(dimension: SysDims.minTap, child: Center(child: dot)),
        ),
      ),
    );
  }
}
