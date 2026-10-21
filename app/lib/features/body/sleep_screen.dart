// Сон (SPEC §8.3): история за 14 дней (график), сравнение с целью плана, запись «лёг/встал» и качества.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/daily.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/sleep_repository.dart';
import 'domain/sleep_math.dart';
import 'widgets/body_common.dart';

const _historyDays = 14;

class SleepScreen extends ConsumerWidget {
  const SleepScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SleepScreen()));

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final target = ref.watch(sleepTargetProvider);
    final nights = ref.watch(sleepHistoryProvider(_historyDays)).value ?? const <SleepDay>[];
    final today = dayOf(ref.watch(bodyClockProvider)());
    final firstDay = DateTime(today.year, today.month, today.day - _historyDays + 1);
    final byDay = {for (final n in nights) n.day: n};
    final hours = [
      for (var i = 0; i < _historyDays; i++) byDay[DateTime(firstDay.year, firstDay.month, firstDay.day + i)]?.duration.inMinutes.toDouble(),
    ].map((m) => m == null ? null : m / 60).toList();
    final stats = SleepStats.of(nights, targetMinutes: target.targetMinutes);
    final avg = stats.averageMinutes;

    return ScheduleSubPage(
      title: l.bdySleepTitle,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: SysButton.primary(
        key: const Key('bdy-sleep-log'),
        label: l.bdySleepLog,
        icon: SysGlyph.moon,
        expand: true,
        onPressed: () => SleepEditScreen.open(context, today),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.bdySleepHistory(_historyDays),
            animateIn: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                BodyInfoRow(label: l.bdySleepTarget, value: formatDuration(l, target.targetMinutes), valueColor: SysColors.gold),
                BodyInfoRow(
                  label: l.bdySleepAverage,
                  value: avg == null ? '—' : formatDuration(l, avg),
                  valueColor: avg != null && avg >= target.targetMinutes ? SysColors.energy : SysColors.textPrimary,
                ),
                if (avg != null)
                  BodyInfoRow(
                    label: l.bdySleepVsTarget,
                    value: '${avg - target.targetMinutes >= 0 ? '+' : '−'}${formatDuration(l, (avg - target.targetMinutes).abs())}',
                    valueColor: avg >= target.targetMinutes ? SysColors.energy : SysColors.dangerLight,
                  ),
                BodyInfoRow(label: l.bdySleepOnTarget, value: '${stats.nightsOnTarget}/${stats.nights}'),
                const SizedBox(height: 12),
                if (stats.nights == 0)
                  Text(l.bdySleepEmpty, style: SysText.secondary)
                else
                  SleepBarChart(
                    firstDay: firstDay,
                    hours: hours,
                    targetHours: target.targetMinutes / 60,
                    semanticLabel: l.bdySleepChartLabel,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          for (final n in nights.reversed) _NightRow(night: n, targetMinutes: target.targetMinutes),
        ],
      ),
    );
  }
}

class _NightRow extends StatelessWidget {
  const _NightRow({required this.night, required this.targetMinutes});

  final SleepDay night;
  final int targetMinutes;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = night.quality;
    final ok = night.duration.inMinutes >= targetMinutes;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () => SleepEditScreen.open(context, night.day),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: SysDims.minTap),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(width: 52, child: Text(formatDayMonth(night.day), style: SysText.mono)),
                Expanded(
                  child: Text(
                    '${formatMinuteOfDay(minuteOfDay(night.bedAt))} → ${formatMinuteOfDay(minuteOfDay(night.wakeAt))}',
                    style: SysText.secondary,
                  ),
                ),
                if (q != null) ...[Text(l.bdySleepQualityShort(q), style: SysText.caption), const SizedBox(width: 10)],
                Text(formatSleep(l, night.duration), style: SysText.mono.copyWith(color: ok ? SysColors.energy : SysColors.textPrimary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Запись ночи: день подъёма, «лёг/встал» (по умолчанию — из расписания или прежней записи), качество 1–5.
class SleepEditScreen extends ConsumerStatefulWidget {
  const SleepEditScreen({super.key, required this.wakeDay});

  final DateTime wakeDay;

  static Future<void> open(BuildContext context, DateTime wakeDay) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => SleepEditScreen(wakeDay: dayOf(wakeDay))));

  @override
  ConsumerState<SleepEditScreen> createState() => _SleepEditScreenState();
}

class _SleepEditScreenState extends ConsumerState<SleepEditScreen> {
  late DateTime _day = widget.wakeDay;
  int? _bed;
  int? _wake;
  int? _quality;
  bool _loaded = false;
  bool _exists = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final existing = await ref.read(sleepRepositoryProvider).getDay(_day);
    if (!mounted) return;
    final target = ref.read(sleepTargetProvider);
    setState(() {
      _loaded = true;
      _exists = existing != null;
      _bed = existing == null ? target.bedMinute : minuteOfDay(existing.bedAt);
      _wake = existing == null ? target.wakeMinute : minuteOfDay(existing.wakeAt);
      _quality = existing?.quality;
    });
  }

  int get _minutes => sleepMinutesBetween(_bed ?? 0, _wake ?? 0);

  Future<void> _save() async {
    if (_busy || _minutes <= 0) return;
    setState(() => _busy = true);
    final w = sleepWindow(_day, bedMinute: _bed!, wakeMinute: _wake!);
    try {
      await logSleep(ref, bedAt: w.bedAt, wakeAt: w.wakeAt, quality: _quality);
      if (mounted) Navigator.of(context).maybePop();
    } on ArgumentError {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete() async {
    await ref.read(sleepRepositoryProvider).deleteDay(_day);
    if (mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final today = dayOf(ref.watch(bodyClockProvider)());
    final minutes = _minutes;
    final target = ref.watch(sleepTargetProvider);
    return ScheduleSubPage(
      title: l.bdySleepLog,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: SysButton.primary(
        key: const Key('bdy-sleep-save'),
        label: l.commonSave,
        expand: true,
        onPressed: _loaded && !_busy && minutes > 0 ? _save : null,
      ),
      child: !_loaded
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysDateField(
                  label: l.bdySleepWakeDay,
                  date: _day,
                  firstDate: DateTime(today.year - 1, today.month, today.day),
                  lastDate: today,
                  onChanged: (d) {
                    setState(() => _day = dayOf(d));
                    _load();
                  },
                ),
                const SysFieldGap(),
                Row(
                  children: [
                    Expanded(
                      child: SysTimeField(label: l.bdySleepBed, minute: _bed, onChanged: (m) => setState(() => _bed = m)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SysTimeField(label: l.bdySleepWake, minute: _wake, onChanged: (m) => setState(() => _wake = m)),
                    ),
                  ],
                ),
                const SysFieldGap(),
                BodyInfoRow(
                  label: l.bdySleepDuration,
                  value: minutes <= 0 ? '—' : formatDuration(l, minutes),
                  valueColor: minutes >= target.targetMinutes ? SysColors.energy : SysColors.textPrimary,
                ),
                BodyInfoRow(label: l.bdySleepTarget, value: formatDuration(l, target.targetMinutes), valueColor: SysColors.gold),
                const SysFieldGap(),
                SysFieldLabel(l.bdySleepQuality, hint: l.bdySleepQualityHint, optional: true, optionalLabel: l.commonOptional),
                SysSegmented<int>(
                  choices: [for (var q = 1; q <= 5; q++) SysChoice(q, '$q')],
                  value: _quality,
                  onChanged: (q) => setState(() => _quality = _quality == q ? null : q),
                ),
                if (_exists) ...[
                  const SysFieldGap(),
                  SysButton.secondary(label: l.commonDelete, onPressed: _delete, expand: true),
                ],
              ],
            ),
    );
  }
}
