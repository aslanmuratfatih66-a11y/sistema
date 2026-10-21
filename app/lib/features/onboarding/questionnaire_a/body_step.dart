import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/profile_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'data/measurement_repository.dart';
import 'data/serial_writer.dart';
import 'widgets/option_list.dart';
import 'widgets/tip_line.dart';

/// Допустимые диапазоны (см, кг).
class BodyRanges {
  static const height = (120.0, 230.0);
  static const weight = (30.0, 300.0);
  static const waist = (40.0, 200.0);
  static const hips = (50.0, 200.0);
  static const chest = (50.0, 200.0);
  static const neck = (20.0, 70.0);
  static const arm = (15.0, 70.0);

  static bool ok(num? v, (double, double) r) => v != null && v >= r.$1 && v <= r.$2;
}

/// Этап 2 «Тело»: рост и вес (обязательно), обхваты (необязательно, свёрнуто — «если знаете»; иначе
/// Система оценит их по фото), активность, нагрузка.
class BodyStep extends ConsumerStatefulWidget {
  const BodyStep({super.key});

  @override
  ConsumerState<BodyStep> createState() => _BodyStepState();
}

class _BodyStepState extends ConsumerState<BodyStep> {
  final _writer = SerialWriter();
  bool _loaded = false;
  num? _height, _weight, _waist, _hips, _chest, _neck, _arm;
  ActivityLevel? _activity;
  Workload? _workload;

  /// Секция обхватов раскрыта (по умолчанию — только если что-то уже введено).
  bool _girthsOpen = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await ref.read(profileRepositoryProvider).get();
    final m = await ref.read(onboardingMeasurementRepositoryProvider).get();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _height = p?.heightCm;
      _activity = enumByName(ActivityLevel.values, p?.activityLevel);
      _workload = enumByName(Workload.values, p?.workload);
      _weight = m?.weightKg;
      _waist = m?.waistCm;
      _hips = m?.hipsCm;
      _chest = m?.chestCm;
      _neck = m?.neckCm;
      _arm = m?.armCm;
      _girthsOpen = [_waist, _hips, _chest, _neck, _arm].any((v) => v != null);
    });
  }

  void _saveProfile(ProfilesCompanion patch) => _writer.run(() => ref.read(profileRepositoryProvider).update(patch));

  void _saveMeasurement(BodyMeasurementsCompanion patch) =>
      _writer.run(() => ref.read(onboardingMeasurementRepositoryProvider).patch(patch));

  /// Значение для БД: в диапазоне — число, иначе null.
  static Value<double?> _v(num? v, (double, double) r) => Value(BodyRanges.ok(v, r) ? v!.toDouble() : null);

  Widget _number({
    required String label,
    required num? value,
    required String unit,
    required (double, double) range,
    required ValueChanged<num?> onChanged,
    bool optional = false,
  }) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysFieldLabel(label, optional: optional, optionalLabel: l.commonOptional),
        SysNumberField(
          value: value,
          unit: unit,
          min: range.$1,
          max: range.$2,
          outOfRangeText: l.qaRangeHint(range.$1.round(), range.$2.round()),
          onChanged: onChanged,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    scope?.setCanProceed(
      _loaded && BodyRanges.ok(_height, BodyRanges.height) && BodyRanges.ok(_weight, BodyRanges.weight),
    );
    if (!_loaded) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: SysColors.accent)),
      );
    }
    Widget pair(Widget a, Widget b) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: a),
        const SizedBox(width: 12),
        Expanded(child: b),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[Text(l.qaBodyIntro, style: SysText.secondary), const SysFieldGap()],
        pair(
          _number(
            label: l.qaBodyHeight,
            value: _height,
            unit: l.qaUnitCm,
            range: BodyRanges.height,
            onChanged: (v) {
              setState(() => _height = v);
              _saveProfile(ProfilesCompanion(heightCm: _v(v, BodyRanges.height)));
            },
          ),
          _number(
            label: l.qaBodyWeight,
            value: _weight,
            unit: l.qaUnitKg,
            range: BodyRanges.weight,
            onChanged: (v) {
              setState(() => _weight = v);
              _saveMeasurement(BodyMeasurementsCompanion(weightKg: _v(v, BodyRanges.weight)));
            },
          ),
        ),
        const SysFieldGap(),
        _GirthsSection(
          open: _girthsOpen,
          onToggle: () => setState(() => _girthsOpen = !_girthsOpen),
          children: [
            Text(l.qaBodyGirthsOptionalHint, style: SysText.caption),
            const SizedBox(height: 8),
            Text(l.qaBodyGirthsHowTitle.toUpperCase(), style: SysText.label),
            const SizedBox(height: 4),
            for (final t in [
              l.qaBodyGirthsHowGeneral,
              l.qaBodyWaistHow,
              l.qaBodyHipsHow,
              l.qaBodyChestHow,
              l.qaBodyNeckHow,
              l.qaBodyArmHow,
            ])
              TipLine(t),
            const SizedBox(height: 10),
            pair(
              _number(
                label: l.qaBodyWaist,
                value: _waist,
                unit: l.qaUnitCm,
                range: BodyRanges.waist,
                optional: true,
                onChanged: (v) {
                  setState(() => _waist = v);
                  _saveMeasurement(BodyMeasurementsCompanion(waistCm: _v(v, BodyRanges.waist)));
                },
              ),
              _number(
                label: l.qaBodyHips,
                value: _hips,
                unit: l.qaUnitCm,
                range: BodyRanges.hips,
                optional: true,
                onChanged: (v) {
                  setState(() => _hips = v);
                  _saveMeasurement(BodyMeasurementsCompanion(hipsCm: _v(v, BodyRanges.hips)));
                },
              ),
            ),
            const SysFieldGap(),
            pair(
              _number(
                label: l.qaBodyChest,
                value: _chest,
                unit: l.qaUnitCm,
                range: BodyRanges.chest,
                optional: true,
                onChanged: (v) {
                  setState(() => _chest = v);
                  _saveMeasurement(BodyMeasurementsCompanion(chestCm: _v(v, BodyRanges.chest)));
                },
              ),
              _number(
                label: l.qaBodyNeck,
                value: _neck,
                unit: l.qaUnitCm,
                range: BodyRanges.neck,
                optional: true,
                onChanged: (v) {
                  setState(() => _neck = v);
                  _saveMeasurement(BodyMeasurementsCompanion(neckCm: _v(v, BodyRanges.neck)));
                },
              ),
            ),
            const SysFieldGap(),
            pair(
              _number(
                label: l.qaBodyArm,
                value: _arm,
                unit: l.qaUnitCm,
                range: BodyRanges.arm,
                optional: true,
                onChanged: (v) {
                  setState(() => _arm = v);
                  _saveMeasurement(BodyMeasurementsCompanion(armCm: _v(v, BodyRanges.arm)));
                },
              ),
              const SizedBox.shrink(),
            ),
          ],
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaBodyActivity),
        OptionList<ActivityLevel>(
          value: _activity,
          items: [
            OptionItem(ActivityLevel.sedentary, l.qaActivitySedentary, l.qaActivitySedentaryHint),
            OptionItem(ActivityLevel.light, l.qaActivityLight, l.qaActivityLightHint),
            OptionItem(ActivityLevel.moderate, l.qaActivityModerate, l.qaActivityModerateHint),
            OptionItem(ActivityLevel.active, l.qaActivityActive, l.qaActivityActiveHint),
            OptionItem(ActivityLevel.veryActive, l.qaActivityVeryActive, l.qaActivityVeryActiveHint),
          ],
          onChanged: (v) {
            setState(() => _activity = v);
            _saveProfile(ProfilesCompanion(activityLevel: Value(v.name)));
          },
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaBodyWorkload, hint: l.qaBodyWorkloadHint),
        SysChoiceChips<Workload>(
          choices: [
            SysChoice(Workload.sitting, l.qaWorkloadSitting),
            SysChoice(Workload.mixed, l.qaWorkloadMixed),
            SysChoice(Workload.standing, l.qaWorkloadStanding),
            SysChoice(Workload.physical, l.qaWorkloadPhysical),
          ],
          selected: {?_workload},
          allowEmpty: false,
          onChanged: (s) {
            if (s.isEmpty) return;
            setState(() => _workload = s.first);
            _saveProfile(ProfilesCompanion(workload: Value(s.first.name)));
          },
        ),
      ],
    );
  }
}

/// Свёрнутая секция «Обхваты — если знаете».
class _GirthsSection extends StatelessWidget {
  const _GirthsSection({required this.open, required this.onToggle, required this.children});

  final bool open;
  final VoidCallback onToggle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      animateIn: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: InkWell(
              onTap: onToggle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: SysDims.minTap),
                child: Row(
                  children: [
                    Expanded(child: Text(l.qaBodyGirthsOptionalTitle.toUpperCase(), style: SysText.title)),
                    Text(l.commonOptional, style: SysText.caption),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: open ? .5 : 0,
                      duration: const Duration(milliseconds: 160),
                      child: const SysIcon(SysGlyph.arrowDown, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (open) ...[const SizedBox(height: 8), ...children],
        ],
      ),
    );
  }
}
