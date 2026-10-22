// Единое отображение ошибок ИИ/сети во всех фичах: иконка и тема по виду ошибки,
// текст — из фичи (свои формулировки), кнопка «Повторить», если повтор имеет смысл.
import 'package:flutter/widgets.dart';

import '../../core/ai/ai_api.dart';
import '../../ui/ui.dart';

/// Вид ошибки из исключения (не AiException — как ошибка сервера).
AiFailure aiFailureOf(Object error) => error is AiException ? error.failure : AiFailure.server;

SysGlyph aiFailureGlyph(AiFailure f) => switch (f) {
      AiFailure.offline => SysGlyph.offline,
      AiFailure.notSignedIn => SysGlyph.lock,
      AiFailure.budget => SysGlyph.diamond,
      AiFailure.rateLimited => SysGlyph.timer,
      AiFailure.unavailable || AiFailure.server => SysGlyph.warning,
    };

/// Лимит — «золотая» тема (не авария), остальное — «опасность».
PanelTone aiFailureTone(AiFailure f) =>
    f == AiFailure.budget || f == AiFailure.rateLimited ? PanelTone.gold : PanelTone.danger;

/// Повтор бессмыслен без входа в аккаунт и при исчерпанном бюджете.
bool aiFailureRetryable(AiFailure f) => f != AiFailure.notSignedIn && f != AiFailure.budget;

/// Панель ошибки ИИ/сети.
class AiErrorView extends StatelessWidget {
  const AiErrorView({
    super.key,
    required this.failure,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.extra,
    this.animateIn = true,
    this.alwaysRetry = false,
  });

  /// Из любого исключения.
  AiErrorView.fromError(
    Object error, {
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel,
    this.extra,
    this.animateIn = true,
    this.alwaysRetry = false,
  }) : failure = aiFailureOf(error);

  final AiFailure failure;
  final String message;
  final VoidCallback? onRetry;
  final String? retryLabel;
  final Widget? extra;
  final bool animateIn;

  /// Показывать «Повторить» при любой ошибке (если повтор уже был доступен раньше).
  final bool alwaysRetry;

  @override
  Widget build(BuildContext context) => SysErrorState(
        message: message,
        glyph: aiFailureGlyph(failure),
        tone: aiFailureTone(failure),
        onRetry: alwaysRetry || aiFailureRetryable(failure) ? onRetry : null,
        retryLabel: retryLabel,
        extra: extra,
        animateIn: animateIn,
      );
}
