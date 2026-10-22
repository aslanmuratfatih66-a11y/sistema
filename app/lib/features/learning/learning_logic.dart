// Знания (SPEC §8.9): модель урока (содержимое Lessons.content/quiz — JSON) и интервальные повторения.
import 'dart:convert';

/// Блок урока: p — объяснение, example — пример/упражнение, tip — совет.
class LessonBlock {
  const LessonBlock(this.type, this.text);

  final String type;
  final String text;

  Map<String, Object?> toJson() => {'type': type, 'text': text};
}

class QuizQuestion {
  const QuizQuestion({required this.q, required this.options, required this.answer, this.explain = ''});

  final String q;
  final List<String> options;
  final int answer;
  final String explain;

  Map<String, Object?> toJson() => {'q': q, 'options': options, 'answer': answer, 'explain': explain};

  static List<QuizQuestion> listFrom(Object? raw) {
    if (raw is! List) return const [];
    final out = <QuizQuestion>[];
    for (final e in raw) {
      if (e is! Map) continue;
      final opts = [for (final o in (e['options'] as List? ?? const [])) if (o is String) o];
      final a = (e['answer'] as num?)?.toInt() ?? -1;
      final q = e['q'];
      if (q is! String || opts.length < 2 || a < 0 || a >= opts.length) continue;
      out.add(QuizQuestion(q: q, options: opts, answer: a, explain: e['explain'] as String? ?? ''));
    }
    return out;
  }

  static List<QuizQuestion> decode(String s) {
    try {
      return listFrom(jsonDecode(s));
    } catch (_) {
      return const [];
    }
  }

  static String encode(List<QuizQuestion> qs) => jsonEncode([for (final q in qs) q.toJson()]);
}

/// Содержимое урока в Lessons.content: {"goal": "...", "blocks": [...]}. Пустые blocks — урок ещё не загружен.
class LessonContent {
  const LessonContent({this.goal = '', this.blocks = const []});

  final String goal;
  final List<LessonBlock> blocks;

  bool get loaded => blocks.isNotEmpty;

  static LessonContent decode(String s) {
    try {
      final m = jsonDecode(s);
      if (m is! Map) return const LessonContent();
      return LessonContent(goal: m['goal'] as String? ?? '', blocks: blocksFrom(m['blocks']));
    } catch (_) {
      return const LessonContent();
    }
  }

  static List<LessonBlock> blocksFrom(Object? raw) => [
        if (raw is List)
          for (final b in raw)
            if (b is Map && b['text'] is String && (b['text'] as String).trim().isNotEmpty)
              LessonBlock(b['type'] as String? ?? 'p', b['text'] as String),
      ];

  String encode() => jsonEncode({'goal': goal, 'blocks': [for (final b in blocks) b.toJson()]});
}

/// Интервальные повторения: ступени 1, 3, 7, 16, 35 дней (по Lessons.reviewStep).
abstract final class SpacedRepetition {
  static const intervalsDays = [1, 3, 7, 16, 35];

  /// Доля правильных для зачёта урока или повторения.
  static const passPercent = 60;

  static DateTime _at(DateTime now, int step) => DateTime(now.year, now.month, now.day + intervalsDays[step]);

  /// Урок пройден впервые: ступень 0, повтор через 1 день.
  static ({int step, DateTime? next}) afterLesson(DateTime now) => (step: 0, next: _at(now, 0));

  /// Повторение: успех — ступень вперёд (после последней повторений больше нет), ошибка — ступень назад.
  static ({int step, DateTime? next}) afterReview(int step, bool passed, DateTime now) {
    if (passed) {
      final s = step + 1;
      return (step: s, next: s < intervalsDays.length ? _at(now, s) : null);
    }
    final s = (step - 1).clamp(0, intervalsDays.length - 1);
    return (step: s, next: _at(now, s));
  }

  static int percent(int correct, int total) => total == 0 ? 100 : (correct * 100 / total).round();
}
