// Общие части экранов «Знаний»: каркас экрана, тексты ошибок ИИ.
import 'package:flutter/material.dart';

import '../../core/ai/ai_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';

/// Понятное сообщение об ошибке ИИ (офлайн, не вошли, лимит…).
String learningError(AppLocalizations l, Object e) => switch (e) {
      AiException(failure: AiFailure.offline) => l.lrnErrOffline,
      AiException(failure: AiFailure.notSignedIn) => l.lrnErrNotSignedIn,
      AiException(failure: AiFailure.budget) => l.lrnErrBudget,
      AiException(failure: AiFailure.unavailable) => l.lrnErrUnavailable,
      _ => l.lrnErrServer,
    };

/// Язык курса: язык интерфейса (tr → турецкий, иначе русский).
String courseLang(BuildContext context) => Localizations.localeOf(context).languageCode == 'tr' ? 'tr' : 'ru';

class LearningFrame extends StatelessWidget {
  const LearningFrame({super.key, required this.title, required this.children, this.trailing});

  final String title;
  final List<Widget> children;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: SysColors.background,
        body: SystemBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    const SysBackButton(),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(title.toUpperCase(), style: SysText.heading, maxLines: 2, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    ?trailing,
                  ],
                ),
                const SizedBox(height: 8),
                ...children,
              ],
            ),
          ),
        ),
      );
}

/// Сообщение-состояние (пусто / готово / ошибка) в едином стиле дизайн-системы.
class LearningMessage extends StatelessWidget {
  const LearningMessage(this.text, {super.key, this.color = SysColors.textSecondary, this.glyph});

  final String text;
  final Color color;
  final SysGlyph? glyph;

  @override
  Widget build(BuildContext context) => SysEmptyState.inline(
        text,
        color: color,
        glyph: glyph ??
            switch (color) {
              SysColors.dangerLight => SysGlyph.warning,
              SysColors.success => SysGlyph.check,
              _ => SysGlyph.book,
            },
      );
}

/// Индикатор загрузки с подписью (строкой).
class LearningBusy extends StatelessWidget {
  const LearningBusy(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          const SysLoader(size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: SysText.secondary)),
        ],
      );
}
