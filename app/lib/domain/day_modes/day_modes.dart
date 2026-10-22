// Режимы дня (SPEC §8.13): автоплан, занятость, адаптивная сложность. Итоги дня — features/day_summary.
// Настройки и состояния — синхронизируемые UserSettings (JSON). Сдвиг квестов при занятости правит экземпляры
// дня напрямую (как snooze движка: поля синхронизации, version+1) и вызывается до tick (ReminderCoordinator.beforeTick),
// чтобы квест во время пар/работы/«занят» не проваливался, а переносился на конец занятости.
import 'dart:convert';
import 'dart:math' as math;

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/user_setting_store.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../features/schedule/data/schedule_repository.dart';
import '../../features/schedule/schedule_logic.dart';

const dayModesSettingId = 'dayModes';
const busySettingId = 'dayBusy';
const adaptiveSettingId = 'dayAdaptive';

/// С какого уровня открывается ручной «Автоплан» (награда пути уровней, GameConfig.levelRewards[8]).
const autoplanUnlockLevel = 8;

class DayModesPrefs {
  const DayModesPrefs({
    this.autoplan = false,
    this.autoplanInDiscipline = true,
    this.busyFromSchedule = true,
    this.adaptive = true,
    this.daySummary = true,
  });

  factory DayModesPrefs.fromJson(Map<String, Object?> j) => DayModesPrefs(
        autoplan: j['autoplan'] == true,
        autoplanInDiscipline: j['autoplanInDiscipline'] != false,
        busyFromSchedule: j['busyFromSchedule'] != false,
        adaptive: j['adaptive'] != false,
        daySummary: j['daySummary'] != false,
      );

  /// Ручной автоплан (видно только текущее задание).
  final bool autoplan;

  /// Автоплан сам включается в режиме дисциплины.
  final bool autoplanInDiscipline;

  /// Пары/работа/дорога из расписания считаются занятостью.
  final bool busyFromSchedule;
  final bool adaptive;

  /// Уведомление «Итоги дня» за 30 мин до отбоя.
  final bool daySummary;

  bool autoplanActive({required bool discipline}) => autoplan || (discipline && autoplanInDiscipline);

  Map<String, Object?> toJson() => {
        'autoplan': autoplan,
        'autoplanInDiscipline': autoplanInDiscipline,
        'busyFromSchedule': busyFromSchedule,
        'adaptive': adaptive,
        'daySummary': daySummary,
      };

  DayModesPrefs copyWith({
    bool? autoplan,
    bool? autoplanInDiscipline,
    bool? busyFromSchedule,
    bool? adaptive,
    bool? daySummary,
  }) =>
      DayModesPrefs(
        autoplan: autoplan ?? this.autoplan,
        autoplanInDiscipline: autoplanInDiscipline ?? this.autoplanInDiscipline,
        busyFromSchedule: busyFromSchedule ?? this.busyFromSchedule,
        adaptive: adaptive ?? this.adaptive,
        daySummary: daySummary ?? this.daySummary,
      );
}

/// Ручная отметка «занят до …».
class BusyMark {
  const BusyMark({required this.from, required this.until});

  static BusyMark? fromJson(Map<String, Object?> j) {
    final from = DateTime.tryParse('${j['from'] ?? ''}');
    final until = DateTime.tryParse('${j['until'] ?? ''}');
    if (from == null || until == null) return null;
    return BusyMark(from: from.toLocal(), until: until.toLocal());
  }

  final DateTime from;
  final DateTime until;

  bool activeAt(DateTime now) => !now.isBefore(from) && now.isBefore(until);

  Map<String, Object?> toJson() => {'from': from.toUtc().toIso8601String(), 'until': until.toUtc().toIso8601String()};
}

/// Адаптивная сложность: шаг −2…+2 → множитель нагрузки 0.8…1.2 (тренировки — не выше 1.1).
class AdaptiveState {
  const AdaptiveState({this.step = 0, this.rate, this.at});

  factory AdaptiveState.fromJson(Map<String, Object?> j) => AdaptiveState(
        step: ((j['step'] as num?)?.toInt() ?? 0).clamp(minStep, maxStep).toInt(),
        rate: (j['rate'] as num?)?.toDouble(),
        at: DateTime.tryParse('${j['at'] ?? ''}')?.toLocal(),
      );

  static const minStep = -2;
  static const maxStep = 2;
  static const stepPct = 10;

  final int step;

  /// Доля выполненных квестов за окно (0..1), по которой выбран шаг.
  final double? rate;
  final DateTime? at;

  int get percent => step * stepPct;

  Map<String, Object?> toJson() => {'step': step, 'rate': rate, 'at': at?.toUtc().toIso8601String()};
}

/// Чистые правила адаптивной сложности (тестируемы без БД).
abstract final class AdaptiveRules {
  /// Окно оценки, минимум закрытых квестов и как часто менять шаг.
  static const window = Duration(days: 14);
  static const minResolved = 10;
  static const every = Duration(days: 7);
  static const upAt = .85;
  static const downAt = .55;

  /// Следующий шаг: не больше чем на 1 за раз, в пределах −2…+2.
  static int nextStep(int step, double rate) {
    if (rate >= upAt) return math.min(step + 1, AdaptiveState.maxStep);
    if (rate <= downAt) return math.max(step - 1, AdaptiveState.minStep);
    return step;
  }

  /// Множитель для вида нагрузки. Тренировки растут не выше +10% к плану (безопасные рамки).
  static double factor(int step, {required bool training}) {
    final f = 1 + step * AdaptiveState.stepPct / 100;
    return training ? math.min(f, 1.1) : f;
  }
}

class DayModesService {
  DayModesService(this._db, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now,
        _store = UserSettingStore(_db);

  final AppDatabase _db;
  final DateTime Function() _clock;
  final UserSettingStore _store;

  Future<DayModesPrefs> prefs() async => DayModesPrefs.fromJson(jsonMap(await _store.load(dayModesSettingId)));
  Future<void> savePrefs(DayModesPrefs p) => _store.save(dayModesSettingId, p.toJson());

  Future<BusyMark?> busy() async => BusyMark.fromJson(jsonMap(await _store.load(busySettingId)));

  /// «Занят» на [duration] с текущего момента: квесты в это время сдвигаются на конец.
  Future<void> setBusy(Duration duration) async {
    final now = _clock();
    await _store.save(busySettingId, BusyMark(from: now, until: now.add(duration)).toJson());
    await apply(now);
  }

  Future<void> clearBusy() async {
    final now = _clock();
    final b = await busy();
    if (b == null) return;
    await _store.save(busySettingId, BusyMark(from: b.from, until: now).toJson());
  }

  /// Все занятые отрезки дня [day]: расписание (если включено) + ручная отметка.
  Future<List<(DateTime, DateTime)>> busyWindows(DateTime day, {DayModesPrefs? prefs}) async {
    final p = prefs ?? await this.prefs();
    final d = DateTime(day.year, day.month, day.day);
    final out = <(DateTime, DateTime)>[];
    if (p.busyFromSchedule) {
      final repo = ScheduleRepository(_db, clock: _clock);
      final config = await repo.getConfig();
      final entries = await repo.getEntries();
      for (final w in ScheduleLogic.busyWindows(d, config, entries)) {
        out.add((d.add(Duration(minutes: w.startMinute)), d.add(Duration(minutes: w.endMinute))));
      }
    }
    final b = await busy();
    if (b != null && b.until.isAfter(d) && b.from.isBefore(d.add(const Duration(days: 1)))) out.add((b.from, b.until));
    out.sort((a, b) => a.$1.compareTo(b.$1));
    return out;
  }

  /// Конец занятости, если [now] внутри занятого отрезка; иначе null (для тихих напоминаний).
  Future<DateTime?> busyUntil(DateTime now) async {
    DateTime? end;
    for (final (s, e) in await busyWindows(now)) {
      if (!now.isBefore(s) && now.isBefore(e)) end = end == null || e.isAfter(end) ? e : end;
    }
    return end;
  }

  /// Вызывается до tick и при отметке «занят»: сдвиг квестов дня и (раз в неделю) пересчёт сложности.
  Future<void> apply(DateTime now) async {
    final p = await prefs();
    try {
      await _shiftForBusy(now, p);
    } catch (_) {}
    if (p.adaptive) {
      try {
        await _adapt(now);
      } catch (_) {}
    }
  }

  // ---------- Занятость ----------

  Future<void> _shiftForBusy(DateTime now, DayModesPrefs p) async {
    final day = DateTime(now.year, now.month, now.day);
    final windows = await busyWindows(day, prefs: p);
    if (windows.isEmpty) return;
    final config = await ScheduleRepository(_db, clock: _clock).getConfig();
    final bed = config.bedMinute > config.wakeMinute ? config.bedMinute : 24 * 60 - 1;
    final dayEnd = day.add(Duration(minutes: bed));
    final rows = await (_db.select(_db.questInstances).join([
      innerJoin(_db.quests, _db.quests.id.equalsExp(_db.questInstances.questId)),
    ])
          ..where(_db.questInstances.day.equals(day) &
              _db.questInstances.deletedAt.isNull() &
              _db.questInstances.status.equals(QuestStatus.pending.name) &
              // Пары/выход из дома сами и есть занятость; босс — недельный.
              _db.quests.kind.isNotIn([QuestKind.schedule.name, QuestKind.boss.name])))
        .get();
    final deviceId = await _db.deviceId();
    for (final r in rows) {
      final inst = r.readTable(_db.questInstances);
      final start = inst.startsAt;
      if (start == null || !inst.deadlineAt.isAfter(now)) continue;
      final span = inst.deadlineAt.difference(start);
      var s = start;
      var d = inst.deadlineAt;
      for (final (bs, be) in windows) {
        if (!s.isBefore(be) || !d.isAfter(bs)) continue;
        if (!s.isBefore(bs)) {
          // Начало внутри занятости — весь квест после неё.
          s = be;
          d = be.add(span);
        } else if (!d.isAfter(be)) {
          // Начался до занятости, а дедлайн внутри — остаток времени переносится за её конец.
          // (Повторный вызов не продлевает: дедлайн уже после be.)
          d = be.add(d.difference(bs));
        }
      }
      if (s == start && d == inst.deadlineAt) continue;
      if (d.isAfter(dayEnd)) d = dayEnd.isAfter(s) ? dayEnd : s.add(const Duration(minutes: 15));
      await (_db.update(_db.questInstances)..where((t) => t.id.equals(inst.id))).write(QuestInstancesCompanion(
        startsAt: Value(s),
        deadlineAt: Value(d),
        updatedAt: Value(_clock().toUtc()),
        deviceId: Value(deviceId),
        version: Value(inst.version + 1),
      ));
    }
  }

  // ---------- Адаптивная сложность ----------

  Future<AdaptiveState> adaptive() async => AdaptiveState.fromJson(jsonMap(await _store.load(adaptiveSettingId)));

  Future<void> _adapt(DateTime now) async {
    final state = await adaptive();
    final at = state.at;
    if (at != null && now.difference(at) < AdaptiveRules.every) return;
    final from = DateTime(now.year, now.month, now.day).subtract(AdaptiveRules.window);
    final rows = await (_db.select(_db.questInstances)
          ..where((t) =>
              t.deletedAt.isNull() &
              t.day.isBiggerOrEqualValue(from) &
              t.status.isIn([QuestStatus.done.name, QuestStatus.failed.name, QuestStatus.refused.name])))
        .get();
    if (rows.length < AdaptiveRules.minResolved) return;
    final rate = rows.where((r) => r.status == QuestStatus.done.name).length / rows.length;
    final step = AdaptiveRules.nextStep(state.step, rate);
    await _store.save(adaptiveSettingId, AdaptiveState(step: step, rate: rate, at: now).toJson());
    if (step != state.step) await _applyStep(step);
  }

  /// Нагрузка квестов плана (минуты тренировок и учёбы, цели прогресса) — от базового значения плана.
  Future<void> _applyStep(int step) async {
    final quests = await (_db.select(_db.quests)
          ..where((t) => t.deletedAt.isNull() & t.active & t.source.equals('plan')))
        .get();
    final deviceId = await _db.deviceId();
    for (final q in quests) {
      final params = jsonMap(_decode(q.params));
      final training = q.titleKey == 'training';
      final scalable = training || q.titleKey == 'study';
      final patch = <String, Object?>{...params};
      var changed = false;
      if (scalable && params['minutes'] is num) {
        final base = (params['baseMinutes'] as num?) ?? params['minutes'] as num;
        patch['baseMinutes'] = base;
        final v = (base * AdaptiveRules.factor(step, training: training)).round();
        if (v != params['minutes']) {
          patch['minutes'] = v;
          changed = true;
        }
      }
      int? target = q.target;
      if (q.target != null && scalable) {
        final base = (params['baseTarget'] as num?) ?? q.target!;
        patch['baseTarget'] = base;
        final v = (base * AdaptiveRules.factor(step, training: training)).round();
        if (v != q.target) {
          target = v;
          changed = true;
        }
      }
      if (!changed) continue;
      await (_db.update(_db.quests)..where((t) => t.id.equals(q.id))).write(QuestsCompanion(
        params: Value(_encode(patch)),
        target: Value(target),
        updatedAt: Value(_clock().toUtc()),
        deviceId: Value(deviceId),
        version: Value(q.version + 1),
      ));
    }
  }

  static Object? _decode(String raw) {
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static String _encode(Map<String, Object?> m) => jsonEncode(m);
}

final dayModesServiceProvider = Provider<DayModesService>((ref) => DayModesService(ref.watch(databaseProvider)));

final dayModesPrefsProvider = StreamProvider<DayModesPrefs>((ref) =>
    ref.watch(userSettingStoreProvider).watch(dayModesSettingId).map((v) => DayModesPrefs.fromJson(jsonMap(v))));

final dayBusyProvider = StreamProvider<BusyMark?>(
    (ref) => ref.watch(userSettingStoreProvider).watch(busySettingId).map((v) => BusyMark.fromJson(jsonMap(v))));

final dayAdaptiveProvider = StreamProvider<AdaptiveState>((ref) =>
    ref.watch(userSettingStoreProvider).watch(adaptiveSettingId).map((v) => AdaptiveState.fromJson(jsonMap(v))));
