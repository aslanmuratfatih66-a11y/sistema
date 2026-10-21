import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/capabilities/capability_service.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'common/section_state.dart';
import 'permissions/permission_gateway.dart';

/// Этап 12 — разрешения, по одному, с объяснением (раздел permissions).
/// Значения: 'granted' | 'denied' | 'skipped' | 'unavailable'. Шаг необязательный.
class PermissionsStep extends ConsumerStatefulWidget {
  const PermissionsStep({super.key});

  @override
  ConsumerState<PermissionsStep> createState() => _PermissionsStepState();
}

/// Как показывать разрешение на этой платформе.
enum _Support { requestable, infoOnly, hidden }

class _PermissionsStepState extends SectionStepState<PermissionsStep> with WidgetsBindingObserver {
  @override
  QuestionnaireSection get section => QuestionnaireSection.permissions;

  final Set<AppPermission> _permanentlyDenied = {};
  AppPermission? _busy;
  bool _checkStarted = false;
  DeviceCapabilities? _caps;

  static const _fallbackCaps = DeviceCapabilities(platform: 'other', available: {});

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Вернулись из системных настроек — перепроверить статусы.
    final caps = _caps;
    if (state == AppLifecycleState.resumed && loaded && caps != null) _recheck(caps);
  }

  static _Support _support(AppPermission p, DeviceCapabilities caps) {
    if (kIsWeb) return _Support.hidden;
    return switch (p) {
      AppPermission.notifications => caps.has(Capability.localNotifications) ? _Support.requestable : _Support.hidden,
      AppPermission.motion => caps.has(Capability.motionSteps) ? _Support.requestable : _Support.hidden,
      AppPermission.locationAlways => caps.has(Capability.backgroundLocation) ? _Support.requestable : _Support.hidden,
      AppPermission.camera => caps.has(Capability.camera) ? _Support.requestable : _Support.hidden,
      AppPermission.microphone =>
        caps.platform == 'ios' || caps.platform == 'android' ? _Support.requestable : _Support.hidden,
      // Медиатека (Apple Music) — только iOS.
      AppPermission.mediaLibrary =>
        caps.platform == 'ios' && caps.has(Capability.nowPlaying) ? _Support.requestable : _Support.hidden,
      // Android — точные будильники; iOS AlarmKit — без нативного кода до этапа будильника.
      AppPermission.alarms => !caps.has(Capability.alarm)
          ? _Support.hidden
          : caps.platform == 'android'
              ? _Support.requestable
              : _Support.infoOnly,
    };
  }

  String? _stored(AppPermission p) => data[p.name] is String ? data[p.name]! as String : null;

  /// Перепроверка статусов при открытии шага: выданное — «granted», отозванное — «denied»,
  /// недоступное на платформе — «unavailable».
  Future<void> _recheck(DeviceCapabilities caps) async {
    final gateway = ref.read(permissionGatewayProvider);
    final updates = <String, Object?>{};
    final permanent = <AppPermission>{};
    for (final p in AppPermission.values) {
      final stored = _stored(p);
      if (_support(p, caps) != _Support.requestable) {
        if (stored != 'unavailable') updates[p.name] = 'unavailable';
        continue;
      }
      final s = await gateway.status(p);
      switch (s) {
        case PermissionState.granted:
          if (stored != 'granted') updates[p.name] = 'granted';
        case PermissionState.unavailable:
          if (stored != 'unavailable') updates[p.name] = 'unavailable';
        case PermissionState.permanentlyDenied:
          permanent.add(p);
          if (stored == 'granted') updates[p.name] = 'denied';
        case PermissionState.denied:
          if (stored == 'granted') updates[p.name] = 'denied';
      }
    }
    if (!mounted) return;
    setState(() {
      _permanentlyDenied
        ..clear()
        ..addAll(permanent);
    });
    if (updates.isNotEmpty) setValues(updates);
  }

  Future<void> _request(AppPermission p) async {
    setState(() => _busy = p);
    final s = await ref.read(permissionGatewayProvider).request(p);
    if (!mounted) return;
    setState(() {
      _busy = null;
      if (s == PermissionState.permanentlyDenied) {
        _permanentlyDenied.add(p);
      } else {
        _permanentlyDenied.remove(p);
      }
    });
    setValue(p.name, switch (s) {
      PermissionState.granted => 'granted',
      PermissionState.denied || PermissionState.permanentlyDenied => 'denied',
      PermissionState.unavailable => 'unavailable',
    });
  }

  String _title(AppLocalizations l, AppPermission p) => switch (p) {
        AppPermission.notifications => l.qbPermNotifications,
        AppPermission.motion => l.qbPermMotion,
        AppPermission.locationAlways => l.qbPermLocationAlways,
        AppPermission.camera => l.qbPermCamera,
        AppPermission.microphone => l.qbPermMicrophone,
        AppPermission.mediaLibrary => l.qbPermMediaLibrary,
        AppPermission.alarms => l.qbPermAlarms,
      };

  String _why(AppLocalizations l, AppPermission p) => switch (p) {
        AppPermission.notifications => l.qbPermNotificationsWhy,
        AppPermission.motion => l.qbPermMotionWhy,
        AppPermission.locationAlways => l.qbPermLocationAlwaysWhy,
        AppPermission.camera => l.qbPermCameraWhy,
        AppPermission.microphone => l.qbPermMicrophoneWhy,
        AppPermission.mediaLibrary => l.qbPermMediaLibraryWhy,
        AppPermission.alarms => l.qbPermAlarmsWhy,
      };

  static SysGlyph _glyph(AppPermission p) => switch (p) {
        AppPermission.notifications => SysGlyph.bell,
        AppPermission.motion => SysGlyph.walk,
        AppPermission.locationAlways => SysGlyph.home,
        AppPermission.camera => SysGlyph.sparkle,
        AppPermission.microphone => SysGlyph.mic,
        AppPermission.mediaLibrary => SysGlyph.book,
        AppPermission.alarms => SysGlyph.clock,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    final editing = scope?.editing ?? false;
    scope?.setCanProceed(true);

    final capsAsync = ref.watch(deviceCapabilitiesProvider);
    final DeviceCapabilities? caps = switch (capsAsync) {
      AsyncData(:final value) => value,
      AsyncError() => _fallbackCaps,
      _ => null,
    };
    if (!loaded || caps == null) return const SectionLoading();
    _caps = caps;
    if (!_checkStarted) {
      _checkStarted = true;
      Future.microtask(() => _recheck(caps));
    }

    final visible = [for (final p in AppPermission.values) if (_support(p, caps) != _Support.hidden) p];
    final current = visible.where((p) => _support(p, caps) == _Support.requestable && _stored(p) == null).firstOrNull;
    final decidedCount = visible.where((p) => _stored(p) != null || _support(p, caps) == _Support.infoOnly).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.qbPermissionsIntro, style: SysText.secondary),
        if (visible.isEmpty)
          Text(l.qbPermNoneAvailable, style: SysText.secondary)
        else ...[
          Text(l.qbPermProgress(decidedCount, visible.length), style: SysText.caption),
          const SizedBox(height: 8),
          for (final p in visible)
            if (p == current)
              _CurrentCard(
                key: ValueKey('qbPermCurrent_${p.name}'),
                permission: p,
                title: _title(l, p),
                why: _why(l, p),
                glyph: _glyph(p),
                allowLabel: l.qbPermAllow,
                laterLabel: l.qbPermLater,
                busy: _busy == p,
                onAllow: () => _request(p),
                onLater: () => setValue(p.name, 'skipped'),
              )
            else if (_stored(p) != null || _support(p, caps) == _Support.infoOnly)
              _DecidedRow(
                key: ValueKey('qbPermRow_${p.name}'),
                permission: p,
                title: _title(l, p),
                note: _support(p, caps) == _Support.infoOnly
                    ? l.qbPermAlarmsLater
                    : (_stored(p) == 'granted' ? null : _why(l, p)),
                glyph: _glyph(p),
                status: _support(p, caps) == _Support.infoOnly ? 'unavailable' : _stored(p)!,
                permanentlyDenied: _permanentlyDenied.contains(p),
                busy: _busy == p,
                onAllow: () => _request(p),
                onOpenSettings: () => ref.read(permissionGatewayProvider).openSettings(),
              ),
          if (current == null) ...[
            const SizedBox(height: 8),
            Text(l.qbPermAllDone, style: SysText.caption),
          ],
        ],
      ],
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({
    super.key,
    required this.permission,
    required this.title,
    required this.why,
    required this.glyph,
    required this.allowLabel,
    required this.laterLabel,
    required this.busy,
    required this.onAllow,
    required this.onLater,
  });

  final AppPermission permission;
  final String title;
  final String why;
  final SysGlyph glyph;
  final String allowLabel;
  final String laterLabel;
  final bool busy;
  final VoidCallback onAllow;
  final VoidCallback onLater;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SysPanel(
          title: title,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SysIcon(glyph, size: 28),
                  const SizedBox(width: 12),
                  Expanded(child: Text(why, style: SysText.body)),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SysButton.secondary(
                      key: ValueKey('qbPermLater_${permission.name}'),
                      label: laterLabel,
                      expand: true,
                      onPressed: busy ? null : onLater,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SysButton.primary(
                      key: ValueKey('qbPermAllow_${permission.name}'),
                      label: allowLabel,
                      expand: true,
                      onPressed: busy ? null : onAllow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}

class _DecidedRow extends StatelessWidget {
  const _DecidedRow({
    super.key,
    required this.permission,
    required this.title,
    required this.note,
    required this.glyph,
    required this.status,
    required this.permanentlyDenied,
    required this.busy,
    required this.onAllow,
    required this.onOpenSettings,
  });

  final AppPermission permission;
  final String title;
  final String? note;
  final SysGlyph glyph;
  final String status;
  final bool permanentlyDenied;
  final bool busy;
  final VoidCallback onAllow;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (label, tone) = switch (status) {
      'granted' => (l.qbPermGranted, PanelTone.success),
      'denied' => (l.qbPermDenied, PanelTone.danger),
      'skipped' => (l.qbPermSkipped, PanelTone.gold),
      _ => (l.qbPermUnavailable, PanelTone.accent),
    };
    final n = note;
    Widget? action;
    if (status == 'denied' && permanentlyDenied) {
      action = SysButton.secondary(
        key: ValueKey('qbPermSettings_${permission.name}'),
        label: l.qbPermOpenSettings,
        onPressed: onOpenSettings,
      );
    } else if (status == 'denied' || status == 'skipped') {
      action = SysButton.secondary(
        key: ValueKey('qbPermAllow_${permission.name}'),
        label: l.qbPermAllow,
        onPressed: busy ? null : onAllow,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: SysColors.accent.withValues(alpha: .05),
          border: Border.all(color: SysColors.accent.withValues(alpha: .30)),
          borderRadius: BorderRadius.circular(SysDims.radius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SysIcon(glyph, size: 18),
                  const SizedBox(width: 10),
                  Expanded(child: Text(title, style: SysText.body)),
                  SysPill(label: label, tone: tone),
                ],
              ),
              if (n != null) ...[const SizedBox(height: 6), Text(n, style: SysText.caption)],
              if (action != null) ...[
                const SizedBox(height: 8),
                Align(alignment: Alignment.centerLeft, child: action),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
