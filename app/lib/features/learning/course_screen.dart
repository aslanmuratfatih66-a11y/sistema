// Курс: уроки по порядку с отметками, прогресс, пауза/продолжить, удаление.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'learning_common.dart';
import 'learning_logic.dart';
import 'learning_repository.dart';
import 'lesson_screen.dart';

class CourseScreen extends ConsumerWidget {
  const CourseScreen({super.key, required this.courseId});

  final String courseId;

  Future<void> _delete(BuildContext context, WidgetRef ref, CourseRow c) async {
    final l = AppLocalizations.of(context);
    final ok = await showSystemWindow<bool>(
      context,
      window: SystemWindow(
        kind: SystemWindowKind.warning,
        warningTone: PanelTone.danger,
        label: l.lrnDelete,
        message: l.lrnDeleteConfirm(c.title),
        actions: [
          Builder(builder: (b) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(b).pop(false))),
          Builder(builder: (b) => SysButton.danger(label: l.lrnDelete, onPressed: () => Navigator.of(b).pop(true))),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(learningRepositoryProvider).deleteCourse(c.id);
    if (context.mounted) Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final courses = ref.watch(coursesProvider).value ?? const <CourseRow>[];
    final course = courses.where((c) => c.id == courseId).firstOrNull;
    if (course == null) return LearningFrame(title: l.lrnTitle, children: const []);
    final lessons = (ref.watch(allLessonsProvider).value ?? const <LessonRow>[])
        .where((x) => x.courseId == courseId)
        .toList();
    final done = lessons.where((x) => x.completedAt != null).length;
    final firstOpen = lessons.where((x) => x.completedAt == null).firstOrNull;
    final repo = ref.read(learningRepositoryProvider);

    return LearningFrame(
      title: course.title,
      children: [
        SysPanel(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StatBar(
                label: course.topic,
                value: done.toDouble(),
                max: lessons.isEmpty ? 1 : lessons.length.toDouble(),
                valueText: '$done/${lessons.length}',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: course.status == 'active'
                        ? SysButton.secondary(label: l.lrnPause, onPressed: () => repo.setCourseStatus(course.id, 'paused'))
                        : course.status == 'paused'
                            ? SysButton.primary(
                                label: l.lrnResume,
                                onPressed: () => repo.setCourseStatus(course.id, 'active'),
                              )
                            : SysPill(label: l.lrnStatusDone, tone: PanelTone.success),
                  ),
                  const Spacer(),
                  SysIconButton(
                    glyph: SysGlyph.trash,
                    tooltip: l.lrnDelete,
                    color: SysColors.dangerLight,
                    onPressed: () => _delete(context, ref, course),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final x in lessons) ...[
          _LessonTile(lesson: x, total: lessons.length, isNext: x.id == firstOpen?.id),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({required this.lesson, required this.total, required this.isNext});

  final LessonRow lesson;
  final int total;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final done = lesson.completedAt != null;
    final goal = LessonContent.decode(lesson.content).goal;
    return SysPressable(
      onTap: () =>
          Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => LessonScreen(lessonId: lesson.id))),
      child: SysPanel(
        tone: done ? PanelTone.success : PanelTone.accent,
        animateIn: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.lrnLessonOf(lesson.orderIndex + 1, total), style: SysText.caption),
                  const SizedBox(height: 2),
                  Text(lesson.title, style: done || isNext ? SysText.title : SysText.title.copyWith(color: SysColors.textInactive)),
                  if (goal.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(goal, style: SysText.secondary),
                  ],
                ],
              ),
            ),
            if (done) ...[
              const SizedBox(width: 8),
              SysPill(label: '${lesson.score ?? 0}%', tone: PanelTone.success),
            ],
          ],
        ),
      ),
    );
  }
}
