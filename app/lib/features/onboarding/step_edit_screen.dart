import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'onboarding_screen.dart';
import 'onboarding_step.dart';
import 'step_scope.dart';

/// Редактирование одного раздела анкеты из настроек (SPEC §5: «любой этап потом редактируется»).
/// Данные сохраняются шагом сразу, «Готово» просто закрывает экран.
class StepEditScreen extends StatefulWidget {
  const StepEditScreen({super.key, required this.step});

  final OnboardingStep step;

  @override
  State<StepEditScreen> createState() => _StepEditScreenState();
}

class _StepEditScreenState extends State<StepEditScreen> {
  final _controller = StepController(editing: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => context.canPop() ? context.pop() : Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return StepFrame(
      step: widget.step,
      controller: _controller,
      onClose: _close,
      actions: [
        Expanded(
          child: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) =>
                SysButton.primary(label: l.commonDone, onPressed: _controller.canProceed ? _close : null, expand: true),
          ),
        ),
      ],
    );
  }
}
