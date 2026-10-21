// Хук квестов дисциплины для движка (LocalQuestService.disciplineQuests) и загрузка контекста из БД.
import 'dart:async';

import 'package:drift/drift.dart';

import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../quests/quest_api.dart';
import 'discipline_rules.dart';

/// Сигнатура хука движка A.
typedef DisciplineQuestsHook = List<QuestInput> Function(DateTime day);

/// Хук с фиксированным контекстом (тесты, фоновые задачи).
DisciplineQuestsHook disciplineQuestsHook(DisciplineContext ctx) => (day) => disciplineQuests(day, ctx: ctx);

/// id строки ScheduleSettings (как в ScheduleRepository.settingsId).
const _scheduleSettingsId = 'main';

/// Читает контекст режима: расписание сна (ScheduleSettings) и анкета (training, health).
class DisciplineContextLoader {
  DisciplineContextLoader(this._db) : _questionnaire = QuestionnaireRepository(_db);

  final AppDatabase _db;
  final QuestionnaireRepository _questionnaire;

  SimpleSelectStatement<$ScheduleSettingsTable, ScheduleSettingsRow> get _schedule =>
      _db.select(_db.scheduleSettings)
    ..where((t) => t.id.equals(_scheduleSettingsId) & t.deletedAt.isNull())
    ..limit(1);

  static DisciplineContext _build(
    ScheduleSettingsRow? schedule,
    Map<String, Object?> training,
    Map<String, Object?> health,
  ) =>
      DisciplineContext.fromSources(
        training: training,
        health: health,
        wakeMinute: schedule?.wakeMinute ?? DisciplineContext.fallback.wakeMinute,
        bedMinute: schedule?.bedMinute ?? DisciplineContext.fallback.bedMinute,
      );

  Future<DisciplineContext> load() async => _build(
        await _schedule.getSingleOrNull(),
        await _questionnaire.read(QuestionnaireSection.training),
        await _questionnaire.read(QuestionnaireSection.health),
      );

  /// Поток контекста: пересчитывается при изменении любого из источников.
  Stream<DisciplineContext> watch() {
    late final StreamController<DisciplineContext> controller;
    final subs = <StreamSubscription<Object?>>[];
    ScheduleSettingsRow? schedule;
    Map<String, Object?>? training;
    Map<String, Object?>? health;
    var scheduleReady = false;
    DisciplineContext? last;

    void emit() {
      final t = training;
      final h = health;
      if (!scheduleReady || t == null || h == null) return;
      final ctx = _build(schedule, t, h);
      if (ctx == last) return;
      last = ctx;
      controller.add(ctx);
    }

    controller = StreamController<DisciplineContext>(
      onListen: () {
        subs
          ..add(_schedule.watchSingleOrNull().listen((r) {
            schedule = r;
            scheduleReady = true;
            emit();
          }, onError: controller.addError))
          ..add(_questionnaire.watch(QuestionnaireSection.training).listen((m) {
            training = m;
            emit();
          }, onError: controller.addError))
          ..add(_questionnaire.watch(QuestionnaireSection.health).listen((m) {
            health = m;
            emit();
          }, onError: controller.addError));
      },
      onCancel: () async {
        for (final s in subs) {
          await s.cancel();
        }
        subs.clear();
      },
    );
    return controller.stream;
  }
}

/// Источник квестов дисциплины для движка: держит актуальный контекст, сам вызов — синхронный.
/// До первой загрузки используется [DisciplineContext.fallback] (6:00/22:00, нагрузка новичка).
///
/// ```dart
/// final source = DisciplineQuestSource(db);
/// await source.start();               // в main; в фоне достаточно await source.load()
/// LocalQuestService(db, disciplineQuests: source.call);
/// ```
class DisciplineQuestSource {
  DisciplineQuestSource(AppDatabase db) : _loader = DisciplineContextLoader(db);

  final DisciplineContextLoader _loader;
  StreamSubscription<DisciplineContext>? _sub;

  DisciplineContext context = DisciplineContext.fallback;

  /// Однократная загрузка (фоновая задача, кнопки уведомлений).
  Future<void> load() async => context = await _loader.load();

  /// Загрузка и подписка на изменения анкеты/расписания.
  Future<void> start() async {
    await load();
    await _sub?.cancel();
    _sub = _loader.watch().listen((c) => context = c);
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  List<QuestInput> call(DateTime day) => disciplineQuests(day, ctx: context);
}
