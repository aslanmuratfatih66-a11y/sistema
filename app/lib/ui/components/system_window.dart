import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import 'panel.dart';
import 'sys_icon.dart';
import 'window_appear.dart';

/// Вид системного сообщения: «[ Уведомление ]», «[ Предупреждение ]», «Квест провален».
enum SystemWindowKind { notice, warning, failed }

/// Системное окно-сообщение. Метку задаёт вызывающий (локализованную),
/// например «Уведомление» — компонент сам обрамляет её в «[ … ]»
/// (для notice и warning; для failed метка выводится как есть, крупно).
class SystemWindow extends StatelessWidget {
  const SystemWindow({
    super.key,
    required this.kind,
    required this.label,
    required this.message,
    this.title,
    this.actions = const [],
    this.animateIn = true,
    this.warningTone = PanelTone.gold,
  });

  final SystemWindowKind kind;
  final String label;
  final String? title;
  final String message;
  final List<Widget> actions;

  /// Анимация появления (масштаб + прозрачность + скан).
  final bool animateIn;

  /// Оттенок предупреждения: золотой (по умолчанию) или красный.
  final PanelTone warningTone;

  PanelTone get tone => switch (kind) {
    SystemWindowKind.notice => PanelTone.accent,
    SystemWindowKind.warning => warningTone,
    SystemWindowKind.failed => PanelTone.danger,
  };

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final failed = kind == SystemWindowKind.failed;
    final glyph = switch (kind) {
      SystemWindowKind.notice => SysGlyph.info,
      SystemWindowKind.warning => SysGlyph.warning,
      SystemWindowKind.failed => SysGlyph.close,
    };
    final headerText = failed ? label.toUpperCase() : '[ ${label.toUpperCase()} ]';
    final headerStyle =
        (failed ? SysText.heading.copyWith(fontSize: 22, letterSpacing: SysDims.headingSpacing(22)) : SysText.heading)
            .copyWith(
              color: tone == PanelTone.accent ? SysColors.textPrimary : p.light,
              shadows: [Shadow(color: p.main.withValues(alpha: .8), blurRadius: 12)],
            );
    final t = title;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SysIcon(glyph, size: failed ? 22 : 18, color: p.light),
            const SizedBox(width: 8),
            Flexible(
              child: Semantics(
                header: true,
                child: Text(headerText, textAlign: TextAlign.center, style: headerStyle),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [p.main.withValues(alpha: 0), p.main, p.main.withValues(alpha: 0)]),
          ),
        ),
        const SizedBox(height: 14),
        if (t != null) ...[
          Text(
            t,
            textAlign: TextAlign.center,
            style: SysText.title.copyWith(fontSize: 15, color: SysColors.textPrimary),
          ),
          const SizedBox(height: 8),
        ],
        Text(
          message,
          textAlign: TextAlign.center,
          style: SysText.body.copyWith(color: SysColors.textSecondary),
        ),
        if (actions.isNotEmpty) ...[const SizedBox(height: 18), _Actions(actions: actions)],
      ],
    );

    Widget window = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 380),
      child: Material(
        type: MaterialType.transparency,
        child: SysPanel(
          tone: tone,
          animateIn: false,
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
          child: content,
        ),
      ),
    );
    if (animateIn) window = WindowAppear(scanColor: p.light, child: window);
    return Semantics(scopesRoute: true, explicitChildNodes: true, child: window);
  }
}

class _Actions extends StatelessWidget {
  const _Actions({required this.actions});
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    if (actions.length == 1) return actions.first;
    if (actions.length == 2 && MediaQuery.textScalerOf(context).scale(14) <= 20) {
      return Row(
        children: [
          Expanded(child: actions[0]),
          const SizedBox(width: 10),
          Expanded(child: actions[1]),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(height: 10), actions[i]],
      ],
    );
  }
}

/// Показать системное окно модально (затемнённый барьер, анимация появления).
Future<T?> showSystemWindow<T>(BuildContext context, {required SystemWindow window, bool barrierDismissible = true}) {
  final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: SysColors.barrier,
    transitionDuration: reduce ? Duration.zero : SysDims.windowAppear,
    pageBuilder: (context, animation, secondaryAnimation) => SafeArea(
      child: Center(
        child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24), child: window),
      ),
    ),
    transitionBuilder: (context, animation, secondaryAnimation, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
  );
}
