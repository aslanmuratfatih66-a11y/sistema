// Хост системных окон: слушает QuestService.outcomes и показывает окна по одному (очередью).
// Выполнение квеста — короткой плашкой сверху, без модального окна. Подряд идущие провалы
// (например, после долгого отсутствия) склеиваются в одно окно.
// Должен стоять под Navigator (оборачивает содержимое AppShell).
import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../domain/quests/quest_api.dart';
import '../../../domain/quests/quest_l10n.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import 'outcome_windows.dart';

class OutcomeWindowsHost extends ConsumerStatefulWidget {
  const OutcomeWindowsHost({super.key, required this.child});

  final Widget child;

  /// Сколько держится плашка «Квест выполнен».
  static const toastDuration = Duration(seconds: 3);

  @override
  ConsumerState<OutcomeWindowsHost> createState() => _OutcomeWindowsHostState();
}

class _OutcomeWindowsHostState extends ConsumerState<OutcomeWindowsHost> {
  StreamSubscription<GameOutcome>? _sub;
  final Queue<GameOutcome> _queue = Queue();
  bool _showing = false;
  QuestCompleted? _toast;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    try {
      _sub = ref.read(questServiceProvider).outcomes.listen(_onOutcome);
    } on Object catch (e) {
      // Движок не подключён (предпросмотр/тест без override) — окон нет.
      debugPrint('OutcomeWindowsHost: нет QuestService ($e)');
    }
  }

  void _onOutcome(GameOutcome o) {
    if (!mounted) return;
    if (o is QuestCompleted) {
      _toastTimer?.cancel();
      setState(() => _toast = o);
      _toastTimer = Timer(OutcomeWindowsHost.toastDuration, () {
        if (mounted) setState(() => _toast = null);
      });
      return;
    }
    _queue.add(o);
    // Даём событиям одного действия (провал + штраф + уровень) собраться в очередь.
    scheduleMicrotask(_pump);
  }

  Future<void> _pump() async {
    if (_showing || _queue.isEmpty || !mounted) return;
    _showing = true;
    try {
      Object next = _queue.removeFirst();
      if (next is QuestFailed && _queue.isNotEmpty && _queue.first is QuestFailed) {
        final batch = [next];
        while (_queue.isNotEmpty && _queue.first is QuestFailed) {
          batch.add(_queue.removeFirst() as QuestFailed);
        }
        next = QuestsFailedBatch(batch);
      }
      final window = buildOutcomeWindow(context, next);
      if (window != null) await showOutcomeDialog(context, window);
    } finally {
      _showing = false;
    }
    if (mounted) await _pump();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _toastTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = _toast;
    return Stack(
      children: [
        Positioned.fill(child: widget.child),
        if (t != null)
          Positioned(
            left: 16,
            right: 16,
            top: 0,
            child: SafeArea(
              child: _CompletedToast(
                key: const Key('toast-completed'),
                outcome: t,
                onClose: () => setState(() => _toast = null),
              ),
            ),
          ),
      ],
    );
  }
}

/// Плашка «[ Уведомление ] Квест выполнен · +10 ◆ +15 XP» (зелёная).
class _CompletedToast extends StatelessWidget {
  const _CompletedToast({super.key, required this.outcome, required this.onClose});

  final QuestCompleted outcome;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final r = outcome.reward;
    return Semantics(
      liveRegion: true,
      child: GestureDetector(
        onTap: onClose,
        child: SysPanel(
          tone: PanelTone.success,
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          child: Row(
            children: [
              const SysIcon(SysGlyph.check, size: 18, color: SysColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '[ ${l.homeNoticeLabel.toUpperCase()} ] ${l.homeQuestCompletedTitle}',
                      style: SysText.title.copyWith(color: SysColors.success),
                    ),
                    Text(
                      questTitleText(l, outcome.quest.title),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SysText.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                [
                  if (r.diamonds != 0) l.homeRewardPoints(nf.format(r.diamonds)),
                  if (r.xp != 0) l.homeRewardXp(nf.format(r.xp)),
                ].join('  '),
                style: SysText.mono.copyWith(fontSize: 12.5, color: SysColors.gold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
