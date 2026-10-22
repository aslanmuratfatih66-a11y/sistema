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
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, color: SysColors.accentLight),
                    ),
                    Expanded(
                      child: Text(title.toUpperCase(), style: SysText.heading, maxLines: 2, overflow: TextOverflow.ellipsis),
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

class LearningMessage extends StatelessWidget {
  const LearningMessage(this.text, {super.key, this.color = SysColors.textSecondary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(text, style: SysText.body.copyWith(color: color)),
      );
}
