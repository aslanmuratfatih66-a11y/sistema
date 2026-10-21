import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_localizations.dart';
import '../ui/ui.dart';

/// Оболочка: фон с сеткой, контент вкладки, нижняя навигация.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: Column(
          children: [
            Expanded(child: shell),
            SysBottomNav(
              currentIndex: shell.currentIndex,
              onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
              items: [
                SysNavItem(glyph: SysGlyph.status, label: l.navStatus),
                SysNavItem(glyph: SysGlyph.quests, label: l.navQuests),
                SysNavItem(glyph: SysGlyph.nutrition, label: l.navNutrition),
                SysNavItem(glyph: SysGlyph.shop, label: l.navShop),
                SysNavItem(glyph: SysGlyph.more, label: l.navMore),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
