import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/live/live_api.dart';
import 'package:sistema/core/live/live_codec.dart';
import 'package:sistema/l10n/app_localizations.dart';

void main() {
  test('liveStateToArgs: мс, конечные числа, прогресс 0..1', () {
    final a = liveStateToArgs(LiveState(
      title: 'Прогулка',
      subtitle: 'налево',
      endsAt: DateTime.fromMillisecondsSinceEpoch(1700000000000),
      distanceM: double.nan,
      paceSecPerKm: 330,
      progress: 1.7,
    ));
    expect(a['title'], 'Прогулка');
    expect(a['subtitle'], 'налево');
    expect(a['endsAt'], 1700000000000);
    expect(a['distanceM'], isNull);
    expect(a['paceSecPerKm'], 330);
    expect(a['progress'], 1.0);
  });

  test('widgetData: квест, дедлайн в секундах, очередь воды, подписи', () {
    final now = DateTime(2026, 3, 5, 10);
    final d = widgetData(
      WidgetSnapshotPlus(
        nextQuestTitle: '  Отжимания ',
        nextQuestDeadline: DateTime.fromMillisecondsSinceEpoch(1700000000999),
        steps: -5,
        waterMl: 500,
        waterGoalMl: 2000,
        level: 3,
        diamonds: 40,
        nextQuestRewardDiamonds: 15,
      ),
      now: now,
      pendingWaterMl: 250,
      labels: widgetLabels(lookupAppLocalizations(const Locale('ru'))),
    );
    expect(d[WidgetKeys.nextQuestTitle], 'Отжимания');
    expect(d[WidgetKeys.nextQuestDeadline], 1700000000);
    expect(d[WidgetKeys.nextQuestReward], 15);
    expect(d[WidgetKeys.steps], 0);
    expect(d[WidgetKeys.waterMl], 750);
    expect(d[WidgetKeys.day], '2026-03-05');
    expect(d[WidgetKeys.lblAddWater], '+250 мл');
  });

  test('widgetData: без квеста ключи квеста удаляются', () {
    final d = widgetData(
      WidgetSnapshot(nextQuestTitle: ' ', nextQuestDeadline: DateTime(2026)),
      now: DateTime(2026),
    );
    expect(d.containsKey(WidgetKeys.nextQuestTitle), isTrue);
    expect(d[WidgetKeys.nextQuestTitle], isNull);
    expect(d[WidgetKeys.nextQuestDeadline], isNull);
    expect(d[WidgetKeys.nextQuestReward], isNull);
  });

  test('подпись снимка различает данные', () {
    const a = WidgetSnapshot(steps: 1);
    const b = WidgetSnapshot(steps: 2);
    expect(widgetSnapshotSignature(a), widgetSnapshotSignature(const WidgetSnapshot(steps: 1)));
    expect(widgetSnapshotSignature(a), isNot(widgetSnapshotSignature(b)));
  });
}
