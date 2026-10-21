import 'package:flutter/widgets.dart';

import '../../../../ui/ui.dart';

/// Пункт инструкции с ромбом.
class TipLine extends StatelessWidget {
  const TipLine(this.text, {super.key, this.color = SysColors.textSecondary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(padding: EdgeInsets.only(top: 6, right: 8), child: SysDiamond(size: 6)),
            Expanded(child: Text(text, style: SysText.secondary.copyWith(color: color))),
          ],
        ),
      );
}
