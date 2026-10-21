// Настройки напоминаний (SPEC §7): включено, «надоедать», тихие часы, упрёки, голос, разрешение, проверка.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/notifications/local_reminder_scheduler.dart' show ReminderPermissionProbe, ReminderPermissionState;
import '../../core/notifications/notification_api.dart';
import '../../core/notifications/reminder_prefs_repository.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../schedule/widgets/schedule_common.dart' show ScheduleSubPage;

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  ReminderPermissionState? _perm;
  bool _permLoaded = false;
  bool _testSent = false;

  @override
  void initState() {
    super.initState();
    _loadPermission();
  }

  void _back() => context.canPop() ? context.pop() : context.go(Routes.more);

  /// Планировщик подключается в main; в предпросмотре/тестах его может не быть.
  ReminderScheduler? get _scheduler {
    try {
      return ref.read(reminderSchedulerProvider);
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadPermission() async {
    final s = _scheduler;
    ReminderPermissionState? perm;
    if (s case final ReminderPermissionProbe probe) {
      try {
        perm = await probe.permissionState();
      } catch (_) {
        perm = null;
      }
    }
    if (!mounted) return;
    setState(() {
      _perm = perm;
      _permLoaded = true;
    });
  }

  Future<void> _requestPermission() async {
    final s = _scheduler;
    if (s == null) return;
    try {
      await s.requestPermission();
    } catch (_) {
      // статус перечитаем ниже
    }
    await _loadPermission();
  }

  Future<void> _test(AppLocalizations l) async {
    final s = _scheduler;
    if (s == null) return;
    try {
      await s.showNow(title: l.ntfTestTitle, body: l.ntfTestBody);
      if (mounted) setState(() => _testSent = true);
    } catch (_) {
      await _loadPermission();
    }
  }

  void _save(ReminderPrefs p) => ref.read(reminderPrefsRepositoryProvider).save(p);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final prefs = ref.watch(reminderPrefsProvider).value;
    return ScheduleSubPage(
      title: l.setReminders,
      onBack: _back,
      child: prefs == null
          ? const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(color: SysColors.accentLight)),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _generalPanel(l, prefs),
                const SizedBox(height: 16),
                _quietPanel(l, prefs),
                const SizedBox(height: 16),
                _permissionPanel(l),
              ],
            ),
    );
  }

  Widget _generalPanel(AppLocalizations l, ReminderPrefs p) => SysPanel(
        title: l.ntfSectionGeneral,
        child: Column(
          children: [
            SysSwitchRow(
              label: l.ntfEnabled,
              hint: l.ntfEnabledHint,
              value: p.enabled,
              onChanged: (v) => _save(copyReminderPrefs(p, enabled: v)),
            ),
            SysSwitchRow(
              label: l.ntfNag,
              hint: l.ntfNagHint,
              value: p.nag,
              onChanged: (v) => _save(copyReminderPrefs(p, nag: v)),
            ),
            SysSwitchRow(
              label: l.ntfReproach,
              hint: l.ntfReproachHint,
              value: p.reproach,
              onChanged: (v) => _save(copyReminderPrefs(p, reproach: v)),
            ),
            SysSwitchRow(
              label: l.ntfVoice,
              hint: l.ntfVoiceHint,
              value: p.voiceSound,
              onChanged: (v) => _save(copyReminderPrefs(p, voiceSound: v)),
            ),
          ],
        ),
      );

  Widget _quietPanel(AppLocalizations l, ReminderPrefs p) {
    final q = p.quiet;
    return SysPanel(
      title: l.ntfSectionQuiet,
      appearDelay: const Duration(milliseconds: 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSwitchRow(
            label: l.ntfQuietEnabled,
            hint: l.ntfQuietHint,
            value: q != null,
            onChanged: (v) => _save(v
                ? copyReminderPrefs(p, quiet: defaultQuietHours)
                : copyReminderPrefs(p, clearQuiet: true)),
          ),
          if (q != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SysTimeField(
                    label: l.ntfQuietFrom,
                    minute: q.startMinute,
                    onChanged: (m) =>
                        _save(copyReminderPrefs(p, quiet: QuietHours(startMinute: m, endMinute: q.endMinute))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SysTimeField(
                    label: l.ntfQuietTo,
                    minute: q.endMinute,
                    onChanged: (m) =>
                        _save(copyReminderPrefs(p, quiet: QuietHours(startMinute: q.startMinute, endMinute: m))),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _permissionPanel(AppLocalizations l) {
    final s = _scheduler;
    final perm = _perm;
    final granted = perm?.notifications;
    final (glyph, color, text) = switch ((s, granted)) {
      (null, _) => (SysGlyph.info, SysColors.textCaption, l.ntfUnavailable),
      (_, true) => (SysGlyph.check, SysColors.success, l.ntfPermGranted),
      (_, false) => (SysGlyph.warning, SysColors.danger, l.ntfPermDenied),
      _ => (SysGlyph.info, SysColors.textCaption, l.ntfPermUnknown),
    };
    return SysPanel(
      title: l.ntfSectionPermission,
      appearDelay: const Duration(milliseconds: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_permLoaded)
            Row(
              children: [
                SysIcon(glyph, size: 20, color: color),
                const SizedBox(width: 10),
                Expanded(child: Text(text, style: SysText.body)),
              ],
            ),
          if (perm?.exactAlarms == false) ...[
            const SizedBox(height: 8),
            Text(l.ntfPermExactOff, style: SysText.caption),
          ],
          if (s != null) ...[
            if (granted != true || perm?.exactAlarms == false) ...[
              const SizedBox(height: 12),
              SysButton.secondary(label: l.ntfPermRequest, icon: SysGlyph.bell, expand: true, onPressed: _requestPermission),
            ],
            const SizedBox(height: 12),
            SysButton.primary(label: l.ntfTest, icon: SysGlyph.send, expand: true, onPressed: () => _test(l)),
            if (_testSent) ...[
              const SizedBox(height: 8),
              Text(l.ntfTestSent, style: SysText.caption, textAlign: TextAlign.center),
            ],
          ],
        ],
      ),
    );
  }
}
