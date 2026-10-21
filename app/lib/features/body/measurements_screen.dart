// Замеры (SPEC §8.3): график показателя за период, изменение, список замеров, добавление.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart' show BodyMeasurementRow;
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/measurement_repository.dart';
import 'data/sleep_repository.dart' show bodyClockProvider;
import 'widgets/body_common.dart';

String measureLabel(AppLocalizations l, MeasureField f) => switch (f) {
      MeasureField.weight => l.bdyMeasureWeight,
      MeasureField.waist => l.bdyMeasureWaist,
      MeasureField.hips => l.bdyMeasureHips,
      MeasureField.chest => l.bdyMeasureChest,
      MeasureField.neck => l.bdyMeasureNeck,
      MeasureField.arm => l.bdyMeasureArm,
      MeasureField.bodyFat => l.bdyMeasureBodyFat,
    };

String measureUnit(AppLocalizations l, MeasureField f) => switch (f) {
      MeasureField.weight => l.bdyUnitKg,
      MeasureField.bodyFat => '%',
      _ => l.bdyUnitCm,
    };

/// Период графика, дней (null — всё время).
const _periods = <int?>[30, 90, null];

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MeasurementsScreen()));

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen> {
  MeasureField _field = MeasureField.weight;
  int? _period = 30;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(bodyMeasurementsProvider).value ?? const <BodyMeasurementRow>[];
    final now = ref.watch(bodyClockProvider)();
    final p = _period;
    final since = p == null ? null : now.subtract(Duration(days: p));
    final series = measureSeries(rows, _field, since: since);
    final change = measureChange(rows, _field, since: since);
    final unit = measureUnit(l, _field);
    final available = {for (final f in MeasureField.values) if (rows.any((r) => f.of(r) != null)) f};

    return ScheduleSubPage(
      title: l.bdyMeasureTitle,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: SysButton.primary(
        key: const Key('bdy-measure-add'),
        label: l.bdyMeasureAdd,
        icon: SysGlyph.plus,
        expand: true,
        onPressed: () => MeasurementEditScreen.open(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysChoiceChips<MeasureField>(
            choices: [
              for (final f in MeasureField.values)
                if (available.contains(f) || f == MeasureField.weight) SysChoice(f, measureLabel(l, f)),
            ],
            selected: {_field},
            multi: false,
            onChanged: (s) => setState(() => _field = s.isEmpty ? _field : s.first),
          ),
          const SizedBox(height: 10),
          SysSegmented<int?>(
            choices: [for (final d in _periods) SysChoice(d, d == null ? l.bdyPeriodAll : l.bdyPeriodDays(d))],
            value: _period,
            onChanged: (v) => setState(() => _period = v),
          ),
          const SizedBox(height: 12),
          SysPanel(
            title: measureLabel(l, _field),
            animateIn: false,
            trailing: change == null
                ? null
                : Text(
                    '${formatDelta(change)} $unit',
                    style: SysText.mono.copyWith(color: change <= 0 ? SysColors.energy : SysColors.gold),
                  ),
            child: series.length < 2
                ? Text(series.isEmpty ? l.bdyMeasureEmpty : l.bdyMeasureNeedTwo, style: SysText.secondary)
                : BodyLineChart(
                    points: series,
                    color: _field == MeasureField.weight ? SysColors.calories : SysColors.accent,
                    semanticLabel: l.bdyMeasureChartLabel(measureLabel(l, _field)),
                  ),
          ),
          const SizedBox(height: 14),
          for (final r in rows.reversed) _MeasurementTile(row: r),
        ],
      ),
    );
  }
}

class _MeasurementTile extends ConsumerWidget {
  const _MeasurementTile({required this.row});

  final BodyMeasurementRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final estimate = row.source == MeasurementSource.aiEstimate.name;
    final parts = [
      for (final f in MeasureField.values)
        if (f.of(row) case final v?) '${measureLabel(l, f)} ${estimate ? '≈' : ''}${formatNum(v)} ${measureUnit(l, f)}',
    ];
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 92, child: Text(formatDate(row.measuredAt.toLocal()), style: SysText.mono)),
          Expanded(child: Text(parts.join(' · '), style: SysText.secondary)),
          IconButton(
            tooltip: l.commonDelete,
            constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
            onPressed: () => ref.read(bodyMeasurementRepositoryProvider).softDelete(row.id),
            icon: const SysIcon(SysGlyph.close, size: 16, color: SysColors.textInactive),
          ),
        ],
      ),
    );
  }
}

/// Новый замер: все поля необязательны, хотя бы одно — нужно.
class MeasurementEditScreen extends ConsumerStatefulWidget {
  const MeasurementEditScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const MeasurementEditScreen()));

  @override
  ConsumerState<MeasurementEditScreen> createState() => _MeasurementEditScreenState();
}

class _MeasurementEditScreenState extends ConsumerState<MeasurementEditScreen> {
  final Map<MeasureField, double?> _values = {};
  bool _busy = false;

  MeasurementInput get _input => MeasurementInput(Map.of(_values));

  Future<void> _save() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await ref.read(bodyMeasurementRepositoryProvider).add(_input);
      if (mounted) Navigator.of(context).maybePop();
    } on ArgumentError {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final input = _input;
    final valid = !input.isEmpty && input.invalidField == null;
    return ScheduleSubPage(
      title: l.bdyMeasureAdd,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: SysButton.primary(
        key: const Key('bdy-measure-save'),
        label: l.commonSave,
        expand: true,
        onPressed: valid && !_busy ? _save : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.bdyMeasureHint, style: SysText.secondary),
          const SysFieldGap(),
          for (final f in MeasureField.values) ...[
            SysNumberField(
              key: Key('bdy-measure-${f.name}'),
              label: measureLabel(l, f),
              unit: measureUnit(l, f),
              value: _values[f],
              min: f.range.$1,
              max: f.range.$2,
              outOfRangeText: l.commonOutOfRange,
              onChanged: (v) => setState(() => _values[f] = v?.toDouble()),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
