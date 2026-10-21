import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../quests/data/quest_providers.dart';
import '../../quests/quest_actions.dart';
import 'status_panel.dart' show statLabel;

Future<void> showStatPointsSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const StatPointsSheet(),
    );

/// Распределение свободных очков характеристик (QuestService.spendStatPoint).
class StatPointsSheet extends ConsumerWidget {
  const StatPointsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final p = ref.watch(questPlayerProvider).value;
    final free = p?.freeStatPoints ?? 0;
    return SingleChildScrollView(
      key: const Key('stat-points-sheet'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanelHeader(
            title: l.qstStatPointsTitle,
            trailing: Text(l.qstStatPointsLeft(free), key: const Key('stat-points-left')),
          ),
          const SizedBox(height: 8),
          for (final k in StatKind.values)
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: SysDims.minTap),
              child: Row(
                children: [
                  Expanded(child: Text(statLabel(l, k), style: SysText.body)),
                  Text('${p?.stats[k] ?? 0}', style: SysText.mono.copyWith(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  Semantics(
                    label: l.qstStatPointAdd(statLabel(l, k)),
                    excludeSemantics: true,
                    child: SysButton.secondary(
                      key: ValueKey('stat-add-${k.name}'),
                      label: '+1',
                      onPressed: free > 0 ? () => runQuestAction(context, ref, (s, _) => s.spendStatPoint(k)) : null,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
