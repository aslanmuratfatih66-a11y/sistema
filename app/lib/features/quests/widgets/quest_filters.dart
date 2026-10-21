import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../home/widgets/status_panel.dart' show statLabel;
import '../data/quest_providers.dart';
import '../quest_format.dart';
import '../quest_labels.dart';

/// Фильтры по характеристике и виду: свёрнутая строка, раскрывается по нажатию.
class QuestFiltersBar extends ConsumerStatefulWidget {
  const QuestFiltersBar({super.key});

  @override
  ConsumerState<QuestFiltersBar> createState() => _QuestFiltersBarState();
}

class _QuestFiltersBarState extends ConsumerState<QuestFiltersBar> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final f = ref.watch(questFilterProvider);
    final set = ref.read(questFilterProvider.notifier).set;
    final active = [?f.stat, ?f.kind].length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: SysButton.secondary(
                key: const Key('quest-filters-toggle'),
                label: active == 0 ? l.qstFilterTitle : l.qstFilterActive(active),
                icon: _open ? SysGlyph.arrowUp : SysGlyph.arrowDown,
                expand: true,
                onPressed: () => setState(() => _open = !_open),
              ),
            ),
            if (active > 0) ...[
              const SizedBox(width: 8),
              SysButton.secondary(label: l.qstFilterReset, onPressed: () => set(QuestFilter.none)),
            ],
          ],
        ),
        if (_open) ...[
          const SizedBox(height: 10),
          SysFieldLabel(l.qstFilterKind),
          SysChoiceChips<QuestKindFilter>(
            key: const Key('quest-filter-kind'),
            choices: [for (final k in QuestKindFilter.values) SysChoice(k, kindFilterLabel(l, k))],
            selected: {?f.kind},
            onChanged: (s) => set(f.withKind(s.isEmpty ? null : s.first)),
          ),
          const SizedBox(height: 10),
          SysFieldLabel(l.qstFilterStat),
          SysChoiceChips<StatKind>(
            key: const Key('quest-filter-stat'),
            choices: [for (final k in StatKind.values) SysChoice(k, statLabel(l, k))],
            selected: {?f.stat},
            onChanged: (s) => set(f.withStat(s.isEmpty ? null : s.first)),
          ),
        ],
      ],
    );
  }
}
