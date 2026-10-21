import 'package:flutter/widgets.dart';

import '../../../ui/ui.dart';

/// Строка мини-сводки «подпись … значение» (калории, финансы).
/// При нехватке ширины значение переносится под подпись.
class SummaryLine extends StatelessWidget {
  const SummaryLine({super.key, required this.label, required this.value, this.color = SysColors.textPrimary});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        children: [
          Text(label, style: SysText.secondary),
          Text(value, style: SysText.mono.copyWith(fontSize: 13, color: color)),
        ],
      ),
    );
  }
}
