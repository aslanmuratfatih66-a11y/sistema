// Урок: содержимое (подгружается с сервера при первом открытии) → проверка → результат и интервал повторения.
// Для пройденного урока тот же экран — повторение (сразу к проверке доступно после чтения).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'learning_common.dart';
import 'learning_logic.dart';
import 'learning_quest_bridge.dart';
import 'learning_repository.dart';

enum _Stage { read, quiz, result }

class LessonScreen extends ConsumerStatefulWidget {
  const LessonScreen({super.key, required this.lessonId});

  final String lessonId;

  @override
  ConsumerState<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends ConsumerState<LessonScreen> {
  LessonRow? _lesson;
  Object? _error;
  bool _loading = true;
  _Stage _stage = _Stage.read;

  // Проверка.
  List<QuizQuestion> _quiz = const [];
  int _q = 0;
  int? _picked;
  int _correct = 0;

  // Итог.
  bool _wasReview = false;
  int _percent = 0;
  int? _nextDays;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final repo = ref.read(learningRepositoryProvider);
    try {
      var lesson = await repo.getLesson(widget.lessonId);
      if (lesson == null) return;
      lesson = await repo.ensureLoaded(lesson);
      await repo.markOpened(lesson);
      if (!mounted) return;
      setState(() => _lesson = lesson);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startQuiz() {
    final lesson = _lesson;
    if (lesson == null) return;
    final quiz = QuizQuestion.decode(lesson.quiz);
    if (quiz.isEmpty) {
      _finish(100);
      return;
    }
    setState(() {
      _quiz = quiz;
      _q = 0;
      _picked = null;
      _correct = 0;
      _stage = _Stage.quiz;
    });
  }

  void _pick(int i) {
    if (_picked != null) return;
    setState(() {
      _picked = i;
      if (i == _quiz[_q].answer) _correct++;
    });
  }

  void _nextQuestion() {
    if (_q + 1 < _quiz.length) {
      setState(() {
        _q++;
        _picked = null;
      });
    } else {
      _finish(SpacedRepetition.percent(_correct, _quiz.length));
    }
  }

  Future<void> _finish(int percent) async {
    final lesson = _lesson;
    if (lesson == null) return;
    final repo = ref.read(learningRepositoryProvider);
    final wasReview = lesson.completedAt != null;
    final firstPass = await repo.finish(lesson, percent: percent);
    if (firstPass) await reportLessonToQuests(ref);
    final updated = await repo.getLesson(lesson.id);
    if (!mounted) return;
    final next = updated?.nextReviewAt;
    final now = ref.read(learningClockProvider)();
    setState(() {
      _lesson = updated ?? lesson;
      _wasReview = wasReview;
      _percent = percent;
      _nextDays = next == null
          ? null
          : DateTime(next.year, next.month, next.day).difference(DateTime(now.year, now.month, now.day)).inDays;
      _stage = _Stage.result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lesson = _lesson;
    return LearningFrame(
      title: lesson?.title ?? l.lrnTitle,
      children: [
        if (_loading)
          Row(
            children: [
              const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              const SizedBox(width: 10),
              Expanded(child: Text(l.lrnLoading, style: SysText.secondary)),
            ],
          )
        else if (_error != null) ...[
          LearningMessage(learningError(l, _error!), color: SysColors.dangerLight),
          const SizedBox(height: 8),
          SysButton.secondary(label: l.lrnRetry, onPressed: _load),
        ] else if (lesson != null)
          ...switch (_stage) {
            _Stage.read => _read(l, lesson),
            _Stage.quiz => _quizView(l),
            _Stage.result => _result(l),
          },
      ],
    );
  }

  List<Widget> _read(AppLocalizations l, LessonRow lesson) {
    final c = LessonContent.decode(lesson.content);
    final hasQuiz = QuizQuestion.decode(lesson.quiz).isNotEmpty;
    return [
      if (c.goal.isNotEmpty)
        SysPanel(
          title: l.lrnGoal,
          child: Text(c.goal, style: SysText.body),
        ),
      const SizedBox(height: 12),
      for (final b in c.blocks) ...[
        switch (b.type) {
          'example' => SysPanel(
              title: l.lrnExample,
              tone: PanelTone.gold,
              animateIn: false,
              child: SelectableText(b.text, style: SysText.mono),
            ),
          'tip' => SysPanel(
              title: l.lrnTip,
              tone: PanelTone.success,
              animateIn: false,
              child: Text(b.text, style: SysText.body),
            ),
          _ => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(b.text, style: SysText.body),
            ),
        },
        const SizedBox(height: 12),
      ],
      SysButton.primary(label: hasQuiz ? l.lrnStartQuiz : l.lrnFinish, expand: true, onPressed: _startQuiz),
    ];
  }

  List<Widget> _quizView(AppLocalizations l) {
    final q = _quiz[_q];
    final picked = _picked;
    return [
      SysPanel(
        key: ValueKey('lrn-q-$_q'),
        title: l.lrnQuestion(_q + 1, _quiz.length),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(q.q, style: SysText.title),
            const SizedBox(height: 12),
            for (var i = 0; i < q.options.length; i++) ...[
              _Option(
                text: q.options[i],
                state: picked == null
                    ? _OptState.idle
                    : i == q.answer
                        ? _OptState.correct
                        : i == picked
                            ? _OptState.wrong
                            : _OptState.idle,
                onTap: () => _pick(i),
              ),
              const SizedBox(height: 8),
            ],
            if (picked != null) ...[
              Text(
                picked == q.answer ? l.lrnCorrect : l.lrnWrong,
                style: SysText.label.copyWith(color: picked == q.answer ? SysColors.success : SysColors.dangerLight),
              ),
              if (q.explain.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(q.explain, style: SysText.secondary),
              ],
              const SizedBox(height: 12),
              SysButton.primary(label: l.lrnNext, expand: true, onPressed: _nextQuestion),
            ],
          ],
        ),
      ),
    ];
  }

  List<Widget> _result(AppLocalizations l) {
    final passed = _percent >= SpacedRepetition.passPercent;
    final lines = <String>[
      l.lrnScore(_percent),
      if (_wasReview) passed ? l.lrnReviewPassed : l.lrnReviewFailed,
      if (!_wasReview) passed ? l.lrnPassed : l.lrnFailed(SpacedRepetition.passPercent),
      if (passed || _wasReview) _nextDays == null ? l.lrnMastered : l.lrnNextReview(_nextDays!),
    ];
    return [
      SysPanel(
        title: l.lrnResult,
        tone: passed ? PanelTone.success : PanelTone.danger,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final s in lines) Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(s, style: SysText.body)),
          ],
        ),
      ),
      const SizedBox(height: 12),
      if (!passed && !_wasReview)
        SysButton.primary(label: l.lrnRetry, expand: true, onPressed: () => setState(() => _stage = _Stage.read))
      else
        SysButton.primary(label: l.commonDone, expand: true, onPressed: () => Navigator.of(context).maybePop()),
    ];
  }
}

enum _OptState { idle, correct, wrong }

class _Option extends StatelessWidget {
  const _Option({required this.text, required this.state, required this.onTap});

  final String text;
  final _OptState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (state) {
      _OptState.idle => SysColors.accent,
      _OptState.correct => SysColors.success,
      _OptState.wrong => SysColors.danger,
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: SysDims.minTap),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SysDims.radius),
          border: Border.all(color: color.withValues(alpha: state == _OptState.idle ? .4 : .9)),
          color: color.withValues(alpha: state == _OptState.idle ? .05 : .15),
        ),
        alignment: Alignment.centerLeft,
        child: Text(text, style: SysText.body),
      ),
    );
  }
}
