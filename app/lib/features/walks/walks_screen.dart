// Прогулки (SPEC §8.5): круговой маршрут на N км/минут, отрезки режимов, карта, трекинг с голосом поверх музыки,
// «Магазин рядом», история. Трекинг (фон, Walks) — WalkTracker (core/location), голос — VoicePrompter (core/audio).
// Открыть сразу с поиском магазина: `/walks?shop=1` (продукты) или `/walks?shop=water`.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/audio/audio_api.dart';
import '../../core/db/database.dart';
import '../../domain/walks/walk_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/walk_history_repository.dart';
import 'data/walk_route_service.dart';
import 'domain/walk_segments.dart';
import 'domain/walk_voice.dart';
import 'nearby_shop_sheet.dart';
import 'walk_l10n.dart';
import 'water_quest.dart';
import 'widgets/walk_map.dart';

const List<double> walkKmChoices = [1, 2, 3, 5, 8];
const List<int> walkMinuteChoices = [15, 20, 30, 45, 60];

class WalksScreen extends ConsumerStatefulWidget {
  const WalksScreen({super.key, this.shop});

  /// Сразу открыть «Магазин рядом» с этой категорией. null — взять из `?shop=` маршрута (если есть).
  final PlaceCategory? shop;

  /// `?shop=1|grocery` → продукты, `?shop=water` → вода, иначе null.
  static PlaceCategory? shopFromQuery(Map<String, String> query) => switch (query['shop']) {
        '1' || 'grocery' => PlaceCategory.grocery,
        'water' => PlaceCategory.water,
        _ => null,
      };

  @override
  ConsumerState<WalksScreen> createState() => _WalksScreenState();
}

class _WalksScreenState extends ConsumerState<WalksScreen> {
  bool _byTime = false;
  double _km = 3;
  int _minutes = 30;
  bool _intervals = true;

  RoutePlan? _plan;
  bool _building = false;
  String? _error;

  WalkTracker? _tracker;
  StreamSubscription<WalkProgress>? _sub;
  WalkProgress? _progress;
  bool _tracking = false;
  bool _busy = false;
  WalkSummary? _summary;
  final _coach = WalkVoiceCoach();

  @override
  void initState() {
    super.initState();
    try {
      _tracker = ref.read(walkTrackerProvider);
    } on Object {
      debugPrint('Walks: трекер не подключён (walkTrackerProvider)');
    }
    final t = _tracker;
    if (t != null && t.isActive) {
      // Прогулка восстановлена после перезапуска — продолжаем показывать.
      _tracking = true;
      _coach.next(const WalkProgress(elapsed: Duration.zero, distanceM: 0)); // без повторного «начинаем»
      _listen(t);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openShopFromRoute();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  void _openShopFromRoute() {
    var shop = widget.shop;
    if (shop == null && GoRouter.maybeOf(context) != null) {
      try {
        shop = WalksScreen.shopFromQuery(GoRouterState.of(context).uri.queryParameters);
      } on Object {
        shop = null;
      }
    }
    if (shop != null) _openShop(shop);
  }

  double get _targetM => _byTime ? metersForMinutes(_minutes) : _km * 1000;

  Future<void> _build() async {
    final l = AppLocalizations.of(context);
    setState(() {
      _building = true;
      _error = null;
    });
    final start = await currentWalkPoint(ref.read(locationServiceProvider));
    if (!mounted) return;
    if (start == null) {
      setState(() {
        _building = false;
        _error = l.wlkNoLocation;
      });
      return;
    }
    RoutePlan? plan;
    try {
      plan = await ref.read(routeServiceProvider).loop(start, _targetM);
    } on Object catch (e) {
      debugPrint('Walks: loop: $e');
    }
    if (!mounted) return;
    setState(() {
      _building = false;
      if (plan == null) {
        _error = l.wlkNoRoute;
      } else {
        _plan = plan.kind == 'loop' ? withIntervals(plan, _intervals) : plan;
        _summary = null;
      }
    });
  }

  Future<void> _openShop([PlaceCategory category = PlaceCategory.grocery]) async {
    if (_tracking) return;
    final plan = await showNearbyShopSheet(context, category: category);
    if (!mounted || plan == null) return;
    // «Нет воды» (SPEC §9.3): маршрут к магазину → разовый квест-прогулка.
    if (category == PlaceCategory.water) {
      unawaited(startWaterShopQuest(ref, plan).then<void>((_) {}, onError: (Object e) => debugPrint('Walks: water quest: $e')));
    }
    setState(() {
      _plan = plan;
      _error = null;
      _summary = null;
    });
  }

  void _listen(WalkTracker t) {
    _sub?.cancel();
    _sub = t.progress.listen(_onProgress, onError: (Object e) => debugPrint('Walks: progress: $e'));
  }

  void _onProgress(WalkProgress p) {
    if (!mounted) return;
    setState(() => _progress = p);
    final line = _coach.next(p);
    if (line == null) return;
    final l = AppLocalizations.of(context);
    final text = walkVoiceText(l, line);
    if (text == null) return;
    unawaited(ref
        .read(voicePrompterProvider)
        .say(text, languageCode: l.localeName, interrupt: line.offRoute || line.arrive)
        .catchError((Object e) => debugPrint('Walks: voice: $e')));
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } on Object catch (e) {
      debugPrint('Walks: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start({required bool withRoute}) => _run(() async {
        final t = _tracker;
        if (t == null) return;
        final plan = withRoute ? _plan : null;
        String? routeId;
        if (plan != null) {
          try {
            routeId = await ref.read(walkHistoryRepositoryProvider).saveRoute(plan);
          } on Object catch (e) {
            debugPrint('Walks: save route: $e');
          }
        }
        _coach.reset();
        _listen(t);
        await t.start(plan: plan, routeId: routeId);
        if (mounted) {
          setState(() {
            _tracking = true;
            _summary = null;
            _progress = null;
          });
        }
      });

  Future<void> _togglePause() => _run(() async {
        final t = _tracker;
        if (t == null) return;
        if (_progress?.paused ?? false) {
          await t.resume();
        } else {
          await t.pause();
        }
      });

  Future<void> _finish() => _run(() async {
        final t = _tracker;
        if (t == null) return;
        final summary = await t.finish();
        await _sub?.cancel();
        _sub = null;
        unawaited(ref.read(voicePrompterProvider).stop().catchError((Object _) {}));
        if (mounted) {
          setState(() {
            _tracking = false;
            _progress = null;
            _summary = summary;
          });
        }
      });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final history = ref.watch(walkHistoryProvider).value ?? const <WalkRow>[];
    final plan = _plan;
    return _WalkPage(
      title: l.wlkTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_tracking)
            _ActivePanel(
              progress: _progress,
              busy: _busy,
              onPause: _togglePause,
              onFinish: _finish,
            )
          else
            _SetupPanel(
              byTime: _byTime,
              km: _km,
              minutes: _minutes,
              intervals: _intervals,
              building: _building,
              onByTime: (v) => setState(() => _byTime = v),
              onKm: (v) => setState(() => _km = v),
              onMinutes: (v) => setState(() => _minutes = v),
              onIntervals: (v) => setState(() {
                _intervals = v;
                final p = _plan;
                if (p != null && p.kind == 'loop') _plan = withIntervals(p, v);
              }),
              onBuild: _build,
              onShop: () => _openShop(),
            ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, key: const Key('wlk-error'), style: SysText.secondary.copyWith(color: SysColors.dangerLight)),
          ],
          if (_tracker == null) ...[
            const SizedBox(height: 8),
            Text(l.wlkTrackerUnavailable, key: const Key('wlk-no-tracker'), style: SysText.caption),
          ],
          if (_summary != null) ...[
            const SizedBox(height: 16),
            _SummaryPanel(summary: _summary!),
          ],
          if (plan != null || _progress?.position != null) ...[
            const SizedBox(height: 16),
            SysPanel(
              key: const Key('wlk-route'),
              title: plan?.kind == 'toPlace' ? l.wlkShop : l.wlkPlan,
              trailing: plan == null
                  ? null
                  : SysPill(label: l.wlkRouteInfo(formatKm(plan.distanceM), ((plan.durationS ?? 0) / 60).round())),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  WalkMap(plan: plan, position: _progress?.position?.point),
                  if (plan != null && plan.segments.length > 1) ...[
                    const SizedBox(height: 10),
                    _SegmentsLegend(plan: plan),
                  ],
                ],
              ),
            ),
          ],
          if (!_tracking) ...[
            const SizedBox(height: 16),
            if (plan != null)
              SysButton.primary(
                key: const Key('wlk-start'),
                label: l.wlkStart,
                icon: SysGlyph.walk,
                expand: true,
                onPressed: _tracker == null || _busy ? null : () => _start(withRoute: true),
              ),
            const SizedBox(height: 8),
            SysButton.secondary(
              key: const Key('wlk-start-free'),
              label: l.wlkStartFree,
              expand: true,
              onPressed: _tracker == null || _busy ? null : () => _start(withRoute: false),
            ),
          ],
          const SizedBox(height: 16),
          _HistoryPanel(walks: history),
        ],
      ),
    );
  }
}

class _WalkPage extends StatelessWidget {
  const _WalkPage({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (EmbeddedTab.of(context)) return EmbeddedTabBody(child: child);
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      tooltip: l.commonBack,
                      constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                      icon: const SysIcon(SysGlyph.arrowLeft, size: 22, color: SysColors.accentLight),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title.toUpperCase(), style: SysText.heading, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), child: child),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SetupPanel extends StatelessWidget {
  const _SetupPanel({
    required this.byTime,
    required this.km,
    required this.minutes,
    required this.intervals,
    required this.building,
    required this.onByTime,
    required this.onKm,
    required this.onMinutes,
    required this.onIntervals,
    required this.onBuild,
    required this.onShop,
  });

  final bool byTime;
  final double km;
  final int minutes;
  final bool intervals;
  final bool building;
  final ValueChanged<bool> onByTime;
  final ValueChanged<double> onKm;
  final ValueChanged<int> onMinutes;
  final ValueChanged<bool> onIntervals;
  final VoidCallback onBuild;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      key: const Key('wlk-setup'),
      title: l.wlkPlan,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSegmented<bool>(
            key: const Key('wlk-unit'),
            choices: [SysChoice(false, l.wlkByDistance), SysChoice(true, l.wlkByTime)],
            value: byTime,
            onChanged: onByTime,
          ),
          const SizedBox(height: 12),
          if (byTime)
            SysChoiceChips<int>(
              key: const Key('wlk-minutes'),
              choices: [for (final m in walkMinuteChoices) SysChoice(m, l.wlkMin(m))],
              selected: {minutes},
              allowEmpty: false,
              onChanged: (s) {
                if (s.isNotEmpty) onMinutes(s.first);
              },
            )
          else
            SysChoiceChips<double>(
              key: const Key('wlk-km'),
              choices: [for (final k in walkKmChoices) SysChoice(k, l.wlkKm(k.toStringAsFixed(0)))],
              selected: {km},
              allowEmpty: false,
              onChanged: (s) {
                if (s.isNotEmpty) onKm(s.first);
              },
            ),
          const SizedBox(height: 8),
          SysSwitchRow(
            key: const Key('wlk-intervals'),
            label: l.wlkIntervals,
            hint: intervals ? null : l.wlkIntervalsHint,
            value: intervals,
            onChanged: onIntervals,
          ),
          const SizedBox(height: 12),
          SysButton.primary(
            key: const Key('wlk-build'),
            label: building ? l.wlkBuilding : l.wlkBuild,
            expand: true,
            onPressed: building ? null : onBuild,
          ),
          const SizedBox(height: 8),
          SysButton.secondary(
            key: const Key('wlk-shop'),
            label: l.wlkShop,
            icon: SysGlyph.shop,
            expand: true,
            onPressed: onShop,
          ),
        ],
      ),
    );
  }
}

class _SegmentsLegend extends StatelessWidget {
  const _SegmentsLegend({required this.plan});

  final RoutePlan plan;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final modes = {for (final s in plan.segments) s.mode};
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        for (final m in modes)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 14, height: 4, color: walkModeColor(m)),
              const SizedBox(width: 6),
              Text(walkModeLabel(l, m), style: SysText.caption),
            ],
          ),
        Text('${plan.segments.length} ×', style: SysText.monoSmall),
      ],
    );
  }
}

class _ActivePanel extends StatelessWidget {
  const _ActivePanel({required this.progress, required this.busy, required this.onPause, required this.onFinish});

  final WalkProgress? progress;
  final bool busy;
  final VoidCallback onPause;
  final VoidCallback onFinish;

  Widget _stat(String label, String value, Key key) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: SysText.label),
            const SizedBox(height: 2),
            Text(value, key: key, style: SysText.monoLarge),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final p = progress;
    final paused = p?.paused ?? false;
    final cue = p?.nextCue;
    final mode = p?.mode;
    return SysPanel(
      key: const Key('wlk-active'),
      title: paused ? l.wlkPaused : l.wlkActive,
      tone: paused ? PanelTone.gold : PanelTone.accent,
      trailing: mode == null ? null : SysPill(key: const Key('wlk-mode'), label: walkModeLabel(l, mode)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _stat(l.wlkDistance, l.wlkKm(formatKm(p?.distanceM ?? 0)), const Key('wlk-distance')),
              _stat(l.wlkTime, formatDuration(p?.elapsed ?? Duration.zero), const Key('wlk-elapsed')),
              _stat(l.wlkPace, formatPace(p?.paceSecPerKm), const Key('wlk-pace')),
            ],
          ),
          if (cue != null) ...[
            const SizedBox(height: 12),
            Row(
              key: const Key('wlk-next-cue'),
              children: [
                Text('${l.wlkNext}: ', style: SysText.caption),
                Expanded(
                  child: Text(
                    [
                      walkTurnLabel(l, cue.turn),
                      if (p?.metersToNextCue != null) l.wlkInMeters(p!.metersToNextCue!.round()),
                      ?cue.street,
                    ].join(' · '),
                    style: SysText.body,
                  ),
                ),
              ],
            ),
          ],
          if (p?.offRoute ?? false) ...[
            const SizedBox(height: 8),
            Text(l.wlkOffRoute, key: const Key('wlk-off-route'), style: SysText.secondary.copyWith(color: SysColors.dangerLight)),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: SysButton.secondary(
                  key: const Key('wlk-pause'),
                  label: paused ? l.wlkResume : l.wlkPause,
                  expand: true,
                  onPressed: busy ? null : onPause,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SysButton.danger(
                  key: const Key('wlk-finish'),
                  label: l.wlkFinish,
                  expand: true,
                  onPressed: busy ? null : onFinish,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.summary});

  final WalkSummary summary;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final kcal = summary.kcal;
    return SysPanel(
      key: const Key('wlk-summary'),
      title: l.wlkSummary,
      tone: PanelTone.success,
      child: Wrap(
        spacing: 16,
        runSpacing: 6,
        children: [
          Text(l.wlkKm(formatKm(summary.distanceM)), style: SysText.monoLarge),
          Text(formatDuration(Duration(seconds: summary.activeSeconds)), style: SysText.monoLarge),
          if (kcal != null) Text(l.wlkKcal(kcal.round()), style: SysText.monoLarge),
        ],
      ),
    );
  }
}

class _HistoryPanel extends StatelessWidget {
  const _HistoryPanel({required this.walks});

  final List<WalkRow> walks;

  String _date(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}.${two(d.month)} ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      key: const Key('wlk-history'),
      title: l.wlkHistory,
      child: walks.isEmpty
          ? SysEmptyState.inline(l.wlkHistoryEmpty, key: const Key('wlk-history-empty'), glyph: SysGlyph.walk)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final w in walks)
                  Padding(
                    key: Key('wlk-history-${w.id}'),
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        const SysIcon(SysGlyph.walk, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_date(w.startedAt.toLocal()), style: SysText.body)),
                        Text(l.wlkKm(formatKm(w.distanceM)), style: SysText.mono),
                        const SizedBox(width: 12),
                        Text(formatDuration(Duration(seconds: w.activeSeconds)), style: SysText.mono),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
