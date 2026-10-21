// Тренировки (SPEC §8.4): программа под уровень, экран тренировки с таймерами и голосом. ЗАГЛУШКА каркаса — экран пишет сабагент D.
import 'package:flutter/material.dart';

import '../../app/empty_section_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class WorkoutsScreen extends StatelessWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SysColors.background,
        body: SafeArea(child: EmptySectionScreen(title: AppLocalizations.of(context).setWorkouts, glyph: SysGlyph.dumbbell)),
      );
}
