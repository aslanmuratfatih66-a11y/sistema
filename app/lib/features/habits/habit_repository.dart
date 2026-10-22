// Вредные привычки (SPEC §8.17): счётчик дней без, срывы с триггерами, экономия денег, награды за серии.
// Хранение — синхронизируемая настройка UserSettings 'habits' (JSON). ◆ — через QuestService.award
// (идемпотентно по ref): серия — бонус один раз на отметку, честный срыв — мягкий штраф.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/user_setting_store.dart';
import '../../core/db/database.dart';
import '../../domain/quests/quest_api.dart';

const habitsSettingId = 'habits';

/// Готовые привычки; `custom` — своё название.
abstract final class HabitKinds {
  static const smoking = 'smoking';
  static const vape = 'vape';
  static const alcohol = 'alcohol';
  static const sweets = 'sweets';
  static const energy = 'energy';
  static const phone = 'phone';
  static const lateSleep = 'lateSleep';
  static const custom = 'custom';

  static const presets = [smoking, vape, alcohol, sweets, energy, phone, lateSleep];

  /// Где уместна ненавязчивая ссылка на профессиональную помощь.
  static const addictive = {smoking, vape, alcohol};

  /// Триггеры срыва (ключи; свой текст — тоже допустим).
  static const triggers = ['stress', 'boredom', 'company', 'tired', 'habitTime', 'other'];
}

class HabitRelapse {
  const HabitRelapse({required this.at, this.trigger});

  static HabitRelapse? fromJson(Object? v) {
    if (v is! Map) return null;
    final at = DateTime.tryParse('${v['at'] ?? ''}');
    if (at == null) return null;
    return HabitRelapse(at: at.toLocal(), trigger: v['trigger'] as String?);
  }

  final DateTime at;
  final String? trigger;

  Map<String, Object?> toJson() => {'at': at.toUtc().toIso8601String(), 'trigger': ?trigger};
}

class Habit {
  const Habit({
    required this.id,
    required this.kind,
    required this.cleanSince,
    this.title,
    this.dailyCost = 0,
    this.bestDays = 0,
    this.relapses = const [],
  });

  static Habit? fromJson(Object? v) {
    if (v is! Map) return null;
    final id = v['id'] as String?;
    final since = DateTime.tryParse('${v['cleanSince'] ?? ''}');
    if (id == null || since == null) return null;
    return Habit(
      id: id,
      kind: v['kind'] as String? ?? HabitKinds.custom,
      title: v['title'] as String?,
      cleanSince: since.toLocal(),
      dailyCost: (v['dailyCost'] as num?)?.toInt() ?? 0,
      bestDays: (v['bestDays'] as num?)?.toInt() ?? 0,
      relapses: [for (final r in (v['relapses'] as List? ?? const [])) ?HabitRelapse.fromJson(r)],
    );
  }

  final String id;
  final String kind;
  final String? title;

  /// С какого момента без привычки (последний срыв или старт).
  final DateTime cleanSince;

  /// Сколько ₽ в день уходило на привычку (0 — не считать).
  final int dailyCost;
  final int bestDays;
  final List<HabitRelapse> relapses;

  int daysClean(DateTime now) => now.isBefore(cleanSince) ? 0 : now.difference(cleanSince).inHours ~/ 24;

  int best(DateTime now) => daysClean(now) > bestDays ? daysClean(now) : bestDays;

  /// Сэкономлено за текущую серию, ₽.
  int saved(DateTime now) => daysClean(now) * dailyCost;

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind,
        'title': ?title,
        'cleanSince': cleanSince.toUtc().toIso8601String(),
        'dailyCost': dailyCost,
        'bestDays': bestDays,
        'relapses': [for (final r in relapses.take(50)) r.toJson()],
      };

  Habit copyWith({DateTime? cleanSince, int? bestDays, List<HabitRelapse>? relapses, int? dailyCost, String? title}) => Habit(
        id: id,
        kind: kind,
        title: title ?? this.title,
        cleanSince: cleanSince ?? this.cleanSince,
        dailyCost: dailyCost ?? this.dailyCost,
        bestDays: bestDays ?? this.bestDays,
        relapses: relapses ?? this.relapses,
      );
}

/// Награды за серию «дней без»: {дней: ◆}. Срыв честно отмечен — штраф мягче скрытого (−3 ◆ против провалов).
abstract final class HabitRules {
  static const milestones = {1: 2, 3: 5, 7: 15, 14: 25, 30: 50, 60: 70, 90: 100, 180: 150, 365: 300};
  static const relapsePenalty = 3;

  /// Ближайшая следующая отметка серии (дней) или null.
  static int? nextMilestone(int days) {
    for (final m in milestones.keys) {
      if (m > days) return m;
    }
    return null;
  }
}

class HabitRepository {
  HabitRepository(this._store, this._quests, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final UserSettingStore _store;
  final QuestService _quests;
  final DateTime Function() _clock;

  static List<Habit> _decode(Object? v) {
    final items = v is Map ? v['items'] : null;
    return [for (final h in (items is List ? items : const [])) ?Habit.fromJson(h)];
  }

  Stream<List<Habit>> watch() => _store.watch(habitsSettingId).map(_decode);

  Future<List<Habit>> all() async => _decode(await _store.load(habitsSettingId));

  Future<void> _save(List<Habit> list) => _store.save(habitsSettingId, {'items': [for (final h in list) h.toJson()]});

  Future<void> add({required String kind, String? title, int dailyCost = 0, DateTime? cleanSince}) async {
    final list = await all();
    final now = _clock();
    await _save([
      ...list,
      Habit(id: newId(), kind: kind, title: title, dailyCost: dailyCost, cleanSince: cleanSince ?? now),
    ]);
  }

  Future<void> update(Habit h) async {
    final list = await all();
    await _save([for (final x in list) x.id == h.id ? h : x]);
  }

  Future<void> remove(String id) async {
    final list = await all();
    await _save([for (final x in list) if (x.id != id) x]);
  }

  /// Честная отметка срыва: серия начинается заново, лучший результат сохраняется, мягкий штраф.
  Future<void> relapse(Habit h, {String? trigger}) async {
    final now = _clock();
    final updated = h.copyWith(
      cleanSince: now,
      bestDays: h.best(now),
      relapses: [HabitRelapse(at: now, trigger: trigger), ...h.relapses],
    );
    await update(updated);
    try {
      await _quests.award(
        diamonds: -HabitRules.relapsePenalty,
        reasonKey: 'habitRelapse',
        ref: 'habit:${h.id}:relapse:${now.toUtc().toIso8601String()}',
        at: now,
      );
    } catch (_) {}
  }

  /// Бонусы за достигнутые отметки серии (повтор безопасен: ref включает начало серии).
  Future<void> checkMilestones([DateTime? at]) async {
    final now = at ?? _clock();
    for (final h in await all()) {
      final days = h.daysClean(now);
      for (final e in HabitRules.milestones.entries) {
        if (e.key > days) break;
        await _quests.award(
          diamonds: e.value,
          reasonKey: 'habitStreak',
          ref: 'habit:${h.id}:${h.cleanSince.toUtc().toIso8601String()}:${e.key}',
          at: now,
        );
      }
    }
  }
}

final habitRepositoryProvider = Provider<HabitRepository>(
  (ref) => HabitRepository(ref.watch(userSettingStoreProvider), ref.watch(questServiceProvider)),
);

final habitsProvider = StreamProvider<List<Habit>>((ref) => ref.watch(habitRepositoryProvider).watch());
