import 'package:flutter/material.dart';

import '../../../../ui/ui.dart';

/// Вариант с пояснением для [OptionList].
class OptionItem<T> {
  const OptionItem(this.value, this.title, this.description);
  final T value;
  final String title;
  final String description;
}

/// Вертикальный одиночный выбор с пояснениями (уровень активности и т.п.).
class OptionList<T> extends StatelessWidget {
  const OptionList({super.key, required this.items, required this.value, required this.onChanged});

  final List<OptionItem<T>> items;
  final T? value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _Tile(item: it, selected: it.value == value, onTap: () => onChanged(it.value)),
            ),
        ],
      );
}

class _Tile<T> extends StatelessWidget {
  const _Tile({required this.item, required this.selected, required this.onTap});

  final OptionItem<T> item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: '${item.title}. ${item.description}',
        excludeSemantics: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SysDims.radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              constraints: const BoxConstraints(minHeight: SysDims.minTap),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SysDims.radius),
                color: selected ? SysColors.accent.withValues(alpha: .20) : SysColors.accent.withValues(alpha: .04),
                border: Border.all(color: selected ? SysColors.accentLight : SysColors.accent.withValues(alpha: .30)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.title, style: SysText.body.copyWith(color: selected ? SysColors.textPrimary : SysColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(item.description, style: SysText.caption),
                      ],
                    ),
                  ),
                  if (selected) const SysIcon(SysGlyph.check, size: 16, color: SysColors.accentLighter),
                ],
              ),
            ),
          ),
        ),
      );
}
