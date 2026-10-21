// Главный экран (вкладка «Статус», SPEC §4 + уточнение 2026-10-21): только шапка, сжатый
// статус, эффекты, следующий квест и лента дня. Квесты/босс — во вкладке «Квесты», калории —
// в «Питании», финансы — в «Ещё». Нижняя навигация — в AppShell.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import 'data/demo_home_data.dart';
import 'widgets/day_timeline_panel.dart';
import 'widgets/effects_panel.dart';
import 'widgets/home_header.dart';
import 'widgets/next_quest_panel.dart';
import 'widgets/status_panel.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _gap = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(homeDataProvider);

    final blocks = <Widget>[
      HomeHeader(
        unread: data.unreadNotifications,
        programStart: data.programStart,
        onSettings: () => context.go(Routes.more),
      ),
      StatusPanel(player: data.player),
      EffectsPanel(effects: data.effects),
      if (data.nextQuest != null) NextQuestPanel(quest: data.nextQuest!),
      DayTimelinePanel(plan: data.day),
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
