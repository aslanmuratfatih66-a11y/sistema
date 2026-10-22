import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/home_providers.dart';
import '../models/home_view_data.dart';
import '../utils/home_format.dart';

/// Блок 3: баффы (зелёные) и дебаффы (красные) с таймером — в одну строку.
class EffectsPanel extends ConsumerWidget {
  const EffectsPanel({super.key, required this.effects});

  final List<HomeEffect> effects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(homeClockProvider);
    final active = effects.where((e) => e.expiresAt.isAfter(now)).toList();

    return SysPanel(
      appearDelay: const Duration(milliseconds: 60),
      title: l.homeEffectsTitle,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: active.isEmpty
          ? SysEmptyState.inline(l.homeEffectsEmpty, glyph: SysGlyph.sparkle)
          // Одна строка с горизонтальной прокруткой — блок не растёт по высоте.
          : SingleChildScrollView(
              key: const Key('effects-scroll'),
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final (i, e) in active.indexed) ...[
                    if (i > 0) const SizedBox(width: 8),
                    SysPill(
                      label: e.label.of(l),
                      tone: e.isBuff ? PanelTone.success : PanelTone.danger,
                      icon: e.isBuff ? SysGlyph.arrowUp : SysGlyph.arrowDown,
                      trailing: formatHoursMinutes(e.expiresAt.difference(now)),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
