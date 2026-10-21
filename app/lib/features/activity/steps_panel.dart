// Панель шагов (SPEC §8.3): шаги/дистанция/этажи за сегодня, прогресс к цели, доступ к счётчику,
// ручной ввод, мини-график за 7 дней. Встраивается в экраны главным агентом.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/activity/activity_api.dart';
import '../../core/activity/activity_providers.dart';
import '../../core/activity/step_repository.dart';
import '../../core/models/daily.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'steps_week_chart.dart';

class StepsPanel extends ConsumerStatefulWidget {
  const StepsPanel({super.key, this.goal = kDefaultStepGoal, this.animateIn = true});

  final int goal;
  final bool animateIn;

  @override
  ConsumerState<StepsPanel> createState() => _StepsPanelState();
}

class _StepsPanelState extends ConsumerState<StepsPanel> {
  bool _manualOpen = false;
  bool _busy = false;
  num? _manualValue;

  static const _manualMax = 100000;

  Future<void> _requestPermission() async {
    setState(() => _busy = true);
    try {
      await ref.read(stepCounterProvider).requestPermission();
    } finally {
      ref.invalidate(stepAccessProvider);
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveManual() async {
    final v = _manualValue;
    if (v == null || v < 0 || v > _manualMax) return;
    setState(() => _busy = true);
    try {
      await ref.read(stepSyncProvider).saveManual(v.round());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _manualOpen = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final today = localDay(ref.watch(activityClockProvider)());
    final day = ref.watch(stepsDayProvider(today)).value;
    final access = ref.watch(stepAccessProvider).value;
    final history = ref.watch(stepsHistoryProvider(7)).value;
    final nf = NumberFormat.decimalPattern(l10n.localeName);

    final steps = day?.steps ?? 0;
    final progress = widget.goal <= 0 ? 0.0 : (steps / widget.goal).clamp(0.0, 1.0);
    final stepsText = nf.format(steps);
    final goalText = nf.format(widget.goal);

    return SysPanel(
      title: l10n.actStepsTitle,
      animateIn: widget.animateIn,
      trailing: Text('${(progress * 100).round()}%', style: SysText.monoSmall),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              ProgressRing(
                progress: progress,
                size: 76,
                color: SysColors.energy,
                semanticLabel: l10n.actStepsSemantic(stepsText, goalText),
                center: const SysIcon(SysGlyph.walk, size: 24, color: SysColors.energy),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stepsText, key: const Key('act-steps'), style: SysText.monoLarge),
                    const SizedBox(height: 2),
                    Text(l10n.actGoal(goalText), style: SysText.caption),
                    const SizedBox(height: 8),
                    _Metric(
                      label: l10n.actDistance,
                      value: day?.distanceM == null
                          ? l10n.actNoValue
                          : l10n.actDistanceKm(_km(day!.distanceM!, l10n.localeName)),
                    ),
                    _Metric(
                      label: l10n.actFloors,
                      value: day?.floors == null ? l10n.actNoValue : nf.format(day!.floors),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (history != null && history.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(l10n.actWeek.toUpperCase(), style: SysText.caption),
            const SizedBox(height: 4),
            StepsWeekChart(days: history, goal: widget.goal),
          ],
          ..._access(l10n, access, day),
        ],
      ),
    );
  }

  List<Widget> _access(AppLocalizations l10n, StepAccess? access, StepDay? day) {
    if (access == null || access == StepAccess.granted) return const [];
    final out = <Widget>[
      const SizedBox(height: 12),
      Text(
        access == StepAccess.needsPermission ? l10n.actPermissionHint : l10n.actUnavailableHint,
        style: SysText.secondary,
      ),
      const SizedBox(height: 8),
    ];
    if (_manualOpen) {
      final v = _manualValue;
      final valid = v != null && v >= 0 && v <= _manualMax;
      out.addAll([
        SysNumberField(
          key: const Key('act-manual-field'),
          value: _manualValue,
          decimal: false,
          min: 0,
          max: _manualMax,
          label: l10n.actManualLabel,
          outOfRangeText: l10n.actManualRange,
          onChanged: (v) => setState(() => _manualValue = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: SysButton.secondary(
                key: const Key('act-manual-cancel'),
                label: l10n.actCancel,
                expand: true,
                onPressed: _busy ? null : () => setState(() => _manualOpen = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SysButton.primary(
                key: const Key('act-manual-save'),
                label: l10n.actSave,
                expand: true,
                onPressed: _busy || !valid ? null : _saveManual,
              ),
            ),
          ],
        ),
      ]);
      return out;
    }
    out.add(Row(
      children: [
        if (access == StepAccess.needsPermission) ...[
          Expanded(
            child: SysButton.primary(
              key: const Key('act-allow'),
              label: l10n.actAllow,
              expand: true,
              onPressed: _busy ? null : _requestPermission,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: SysButton.secondary(
            key: const Key('act-manual'),
            label: l10n.actManual,
            icon: SysGlyph.plus,
            expand: true,
            onPressed: _busy
                ? null
                : () => setState(() {
                      _manualOpen = true;
                      _manualValue = day?.steps;
                    }),
          ),
        ),
      ],
    ));
    return out;
  }

  static String _km(double meters, String locale) =>
      NumberFormat('0.0#', locale).format(meters / 1000);
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          children: [
            Expanded(child: Text(label, style: SysText.secondary, maxLines: 1, overflow: TextOverflow.ellipsis)),
            Text(value, style: SysText.mono),
          ],
        ),
      );
}
