// Уход за кожей (SPEC §8.3): утренний и вечерний чек-лист по шаблону анкеты, отметки по дням.
// Когда рутина закрыта полностью — hooks.careRoutineDone (через CareService).
// TODO(этап 5): чек-лист и рекомендации средств от ИИ под тип кожи (§8.8) вместо шаблона.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/care_repository.dart';
import 'domain/care_template.dart';
import 'widgets/body_common.dart';

String careItemLabel(AppLocalizations l, String key) => switch (key) {
      CareItemKeys.cleanse => l.bdyCareCleanse,
      CareItemKeys.coldRinse => l.bdyCareColdRinse,
      CareItemKeys.moisturize => l.bdyCareMoisturize,
      CareItemKeys.sunscreen => l.bdyCareSunscreen,
      CareItemKeys.removeSunscreen => l.bdyCareRemoveSunscreen,
      CareItemKeys.acneCare => l.bdyCareAcne,
      CareItemKeys.exfoliate => l.bdyCareExfoliate,
      CareItemKeys.handsOff => l.bdyCareHandsOff,
      _ => key,
    };

/// Уточнение пункта под тип кожи (null — без уточнения).
String? careItemHint(AppLocalizations l, String key, SkinType type) => switch (key) {
      CareItemKeys.moisturize => switch (type) {
          SkinType.oily || SkinType.combination => l.bdyCareMoisturizeLight,
          SkinType.dry => l.bdyCareMoisturizeRich,
          _ => null,
        },
      CareItemKeys.cleanse => type == SkinType.dry ? l.bdyCareCleanseGentle : null,
      _ => null,
    };

String skinTypeLabel(AppLocalizations l, SkinType t) => switch (t) {
      SkinType.normal => l.bdySkinNormal,
      SkinType.oily => l.bdySkinOily,
      SkinType.combination => l.bdySkinCombination,
      SkinType.dry => l.bdySkinDry,
      SkinType.unknown => l.bdySkinUnknown,
    };

String routineLabel(AppLocalizations l, CareRoutine r) => r == CareRoutine.morning ? l.bdyCareMorning : l.bdyCareEvening;

/// Чек-лист одной рутины за день (используется на экране ухода).
class CareChecklist extends ConsumerWidget {
  const CareChecklist({super.key, required this.routine, required this.day});

  final CareRoutine routine;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final template = ref.watch(careTemplateProvider);
    final items = template.items(routine, day);
    final marks = ref.watch(careMarksProvider(day)).value ?? const <CareMark>{};
    final done = items.where((k) => marks.contains((routine: routine, itemKey: k))).length;
    final complete = items.isNotEmpty && done == items.length;
    return SysPanel(
      title: routineLabel(l, routine),
      tone: complete ? PanelTone.success : PanelTone.accent,
      animateIn: false,
      trailing: Text('$done/${items.length}', style: SysText.mono),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final key in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: KeyedSubtree(
                key: Key('bdy-care-${routine.name}-$key'),
                child: QuestRow(
                  title: careItemLabel(l, key),
                  time: careItemHint(l, key, template.profile.skinType),
                  done: marks.contains((routine: routine, itemKey: key)),
                  onToggle: (v) async {
                    final closed = await ref.read(careServiceProvider).toggle(
                          day: day,
                          routine: routine,
                          itemKey: key,
                          done: v,
                          items: items,
                          at: DateTime.now(),
                        );
                    if (closed && context.mounted) {
                      ScaffoldMessenger.maybeOf(context)
                          ?.showSnackBar(SnackBar(content: Text(l.bdyCareRoutineDone(routineLabel(l, routine)))));
                    }
                  },
                ),
              ),
            ),
          if (complete) Text(l.bdyCareCompleteNote, style: SysText.caption.copyWith(color: SysColors.success)),
        ],
      ),
    );
  }
}

class SkinCareScreen extends ConsumerWidget {
  const SkinCareScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SkinCareScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final day = ref.watch(bodyTodayProvider);
    final profile = ref.watch(careTemplateProvider.select((t) => t.profile));
    return ScheduleSubPage(
      title: l.bdyCareTitle,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BodyInfoRow(label: l.bdySkinType, value: skinTypeLabel(l, profile.skinType)),
          const SizedBox(height: 4),
          Text(l.bdyCareTemplateNote, style: SysText.caption),
          if (profile.sensitive) ...[
            const SizedBox(height: 6),
            Text(l.bdyCareSensitiveNote, style: SysText.caption.copyWith(color: SysColors.gold)),
          ],
          const SizedBox(height: 12),
          CareChecklist(routine: CareRoutine.morning, day: day),
          const SizedBox(height: 12),
          CareChecklist(routine: CareRoutine.evening, day: day),
          const SizedBox(height: 12),
          Text(l.qaSkinDermAdvice, style: SysText.caption),
        ],
      ),
    );
  }
}
