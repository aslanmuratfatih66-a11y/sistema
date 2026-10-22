// Сценарий «нет воды» (SPEC §9.3): после построения маршрута к магазину — разовый квест-прогулка
// «Дойти до магазина» на сегодня (движок квестов: createQuest с activeFrom = activeUntil = сегодня).
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/notifications/reminder_texts.dart';
import '../../domain/quests/quest_api.dart';
import '../../domain/walks/walk_api.dart';

/// Создаёт квест «Дойти до магазина за водой», который начинается сейчас; время на выполнение —
/// длительность маршрута туда и обратно с запасом (не меньше 30 мин). Возвращает id шаблона квеста.
Future<String> startWaterShopQuest(WidgetRef ref, RoutePlan plan, {DateTime? now}) async {
  final t = now ?? DateTime.now();
  final l = await reminderL10n(ref.read(databaseProvider));
  // Пешком ~1.3 м/с, если сервис не дал времени; ×2 — обратно, +15 мин — на покупку.
  final oneWayS = plan.durationS ?? (plan.distanceM / 1.3).round();
  final window = math.max(30, (oneWayS * 2 / 60).ceil() + 15);
  final today = DateTime(t.year, t.month, t.day);
  return ref.read(questServiceProvider).createQuest(QuestInput(
        kind: QuestKind.custom,
        title: QuestTitle(text: l.msgWaterQuestTitle),
        stat: StatKind.endurance,
        minute: t.hour * 60 + t.minute,
        windowMinutes: window,
        activeFrom: today,
        activeUntil: today,
        reward: const GameReward(diamonds: 5, xp: 10, stats: {StatKind.endurance: 1}),
        nag: false, // человек уже идёт — без повторов каждую минуту
        source: QuestSource.system,
      ));
}
