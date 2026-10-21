// Чистые функции вкладки «Квесты»: даты, фильтры, суммы, отображение экземпляра (покрыты тестами).
import '../../core/models/enums.dart';
import '../../domain/quests/quest_api.dart';

/// Локальная полночь даты.
DateTime dayOf(DateTime t) => DateTime(t.year, t.month, t.day);

/// Понедельник недели (локальная полночь).
DateTime weekStartOf(DateTime t) {
  final d = dayOf(t);
  return DateTime(d.year, d.month, d.day - (d.weekday - DateTime.monday));
}

/// Вид квеста для фильтра (SPEC §8.1): ежедневные, из расписания, по цели, штрафные, босс.
enum QuestKindFilter { daily, schedule, goal, penalty, boss }

QuestKindFilter kindFilterOf(QuestKind k) => switch (k) {
      QuestKind.schedule => QuestKindFilter.schedule,
      QuestKind.goal => QuestKindFilter.goal,
      QuestKind.penalty => QuestKindFilter.penalty,
      QuestKind.boss => QuestKindFilter.boss,
      // Свои, знакомство, контрольные, дисциплина — в «ежедневных».
      QuestKind.daily || QuestKind.custom || QuestKind.intro || QuestKind.control || QuestKind.discipline =>
        QuestKindFilter.daily,
    };

/// Фильтр списка: null — без ограничения.
class QuestFilter {
  const QuestFilter({this.stat, this.kind});
  final StatKind? stat;
  final QuestKindFilter? kind;

  static const none = QuestFilter();

  bool get isEmpty => stat == null && kind == null;

  bool matches(QuestItem q) => (stat == null || q.stat == stat) && (kind == null || kindFilterOf(q.kind) == kind);

  QuestFilter withStat(StatKind? s) => QuestFilter(stat: s, kind: kind);
  QuestFilter withKind(QuestKindFilter? k) => QuestFilter(stat: stat, kind: k);

  @override
  bool operator ==(Object other) => other is QuestFilter && other.stat == stat && other.kind == kind;

  @override
  int get hashCode => Object.hash(stat, kind);
}

/// Порядок в списке: по началу/дедлайну, затем по названию-ключу.
List<QuestItem> sortQuests(Iterable<QuestItem> list) =>
    list.toList()..sort((a, b) => (a.startsAt ?? a.deadlineAt).compareTo(b.startsAt ?? b.deadlineAt));

/// Итоговый штраф дня: сумма штрафов ещё не закрытых квестов (босс не входит).
int dayPenaltyTotal(Iterable<QuestItem> quests) => quests
    .where((q) => q.isPending && q.kind != QuestKind.boss)
    .fold(0, (sum, q) => sum + q.penaltyDiamonds);

/// Время в строке квеста: начало, иначе дедлайн; «в течение дня» (дедлайн в полночь/23:59) — null.
DateTime? questTimeOf(QuestItem q) {
  final s = q.startsAt;
  if (s != null) return s;
  final d = q.deadlineAt;
  final endOfDay = (d.hour == 0 && d.minute == 0) || (d.hour == 23 && d.minute == 59);
  return endOfDay ? null : d;
}

/// Доля прогресса 0..1: по цели (progress/target) или по подзадачам; null — без шкалы.
double? questProgressOf(QuestItem q) {
  final t = q.target;
  if (t != null && t > 0) return (q.progress / t).clamp(0.0, 1.0).toDouble();
  if (q.subtasks.isNotEmpty) return q.subtasks.where((s) => s.done).length / q.subtasks.length;
  return null;
}

/// Красная подсветка: просрочен, провален или отказ.
bool questIsRed(QuestItem q, DateTime now) =>
    q.overdueAt(now) || q.status == QuestStatus.failed || q.status == QuestStatus.refused;

/// Шаг кнопки прогресса: 1 для малых целей, десятая часть цели для больших (шаги, мл).
int progressStepOf(QuestItem q) {
  final t = q.target ?? 1;
  if (t <= 20) return 1;
  return (t / 10).ceil();
}

/// Свой квест можно редактировать и архивировать (из плана — правится через план).
bool questEditable(QuestItem q) => q.source == QuestSource.user && q.kind != QuestKind.penalty && q.kind != QuestKind.boss;

/// Ввод для формы редактирования по экземпляру.
/// TODO(A): в контракте нет чтения шаблона (дни недели, чередование) — берём что есть в экземпляре.
QuestInput questInputFromItem(QuestItem q) {
  final s = q.startsAt;
  final time = questTimeOf(q);
  final window = s == null ? 60 : q.deadlineAt.difference(s).inMinutes;
  return QuestInput(
    kind: q.kind,
    title: q.title,
    stat: q.stat,
    subtasks: [for (final t in q.subtasks) t.title],
    minute: time == null ? null : time.hour * 60 + time.minute,
    windowMinutes: window > 0 ? window : 60,
    reward: q.reward,
    penaltyDiamonds: q.penaltyDiamonds,
    refusePenaltyDiamonds: q.refusePenaltyDiamonds,
    confirm: q.confirm,
    target: q.target,
    nag: q.nag,
    cancellable: q.cancellable,
    source: q.source,
  );
}

/// Группировка недели по дням (пн..вс), босс — отдельно.
Map<DateTime, List<QuestItem>> groupByDay(Iterable<QuestItem> list) {
  final res = <DateTime, List<QuestItem>>{};
  for (final q in list) {
    if (q.kind == QuestKind.boss) continue;
    (res[dayOf(q.day)] ??= []).add(q);
  }
  for (final e in res.entries) {
    res[e.key] = sortQuests(e.value);
  }
  return res;
}
