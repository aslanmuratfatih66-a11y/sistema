// Общие элементы экранов тренировок.
import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../model/exercise_catalog.dart';
import '../model/workout_program.dart';
import '../wrk_l10n.dart';

/// Страница с заголовком и кнопкой «назад».
class WorkoutPage extends StatelessWidget {
  const WorkoutPage({super.key, required this.title, required this.child, this.onBack, this.actions = const [], this.bottom});

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = bottom;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                      tooltip: l.commonBack,
                      constraints: const BoxConstraints(minWidth: SysDims.minTap, minHeight: SysDims.minTap),
                      icon: const RotatedBox(
                        quarterTurns: 3,
                        child: SysIcon(SysGlyph.arrowUp, size: 22, color: SysColors.accentLight),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title.toUpperCase(), style: SysText.heading, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    ...actions,
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 8, 16, 24), child: child),
              ),
              if (b != null) Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: b),
            ],
          ),
        ),
      ),
    );
  }
}

SysGlyph categoryGlyph(ExerciseCategory? c) => switch (c) {
      ExerciseCategory.warmup => SysGlyph.flame,
      ExerciseCategory.legs => SysGlyph.walk,
      ExerciseCategory.push || ExerciseCategory.pull => SysGlyph.dumbbell,
      ExerciseCategory.core => SysGlyph.shield,
      ExerciseCategory.cardio => SysGlyph.heart,
      ExerciseCategory.cooldown => SysGlyph.moon,
      null => SysGlyph.bolt,
    };

/// «3 × 12» / «2 × 30 с».
String loadLabel(AppLocalizations l, ProgramExercise e) =>
    e.timed ? l.wrkSetsSeconds(e.sets, e.seconds!) : l.wrkSetsReps(e.sets, e.reps ?? 0);

/// «01:05».
String mmss(Duration d) {
  final s = d.inSeconds < 0 ? 0 : d.inSeconds;
  return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Техника по шагам: нумерованный список.
class TechniqueSteps extends StatelessWidget {
  const TechniqueSteps({super.key, required this.exerciseKey});

  final String exerciseKey;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lines = exerciseHint(l, exerciseKey).split('\n').where((s) => s.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < lines.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(width: 22, child: Text('${i + 1}.', style: SysText.monoSmall)),
                Expanded(child: Text(lines[i], style: SysText.secondary)),
              ],
            ),
          ),
      ],
    );
  }
}

/// Окно с техникой упражнения.
Future<void> showTechnique(BuildContext context, String exerciseKey) {
  final l = AppLocalizations.of(context);
  return showSystemWindow<void>(
    context,
    window: SystemWindow(
      key: const Key('wrk-technique'),
      kind: SystemWindowKind.notice,
      label: l.wrkTechnique,
      title: exerciseName(l, exerciseKey),
      message: exerciseHint(l, exerciseKey),
      actions: [
        Builder(builder: (c) => SysButton.primary(label: l.commonClose, onPressed: () => Navigator.of(c).pop())),
      ],
    ),
  );
}
