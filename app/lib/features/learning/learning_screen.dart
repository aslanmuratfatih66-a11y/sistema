// Знания (SPEC §8.9): «Сегодня» (уроки дня + повторения), курсы с прогрессом, создание курса по теме.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'course_screen.dart';
import 'learning_common.dart';
import 'learning_repository.dart';
import 'lesson_screen.dart';

enum _Tab { today, courses }

class LearningScreen extends ConsumerStatefulWidget {
  const LearningScreen({super.key});

  @override
  ConsumerState<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends ConsumerState<LearningScreen> {
  _Tab _tab = _Tab.today;
  String _topic = '';
  int _perDay = 1;
  int _length = 10;
  bool _creating = false;
  String? _error;

  Future<void> _create() async {
    final topic = _topic.trim();
    if (topic.isEmpty || _creating) return;
    final l = AppLocalizations.of(context);
    final lang = courseLang(context);
    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(learningRepositoryProvider)
          .createCourse(topic: topic, lang: lang, dailyLessons: _perDay, lessons: _length);
      if (!mounted) return;
      setState(() {
        _topic = '';
        _tab = _Tab.courses;
      });
      await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CourseScreen(courseId: id)));
    } catch (e) {
      if (mounted) setState(() => _error = learningError(l, e));
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final courses = ref.watch(coursesProvider).value ?? const <CourseRow>[];
    final lessons = ref.watch(allLessonsProvider).value ?? const <LessonRow>[];
    final now = ref.watch(learningClockProvider)();

    return LearningFrame(
      title: l.lrnTitle,
      children: [
        SysSegmented<_Tab>(
          choices: [SysChoice(_Tab.today, l.lrnToday), SysChoice(_Tab.courses, l.lrnCourses)],
          value: _tab,
          onChanged: (t) => setState(() => _tab = t),
        ),
        const SizedBox(height: 16),
        if (_tab == _Tab.today) ..._today(l, buildToday(courses, lessons, now), courses.isEmpty),
        if (_tab == _Tab.courses) ...[
          _newCoursePanel(l),
          const SizedBox(height: 16),
          for (final c in courses) ...[
            _CourseTile(course: c, lessons: lessons.where((x) => x.courseId == c.id).toList()),
            const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }

  List<Widget> _today(AppLocalizations l, List<TodayItem> items, bool noCourses) {
    if (noCourses) {
      return [
        LearningMessage(l.lrnNoCourses),
        const SizedBox(height: 8),
        _newCoursePanel(l),
      ];
    }
    if (items.isEmpty) return [LearningMessage(l.lrnTodayEmpty, color: SysColors.success)];
    return [
      for (final it in items) ...[
        _TodayTile(item: it),
        const SizedBox(height: 10),
      ],
    ];
  }

  Widget _newCoursePanel(AppLocalizations l) => SysPanel(
        title: l.lrnNewCourse,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SysTextField(
              key: ValueKey('lrn-topic-${_topic.isEmpty}'),
              value: _topic,
              label: l.lrnTopic,
              hint: l.lrnTopicHint,
              onChanged: (v) => setState(() => _topic = v),
            ),
            const SysFieldGap(),
            SysFieldLabel(l.lrnPerDay),
            SysSegmented<int>(
              choices: const [SysChoice(1, '1'), SysChoice(2, '2'), SysChoice(3, '3')],
              value: _perDay,
              onChanged: (v) => setState(() => _perDay = v),
            ),
            const SysFieldGap(),
            SysFieldLabel(l.lrnLength),
            SysSegmented<int>(
              choices: const [SysChoice(5, '5'), SysChoice(10, '10'), SysChoice(20, '20'), SysChoice(30, '30')],
              value: _length,
              onChanged: (v) => setState(() => _length = v),
            ),
            if (_error != null) LearningMessage(_error!, color: SysColors.dangerLight),
            const SizedBox(height: 12),
            if (_creating)
              LearningBusy(l.lrnCreating)
            else
              SysButton.primary(
                label: l.lrnCreate,
                expand: true,
                onPressed: _topic.trim().isEmpty ? null : _create,
              ),
          ],
        ),
      );
}

class _TodayTile extends StatelessWidget {
  const _TodayTile({required this.item});

  final TodayItem item;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPressable(
      onTap: () => Navigator.of(context)
          .push(MaterialPageRoute<void>(builder: (_) => LessonScreen(lessonId: item.lesson.id))),
      child: SysPanel(
        tone: item.review ? PanelTone.boss : PanelTone.accent,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.course.title, style: SysText.caption),
                  const SizedBox(height: 4),
                  Text(item.lesson.title, style: SysText.title),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SysPill(
              label: item.review ? l.lrnReview : l.lrnLessonDay,
              tone: item.review ? PanelTone.boss : PanelTone.accent,
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({required this.course, required this.lessons});

  final CourseRow course;
  final List<LessonRow> lessons;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final total = lessons.isEmpty ? course.totalLessons : lessons.length;
    final done = lessons.where((x) => x.completedAt != null).length;
    final status = switch (course.status) {
      'paused' => l.lrnStatusPaused,
      'done' => l.lrnStatusDone,
      _ => null,
    };
    return SysPressable(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CourseScreen(courseId: course.id))),
      child: SysPanel(
        tone: course.status == 'done' ? PanelTone.success : PanelTone.accent,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: Text(course.title, style: SysText.title)),
                if (status != null) SysPill(label: status, tone: PanelTone.gold),
              ],
            ),
            const SizedBox(height: 8),
            StatBar(label: course.topic, value: done.toDouble(), max: total == 0 ? 1 : total.toDouble(), valueText: '$done/$total'),
          ],
        ),
      ),
    );
  }
}
