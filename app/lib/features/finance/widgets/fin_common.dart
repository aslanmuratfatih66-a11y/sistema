// Общие виджеты раздела «Финансы».
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

export '../../schedule/widgets/schedule_common.dart' show ScheduleSubPage;

/// Строка «подпись — значение».
class FinInfoRow extends StatelessWidget {
  const FinInfoRow({super.key, required this.label, required this.value, this.valueColor = SysColors.textPrimary, this.glyph});

  final String label;
  final String value;
  final Color valueColor;
  final SysGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    final g = glyph;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          if (g != null) ...[SysIcon(g, size: 16, color: SysColors.textCaption), const SizedBox(width: 8)],
          Expanded(child: Text(label, style: SysText.secondary, overflow: TextOverflow.ellipsis)),
          const SizedBox(width: 8),
          Text(value, style: SysText.mono.copyWith(color: valueColor)),
        ],
      ),
    );
  }
}

/// Ряд кнопок (переносится).
class FinActions extends StatelessWidget {
  const FinActions({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(spacing: 10, runSpacing: 10, children: children),
      );
}

/// Нажимаемая строка списка (≥44px).
class FinTile extends StatelessWidget {
  const FinTile({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.trailingColor = SysColors.textPrimary,
    this.glyph,
    this.glyphColor = SysColors.accentLight,
    this.onTap,
    this.below,
  });

  final String title;
  final String? subtitle;
  final String? trailing;
  final Color trailingColor;
  final SysGlyph? glyph;
  final Color glyphColor;
  final VoidCallback? onTap;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    final g = glyph;
    final sub = subtitle;
    final tr = trailing;
    final b = below;
    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SysDims.minTap),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (g != null) ...[SysIcon(g, size: 20, color: glyphColor), const SizedBox(width: 10)],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: SysText.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                          if (sub != null) Text(sub, style: SysText.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    if (tr != null) ...[
                      const SizedBox(width: 8),
                      Text(tr, style: SysText.mono.copyWith(color: trailingColor)),
                    ],
                  ],
                ),
                if (b != null) Padding(padding: const EdgeInsets.only(top: 6), child: b),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Пустое состояние панели.
class FinEmpty extends StatelessWidget {
  const FinEmpty(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => SysEmptyState.inline(text, glyph: SysGlyph.wallet);
}

/// Подтверждение удаления (системное окно).
Future<bool> confirmFinDelete(BuildContext context, String message) async {
  final l = AppLocalizations.of(context);
  final ok = await showDialog<bool>(
    context: context,
    barrierColor: SysColors.barrier,
    builder: (c) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: SystemWindow(
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.finWarning,
        message: message,
        actions: [
          SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false)),
          SysButton.danger(label: l.commonDelete, onPressed: () => Navigator.of(c).pop(true)),
        ],
      ),
    ),
  );
  return ok == true;
}

/// Выбор из списка в нижнем листе. null — отмена.
Future<T?> pickFin<T>(BuildContext context, {required String title, required List<SysChoice<T>> choices, T? selected}) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: SysColors.panelBottom,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: SysColors.panelBorder),
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
      ),
      builder: (c) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SysPanelHeader(title: title),
            const SizedBox(height: 8),
            for (final ch in choices)
              FinTile(
                title: ch.label,
                glyph: ch.glyph,
                trailing: ch.value == selected ? '✓' : null,
                trailingColor: SysColors.success,
                onTap: () => Navigator.of(c).pop(ch.value),
              ),
          ],
        ),
      ),
    );

void finSnack(BuildContext context, String text) =>
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(text)));

/// Полоса прогресса с подписью «потрачено / лимит».
class FinProgress extends StatelessWidget {
  const FinProgress({super.key, required this.label, required this.value, required this.max, required this.valueText});

  final String label;
  final int value;
  final int max;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final ratio = max <= 0 ? 0.0 : value / max;
    final color = ratio > 1 ? SysColors.danger : (ratio > .85 ? SysColors.gold : SysColors.success);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text(label, style: SysText.secondary, overflow: TextOverflow.ellipsis)),
            Text(valueText, style: SysText.monoSmall.copyWith(color: color)),
          ]),
          const SizedBox(height: 4),
          SysBar(value: ratio.clamp(0, 1).toDouble(), color: color),
        ],
      ),
    );
  }
}
