// Режим дисциплины (SPEC §6): статус, правила, ручное включение. ЗАГЛУШКА каркаса — экран пишет сабагент D.
import 'package:flutter/material.dart';

import '../../app/empty_section_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class DisciplineScreen extends StatelessWidget {
  const DisciplineScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SysColors.background,
        body: SafeArea(child: EmptySectionScreen(title: AppLocalizations.of(context).setDiscipline, glyph: SysGlyph.shield)),
      );
}
