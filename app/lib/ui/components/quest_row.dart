import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'stat_bar.dart';
import 'sys_icon.dart';

class QuestSubtask {
  const QuestSubtask(this.title, {this.done = false});
  final String title;
  final bool done;
}

/// Строка квеста: чекбокс, время, название, награда/штраф, подзадачи, прогресс.
/// Просроченные — красным, выполненные — приглушены и зачёркнуты.
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
  Widget build(BuildContext context) {
    final isOverdue = overdue && !done;
    final accent = isOverdue ? SysColors.danger : (done ? SysColors.success : SysColors.accent);
    final titleColor = done ? SysColors.textInactive : (isOverdue ? SysColors.dangerLight : SysColors.textPrimary);
    final toggle = onToggle;
    final t = time;
    final r = reward;
    final pen = penalty;
    final pr = progress;
    final prText = progressText;

    final details = <Widget>[
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (t != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(
                t,
                style: SysText.mono.copyWith(
                  fontSize: 12,
                  color: isOverdue ? SysColors.danger : (done ? SysColors.textInactive : SysColors.textCaption),
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: SysText.body.copyWith(
                color: titleColor,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: SysColors.textInactive,
              ),
            ),
          ),
          if (r != null || pen != null) ...[
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (r != null)
                  Text(
                    r,
                    style: SysText.mono.copyWith(
                      fontSize: 12,
                      color: done ? SysColors.gold.withValues(alpha: .55) : SysColors.gold,
                    ),
                  ),
                if (pen != null)
                  Text(
                    pen,
                    style: SysText.mono.copyWith(
                      fontSize: 12,
                      color: done
                          ? SysColors.danger.withValues(alpha: .5)
                          : (isOverdue ? SysColors.danger : SysColors.dangerLight),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
      for (final s in subtasks)
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: _MiniCheck(done: s.done || done, color: accent),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  s.title,
                  style: SysText.caption.copyWith(
                    fontSize: 12,
                    color: (s.done || done) ? SysColors.textInactive : SysColors.textSecondary,
                    decoration: (s.done || done) ? TextDecoration.lineThrough : null,
                    decorationColor: SysColors.textInactive,
                  ),
                ),
              ),
            ],
          ),
        ),
      if (pr != null)
        Padding(
          padding: const EdgeInsets.only(top: 7),
          child: Row(
            children: [
              Expanded(
                child: SysBar(value: pr, color: accent, height: 4),
              ),
              if (prText != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    prText,
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: SysText.monoSmall.copyWith(color: isOverdue ? SysColors.dangerLight : null),
                  ),
                ),
              ],
            ],
          ),
        ),
    ];

    return MergeSemantics(
      child: Semantics(
        checked: done,
        enabled: toggle != null,
        onTap: toggle == null ? null : () => toggle(!done),
        child: Opacity(
          opacity: done ? .78 : 1,
          child: Container(
            decoration: isOverdue
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [SysColors.danger.withValues(alpha: .12), SysColors.danger.withValues(alpha: 0)],
                    ),
                    border: const Border(left: BorderSide(color: SysColors.danger, width: 2)),
                  )
                : null,
            padding: const EdgeInsets.only(right: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuestCheckbox(done: done, color: accent, onTap: toggle == null ? null : () => toggle(!done)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12, bottom: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: details,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Квадратный чекбокс 20px в зоне нажатия 44×44.
class _QuestCheckbox extends StatelessWidget {
  const _QuestCheckbox({required this.done, required this.color, this.onTap});
  final bool done;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return Material(
      type: MaterialType.transparency,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        splashColor: color.withValues(alpha: .25),
        highlightColor: color.withValues(alpha: .1),
        excludeFromSemantics: true,
        child: SizedBox.square(
          dimension: SysDims.minTap,
          child: Center(
            child: AnimatedContainer(
              duration: reduce ? Duration.zero : const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: done ? color.withValues(alpha: .22) : color.withValues(alpha: .05),
                border: Border.all(color: done ? color : color.withValues(alpha: .7), width: 1.4),
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: done ? .5 : .2),
                    blurRadius: done ? 10 : 6,
                  ),
                ],
              ),
              child: done ? SysIcon(SysGlyph.check, size: 16, color: color) : null,
            ),
          ),
        ),
      ),
    );
  }
}

class _MiniCheck extends StatelessWidget {
  const _MiniCheck({required this.done, required this.color});
  final bool done;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 11,
      height: 11,
      decoration: BoxDecoration(
        color: done ? color.withValues(alpha: .25) : null,
        border: Border.all(color: done ? color : SysColors.textInactive, width: 1),
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: done ? SysIcon(SysGlyph.check, size: 9, color: color) : null,
    );
  }
}
