import 'package:flutter/widgets.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'sys_icon.dart';

/// Маленькая метка-«пилюля» (бафф, ранг, награда).
class SysPill extends StatelessWidget {
  const SysPill({super.key, required this.label, this.tone = PanelTone.accent, this.icon, this.trailing});

  final String label;
  final PanelTone tone;
  final SysGlyph? icon;

  /// Например таймер эффекта (моноширинный).
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final ic = icon;
    final tr = trailing;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: p.main.withValues(alpha: .10),
        border: Border.all(color: p.border),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [BoxShadow(color: p.glow.withValues(alpha: .5), blurRadius: 8)],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ic != null) ...[SysIcon(ic, size: 13, color: p.light), const SizedBox(width: 5)],
            Flexible(
              child: Text(
                label,
                style: SysText.caption.copyWith(color: p.light, fontSize: 11.5, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            if (tr != null) ...[
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  tr,
                  maxLines: 1,
                  overflow: TextOverflow.fade,
                  softWrap: false,
                  style: SysText.monoSmall.copyWith(color: p.light.withValues(alpha: .85)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
