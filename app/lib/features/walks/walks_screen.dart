// Прогулки (SPEC §8.5): круговой маршрут, отрезки, голос, музыка, поиск магазина. ЗАГЛУШКА каркаса — экран пишет сабагент A.
import 'package:flutter/material.dart';

import '../../app/empty_section_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class WalksScreen extends StatelessWidget {
  const WalksScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SysColors.background,
        body: SafeArea(child: EmptySectionScreen(title: AppLocalizations.of(context).setWalks, glyph: SysGlyph.walk)),
      );
}
