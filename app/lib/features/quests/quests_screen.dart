// Вкладка «Квесты» (SPEC §8.1): сегодня / неделя / история / привычки (§8.17), фильтры, босс недели, свои квесты,
// автоплан и занятость (§8.13), итоги дня, честные отметки дня и пауза. Данные — QuestService (движок A).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../app/routes.dart';
import '../../core/models/enums.dart';
import '../../domain/day_modes/day_modes.dart';
import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../habits/habits_view.dart';
import '../home/widgets/tab_section_view.dart';
import 'data/quest_providers.dart';
import 'quest_format.dart';
import 'widgets/busy_panel.dart';
import 'widgets/daily_quests_panel.dart';
import 'widgets/day_controls.dart';
import 'widgets/history_list.dart';
import 'widgets/quest_editor_screen.dart';
import 'widgets/quest_filters.dart';
import 'widgets/weekly_boss_panel.dart';

class QuestsScreen extends ConsumerWidget {
  const QuestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final view = ref.watch(questsViewProvider);

    final body = switch (view) {
      QuestsView.today => const _TodayView(),
      QuestsView.week => const _WeekView(),
      QuestsView.history => const _HistoryView(),
      QuestsView.habits => const HabitsView(),
    };

    return TabSectionView(
      scrollKey: const Key('quests-scroll'),
      title: l.navQuests,
      glyph: SysGlyph.quests,
      children: [
        SysSegmented<QuestsView>(
          key: const Key('quests-view'),
          choices: [
            SysChoice(QuestsView.today, l.qstViewToday),
            SysChoice(QuestsView.week, l.qstViewWeek),
            SysChoice(QuestsView.history, l.qstViewHistory),
            SysChoice(QuestsView.habits, l.habTitle),
          ],
          value: view,
          onChanged: ref.read(questsViewProvider.notifier).set,
        ),
        if (view == QuestsView.today || view == QuestsView.week) const QuestFiltersBar(),
        body,
      ],
    );
  }
}

/// Загрузка/ошибка стрима движка.
Widget _async<T>(AppLocalizations l, AsyncValue<T> v, Widget Function(T data) data) {
  final value = v.value;
  if (value != null) return data(value);
  if (v.hasError) {
    return SysErrorState(message: l.qstLoadError);
  }
  return const Column(
    mainAxisSize: MainAxisSize.min,
    children: [SysSkeletonPanel(lines: 3), SizedBox(height: 12), SysSkeletonPanel(lines: 3)],
  );
}

class _TodayView extends ConsumerWidget {
  const _TodayView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final today = ref.watch(questTodayProvider);
    final filter = ref.watch(questFilterProvider);
    final day = ref.watch(questDayProvider(today));
    final week = ref.watch(questWeekProvider(weekStartOf(today)));
    final player = ref.watch(questPlayerProvider).value;
    final pause = player?.pause;
    // Автоплан (§8.13): видно только текущее задание, следующее откроется после него.
    final autoplan = ref.watch(dayModesPrefsProvider).value?.autoplanActive(discipline: player?.disciplineActive ?? false) ?? false;
    final bosses = [for (final q in week.value ?? const <QuestItem>[]) if (q.kind == QuestKind.boss && filter.matches(q)) q];
    final onlyBoss = filter.kind == QuestKindFilter.boss;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!onlyBoss)
          _async(l, day, (list) {
            final quests = sortQuests(list.where((q) => q.kind != QuestKind.boss && filter.matches(q)));
            if (autoplan) {
              final open = [for (final q in quests) if (q.status == QuestStatus.pending) q];
              final closed = [for (final q in quests) if (q.status != QuestStatus.pending) q];
              final current = open.isEmpty ? <QuestItem>[] : [open.first];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  DailyQuestsPanel(quests: [...closed, ...current], emptyText: l.qstEmptyDay),
                  if (open.length > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      key: const Key('autoplan-hidden'),
                      children: [
                        const SysIcon(SysGlyph.lock, size: 16, color: SysColors.textCaption),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l.autoplanHidden(open.length - 1), style: SysText.caption)),
                      ],
                    ),
                  ],
                ],
              );
            }
            return DailyQuestsPanel(
              quests: quests,
              emptyText: filter.isEmpty ? l.qstEmptyDay : l.qstEmptyFiltered,
            );
          }),
        for (final b in bosses) ...[
          const SizedBox(height: TabSectionView.gap),
          WeeklyBossPanel(key: ValueKey('boss-${b.instanceId}'), boss: b),
        ],
        if (onlyBoss && bosses.isEmpty)
          SysPanel(title: l.homeBossTitle, tone: PanelTone.boss, child: SysEmptyState.inline(l.qstEmptyFiltered, glyph: SysGlyph.crown)),
        const SizedBox(height: TabSectionView.gap),
        SysButton.secondary(
          key: const Key('quest-new'),
          label: l.qstNewQuest,
          icon: SysGlyph.plus,
          expand: true,
          onPressed: () => QuestEditorScreen.open(Navigator.of(context)),
        ),
        const SizedBox(height: TabSectionView.gap),
        SysButton.secondary(
          key: const Key('day-summary-open'),
          label: l.sumTitle,
          icon: SysGlyph.status,
          expand: true,
          onPressed: () => context.push(Routes.daySummary),
        ),
        const SizedBox(height: TabSectionView.gap),
        const BusyPanel(),
        const SizedBox(height: TabSectionView.gap),
        const DayMarksPanel(),
        const SizedBox(height: TabSectionView.gap),
        PausePanel(pause: pause),
      ],
    );
  }
}

class _WeekView extends ConsumerWidget {
  const _WeekView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final today = ref.watch(questTodayProvider);
    final start = weekStartOf(today);
    final filter = ref.watch(questFilterProvider);
    final week = ref.watch(questWeekProvider(start));
    final dateFmt = DateFormat.MMMMEEEEd(l.localeName);

    return _async(l, week, (list) {
      final filtered = list.where(filter.matches).toList();
      final bosses = [for (final q in filtered) if (q.kind == QuestKind.boss) q];
      final byDay = groupByDay(filtered);
      final children = <Widget>[
        for (final b in bosses) WeeklyBossPanel(key: ValueKey('boss-${b.instanceId}'), boss: b),
        for (var i = 0; i < 7; i++)
          if (byDay[DateTime(start.year, start.month, start.day + i)] case final quests?)
            DailyQuestsPanel(
              key: ValueKey('week-day-$i'),
              title: dateFmt.format(DateTime(start.year, start.month, start.day + i)),
              quests: quests,
            ),
      ];
      if (children.isEmpty) {
        return SysPanel(
          title: l.qstViewWeek,
          child: Text(filter.isEmpty ? l.qstEmptyWeek : l.qstEmptyFiltered, style: SysText.secondary),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[if (i > 0) const SizedBox(height: TabSectionView.gap), c],
        ],
      );
    });
  }
}

class _HistoryView extends ConsumerWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return _async(l, ref.watch(questHistoryProvider), (list) => HistoryList(entries: list));
  }
}
