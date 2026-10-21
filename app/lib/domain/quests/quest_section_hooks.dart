// Хуки разделов этапа 3 поверх движка: факты (вода, еда, шаги, тренировка, уход, сон) → квесты дня.
// Квесты ищутся по ключу плана (QuestTitle.key = QuestKey.name) или по способу подтверждения (шаги).
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../core/models/enums.dart';
import '../../features/plan/model/plan.dart' show QuestKey;
import 'quest_api.dart';
import 'section_hooks.dart';

class QuestSectionHooks implements SectionQuestHooks {
  QuestSectionHooks(this._quests, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final QuestService _quests;
  final DateTime Function() _clock;

  /// Тренировка засчитывается, если сделано не меньше этой доли от минут квеста.
  static const trainingShare = 0.8;

  /// Допуск к времени отбоя для квеста «лечь вовремя».
  static const bedTolerance = Duration(minutes: 15);

  static DateTime _dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

  Future<List<QuestItem>> _pending(DateTime day, bool Function(QuestItem q) where) async {
    final items = await _quests.watchDay(_dayOf(day)).first;
    return [for (final q in items) if (q.isPending && where(q)) q]
      ..sort((a, b) => (a.startsAt ?? a.deadlineAt).compareTo(b.startsAt ?? b.deadlineAt));
  }

  static bool _isKey(QuestItem q, QuestKey key) => q.title.key == key.name;

  static int? _int(Object? v) => v is num ? v.toInt() : null;

  /// Ошибки движка разделам не видны (квест мог закрыться параллельно).
  Future<void> _safe(String what, Future<void> Function() body) async {
    try {
      await body();
    } catch (e, st) {
      debugPrint('QuestSectionHooks.$what: $e\n$st');
    }
  }

  @override
  Future<void> waterAdded({required int ml, required int totalTodayMl, DateTime? at}) => _safe('water', () async {
        final now = at ?? _clock();
        // Выпитое закрывает квесты воды по порядку: сначала уже начавшиеся, остаток — в следующий.
        var left = ml;
        for (final q in await _pending(now, (q) => _isKey(q, QuestKey.water))) {
          if (left <= 0) break;
          final target = q.target;
          if (target == null) {
            await _quests.complete(q.instanceId, at: now);
            left = 0;
            break;
          }
          final take = math.min(left, target - q.progress);
          if (take <= 0) continue;
          await _quests.addProgress(q.instanceId, take, at: now);
          left -= take;
        }
      });

  @override
  Future<void> mealLogged({required int mealsToday, DateTime? at}) => _safe('meal', () async {
        final now = at ?? _clock();
        for (final q in await _pending(now, (q) => _isKey(q, QuestKey.meals))) {
          final need = _int(q.title.params['count']) ?? 1;
          if (mealsToday >= need) await _quests.complete(q.instanceId, at: now);
        }
      });

  @override
  Future<void> stepsUpdated({required int stepsToday, DateTime? at}) => _safe('steps', () async {
        final now = at ?? _clock();
        for (final q in await _pending(now, (q) => q.confirm == ConfirmMethod.steps && q.target != null)) {
          final delta = stepsToday - q.progress;
          if (delta > 0) await _quests.addProgress(q.instanceId, delta, at: now);
        }
      });

  @override
  Future<void> workoutFinished({required int activeMinutes, DateTime? at}) => _safe('workout', () async {
        final now = at ?? _clock();
        final quests = await _pending(now, (q) => _isKey(q, QuestKey.training));
        for (final q in quests.take(1)) {
          final minutes = _int(q.title.params['minutes']);
          if (minutes == null || activeMinutes >= minutes * trainingShare) {
            await _quests.complete(q.instanceId, at: now);
          }
        }
      });

  @override
  Future<void> careRoutineDone(CareRoutine routine, {DateTime? at}) => _safe('care', () async {
        final now = at ?? _clock();
        final key = routine == CareRoutine.morning ? QuestKey.skincareMorning : QuestKey.skincareEvening;
        for (final q in await _pending(now, (q) => _isKey(q, key))) {
          await _quests.complete(q.instanceId, at: now);
        }
      });

  @override
  Future<void> sleepLogged({required DateTime bedAt, required DateTime wakeAt}) => _safe('sleep', () async {
        // Квест «лечь вовремя» — в день отбоя (лёг после полуночи — квест предыдущего дня).
        final evening = bedAt.hour < 12 ? _dayOf(bedAt).subtract(const Duration(days: 1)) : _dayOf(bedAt);
        for (final q in await _pending(evening, (q) => _isKey(q, QuestKey.sleepOnTime))) {
          final minute = _int(q.title.params['minute']);
          if (minute == null) continue;
          final planned = evening.add(Duration(minutes: minute));
          final hours = q.title.params['hours'];
          final enough = hours is! num || wakeAt.difference(bedAt).inMinutes >= hours * 60 * 0.9;
          if (!bedAt.isAfter(planned.add(bedTolerance)) && enough) {
            await _quests.complete(q.instanceId, at: bedAt);
          }
        }
      });
}
