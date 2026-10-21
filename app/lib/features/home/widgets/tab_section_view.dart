import 'package:flutter/material.dart';

import '../../../ui/ui.dart';
import '../utils/home_format.dart';

/// Каркас вкладки-раздела (Квесты, Питание): заголовок раздела и панели
/// со скроллом. Нижнюю навигацию и верхний safe area даёт оболочка (AppShell).
class TabSectionView extends StatelessWidget {
  const TabSectionView({
    super.key,
    required this.title,
    required this.glyph,
    required this.children,
    this.scrollKey,
  });

  final String title;
  final SysGlyph glyph;
  final List<Widget> children;
  final Key? scrollKey;

  static const double gap = 14;

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        bottom: false,
        child: ListView(
          key: scrollKey,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Semantics(
              header: true,
              child: Row(
                children: [
                  SysIcon(glyph, size: 22, color: SysColors.accentLight),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      upperFor(title, locale),
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
            for (final c in children) ...[const SizedBox(height: gap), c],
          ],
        ),
      ),
    );
  }
}
