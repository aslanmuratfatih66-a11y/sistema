import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';

const allWeekdays = [
  DateTime.monday,
  DateTime.tuesday,
  DateTime.wednesday,
  DateTime.thursday,
  DateTime.friday,
  DateTime.saturday,
  DateTime.sunday,
];

String weekdayShort(AppLocalizations l, int wd) => switch (wd) {
      DateTime.monday => l.schWd1,
      DateTime.tuesday => l.schWd2,
      DateTime.wednesday => l.schWd3,
      DateTime.thursday => l.schWd4,
      DateTime.friday => l.schWd5,
      DateTime.saturday => l.schWd6,
      _ => l.schWd7,
    };

String weekdayFull(AppLocalizations l, int wd) => switch (wd) {
      DateTime.monday => l.schWdFull1,
      DateTime.tuesday => l.schWdFull2,
      DateTime.wednesday => l.schWdFull3,
      DateTime.thursday => l.schWdFull4,
      DateTime.friday => l.schWdFull5,
      DateTime.saturday => l.schWdFull6,
      _ => l.schWdFull7,
    };

String institutionLabel(AppLocalizations l, InstitutionType t) => switch (t) {
      InstitutionType.school => l.schInstSchool,
      InstitutionType.college => l.schInstCollege,
      InstitutionType.university => l.schInstUniversity,
      InstitutionType.none => l.schInstNone,
    };

String kindLabel(AppLocalizations l, ScheduleItemKind k) => switch (k) {
      ScheduleItemKind.lesson => l.schKindLesson,
      ScheduleItemKind.work => l.schKindWork,
      ScheduleItemKind.other => l.schKindOther,
    };

SysGlyph kindGlyph(ScheduleItemKind k) => switch (k) {
      ScheduleItemKind.lesson => SysGlyph.book,
      ScheduleItemKind.work => SysGlyph.wallet,
      ScheduleItemKind.other => SysGlyph.star,
    };

/// «1 ч 30 мин» / «45 мин».
String formatDuration(AppLocalizations l, int minutes) =>
    minutes >= 60 ? l.schHoursMinutes(minutes ~/ 60, minutes % 60) : l.schMinutes(minutes);

/// «21.10».
String formatDayMonth(DateTime d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';

/// Полноэкранная страница фичи: фон Системы, шапка с кнопкой «назад», прокручиваемое содержимое.
class ScheduleSubPage extends StatelessWidget {
  const ScheduleSubPage({super.key, required this.title, required this.onBack, required this.child, this.bottom});

  final String title;
  final VoidCallback onBack;
  final Widget child;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = bottom;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack,
                      tooltip: l.schBack,
                      constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                      icon: const SysIcon(SysGlyph.arrowLeft, size: 22, color: SysColors.accentLight),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title.toUpperCase(), style: SysText.heading, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: child,
                ),
              ),
              if (b != null) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: b),
            ],
          ),
        ),
      ),
    );
  }
}
