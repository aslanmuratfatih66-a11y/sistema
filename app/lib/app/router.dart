// Роутер приложения. Правит только главный агент.
import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../l10n/app_localizations.dart';
import '../ui/ui.dart';
import 'app_shell.dart';
import 'empty_section_screen.dart';

abstract final class Routes {
  static const status = '/status';
  static const quests = '/quests';
  static const nutrition = '/nutrition';
  static const shop = '/shop';
  static const more = '/more';
}

GoRouter buildRouter() => GoRouter(
      initialLocation: Routes.status,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, shell) => AppShell(shell: shell),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: Routes.status, builder: (_, _) => const HomeScreen()),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.quests,
                builder: (c, _) => EmptySectionScreen(title: AppLocalizations.of(c).navQuests, glyph: SysGlyph.quests),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.nutrition,
                builder: (c, _) => EmptySectionScreen(title: AppLocalizations.of(c).navNutrition, glyph: SysGlyph.nutrition),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.shop,
                builder: (c, _) => EmptySectionScreen(title: AppLocalizations.of(c).navShop, glyph: SysGlyph.shop),
              ),
            ]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: Routes.more,
                builder: (c, _) => EmptySectionScreen(title: AppLocalizations.of(c).navMore, glyph: SysGlyph.more),
              ),
            ]),
          ],
        ),
      ],
    );
