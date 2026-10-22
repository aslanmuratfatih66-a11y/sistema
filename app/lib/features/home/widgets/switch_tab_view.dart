import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../utils/home_format.dart';

/// Вкладка с переключателем разделов (Здоровье, Магазин): заголовок, переключатель и содержимое
/// выбранного раздела. Разделы строятся при первом открытии и дальше держат состояние
/// (активная прогулка/тренировка не сбрасываются при переключении).
class SwitchTabView<T> extends StatefulWidget {
  const SwitchTabView({
    super.key,
    required this.title,
    required this.glyph,
    required this.choices,
    required this.value,
    required this.onChanged,
    required this.builder,
  });

  final String title;
  final SysGlyph glyph;
  final List<SysChoice<T>> choices;
  final T value;
  final ValueChanged<T> onChanged;
  final Widget Function(T value) builder;

  @override
  State<SwitchTabView<T>> createState() => _SwitchTabViewState<T>();
}

class _SwitchTabViewState<T> extends State<SwitchTabView<T>> {
  final Set<T> _visited = {};

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    _visited.add(widget.value);
    final index = widget.choices.indexWhere((c) => c.value == widget.value);
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Semantics(
                    header: true,
                    child: Row(
                      children: [
                        SysIcon(widget.glyph, size: 22, color: SysColors.accentLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            upperFor(widget.title, locale),
                            style: SysText.heading.copyWith(
                              fontSize: 20,
                              letterSpacing: 2.4,
                              color: SysColors.accentLighter,
                              shadows: const [Shadow(color: SysColors.accent, blurRadius: 8)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  SysSegmented<T>(choices: widget.choices, value: widget.value, onChanged: widget.onChanged),
                ],
              ),
            ),
            Expanded(
              child: EmbeddedTab(
                child: IndexedStack(
                  index: index < 0 ? 0 : index,
                  children: [
                    for (final c in widget.choices)
                      _visited.contains(c.value) ? widget.builder(c.value) : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
