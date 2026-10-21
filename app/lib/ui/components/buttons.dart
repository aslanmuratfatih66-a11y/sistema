// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

import '../theme/tokens.dart';
import 'sys_icon.dart';

enum SysButtonVariant { primary, secondary, danger }

/// Кнопка ≥44px: основная / вторичная / опасная.
class SysButton extends StatelessWidget {
  const SysButton({super.key, required this.label, required this.onPressed, this.variant = SysButtonVariant.primary, this.icon, this.expand = false});
  const SysButton.primary({super.key, required this.label, required this.onPressed, this.icon, this.expand = false})
      : variant = SysButtonVariant.primary;
  const SysButton.secondary({super.key, required this.label, required this.onPressed, this.icon, this.expand = false})
      : variant = SysButtonVariant.secondary;
  const SysButton.danger({super.key, required this.label, required this.onPressed, this.icon, this.expand = false})
      : variant = SysButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final SysButtonVariant variant;
  final SysGlyph? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) => Text(label);
}

/// Кнопка подтверждения удержанием (по умолчанию 5 сек) — для отказа от квеста.
/// Заполняется по мере удержания; отпустил раньше — сброс.
class HoldButton extends StatelessWidget {
  const HoldButton({
    super.key,
    required this.label,
    required this.onCompleted,
    this.duration = SysDims.holdToConfirm,
    this.tone = PanelTone.danger,
    this.expand = false,
  });

  final String label;
  final VoidCallback onCompleted;
  final Duration duration;
  final PanelTone tone;
  final bool expand;

  @override
  Widget build(BuildContext context) => Text(label);
}
