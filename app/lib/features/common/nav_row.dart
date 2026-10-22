import 'package:flutter/material.dart';

import '../../ui/ui.dart';

/// Строка-переход: иконка, заголовок, подсказка, значение справа и шеврон.
class NavRow extends StatelessWidget {
  const NavRow({super.key, required this.glyph, required this.title, required this.onTap, this.hint, this.trailing});

  final SysGlyph glyph;
  final String title;
  final String? hint;
  final String? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final h = hint;
    final t = trailing;
    return MergeSemantics(
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: SysDims.minTap),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SysIcon(glyph, size: 20, color: onTap == null ? SysColors.textInactive : SysColors.accentLight),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: SysText.body),
                        if (h != null) Text(h, style: SysText.caption),
                      ],
                    ),
                  ),
                  if (t != null) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        t,
                        style: SysText.monoSmall.copyWith(color: SysColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                  const SizedBox(width: 4),
                  const SysIcon(SysGlyph.chevronRight, size: 20, color: SysColors.textInactive),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
