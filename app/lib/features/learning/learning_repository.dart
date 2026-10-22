// Курсы и уроки (таблицы Courses, Lessons): создание курса по плану с сервера, подгрузка уроков по мере надобности,
// прохождение и повторения. Поля синхронизации: updatedAt (UTC), deviceId, version+1 — синхронизация сама.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/db/database.dart';
import 'learning_logic.dart';

/// Клиент эндпоинтов /api/v1/learning/*. Ошибки — [AiException].
class LearningApi {
  const LearningApi(this._gw);

  final AiGateway _gw;

  Future<({String title, List<({String title, String goal})> lessons})> outline({
    required String topic,
    required String lang,
    required int lessons,
  }) async {
    final r = await _gw.json('POST', '/api/v1/learning/outline', body: {'topic': topic, 'lang': lang, 'lessons': lessons});
    final list = [
      for (final e in (r['lessons'] as List? ?? const []))
        if (e is Map && e['title'] is String) (title: e['title'] as String, goal: e['goal'] as String? ?? ''),
    ];
    if (list.isEmpty) throw const AiException(AiFailure.server, 'empty_outline');
    return (title: r['title'] as String? ?? topic, lessons: list);
  }

  Future<({String title, List<LessonBlock> blocks, List<QuizQuestion> quiz})> lesson({
    required String topic,
    required String title,
    required String goal,
    required String lang,
    required int index,
  }) async {
    final r = await _gw.json('POST', '/api/v1/learning/lesson',
        body: {'topic': topic, 'title': title, 'goal': goal, 'lang': lang, 'index': index});
    final blocks = LessonContent.blocksFrom(r['content']);
    if (blocks.isEmpty) throw const AiException(AiFailure.server, 'empty_lesson');
    return (title: r['title'] as String? ?? title, blocks: blocks, quiz: QuizQuestion.listFrom(r['quiz']));
  }
}

class LearningRepository {
  LearningRepository(this._db, this._api, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final AppDatabase _db;
  final LearningApi _api;
  final DateTime Function() _clock;

  Stream<List<CourseRow>> watchCourses() => (_db.select(_db.courses)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .watch();

  Stream<List<LessonRow>> watchLessons() => (_db.select(_db.lessons)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm(expression: t.orderIndex)]))
      .watch();

  Future<LessonRow?> getLesson(String id) =>
      (_db.select(_db.lessons)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<CourseRow?> getCourse(String id) =>
      (_db.select(_db.courses)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Новый курс: план уроков с сервера → Courses + Lessons (содержимое — позже, по мере надобности).
  Future<String> createCourse({required String topic, required String lang, required int dailyLessons, required int lessons}) async {
    final plan = await _api.outline(topic: topic.trim(), lang: lang, lessons: lessons);
    final id = newId();
    final deviceId = await _db.deviceId();
    final now = _clock();
    await _db.transaction(() async {
      await _db.into(_db.courses).insert(CoursesCompanion.insert(
            id: id,
            updatedAt: now.toUtc(),
            deviceId: deviceId,
            title: plan.title,
            topic: topic.trim(),
            lang: lang,
            totalLessons: Value(plan.lessons.length),
            dailyLessons: Value(dailyLessons),
            createdAt: now,
          ));
      for (var i = 0; i < plan.lessons.length; i++) {
        final l = plan.lessons[i];
        await _db.into(_db.lessons).insert(LessonsCompanion.insert(
              id: newId(),
              updatedAt: now.toUtc(),
              deviceId: deviceId,
              courseId: id,
              orderIndex: i,
              title: l.title,
              content: LessonContent(goal: l.goal).encode(),
            ));
      }
    });
    return id;
  }

  /// Урок с содержимым: если ещё не загружен — запрос к серверу и сохранение.
  Future<LessonRow> ensureLoaded(LessonRow lesson) async {
    final c = LessonContent.decode(lesson.content);
    if (c.loaded) return lesson;
    final course = await getCourse(lesson.courseId);
    if (course == null) return lesson;
    final r = await _api.lesson(
      topic: course.topic,
      title: lesson.title,
      goal: c.goal,
      lang: course.lang,
      index: lesson.orderIndex,
    );
    await _patch(
      lesson.id,
      LessonsCompanion(
        content: Value(LessonContent(goal: c.goal, blocks: r.blocks).encode()),
        quiz: Value(QuizQuestion.encode(r.quiz)),
      ),
    );
    return (await getLesson(lesson.id)) ?? lesson;
  }

  Future<void> markOpened(LessonRow lesson) async {
    if (lesson.openedAt != null) return;
    await _patch(lesson.id, LessonsCompanion(openedAt: Value(_clock())));
  }

  /// Итог урока. Возвращает true, если урок впервые засчитан (для квеста «учёба»).
  Future<bool> finish(LessonRow lesson, {required int percent}) async {
    final now = _clock();
    final passed = percent >= SpacedRepetition.passPercent;
    if (lesson.completedAt == null) {
      if (!passed) {
        await _patch(lesson.id, LessonsCompanion(score: Value(percent)));
        return false;
      }
      final sr = SpacedRepetition.afterLesson(now);
      await _patch(
        lesson.id,
        LessonsCompanion(
          completedAt: Value(now),
          score: Value(percent),
          reviewStep: Value(sr.step),
          nextReviewAt: Value(sr.next),
        ),
      );
      await _closeCourseIfDone(lesson.courseId);
      return true;
    }
    final sr = SpacedRepetition.afterReview(lesson.reviewStep, passed, now);
    await _patch(
      lesson.id,
      LessonsCompanion(score: Value(percent), reviewStep: Value(sr.step), nextReviewAt: Value(sr.next)),
    );
    return false;
  }

  Future<void> setCourseStatus(String courseId, String status) =>
      _patchCourse(courseId, CoursesCompanion(status: Value(status)));

  Future<void> deleteCourse(String courseId) async {
    final now = _clock();
    await _patchCourse(courseId, CoursesCompanion(deletedAt: Value(now)));
    final ls = await (_db.select(_db.lessons)..where((t) => t.courseId.equals(courseId) & t.deletedAt.isNull())).get();
    for (final l in ls) {
      await _patch(l.id, LessonsCompanion(deletedAt: Value(now)));
    }
  }

  Future<void> _closeCourseIfDone(String courseId) async {
    final left = await (_db.select(_db.lessons)
          ..where((t) => t.courseId.equals(courseId) & t.deletedAt.isNull() & t.completedAt.isNull()))
        .get();
    if (left.isEmpty) await setCourseStatus(courseId, 'done');
  }

  Future<void> _patch(String id, LessonsCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final e = await getLesson(id);
      if (e == null) return;
      await (_db.update(_db.lessons)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(deviceId),
            version: Value(e.version + 1),
          ));
    });
  }

  Future<void> _patchCourse(String id, CoursesCompanion patch) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final e = await getCourse(id);
      if (e == null) return;
      await (_db.update(_db.courses)..where((t) => t.id.equals(id))).write(patch.copyWith(
            updatedAt: Value(_clock().toUtc()),
            deviceId: Value(deviceId),
            version: Value(e.version + 1),
          ));
    });
  }
}

/// Пункт «Сегодня»: урок дня или повторение.
class TodayItem {
  const TodayItem(this.course, this.lesson, {required this.review});

  final CourseRow course;
  final LessonRow lesson;
  final bool review;
}

/// Уроки дня (по dailyLessons минус пройденные сегодня) и повторения (nextReviewAt не позже конца дня).
List<TodayItem> buildToday(List<CourseRow> courses, List<LessonRow> lessons, DateTime now) {
  final dayStart = DateTime(now.year, now.month, now.day);
  final dayEnd = dayStart.add(const Duration(days: 1));
  final out = <TodayItem>[];
  final reviews = <TodayItem>[];
  for (final c in courses) {
    final ls = lessons.where((l) => l.courseId == c.id).toList()..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    if (c.status == 'active') {
      final doneToday = ls.where((l) => l.completedAt != null && !l.completedAt!.isBefore(dayStart)).length;
      final slots = c.dailyLessons - doneToday;
      if (slots > 0) {
        for (final l in ls.where((l) => l.completedAt == null).take(slots)) {
          out.add(TodayItem(c, l, review: false));
        }
      }
    }
    if (c.status == 'paused') continue;
    for (final l in ls) {
      final next = l.nextReviewAt;
      if (l.completedAt != null && next != null && next.isBefore(dayEnd)) reviews.add(TodayItem(c, l, review: true));
    }
  }
  return [...out, ...reviews];
}

// ---- провайдеры ----

final learningClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final learningRepositoryProvider = Provider<LearningRepository>((ref) => LearningRepository(
      ref.watch(databaseProvider),
      LearningApi(ref.watch(aiGatewayProvider)),
      clock: ref.watch(learningClockProvider),
    ));

final coursesProvider = StreamProvider<List<CourseRow>>((ref) => ref.watch(learningRepositoryProvider).watchCourses());

final allLessonsProvider = StreamProvider<List<LessonRow>>((ref) => ref.watch(learningRepositoryProvider).watchLessons());
