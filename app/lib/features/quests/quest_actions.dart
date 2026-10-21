// Вызовы движка из UI: текущее время из инжектируемых часов, ошибки — системным окном.
// Окна последствий (провал, штраф, уровень) показывает OutcomeWindowsHost по стриму outcomes.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../home/data/home_providers.dart';

/// Выполнить действие движка. Возвращает false, если движок отклонил его.
Future<bool> runQuestAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function(QuestService service, DateTime now) action,
) async {
  final service = ref.read(questServiceProvider);
  final now = ref.read(homeNowSourceProvider)();
  try {
    await action(service, now);
    return true;
  } on Object catch (e) {
    debugPrint('Квест: действие отклонено: $e');
    if (context.mounted) await showActionRejected(context);
    return false;
  }
}

Future<void> showActionRejected(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showSystemWindow<void>(
    context,
    window: SystemWindow(
      kind: SystemWindowKind.warning,
      label: l.homeWarningLabel,
      message: l.qstActionRejected,
      actions: [
        Builder(builder: (c) => SysButton.primary(label: l.homeOk, onPressed: () => Navigator.of(c).pop())),
      ],
    ),
  );
}

/// Подтверждение системным окном: true — «да».
Future<bool> confirmSystem(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  PanelTone tone = PanelTone.gold,
  bool danger = false,
}) async {
  final l = AppLocalizations.of(context);
  final res = await showSystemWindow<bool>(
    context,
    window: SystemWindow(
      kind: SystemWindowKind.warning,
      warningTone: tone,
      label: l.homeWarningLabel,
      title: title,
      message: message,
      actions: [
        Builder(
          builder: (c) => SysButton.secondary(label: l.commonCancel, onPressed: () => Navigator.of(c).pop(false)),
        ),
        Builder(
          builder: (c) => danger
              ? SysButton.danger(label: confirmLabel, onPressed: () => Navigator.of(c).pop(true))
              : SysButton.primary(label: confirmLabel, onPressed: () => Navigator.of(c).pop(true)),
        ),
      ],
    ),
  );
  return res ?? false;
}
