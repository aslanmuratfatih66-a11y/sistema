// Тело и здоровье (SPEC §8.3): сон, замеры, графики, шаги, фото-дневник, уход за кожей. ЗАГЛУШКА каркаса — экран пишет сабагент C.
import 'package:flutter/material.dart';

import '../../app/empty_section_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SysColors.background,
        body: SafeArea(child: EmptySectionScreen(title: AppLocalizations.of(context).setBody, glyph: SysGlyph.heart)),
      );
}
