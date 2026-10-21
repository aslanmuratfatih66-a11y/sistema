import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'sys_icon.dart';

class SysNavItem {
  const SysNavItem({required this.glyph, required this.label});
  final SysGlyph glyph;
  final String label;
}

/// Нижняя навигация в стиле системной панели (учитывает safe area снизу).
class SysBottomNav extends StatelessWidget {
  const SysBottomNav({super.key, required this.items, required this.currentIndex, required this.onTap});

  final List<SysNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromRGBO(8, 22, 48, .97), Color.fromRGBO(3, 6, 14, .99)],
        ),
        border: Border(top: BorderSide(color: SysColors.panelBorder)),
        boxShadow: [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 18, offset: Offset(0, -2))],
      ),
      child: Stack(
        children: [
          // Светящаяся линия сверху: ярче в центре.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    SysColors.accentLight.withValues(alpha: 0),
                    SysColors.accentLighter,
                    SysColors.accentLight.withValues(alpha: 0),
                  ],
                ),
                boxShadow: const [BoxShadow(color: Color.fromRGBO(63, 180, 255, .6), blurRadius: 8)],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottom, top: 2),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(item: items[i], selected: i == currentIndex, onTap: () => onTap(i)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.item, required this.selected, required this.onTap});
  final SysNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final dur = reduce ? Duration.zero : const Duration(milliseconds: 200);
    final color = selected ? SysColors.accentLighter : SysColors.textInactive;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          splashColor: SysColors.accent.withValues(alpha: .18),
          highlightColor: SysColors.accent.withValues(alpha: .08),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Индикатор активного пункта.
                AnimatedContainer(
                  duration: dur,
                  width: selected ? 28 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: SysColors.accentLighter,
                    boxShadow: selected
                        ? const [BoxShadow(color: Color.fromRGBO(63, 180, 255, .9), blurRadius: 10)]
                        : null,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: dur,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: selected
                              ? const [BoxShadow(color: Color.fromRGBO(63, 180, 255, .35), blurRadius: 14)]
                              : null,
                        ),
                        child: SysIcon(item.glyph, size: 22, color: color),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.label.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: SysText.label.copyWith(
                          fontSize: 10.5,
                          letterSpacing: SysDims.headingSpacing(10.5),
                          color: color,
                          shadows: selected
                              ? const [Shadow(color: Color.fromRGBO(63, 180, 255, .7), blurRadius: 8)]
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
