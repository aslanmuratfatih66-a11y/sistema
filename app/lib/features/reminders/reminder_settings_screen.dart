// Настройки напоминаний: тихие часы, «надоедать», упрёки (SPEC §7). ЗАГЛУШКА каркаса — экран пишет сабагент B.
import 'package:flutter/material.dart';

import '../../app/empty_section_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

class ReminderSettingsScreen extends StatelessWidget {
  const ReminderSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SysColors.background,
        body: SafeArea(child: EmptySectionScreen(title: AppLocalizations.of(context).setReminders, glyph: SysGlyph.bell)),
      );
}
