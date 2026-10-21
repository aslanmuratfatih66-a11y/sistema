// Вкладка «Магазин» (SPEC §6). ЗАГЛУШКА каркаса — экран пишет сабагент D.
import 'package:flutter/material.dart';

import '../../app/empty_section_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      EmptySectionScreen(title: AppLocalizations.of(context).navShop, glyph: SysGlyph.shop);
}
