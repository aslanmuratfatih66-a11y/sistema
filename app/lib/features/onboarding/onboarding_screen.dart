import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'onboarding_progress.dart';
import 'onboarding_step.dart';
import 'step_registry.dart';
import 'step_scope.dart';

/// Анкета первого запуска (SPEC §5): окно-приглашение, затем 12 этапов с прогрессом.
/// Текущий этап сохраняется — можно закрыть приложение и продолжить.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(onboardingProgressProvider);
    return ListenableBuilder(
      listenable: progress,
      builder: (context, _) => progress.introSeen
          ? _StepsView(progress: progress)
          : _Intro(onAccept: progress.acceptIntro),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({required this.onAccept});

  final VoidCallback onAccept;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: SystemWindow(
                kind: SystemWindowKind.notice,
                label: l.onbIntroLabel,
                title: l.onbIntroTitle,
                message: l.onbIntroMessage,
                actions: [SysButton.primary(label: l.onbIntroAccept, onPressed: onAccept, expand: true)],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepsView extends StatefulWidget {
  const _StepsView({required this.progress});

  final OnboardingProgress progress;

  @override
  State<_StepsView> createState() => _StepsViewState();
}

class _StepsViewState extends State<_StepsView> {
  final _scroll = ScrollController();
  late StepController _controller = StepController(editing: false);
  late int _shownIndex = widget.progress.stepIndex;

  @override
  void didUpdateWidget(_StepsView old) {
    super.didUpdateWidget(old);
    _syncStep();
  }

  void _syncStep() {
    if (_shownIndex == widget.progress.stepIndex) return;
    _shownIndex = widget.progress.stepIndex;
    _controller.dispose();
    _controller = StepController(editing: false);
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final p = widget.progress;
    if (p.stepIndex == OnboardingStep.values.length - 1) {
      await p.complete();
      if (mounted) context.go(Routes.plan);
    } else {
      await p.goTo(p.stepIndex + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    _syncStep();
    final p = widget.progress;
    final l = AppLocalizations.of(context);
    final last = p.stepIndex == OnboardingStep.values.length - 1;
    return StepFrame(
      step: p.step,
      controller: _controller,
      scroll: _scroll,
      counter: l.onbStepCounter(p.stepIndex + 1, OnboardingStep.values.length),
      progress: (p.stepIndex + 1) / OnboardingStep.values.length,
      actions: [
        if (p.stepIndex > 0)
          Expanded(child: SysButton.secondary(label: l.commonBack, onPressed: () => p.goTo(p.stepIndex - 1), expand: true)),
        if (p.stepIndex > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => SysButton.primary(
              label: last ? l.onbFinish : l.commonNext,
              onPressed: _controller.canProceed ? _next : null,
              expand: true,
            ),
          ),
        ),
      ],
    );
  }
}

/// Общая рамка шага: шапка «ЭТАП n/12 · НАЗВАНИЕ», полоса прогресса, прокручиваемое
/// содержимое шага и кнопки снизу. Используется онбордингом и редактированием в настройках.
class StepFrame extends StatelessWidget {
  const StepFrame({
    super.key,
    required this.step,
    required this.controller,
    required this.actions,
    this.counter,
    this.progress,
    this.scroll,
    this.onClose,
  });

  final OnboardingStep step;
  final StepController controller;
  final List<Widget> actions;
  final String? counter;
  final double? progress;
  final ScrollController? scroll;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final c = counter;
    final pr = progress;
    final close = onClose;
    return Scaffold(
      backgroundColor: SysColors.background,
      resizeToAvoidBottomInset: true,
      body: SystemBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Row(
                  children: [
                    SysIcon(step.glyph, size: 22, color: SysColors.accentLight),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (c != null) Text(c.toUpperCase(), style: SysText.monoSmall),
                          Semantics(header: true, child: Text(step.title(l).toUpperCase(), style: SysText.heading)),
                        ],
                      ),
                    ),
                    if (close != null)
                      SysIconButton(glyph: SysGlyph.close, tooltip: l.commonClose, size: 20, onPressed: close),
                  ],
                ),
              ),
              if (pr != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SysBar(value: pr),
                ),
              Expanded(
                child: StepScope(
                  controller: controller,
                  child: SingleChildScrollView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: KeyedSubtree(key: ValueKey(step), child: buildStepContent(step)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(children: actions),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
