import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/core/notifications/notification_api.dart';
import 'package:sistema/core/notifications/reminder_coordinator.dart';
import 'package:sistema/core/notifications/reminder_texts.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/l10n/app_localizations.dart';

QuestItem quest(
  String id, {
  required DateTime deadline,
  DateTime? startsAt,
  DateTime? snoozedUntil,
  QuestStatus status = QuestStatus.pending,
  QuestKind kind = QuestKind.daily,
  int diamonds = 10,
  bool nag = true,
}) =>
    QuestItem(
      instanceId: id,
      questId: 'q-$id',
      kind: kind,
      title: QuestTitle(text: 'Выпить воды $id'),
      day: DateTime(deadline.year, deadline.month, deadline.day),
      deadlineAt: deadline,
      startsAt: startsAt,
      snoozedUntil: snoozedUntil,
      status: status,
      reward: GameReward(diamonds: diamonds),
      penaltyDiamonds: 5,
      refusePenaltyDiamonds: 3,
      nag: nag,
    );

class FakeQuests implements QuestService {
  List<QuestItem> items = [];
  List<GameOutcome> tickResult = [];
  final outcomeCtrl = StreamController<GameOutcome>.broadcast();
  final dayCtrl = StreamController<List<QuestItem>>.broadcast();
  final calls = <String>[];
  final watchedDays = <DateTime>[];

  @override
  Future<List<QuestItem>> upcoming(DateTime now, Duration horizon) async {
    calls.add('upcoming');
    return items;
  }

  @override
  Future<List<GameOutcome>> tick(DateTime now) async {
    calls.add('tick');
    return tickResult;
  }

  @override
  Future<List<GameOutcome>> complete(String instanceId, {DateTime? at}) async {
    calls.add('complete:$instanceId');
    items = items.where((q) => q.instanceId != instanceId).toList();
    return const [];
  }

  @override
  Future<void> snooze(String instanceId, {Duration by = const Duration(minutes: 10), DateTime? at}) async {
    calls.add('snooze:$instanceId');
  }

  @override
  Stream<GameOutcome> get outcomes => outcomeCtrl.stream;

  @override
  Stream<List<QuestItem>> watchDay(DateTime day) {
    watchedDays.add(day);
    return dayCtrl.stream;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeScheduler implements ReminderScheduler {
  final syncs = <List<ReminderRequest>>[];
  final cancelled = <String>[];
  final shown = <String>[];
  ReminderPrefs? lastPrefs;

  @override
  Future<void> init({required Future<void> Function(ReminderResponse) onResponse}) async {}

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> sync(List<ReminderRequest> upcoming, ReminderPrefs prefs, {required DateTime now}) async {
    syncs.add(upcoming);
    lastPrefs = prefs;
  }

  @override
  Future<void> cancelInstance(String instanceId) async => cancelled.add(instanceId);

  @override
  Future<void> showNow({required String title, required String body}) async => shown.add(title);
}

Future<void> settle() => Future<void>.delayed(const Duration(milliseconds: 20));

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final now = DateTime(2026, 10, 21, 12, 0);
  final l = lookupAppLocalizations(const Locale('ru'));

  late FakeQuests quests;
  late FakeScheduler scheduler;
  late StreamController<ReminderPrefs> prefsCtrl;
  late ReminderCoordinator c;
  var prefs = const ReminderPrefs();

  ReminderCoordinator build({bool foreground = true}) => ReminderCoordinator(
        quests: quests,
        scheduler: scheduler,
        loadPrefs: () async => prefs,
        prefsChanges: prefsCtrl.stream,
        l10n: () async => l,
        clock: () => now,
        debounce: Duration.zero,
        observeLifecycle: false,
        foreground: foreground,
      );

  setUp(() {
    quests = FakeQuests();
    scheduler = FakeScheduler();
    prefsCtrl = StreamController<ReminderPrefs>.broadcast();
    prefs = const ReminderPrefs();
    c = build();
  });
  tearDown(() => c.dispose());

  test('старт: tick, затем sync с локализованными текстами', () async {
    quests.items = [
      quest('a', startsAt: now.add(const Duration(minutes: 5)), deadline: now.add(const Duration(minutes: 35))),
    ];
    await c.start();
    expect(quests.calls.take(2), ['tick', 'upcoming']);
    final r = scheduler.syncs.last.single;
    expect(r.instanceId, 'a');
    expect(r.title, '[ Квест ] Выпить воды a');
    expect(r.body, contains('12:35'));
    expect(r.body, contains('+10 ◆'));
    expect(r.dueAt, now.add(const Duration(minutes: 5)));
    expect(r.reproachTitle, l.ntfReproachTitle);
    expect(r.reproachBody, contains('Выпить воды a'));
    expect(quests.watchedDays, [DateTime(2026, 10, 21), DateTime(2026, 10, 22)]);
  });

  test('закрытые не попадают, «+10 мин» — dueAt из snoozedUntil', () async {
    quests.items = [
      quest('done', deadline: now.add(const Duration(hours: 1)), status: QuestStatus.done),
      quest('s', deadline: now.add(const Duration(hours: 1)), snoozedUntil: now.add(const Duration(minutes: 10))),
    ];
    await c.start();
    final r = scheduler.syncs.last.single;
    expect(r.instanceId, 's');
    expect(r.dueAt, now.add(const Duration(minutes: 10)));
  });

  test('изменение квестов дня → sync (debounce)', () async {
    await c.start();
    final before = scheduler.syncs.length;
    quests.dayCtrl.add(const []);
    quests.dayCtrl.add(const []);
    await settle();
    expect(scheduler.syncs.length, before + 1);
  });

  test('изменение настроек → sync с новыми настройками', () async {
    await c.start();
    prefsCtrl.add(const ReminderPrefs()); // первое значение (текущее) пропускается
    prefs = const ReminderPrefs(nag: false);
    prefsCtrl.add(prefs);
    await settle();
    expect(scheduler.lastPrefs?.nag, isFalse);
  });

  test('«Выполнено» из уведомления: снять напоминания, complete, sync', () async {
    quests.items = [quest('a', deadline: now.add(const Duration(hours: 1)))];
    await c.start();
    await c.handleResponse(const ReminderResponse(instanceId: 'a', action: ReminderAction.done));
    expect(scheduler.cancelled, ['a']);
    expect(quests.calls, contains('complete:a'));
    expect(scheduler.syncs.last, isEmpty);
  });

  test('«+10 мин» из уведомления: snooze и sync', () async {
    await c.start();
    final before = scheduler.syncs.length;
    await c.handleResponse(const ReminderResponse(instanceId: 'a', action: ReminderAction.snooze10));
    expect(quests.calls, contains('snooze:a'));
    expect(scheduler.cancelled, isEmpty);
    expect(scheduler.syncs.length, before + 1);
  });

  test('выполнено на экране (outcome) → упрёк снимается; провал движком — нет', () async {
    await c.start();
    final q = quest('a', deadline: now);
    quests.outcomeCtrl.add(QuestCompleted(q, GameReward.none));
    quests.outcomeCtrl.add(QuestFailed(quest('b', deadline: now), 5));
    await settle();
    expect(scheduler.cancelled, ['a']);
  });

  test('на переднем плане последствия tick — без уведомлений, в фоне — уведомлением', () async {
    quests.tickResult = [QuestFailed(quest('a', deadline: now), 5), const LevelUp(level: 3, freeStatPoints: 2)];
    await c.refresh();
    expect(scheduler.shown, isEmpty);
    final bg = build(foreground: false);
    await bg.refresh();
    expect(scheduler.shown, [l.ntfFailedTitle, l.ntfLevelUpTitle]);
    await bg.dispose();
  });

  test('уход в фон и возврат: возврат — tick + sync', () async {
    var resumed = 0;
    final cc = ReminderCoordinator(
      quests: quests,
      scheduler: scheduler,
      loadPrefs: () async => prefs,
      l10n: () async => l,
      clock: () => now,
      debounce: Duration.zero,
      observeLifecycle: false,
      onResume: () async => resumed++,
    );
    cc.didChangeAppLifecycleState(AppLifecycleState.paused);
    expect(cc.isForeground, isFalse);
    final before = scheduler.syncs.length;
    cc.didChangeAppLifecycleState(AppLifecycleState.resumed);
    await settle();
    expect(cc.isForeground, isTrue);
    expect(resumed, 1);
    expect(scheduler.syncs.length, before + 1);
    await cc.dispose();
  });

  test('босс недели не надоедает каждую минуту; штрафной — свой заголовок', () {
    final boss = reminderRequestFor(l, quest('b', deadline: now, kind: QuestKind.boss))!;
    expect(boss.nag, isFalse);
    expect(boss.title, startsWith('[ Босс недели ]'));
    final pen = reminderRequestFor(l, quest('p', deadline: now, kind: QuestKind.penalty))!;
    expect(pen.title, startsWith('[ Штрафной квест ]'));
    expect(pen.body, l.ntfPenaltyQuestBody('12:00'));
    final noReward = reminderRequestFor(l, quest('n', deadline: now, diamonds: 0))!;
    expect(noReward.body, l.ntfQuestBodyNoReward('12:00'));
  });

  test('язык уведомлений: профиль → система → русский', () {
    expect(resolveReminderLocale('tr', const [Locale('ru')]).languageCode, 'tr');
    expect(resolveReminderLocale(null, const [Locale('en'), Locale('tr')]).languageCode, 'tr');
    expect(resolveReminderLocale(null, const [Locale('en')]).languageCode, 'ru');
    expect(resolveReminderLocale('de', const []).languageCode, 'ru');
  });
}
