import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../domain/quests/quest_api.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../quests/quest_actions.dart';
import '../data/home_providers.dart';
import '../models/home_view_data.dart';
import '../utils/home_format.dart';

/// Блок 4: следующий квест (золотая тема) — кольцо-таймер, награда/штраф, действия.
/// Действия идут в движок (QuestService); окна последствий показывает OutcomeWindowsHost.
class NextQuestPanel extends ConsumerStatefulWidget {
  const NextQuestPanel({super.key, required this.quest});

  final NextQuest quest;

  @override
  ConsumerState<NextQuestPanel> createState() => _NextQuestPanelState();
}

class _NextQuestPanelState extends ConsumerState<NextQuestPanel> {
  Timer? _ticker;
  late DateTime _now;

  DateTime Function() get _clock => ref.read(homeNowSourceProvider);

  @override
  void initState() {
    super.initState();
    _now = _clock();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = _clock());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _act(Future<void> Function(QuestService s, String id, DateTime now) f) {
    final id = widget.quest.instanceId;
    if (id == null) return;
    runQuestAction(context, ref, (s, now) => f(s, id, now));
  }

  void _onNoWater(AppLocalizations l) {
    _act((s, id, now) => s.snooze(id, at: now));
    showSystemWindow<void>(
      context,
      window: SystemWindow(
        kind: SystemWindowKind.notice,
        label: l.homeNoticeLabel,
        message: l.homeNoWaterMessage,
        actions: [
          // Маршрут к ближайшему магазину с водой (этап 4).
          Builder(
            builder: (ctx) => SysButton.primary(
              label: l.wlkShop,
              icon: SysGlyph.water,
              onPressed: () {
                // Панель могла смениться после «отложить» — роутер берём из окна.
                final router = GoRouter.of(ctx);
                Navigator.of(ctx).pop();
                router.push('${Routes.walks}?shop=water');
              },
            ),
          ),
          Builder(builder: (ctx) => SysButton.secondary(label: l.homeOk, onPressed: () => Navigator.of(ctx).pop())),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final nf = NumberFormat.decimalPattern(l.localeName);
    final q = widget.quest;
    final deadline = q.deadline;
    final left = deadline.difference(_now);
    final leftText = formatCountdown(left);
    final fraction = remainingFraction(q.startedAt, deadline, _now);
    final overdue = left.isNegative;
    final ringColor = overdue ? SysColors.danger : SysColors.gold;

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          q.title.of(l),
          style: SysText.body.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            // Подписи «Награда/Штраф» — в семантике, на экране только значения (компактно).
            Semantics(
              label: l.homeRewardLabel,
              child: SysPill(
                label: '${l.homeRewardPoints(nf.format(q.rewardPoints))}  ${l.homeRewardXp(nf.format(q.rewardXp))}',
                tone: PanelTone.gold,
                icon: SysGlyph.diamond,
              ),
            ),
            Semantics(
              label: l.homePenaltyLabel,
              child: SysPill(
                label: l.homePenaltyPoints(nf.format(q.penaltyPoints)),
                tone: PanelTone.danger,
                icon: SysGlyph.warning,
              ),
            ),
          ],
        ),
      ],
    );

    return SysPanel(
      appearDelay: const Duration(milliseconds: 120),
      title: l.homeNextQuestTitle,
      tone: PanelTone.gold,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      trailing: Text(
        l.homeQuestDeadline(DateFormat.Hm(l.localeName).format(deadline)),
        style: SysText.mono.copyWith(fontSize: 12, color: SysColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Semantics(
                label: l.homeTimeLeftSemantics(leftText),
                excludeSemantics: true,
                child: ProgressRing(
                  progress: fraction,
                  size: 64,
                  strokeWidth: 5,
                  color: ringColor,
                  center: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        leftText,
                        textScaler: TextScaler.noScaling,
                        style: SysText.mono.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: overdue ? SysColors.dangerLight : SysColors.textPrimary,
                          shadows: [Shadow(color: ringColor, blurRadius: 8)],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: info),
            ],
          ),
          const SizedBox(height: 10),
          _Actions(
            done: SysButton.primary(
              label: l.homeActionDone,
              icon: SysGlyph.check,
              expand: true,
              onPressed: () => _act((s, id, now) => s.complete(id, at: now)),
            ),
            snooze: SysButton.secondary(
              label: l.homeActionSnooze,
              icon: SysGlyph.clock,
              onPressed: () => _act((s, id, now) => s.snooze(id, at: now)),
            ),
            contextAction: q.contextAction == NextQuestContextAction.noWater
                ? SysButton.secondary(label: l.homeActionNoWater, icon: SysGlyph.water, onPressed: () => _onNoWater(l))
                : null,
            // Штрафной квест: отказа нет.
            refuse: q.cancellable
                ? HoldButton(
                    key: const Key('next-quest-refuse'),
                    label: l.homeActionRefuse,
                    semanticHint: l.homeRefuseHint,
                    tone: PanelTone.danger,
                    expand: true,
                    onCompleted: () => _act((s, id, now) => s.refuse(id, at: now)),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            q.cancellable ? l.homeRefuseHint : l.qstNoRefuse,
            textAlign: TextAlign.right,
            style: SysText.caption.copyWith(color: SysColors.dangerLight, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

/// Кнопки квеста в два ряда: [Выполнено ····][+10 мин] / [Нет воды][Отказ (удержание) ····].
/// На узкой ширине или при крупном шрифте — столбиком.
class _Actions extends StatelessWidget {
  const _Actions({required this.done, required this.snooze, this.refuse, this.contextAction});

  final Widget done;
  final Widget snooze;
  final Widget? refuse;
  final Widget? contextAction;

  @override
  Widget build(BuildContext context) {
    final ctx = contextAction;
    final refuse = this.refuse;
    return LayoutBuilder(builder: (context, c) {
      final scale = MediaQuery.textScalerOf(context).scale(14) / 14;
      if (c.maxWidth / scale < 300) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            done,
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: [snooze, ?ctx]),
            if (refuse != null) ...[const SizedBox(height: 8), refuse],
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [Expanded(child: done), const SizedBox(width: 8), snooze]),
          if (refuse != null || ctx != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              if (ctx != null) ...[ctx, if (refuse != null) const SizedBox(width: 8)],
              if (refuse != null) Expanded(child: refuse),
            ]),
          ],
        ],
      );
    });
  }
}
