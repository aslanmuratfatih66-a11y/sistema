// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

class QuestSubtask {
  const QuestSubtask(this.title, {this.done = false});
  final String title;
  final bool done;
}

/// Строка квеста: чекбокс, время, название, награда/штраф, подзадачи, прогресс.
/// Просроченные — красным.
class QuestRow extends StatelessWidget {
  const QuestRow({
    super.key,
    required this.title,
    this.time,
    this.done = false,
    this.overdue = false,
    this.reward,
    this.penalty,
    this.subtasks = const [],
    this.progress,
    this.progressText,
    this.onToggle,
  });

  final String title;
  final String? time;
  final bool done;
  final bool overdue;

  /// Готовый текст награды, например «+20 ◆».
  final String? reward;

  /// Готовый текст штрафа, например «−15 ◆».
  final String? penalty;
  final List<QuestSubtask> subtasks;

  /// 0..1, null — без прогресс-бара.
  final double? progress;
  final String? progressText;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) => Text(title);
}
