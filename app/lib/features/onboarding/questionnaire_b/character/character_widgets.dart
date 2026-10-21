import 'package:flutter/material.dart';

import '../../../../core/models/enums.dart';
import '../../../../ui/ui.dart';
import '../../../character/character_view.dart';

/// Карточка архетипа с живым персонажем (idle).
class ArchetypeCard extends StatelessWidget {
  const ArchetypeCard({
    super.key,
    required this.archetype,
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final CharacterArchetype archetype;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = PanelTone.accent.palette;
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SysDims.radius),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SysDims.radius),
              color: selected ? p.main.withValues(alpha: .18) : p.main.withValues(alpha: .05),
              border: Border.all(color: selected ? p.light : p.main.withValues(alpha: .35)),
              boxShadow: selected ? [BoxShadow(color: p.glow, blurRadius: 12)] : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CharacterView(archetype: archetype, height: 104),
                const SizedBox(height: 8),
                Text(
                  name.toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: SysText.label.copyWith(color: selected ? SysColors.textPrimary : p.light),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка выбора с заголовком и строками (режим мотивации).
class SelectCard extends StatelessWidget {
  const SelectCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.title,
    required this.lines,
    this.tone = PanelTone.accent,
    this.footer,
  });

  final bool selected;
  final VoidCallback onTap;
  final String title;
  final List<String> lines;
  final PanelTone tone;

  /// Доп. содержимое под текстом (показывается у выбранной карточки).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final f = footer;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SysDims.radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              constraints: const BoxConstraints(minHeight: SysDims.minTap),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SysDims.radius),
                color: selected ? p.main.withValues(alpha: .18) : p.main.withValues(alpha: .05),
                border: Border.all(color: selected ? p.light : p.main.withValues(alpha: .35)),
                boxShadow: selected ? [BoxShadow(color: p.glow, blurRadius: 12)] : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title.toUpperCase(),
                          style: SysText.label.copyWith(color: selected ? SysColors.textPrimary : p.light),
                        ),
                      ),
                      if (selected) SysIcon(SysGlyph.check, size: 16, color: p.light),
                    ],
                  ),
                  for (final line in lines) ...[
                    const SizedBox(height: 4),
                    Text(line, style: SysText.secondary),
                  ],
                  if (f != null) ...[const SizedBox(height: 10), f],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Реплика-цитата персонажа.
class QuoteLine extends StatelessWidget {
  const QuoteLine(this.text, {super.key, this.tone = PanelTone.accent});

  final String text;
  final PanelTone tone;

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(10, 6, 8, 6),
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: tone.palette.light, width: 2)),
          color: tone.palette.main.withValues(alpha: .06),
        ),
        child: Text(text, style: SysText.body.copyWith(fontStyle: FontStyle.italic)),
      );
}
