import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';

/// Блок оценок ИИ до расчёта: «≈ … Будет рассчитано Системой» + пометка «оценка по фото…».
class EstimateBlock extends StatelessWidget {
  const EstimateBlock({super.key, required this.items});

  /// Названия оцениваемых показателей.
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                Expanded(child: Text(item, style: SysText.body)),
                Text('≈ …', style: SysText.mono.copyWith(color: SysColors.accentLight)),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    l.commonCalculatedBySystem,
                    style: SysText.caption.copyWith(color: SysColors.textInactive),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SysIcon(SysGlyph.info, size: 14, color: SysColors.textCaption),
            const SizedBox(width: 6),
            Expanded(child: Text(l.commonEstimateNote, style: SysText.caption)),
          ],
        ),
      ],
    );
  }
}
