// Главный экран (вкладка «Статус», SPEC §4 + docs/navigation.md): шапка, сжатый статус, быстрые
// действия, эффекты, следующий квест и лента дня. Квесты/босс — во вкладке «Квесты», калории —
// в «Здоровье», финансы — в «Ещё». Нижняя навигация — в AppShell.
// Данные — движок квестов + расписание/план (data/home_live_data.dart).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'data/home_live_data.dart';
import 'widgets/day_timeline_panel.dart';
import 'widgets/effects_panel.dart';
import 'widgets/home_header.dart';
import 'widgets/next_quest_panel.dart';
import 'widgets/quick_actions_panel.dart';
import 'widgets/stat_points_sheet.dart';
import 'widgets/status_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _gap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final status = ref.watch(homeStatusProvider);
    final data = status.value;

    final blocks = <Widget>[
      HomeHeader(
        unread: data?.unreadNotifications ?? 0,
        programStart: data?.programStart ?? ref.watch(homeContextProvider.select((c) => c.programStart)),
        onSettings: () => context.push(Routes.settings),
      ),
      if (data != null) ...[
        StatusPanel(
          player: data.player,
          onStatPoints: () => showStatPointsSheet(context),
          onLevel: () => context.push(Routes.levels),
        ),
        EffectsPanel(effects: data.effects),
        if (data.nextQuest != null)
          NextQuestPanel(key: ValueKey('next-${data.nextQuest!.instanceId}'), quest: data.nextQuest!),
        const QuickActionsPanel(),
        DayTimelinePanel(plan: data.day),
      ] else if (status.hasError)
        SysErrorState(message: l.qstLoadError)
      else ...[
        const SysSkeletonPanel(lines: 4),
        const SysSkeletonPanel(lines: 2),
      ],
    ];

    // Material-предок нужен для InkResponse/TextField; фон рисует оболочка.
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          key: const Key('home-scroll'),
          slivers: [
            // Блоков немного — строим все сразу, чтобы локальное состояние
            // (таймер квеста) не терялось при прокрутке.
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < blocks.length; i++) ...[
                      if (i > 0) const SizedBox(height: _gap),
                      blocks[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
