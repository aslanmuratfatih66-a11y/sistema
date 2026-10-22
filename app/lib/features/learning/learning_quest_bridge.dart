// Пройденный урок → квест плана «учёба» (QuestKey.study) на сегодня: без цели — закрыть, с целью в минутах —
// засчитать [lessonMinutes]. Ошибки движка (не подключён, квест закрыт параллельно) разделу не видны.
// TODO(главный агент): перенести в SectionQuestHooks.lessonCompleted, когда контракт хуков расширится.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/quests/quest_api.dart';
import '../plan/model/plan.dart' show QuestKey;

const lessonMinutes = 15;

Future<void> reportLessonToQuests(WidgetRef ref, {DateTime? at}) async {
  try {
    final quests = ref.read(questServiceProvider);
    final now = at ?? DateTime.now();
    final items = await quests.watchDay(DateTime(now.year, now.month, now.day)).first;
    for (final q in items) {
      if (!q.isPending || q.title.key != QuestKey.study.name) continue;
      final target = q.target;
      if (target == null) {
        await quests.complete(q.instanceId, at: now);
      } else {
        final left = target - q.progress;
        if (left <= 0) continue;
        await quests.addProgress(q.instanceId, left < lessonMinutes ? left : lessonMinutes, at: now);
      }
      return;
    }
  } catch (e) {
    debugPrint('learning → quests: $e');
  }
}
