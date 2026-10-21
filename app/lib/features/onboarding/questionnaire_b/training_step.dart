import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'common/section_state.dart';

/// Ключи инвентаря (раздел training.equipment).
const trainingEquipmentKeys = ['none', 'dumbbells', 'pullupBar', 'bands', 'mat', 'kettlebell'];
const trainingMinutePresets = [10, 20, 30, 45, 60];

/// Подписи дней недели (DateTime.weekday 1..7).
List<String> weekdayShortLabels(AppLocalizations l) =>
    [l.qbDayMon, l.qbDayTue, l.qbDayWed, l.qbDayThu, l.qbDayFri, l.qbDaySat, l.qbDaySun];

/// Этап 9 — тренировки (раздел training).
class TrainingStep extends ConsumerStatefulWidget {
  const TrainingStep({super.key});

  @override
  ConsumerState<TrainingStep> createState() => _TrainingStepState();
}

class _TrainingStepState extends SectionStepState<TrainingStep> {
  @override
  QuestionnaireSection get section => QuestionnaireSection.training;

  @override
  Map<String, Object?> initialDefaults(Map<String, Object?> current) =>
      current['place'] == 'home' ? const {} : const {'place': 'home'};

  String _equipmentLabel(AppLocalizations l, String key) => switch (key) {
        'none' => l.qbEquipNone,
        'dumbbells' => l.qbEquipDumbbells,
        'pullupBar' => l.qbEquipPullupBar,
        'bands' => l.qbEquipBands,
        'mat' => l.qbEquipMat,
        'kettlebell' => l.qbEquipKettlebell,
        _ => key,
      };

  void _setEquipment(Set<String> next, Set<String> prev) {
    var s = next;
    // «Нет инвентаря» исключает остальное и наоборот.
    if (s.contains('none') && !prev.contains('none')) {
      s = {'none'};
    } else if (s.length > 1) {
      s = {...s}..remove('none');
    }
    setValue('equipment', [for (final k in trainingEquipmentKeys) if (s.contains(k)) k]);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final editing = StepScope.maybeOf(context)?.editing ?? false;
    if (!loaded) return const SectionLoading();

    final equipment = strList('equipment').toSet();
    final minutes = intOf('minutesPerDay');
    final level = data['level'] is String ? data['level']! as String : null;
    final days = intList('days').toSet();
    final dayLabels = weekdayShortLabels(l);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.qbTrainingIntro, style: SysText.secondary),
        SysFieldLabel(l.qbPlace),
        Row(
          children: [
            const SysIcon(SysGlyph.home, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(l.qbPlaceHome, style: SysText.body)),
          ],
        ),
        const SizedBox(height: 2),
        Text(l.qbPlaceHomeNote, style: SysText.caption),
        const SysFieldGap(),
        SysFieldLabel(l.qbEquipment),
        SysChoiceChips<String>(
          multi: true,
          choices: [for (final k in trainingEquipmentKeys) SysChoice(k, _equipmentLabel(l, k))],
          selected: equipment,
          onChanged: (s) => _setEquipment(s, equipment),
        ),
        const SizedBox(height: 8),
        SysTextField(
          value: str('equipmentOther'),
          label: l.qbEquipOther,
          onChanged: (v) => setValue('equipmentOther', v.trim().isEmpty ? null : v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbLevel),
        SysSegmented<String>(
          choices: [
            SysChoice('beginner', l.qbLevelBeginner),
            SysChoice('intermediate', l.qbLevelIntermediate),
            SysChoice('advanced', l.qbLevelAdvanced),
          ],
          value: level,
          onChanged: (v) => setValue('level', v),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbMinutesPerDay),
        SysChoiceChips<int>(
          choices: [for (final m in trainingMinutePresets) SysChoice(m, '$m')],
          selected: {if (minutes != null && trainingMinutePresets.contains(minutes)) minutes},
          onChanged: (s) => setValue('minutesPerDay', s.isEmpty ? null : s.first),
        ),
        const SizedBox(height: 8),
        SysNumberField(
          value: minutes,
          label: l.qbMinutesExact,
          unit: l.qbMinutesUnit,
          decimal: false,
          min: 1,
          max: 300,
          outOfRangeText: l.commonOutOfRange,
          onChanged: (v) => setValue('minutesPerDay', v?.round()),
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qbTrainingDays),
        SysChoiceChips<int>(
          multi: true,
          choices: [for (var d = 1; d <= 7; d++) SysChoice(d, dayLabels[d - 1])],
          selected: days,
          onChanged: (s) => setValue('days', (s.toList()..sort())),
        ),
      ],
    );
  }
}
