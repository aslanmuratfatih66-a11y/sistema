// Расходы ИИ за месяц и журнал действий ИИ с отменой (SPEC §9.1).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/ai/ai_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../chat/chat_texts.dart';
import 'ai_journal_api.dart';

class AiJournalScreen extends ConsumerWidget {
  const AiJournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(aiUsageProvider);
              ref.invalidate(aiActionsProvider);
              await ref.read(aiUsageProvider.future).catchError((Object _) => AiUsage.fromJson(const {}));
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(Icons.arrow_back, color: SysColors.accentLight),
                    ),
                    Expanded(child: Text(l.chtJournal.toUpperCase(), style: SysText.heading)),
                  ],
                ),
                const SizedBox(height: 8),
                const _UsagePanel(),
                const SizedBox(height: 16),
                const _ActionsPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _usd(double v) => '\$${v.toStringAsFixed(v < 10 ? 2 : 1)}';

String _taskName(AppLocalizations l, String task) => switch (task) {
      'chat' => l.chtTaskChat,
      'analysis' => l.chtTaskAnalysis,
      'plan' => l.chtTaskPlan,
      'plan_edit' => l.chtTaskPlanEdit,
      'short' => l.chtTaskShort,
      'bank_parse' => l.chtTaskBankParse,
      'food_vision' => l.chtTaskFoodVision,
      'body_vision' => l.chtTaskBodyVision,
      'learning' => l.chtTaskLearning,
      'tts' => l.chtTaskTts,
      _ => task,
    };

Widget _errorText(AppLocalizations l, Object e) =>
    Text(e is AiException ? aiFailureText(l, e.failure) : l.chtLoadFailed, style: SysText.secondary);

class _UsagePanel extends ConsumerWidget {
  const _UsagePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final usage = ref.watch(aiUsageProvider);
    return SysPanel(
      title: l.chtUsageTitle,
      child: usage.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
        error: (e, _) => _errorText(l, e),
        data: (u) {
          final share = u.budgetUsd > 0 ? u.monthUsd / u.budgetUsd : 0.0;
          final color = share >= .9
              ? SysColors.danger
              : share >= .7
                  ? SysColors.gold
                  : SysColors.accent;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.chtUsageMonth(_usd(u.monthUsd), _usd(u.budgetUsd)), style: SysText.mono),
              const SizedBox(height: 8),
              SysBar(value: share, color: color),
              const SizedBox(height: 6),
              Text(l.chtUsageToday(_usd(u.dayUsd)), style: SysText.caption),
              if (u.degraded) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SysIcon(SysGlyph.warning, size: 16, color: SysColors.gold),
                    const SizedBox(width: 8),
                    Expanded(child: Text(l.chtUsageDegraded, style: SysText.caption.copyWith(color: SysColors.gold))),
                  ],
                ),
              ],
              const SizedBox(height: 14),
              Text(l.chtUsageByTask.toUpperCase(), style: SysText.label),
              const SizedBox(height: 6),
              if (u.byTask.isEmpty) Text(l.chtUsageEmpty, style: SysText.secondary),
              for (final t in u.byTask)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      Expanded(child: Text(_taskName(l, t.task), style: SysText.body)),
                      Text(l.chtUsageCalls(t.calls), style: SysText.caption),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 64,
                        child: Text(_usd(t.usd), style: SysText.mono, textAlign: TextAlign.right),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ActionsPanel extends ConsumerWidget {
  const _ActionsPanel();

  Future<void> _undo(BuildContext context, WidgetRef ref, String id) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(aiJournalApiProvider).undo(id);
      ref.read(undoneAiActionsProvider.notifier).add(id);
      ref.invalidate(aiActionsProvider);
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.chtUndoFailed)));
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final actions = ref.watch(aiActionsProvider);
    final undone = ref.watch(undoneAiActionsProvider);
    final fmt = DateFormat('d MMM, HH:mm', Localizations.localeOf(context).languageCode);
    return SysPanel(
      title: l.chtActionsTitle,
      child: actions.when(
        loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
        error: (e, _) => _errorText(l, e),
        data: (list) => list.isEmpty
            ? Text(l.chtActionsEmpty, style: SysText.secondary)
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final a in list)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  a.summary,
                                  style: SysText.body.copyWith(
                                    decoration: a.undoneAt != null || undone.contains(a.id)
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(fmt.format(a.at), style: SysText.caption),
                              ],
                            ),
                          ),
                          if (a.undoneAt != null || undone.contains(a.id))
                            Text(l.chtUndone, style: SysText.caption)
                          else if (a.canUndo)
                            TextButton(onPressed: () => _undo(context, ref, a.id), child: Text(l.chtUndo)),
                        ],
                      ),
                    ),
                ],
              ),
      ),
    );
  }
}
