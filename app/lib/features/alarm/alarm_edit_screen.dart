// Добавление / правка будильника: время, дни, задание (приседания или QR в другой комнате).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/alarm/alarm_api.dart';
import '../../core/alarm/alarm_repository.dart';
import '../../core/alarm/alarm_schedule.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'alarm_qr.dart';
import 'alarm_texts.dart';

class AlarmEditScreen extends ConsumerStatefulWidget {
  const AlarmEditScreen({super.key, this.alarm});

  /// null — новый будильник.
  final AlarmRow? alarm;

  @override
  ConsumerState<AlarmEditScreen> createState() => _AlarmEditScreenState();
}

class _AlarmEditScreenState extends ConsumerState<AlarmEditScreen> {
  late int _minute;
  late int _weekdays;
  late String _label;
  late AlarmTask _task;
  late int _squats;
  String? _qr;
  bool _saving = false;

  bool get _discipline => widget.alarm?.fromDiscipline ?? false;

  @override
  void initState() {
    super.initState();
    final a = widget.alarm;
    _minute = a?.minute ?? 6 * 60;
    _weekdays = a?.weekdays ?? alarmAllDays;
    _label = a?.label ?? '';
    _task = a == null ? AlarmTask.squats : almTaskOf(a);
    _squats = a?.squats ?? 15;
    _qr = a?.qrCode;
  }

  void _setTask(AlarmTask t) => setState(() {
        _task = t;
        if (t == AlarmTask.qr) _qr ??= AlarmRepository.newQrCode();
      });

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final a = widget.alarm;
    final repo = ref.read(alarmRepositoryProvider);
    try {
      await repo.save(
        id: a?.id,
        minute: _minute,
        weekdays: _weekdays,
        label: _label.trim().isEmpty ? null : _label.trim(),
        task: _task,
        squats: _squats,
        qrCode: _task == AlarmTask.qr ? _qr : a?.qrCode,
        enabled: a?.enabled ?? true,
      );
      // Новый будильник — сразу спросить разрешения (если ещё нет).
      if (a == null) {
        final s = ref.read(alarmSchedulerProvider);
        if (!await s.isAvailable()) await s.requestPermission();
      }
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    final a = widget.alarm;
    if (a == null) return;
    final l = AppLocalizations.of(context);
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        kind: SystemWindowKind.warning,
        label: l.almEditTitle,
        message: l.almDeleteConfirm,
        actions: [
          Builder(builder: (c) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false))),
          Builder(builder: (c) => SysButton.danger(label: l.commonDelete, onPressed: () => Navigator.of(c).pop(true))),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(alarmRepositoryProvider).delete(a);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final names = almDayNames(l);
    final days = {
      for (var d = 1; d <= 7; d++)
        if (_weekdays & alarmWeekdayBit(d) != 0) d,
    };
    final qr = _qr;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  const SysBackButton(),
                  Expanded(
                    child: Text((widget.alarm == null ? l.almNew : l.almEditTitle).toUpperCase(), style: SysText.heading),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SysPanel(
                title: l.almTime,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_discipline) ...[
                      Text(l.almDisciplineHint, style: SysText.secondary),
                      const SizedBox(height: 10),
                      Text(formatMinuteOfDay(_minute), style: SysText.monoLarge),
                      const SizedBox(height: 4),
                      Text(almDaysText(l, _weekdays), style: SysText.caption),
                    ] else ...[
                      SysTimeField(minute: _minute, label: l.almTime, onChanged: (m) => setState(() => _minute = m)),
                      const SysFieldGap(),
                      SysFieldLabel(l.almDays, hint: _weekdays == 0 ? l.almDaysHint : null),
                      SysChoiceChips<int>(
                        multi: true,
                        choices: [for (var d = 1; d <= 7; d++) SysChoice(d, names[d - 1])],
                        selected: days,
                        onChanged: (s) => setState(() {
                          _weekdays = s.fold(0, (m, d) => m | alarmWeekdayBit(d));
                        }),
                      ),
                      const SysFieldGap(),
                      SysTextField(
                        value: _label,
                        label: l.almLabel,
                        onChanged: (v) => _label = v,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SysPanel(
                title: l.almTask,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SysChoiceChips<AlarmTask>(
                      allowEmpty: false,
                      choices: [
                        SysChoice(AlarmTask.squats, l.almTaskSquats, glyph: SysGlyph.dumbbell),
                        SysChoice(AlarmTask.qr, l.almTaskQr, glyph: SysGlyph.shield),
                      ],
                      selected: {_task},
                      onChanged: (s) {
                        if (s.isNotEmpty) _setTask(s.first);
                      },
                    ),
                    const SysFieldGap(),
                    if (_task == AlarmTask.squats)
                      SysNumberField(
                        value: _squats,
                        label: l.almSquatsCount,
                        decimal: false,
                        min: 5,
                        max: 100,
                        onChanged: (v) {
                          final n = v?.round();
                          if (n != null && n >= 5 && n <= 100) setState(() => _squats = n);
                        },
                      )
                    else if (qr != null) ...[
                      Text(l.almQrHint, style: SysText.secondary),
                      const SizedBox(height: 12),
                      Center(child: AlarmQrView(code: qr)),
                      const SizedBox(height: 6),
                      Center(child: Text(qr, style: SysText.monoSmall)),
                      const SizedBox(height: 12),
                      Builder(
                        builder: (c) => SysButton.secondary(
                          label: l.almQrShare,
                          icon: SysGlyph.send,
                          expand: true,
                          onPressed: () {
                            final box = c.findRenderObject() as RenderBox?;
                            final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
                            shareAlarmQr(c, qr, origin: origin);
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                      SysButton.secondary(
                        label: l.almQrRegenerate,
                        expand: true,
                        onPressed: () => setState(() => _qr = AlarmRepository.newQrCode()),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SysButton.primary(label: l.commonSave, expand: true, onPressed: _saving ? null : _save),
              if (widget.alarm != null && !_discipline) ...[
                const SizedBox(height: 10),
                SysButton.danger(label: l.commonDelete, expand: true, onPressed: _delete),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
