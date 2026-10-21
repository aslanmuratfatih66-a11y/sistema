import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../schedule/schedule_editor.dart';
import '../step_scope.dart';
import 'common/section_state.dart';

/// Этап 7 — расписание. Сам редактор живёт в фиче schedule (общий с экраном расписания).
class ScheduleStep extends StatelessWidget {
  const ScheduleStep({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = StepScope.maybeOf(context)?.editing ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.qbScheduleIntro, style: SysText.secondary),
        const ScheduleEditor(),
      ],
    );
  }
}
