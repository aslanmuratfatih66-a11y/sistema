// Будильник-квест (SPEC §8.11): список будильников, разрешения, проверочный звонок.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/alarm/alarm_api.dart';
import '../../core/alarm/alarm_repository.dart';
import '../../core/alarm/channel_alarm_scheduler.dart';
import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'alarm_edit_screen.dart';
import 'alarm_texts.dart';

final _alarmsProvider = StreamProvider.autoDispose<List<AlarmRow>>((ref) => ref.watch(alarmRepositoryProvider).watchAll());

class AlarmsScreen extends ConsumerStatefulWidget {
  const AlarmsScreen({super.key});

  @override
  ConsumerState<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends ConsumerState<AlarmsScreen> with WidgetsBindingObserver {
  AlarmPermissionState? _perm;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_loadPerm());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Вернулись из системных настроек.
    if (state == AppLifecycleState.resumed) unawaited(_loadPerm());
  }

  Future<void> _loadPerm() async {
    final s = ref.read(alarmSchedulerProvider);
    final AlarmPermissionState p;
    if (s is AlarmRingControl) {
      p = await (s as AlarmRingControl).permissionState();
    } else {
      p = AlarmPermissionState(available: await s.isAvailable());
    }
    if (mounted) setState(() => _perm = p);
  }

  Future<void> _grant() async {
    final s = ref.read(alarmSchedulerProvider);
    await s.requestPermission();
    await _loadPerm();
    // AlarmKit мог стать доступен — перепланировать на нём.
    await s.sync(await ref.read(alarmRepositoryProvider).all());
  }

  Future<void> _test(AlarmRow a) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(alarmRepositoryProvider);
    final s = ref.read(alarmSchedulerProvider);
    if (!await s.isAvailable()) await s.requestPermission();
    await repo.setOneShot(a.id, DateTime.now().add(const Duration(minutes: 1)), test: true);
    await s.sync(await repo.all());
    messenger.showSnackBar(SnackBar(content: Text(l.almTestScheduled)));
  }

  void _open([AlarmRow? a]) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => AlarmEditScreen(alarm: a)));

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final alarms = ref.watch(_alarmsProvider);
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
                  Expanded(child: Text(l.almTitle.toUpperCase(), style: SysText.heading)),
                ],
              ),
              const SizedBox(height: 8),
              _PermissionPanel(state: _perm, onGrant: _grant),
              const SizedBox(height: 16),
              ...alarms.when(
                data: (list) => [
                  if (list.isEmpty)
                    SysPanel(child: SysEmptyState(title: l.almTitle, hint: l.almEmpty, glyph: SysGlyph.clock))
                  else
                    for (final a in list) ...[
                      _AlarmTile(
                        alarm: a,
                        onTap: () => _open(a),
                        onToggle: a.fromDiscipline
                            ? null
                            : (v) => ref.read(alarmRepositoryProvider).setEnabled(a, v),
                        onTest: () => _test(a),
                      ),
                      const SizedBox(height: 12),
                    ],
                ],
                loading: () => const [SysSkeletonPanel(lines: 2)],
                error: (e, _) => [SysErrorState(message: '$e')],
              ),
              const SizedBox(height: 8),
              SysButton.primary(label: l.almAdd, icon: SysGlyph.plus, expand: true, onPressed: () => _open()),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionPanel extends StatelessWidget {
  const _PermissionPanel({required this.state, required this.onGrant});

  final AlarmPermissionState? state;
  final VoidCallback onGrant;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = state;
    if (s == null) return const SizedBox.shrink();
    Widget row(String label, bool? ok) => ok == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                SysIcon(ok ? SysGlyph.check : SysGlyph.warning,
                    size: 16, color: ok ? SysColors.energy : SysColors.calories),
                const SizedBox(width: 8),
                Expanded(child: Text(label, style: SysText.body)),
                Text(ok ? l.almPermOn : l.almPermOff, style: SysText.caption),
              ],
            ),
          );
    final ios = s.alarmKit != null;
    final allOk = s.available && (s.notifications ?? true);
    return SysPanel(
      title: l.almPermTitle,
      tone: allOk ? PanelTone.success : PanelTone.gold,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (allOk) Text(l.almPermReady, style: SysText.secondary),
          if (ios) row(l.almPermAlarmKit, s.alarmKit == 'authorized'),
          row(l.almPermExact, s.exactAlarms),
          row(l.almPermFullScreen, s.fullScreen),
          row(l.almPermNotifications, s.notifications),
          if (ios) ...[
            const SizedBox(height: 10),
            Text(s.usesFallback ? l.almPermFallback : l.almPermBackup, style: SysText.caption),
          ],
          if ((!allOk && s.alarmKit != 'unsupported') || s.notifications == false) ...[
            const SizedBox(height: 12),
            SysButton.secondary(label: l.almPermGrant, expand: true, onPressed: onGrant),
          ],
        ],
      ),
    );
  }
}

class _AlarmTile extends StatelessWidget {
  const _AlarmTile({required this.alarm, required this.onTap, required this.onToggle, required this.onTest});

  final AlarmRow alarm;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggle;
  final VoidCallback onTest;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = alarm;
    final label = a.label?.trim();
    return SysPressable(
      onTap: onTap,
      child: SysPanel(
        tone: a.fromDiscipline ? PanelTone.boss : PanelTone.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatMinuteOfDay(a.minute),
                        style: SysText.monoLarge.copyWith(color: a.enabled ? null : SysColors.textInactive),
                      ),
                      const SizedBox(height: 2),
                      Text(almDaysText(l, a.weekdays), style: SysText.caption),
                    ],
                  ),
                ),
                Switch(value: a.enabled, onChanged: onToggle),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                SysPill(label: almTaskText(l, a), icon: SysGlyph.dumbbell),
                if (a.fromDiscipline) SysPill(label: l.almDiscipline, tone: PanelTone.boss, icon: SysGlyph.shield),
                if (label != null && label.isNotEmpty) SysPill(label: label, tone: PanelTone.gold),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: SysButton.secondary(label: l.almTest, icon: SysGlyph.bell, onPressed: onTest),
            ),
          ],
        ),
      ),
    );
  }
}
