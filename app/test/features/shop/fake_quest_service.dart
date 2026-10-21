// Фейковый движок для тестов магазина и дисциплины: баланс, покупки (пишет purchase в журнал БД), дисциплина.
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/quest_api.dart';

class FakeQuestService implements QuestService {
  FakeQuestService({this.db, this._diamonds = 0, this._discipline = false});

  final AppDatabase? db;
  int _diamonds;
  bool _discipline;
  final _history = <HistoryEntry>[];
  final purchases = <({String rewardId, String title, int price})>[];
  final disciplineCalls = <({bool active, String? reasonKey})>[];
  final _player = StreamController<PlayerSnapshot>.broadcast();
  final _historyCtl = StreamController<List<HistoryEntry>>.broadcast();

  int get diamonds => _diamonds;

  PlayerSnapshot get snapshot => PlayerSnapshot(
        diamonds: _diamonds,
        xp: 0,
        level: 1,
        xpIntoLevel: 0,
        xpForNextLevel: 100,
        rank: PlayerRank.e,
        stats: const {},
        statDeltaToday: const {},
        freeStatPoints: 0,
        streakDays: 0,
        effects: const [],
        disciplineActive: _discipline,
      );

  void setBalance(int v) {
    _diamonds = v;
    _player.add(snapshot);
  }

  void addHistory(HistoryEntry e) {
    _history.insert(0, e);
    _historyCtl.add(List.of(_history));
  }

  @override
  Stream<PlayerSnapshot> watchPlayer() async* {
    yield snapshot;
    yield* _player.stream;
  }

  @override
  Stream<List<HistoryEntry>> watchHistory({int limit = 100}) async* {
    yield List.of(_history);
    yield* _historyCtl.stream;
  }

  @override
  Future<bool> purchase({required String rewardId, required String title, required int price, DateTime? at}) async {
    if (_diamonds < 0 || _diamonds < price) return false;
    purchases.add((rewardId: rewardId, title: title, price: price));
    final d = db;
    if (d != null) {
      await d.into(d.questEvents).insert(QuestEventsCompanion.insert(
            id: newId(),
            updatedAt: DateTime.now().toUtc(),
            deviceId: await d.deviceId(),
            type: QuestEventType.purchase.name,
            occurredAt: at ?? DateTime.now(),
            diamonds: Value(-price),
            payload: Value(jsonEncode({'rewardId': rewardId, 'title': title})),
          ));
    }
    setBalance(_diamonds - price);
    return true;
  }

  @override
  Future<void> setDiscipline({required bool active, String? reasonKey, DateTime? at}) async {
    disciplineCalls.add((active: active, reasonKey: reasonKey));
    _discipline = active;
    addHistory(HistoryEntry(
      id: newId(),
      type: active ? QuestEventType.disciplineOn : QuestEventType.disciplineOff,
      occurredAt: at ?? DateTime.now(),
      payload: {'reason': ?reasonKey},
    ));
    _player.add(snapshot);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('FakeQuestService: ${invocation.memberName}');
}
