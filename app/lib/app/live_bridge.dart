// Интеграция этапа 4: данные «Статуса» → виджеты, вода из виджета/App Intent → журнал воды,
// прогулка → Live Activity (с ограничением частоты обновлений).
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/activity/activity_providers.dart';
import '../core/activity/step_repository.dart' show localDay;
import '../core/live/live_api.dart';
import '../core/live/live_codec.dart';
import '../domain/walks/walk_api.dart';
import '../features/home/data/home_live_data.dart';
import '../features/nutrition/data/water_repository.dart';
import '../features/nutrition/nutrition_providers.dart';
import '../features/quests/data/quest_providers.dart';
import '../l10n/app_localizations.dart';

/// Шаги по умолчанию для виджета (своей нормы шагов пока нет).
const int widgetStepGoal = 8000;

/// Минимальный интервал обновления Live Activity прогулки.
const Duration walkLiveInterval = Duration(seconds: 5);

class LiveBridge with WidgetsBindingObserver {
  LiveBridge(this._container, this._l10n);

  final ProviderContainer _container;
  final Future<AppLocalizations> Function() _l10n;
  final List<ProviderSubscription<Object?>> _subs = [];
  StreamSubscription<WalkProgress>? _walkSub;
  Timer? _debounce;
  String? _walkLiveId;
  DateTime? _walkLiveAt;
  bool _taking = false;

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _subs.add(_container.listen(homeStatusProvider, (_, _) => _scheduleWidgets()));
    _subs.add(_container.listen(questNextProvider, (_, _) => _scheduleWidgets()));
    _subs.add(_container.listen(stepsDayProvider(localDay(DateTime.now())), (_, _) => _scheduleWidgets()));
    _scheduleWidgets();
    unawaited(takePendingWater());
    _watchWalk();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(takePendingWater());
  }

  void _scheduleWidgets() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => unawaited(_pushWidgets()));
  }

  Future<void> _pushWidgets() async {
    try {
      final status = _container.read(homeStatusProvider).value;
      if (status == null) return;
      final next = _container.read(questNextProvider).value;
      final steps = _container.read(stepsDayProvider(localDay(DateTime.now()))).value?.steps ?? 0;
      final l = await _l10n();
      final p = status.player;
      await _container.read(widgetSyncProvider).update(WidgetSnapshotPlus(
            nextQuestTitle: status.nextQuest?.title.of(l),
            nextQuestDeadline: next?.deadlineAt,
            nextQuestRewardDiamonds: status.nextQuest?.rewardPoints ?? 0,
            steps: steps,
            stepGoal: widgetStepGoal,
            waterMl: p.waterMl,
            waterGoalMl: p.waterGoalMl,
            level: p.level,
            diamonds: p.points,
          ));
    } catch (e) {
      debugPrint('LiveBridge widgets: $e');
    }
  }

  /// Вода, добавленная кнопкой виджета / App Intent, пока приложение было закрыто.
  Future<void> takePendingWater() async {
    if (_taking) return;
    _taking = true;
    try {
      var ml = await _container.read(widgetSyncProvider).takePendingWater();
      final repo = _container.read(waterRepositoryProvider);
      while (ml > 0) {
        final part = ml > WaterRepository.maxMl ? WaterRepository.maxMl : ml;
        await repo.add(part);
        ml -= part;
      }
    } catch (e) {
      debugPrint('LiveBridge water: $e');
    } finally {
      _taking = false;
    }
  }

  void _watchWalk() {
    final WalkTracker tracker;
    try {
      tracker = _container.read(walkTrackerProvider);
    } catch (_) {
      return; // трекер не подключён (тесты/предпросмотр)
    }
    _walkSub = tracker.progress.listen((p) => unawaited(_onWalk(p, tracker)));
  }

  Future<void> _onWalk(WalkProgress p, WalkTracker tracker) async {
    final live = _container.read(liveActivityServiceProvider);
    try {
      if (!tracker.isActive) {
        final id = _walkLiveId;
        _walkLiveId = null;
        if (id != null) await live.end(id);
        return;
      }
      final now = DateTime.now();
      final last = _walkLiveAt;
      if (_walkLiveId != null && last != null && now.difference(last) < walkLiveInterval) return;
      _walkLiveAt = now;
      final l = await _l10n();
      final state = LiveState(
        title: l.livWalk,
        subtitle: p.nextCue == null ? '' : l.livWalkNextIn(p.metersToNextCue?.round() ?? 0),
        distanceM: p.distanceM,
        paceSecPerKm: p.paceSecPerKm,
        progress: p.routeProgress,
      );
      final id = _walkLiveId;
      if (id == null) {
        _walkLiveId = await live.start(LiveKind.walk, state);
      } else {
        await live.update(id, state);
      }
    } catch (e) {
      debugPrint('LiveBridge walk: $e');
    }
  }

  /// Завершить Live Activity прогулки (после finish трекера).
  Future<void> endWalk() async {
    final id = _walkLiveId;
    _walkLiveId = null;
    if (id != null) await _container.read(liveActivityServiceProvider).end(id);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final s in _subs) {
      s.close();
    }
    _debounce?.cancel();
    unawaited(_walkSub?.cancel());
  }
}
