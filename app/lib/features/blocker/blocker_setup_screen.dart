// Настройка блокировки отвлекающих приложений (SPEC §8.6).
// Android: разрешения (Usage Access, поверх приложений), выбор из установленных, статус.
// iOS: мастер личных автоматизаций «Команд» со ссылками sistema://app/blocked?app=<id> и совет по фокус-режиму.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../domain/discipline/app_blocker_catalog.dart';
import '../../domain/discipline/app_blocker_channel.dart';
import '../../domain/discipline/app_blocker_repository.dart';
import '../../domain/discipline/app_blocker_sync.dart';
import '../../domain/discipline/app_blocker_window.dart';
import '../../domain/discipline/discipline_rules.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../discipline/discipline_providers.dart';
import '../schedule/widgets/schedule_common.dart' show ScheduleSubPage;

final _blockedAppsProvider = StreamProvider.autoDispose.family<List<BlockedAppRow>, String>(
  (ref, platform) => ref.watch(appBlockerRepositoryProvider).watchApps(platform),
);

class BlockerSetupScreen extends StatelessWidget {
  const BlockerSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final Widget body;
    if (kIsWeb) {
      body = _Unsupported(l: l);
    } else {
      body = switch (defaultTargetPlatform) {
        TargetPlatform.android => const _AndroidSetup(),
        TargetPlatform.iOS => const _IosSetup(),
        _ => _Unsupported(l: l),
      };
    }
    return ScheduleSubPage(
      title: l.blkTitle,
      onBack: () => Navigator.of(context).maybePop(),
      child: body,
    );
  }
}

class _Unsupported extends StatelessWidget {
  const _Unsupported({required this.l});
  final AppLocalizations l;

  @override
  Widget build(BuildContext context) =>
      SysPanel(title: l.blkStatusTitle, child: Text(l.blkUnsupported, style: SysText.secondary));
}

// ---------- Общий статус ----------

class _StatusPanel extends ConsumerWidget {
  const _StatusPanel({this.extra = const []});

  final List<Widget> extra;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final active = ref.watch(disciplinePlayerProvider).value?.disciplineActive ?? false;
    final ctx = ref.watch(disciplineContextProvider).value ?? DisciplineContext.fallback;
    final now = DateTime.now();
    final w = disciplineBlockWindow(now, usualBedMinute: ctx.bedMinute, usualWakeMinute: ctx.wakeMinute);
    final m = disciplineBlockMinutes(ctx);
    final from = disciplineTime(m.bed);
    final until = disciplineTime(m.wake);
    final blockingNow = active && w.contains(now);
    return SysPanel(
      title: l.blkStatusTitle,
      tone: active ? PanelTone.danger : PanelTone.accent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.blkIntro('$blockPenaltyDiamonds'), style: SysText.secondary),
          const SizedBox(height: 10),
          Text(active ? l.blkDisciplineOn(from, until) : l.blkDisciplineOff(from, until), style: SysText.body),
          if (blockingNow) ...[
            const SizedBox(height: 8),
            SysPill(label: l.blkActiveNow, tone: PanelTone.danger, icon: SysGlyph.moon),
            const SizedBox(height: 8),
            _AttemptsTonight(window: w),
          ],
          ...extra,
        ],
      ),
    );
  }
}

class _AttemptsTonight extends ConsumerWidget {
  const _AttemptsTonight({required this.window});
  final BlockWindow window;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final count = ref.watch(_setupAttemptsProvider(window)).value ?? 0;
    return Text(l.blkAttemptsTonight(count), style: SysText.caption);
  }
}

final _setupAttemptsProvider = StreamProvider.autoDispose.family<int, BlockWindow>(
  (ref, w) => ref.watch(appBlockerRepositoryProvider).watchAttemptCount(w.from, w.until),
);

// ---------- Android ----------

class _AndroidSetup extends ConsumerStatefulWidget {
  const _AndroidSetup();

  @override
  ConsumerState<_AndroidSetup> createState() => _AndroidSetupState();
}

class _AndroidSetupState extends ConsumerState<_AndroidSetup> with WidgetsBindingObserver {
  static const _channel = BlockerChannel();

  bool? _usage;
  bool? _overlay;
  List<LaunchableApp>? _apps;
  String _query = '';
  bool _showAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_refreshPermissions());
    unawaited(_loadApps());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_refreshPermissions());
  }

  Future<void> _refreshPermissions() async {
    final usage = await _channel.hasUsageAccess();
    final overlay = await _channel.canDrawOverlays();
    if (!mounted) return;
    setState(() {
      _usage = usage;
      _overlay = overlay;
    });
  }

  Future<void> _loadApps() async {
    final apps = await _channel.listLaunchableApps();
    final repo = ref.read(appBlockerRepositoryProvider);
    // Первый вход: отметить установленные известные развлекательные приложения.
    if (!await repo.hasAnyRows(BlockerPlatformKey.android)) {
      final defaults = {
        for (final a in apps)
          if (knownDistractingAndroidPackages.contains(a.packageName)) a.packageName: a.label,
      };
      if (defaults.isNotEmpty) await repo.enableAll(BlockerPlatformKey.android, defaults);
    }
    if (!mounted) return;
    setState(() => _apps = apps);
  }

  Future<void> _toggle(LaunchableApp app, bool enabled) => ref.read(appBlockerRepositoryProvider).setEnabled(
        platform: BlockerPlatformKey.android,
        appId: app.packageName,
        name: app.label,
        enabled: enabled,
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(_blockedAppsProvider(BlockerPlatformKey.android)).value ?? const <BlockedAppRow>[];
    final enabled = {for (final r in rows) if (r.enabled) r.appId};
    final ready = _usage == true && _overlay == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusPanel(extra: [
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            SysPill(
              label: ready ? l.blkReady : l.blkNotReady,
              tone: ready ? PanelTone.success : PanelTone.gold,
              icon: ready ? SysGlyph.check : SysGlyph.warning,
            ),
            if (enabled.isEmpty) SysPill(label: l.blkNoApps, tone: PanelTone.gold, icon: SysGlyph.info),
          ]),
        ]),
        const SizedBox(height: 14),
        SysPanel(
          title: l.blkPermsTitle,
          appearDelay: const Duration(milliseconds: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PermissionRow(
                title: l.blkUsageAccess,
                hint: l.blkUsageAccessHint,
                granted: _usage,
                onOpen: () => _channel.openUsageAccessSettings(),
              ),
              const SizedBox(height: 12),
              _PermissionRow(
                title: l.blkOverlayPerm,
                hint: l.blkOverlayPermHint,
                granted: _overlay,
                onOpen: () => _channel.openOverlaySettings(),
              ),
              const SizedBox(height: 12),
              Text(l.blkNotifHint, style: SysText.caption),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _appsPanel(l, enabled),
      ],
    );
  }

  Widget _appsPanel(AppLocalizations l, Set<String> enabled) {
    final apps = _apps;
    final Widget list;
    if (apps == null) {
      list = Text(l.blkAppsLoading, style: SysText.secondary);
    } else {
      final q = _query.trim().toLowerCase();
      var shown = apps.where((a) {
        if (!_showAll && q.isEmpty && !enabled.contains(a.packageName)) return false;
        if (q.isEmpty) return true;
        return a.label.toLowerCase().contains(q) || a.packageName.toLowerCase().contains(q);
      }).toList();
      // Выбранные — сверху.
      shown = [
        ...shown.where((a) => enabled.contains(a.packageName)),
        ...shown.where((a) => !enabled.contains(a.packageName)),
      ];
      list = shown.isEmpty
          ? Text(l.blkAppsEmpty, style: SysText.secondary)
          : Column(
              children: [
                for (final a in shown)
                  _AppRow(
                    key: ValueKey('blk-app-${a.packageName}'),
                    app: a,
                    enabled: enabled.contains(a.packageName),
                    onChanged: (v) => _toggle(a, v),
                  ),
              ],
            );
    }
    return SysPanel(
      title: l.blkAppsTitle,
      trailing: Text(l.blkAppsSelected(enabled.length), style: SysText.monoSmall),
      appearDelay: const Duration(milliseconds: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.blkAppsHint, style: SysText.caption),
          const SizedBox(height: 10),
          SysTextField(value: _query, onChanged: (v) => setState(() => _query = v), hint: l.blkSearch),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: SysButton.secondary(
              label: _showAll ? l.blkShowSelected : l.blkShowAll,
              onPressed: () => setState(() => _showAll = !_showAll),
            ),
          ),
          const SizedBox(height: 8),
          list,
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.title, required this.hint, required this.granted, required this.onOpen});

  final String title;
  final String hint;
  final bool? granted;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ok = granted == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: SysText.body)),
            if (granted != null)
              SysPill(
                label: ok ? l.blkGranted : l.blkNotGranted,
                tone: ok ? PanelTone.success : PanelTone.danger,
                icon: ok ? SysGlyph.check : SysGlyph.close,
              ),
          ],
        ),
        Text(hint, style: SysText.caption),
        if (granted == false) ...[
          const SizedBox(height: 6),
          SysButton.secondary(label: l.blkOpenSettings, onPressed: onOpen, icon: SysGlyph.settings),
        ],
      ],
    );
  }
}

class _AppRow extends StatelessWidget {
  const _AppRow({super.key, required this.app, required this.enabled, required this.onChanged});

  final LaunchableApp app;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final icon = app.icon;
    return Row(
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: icon == null
              ? const SysIcon(SysGlyph.status, size: 22, color: SysColors.textInactive)
              : Image.memory(icon, width: 32, height: 32, gaplessPlayback: true, filterQuality: FilterQuality.medium),
        ),
        const SizedBox(width: 10),
        Expanded(child: SysSwitchRow(label: app.label, value: enabled, onChanged: onChanged)),
      ],
    );
  }
}

// ---------- iOS ----------

class _IosSetup extends ConsumerStatefulWidget {
  const _IosSetup();

  @override
  ConsumerState<_IosSetup> createState() => _IosSetupState();
}

class _IosSetupState extends ConsumerState<_IosSetup> {
  @override
  void initState() {
    super.initState();
    unawaited(_ensureDefaults());
  }

  Future<void> _ensureDefaults() async {
    final repo = ref.read(appBlockerRepositoryProvider);
    if (await repo.hasAnyRows(BlockerPlatformKey.ios)) return;
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    await repo.enableAll(BlockerPlatformKey.ios, {
      for (final a in iosBlockerCatalog)
        if (iosDefaultBlockerApps.contains(a.id)) a.id: _name(l, a),
    });
  }

  static String _name(AppLocalizations l, IosBlockerApp a) => a.name ?? l.blkIosGames;

  Future<void> _onChanged(AppLocalizations l, Set<String> before, Set<String> after) async {
    final repo = ref.read(appBlockerRepositoryProvider);
    for (final a in iosBlockerCatalog) {
      final was = before.contains(a.id);
      final now = after.contains(a.id);
      if (was == now) continue;
      await repo.setEnabled(platform: BlockerPlatformKey.ios, appId: a.id, name: _name(l, a), enabled: now);
    }
  }

  Future<void> _copy(AppLocalizations l, IosBlockerApp a) async {
    await Clipboard.setData(ClipboardData(text: iosBlockerLink(a.id)));
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.blkCopied(_name(l, a)))));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(_blockedAppsProvider(BlockerPlatformKey.ios)).value ?? const <BlockedAppRow>[];
    final selected = {for (final r in rows) if (r.enabled) r.appId};
    final chosen = [for (final a in iosBlockerCatalog) if (selected.contains(a.id)) a];
    final steps = [l.blkIosStep1, l.blkIosStep2, l.blkIosStep3, l.blkIosStep4, l.blkIosStep5, l.blkIosStep6];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatusPanel(extra: [
          const SizedBox(height: 10),
          Text(l.blkIosIntro, style: SysText.secondary),
        ]),
        const SizedBox(height: 14),
        SysPanel(
          title: l.blkIosPickTitle,
          appearDelay: const Duration(milliseconds: 60),
          child: SysChoiceChips<String>(
            multi: true,
            choices: [for (final a in iosBlockerCatalog) SysChoice(a.id, _name(l, a))],
            selected: selected,
            onChanged: (next) => _onChanged(l, selected, next),
          ),
        ),
        const SizedBox(height: 14),
        SysPanel(
          title: l.blkIosStepsTitle,
          appearDelay: const Duration(milliseconds: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 24, child: Text('${i + 1}', style: SysText.mono)),
                      Expanded(child: Text(steps[i], style: SysText.body)),
                    ],
                  ),
                ),
              Text(l.blkIosAlwaysNote, style: SysText.caption),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SysPanel(
          title: l.blkIosLinksTitle,
          appearDelay: const Duration(milliseconds: 180),
          child: chosen.isEmpty
              ? Text(l.blkIosLinksEmpty, style: SysText.secondary)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final a in chosen)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_name(l, a), style: SysText.body),
                                  SelectableText(iosBlockerLink(a.id), style: SysText.monoSmall),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SysButton.secondary(label: l.blkCopy, onPressed: () => _copy(l, a)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 14),
        SysPanel(
          title: l.blkIosFocusTitle,
          tone: PanelTone.gold,
          appearDelay: const Duration(milliseconds: 240),
          child: Text(l.blkIosFocusBody, style: SysText.secondary),
        ),
      ],
    );
  }
}
