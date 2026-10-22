// Список блокируемых приложений (BlockedApps) и попытки (BlockAttempts) — SPEC §8.6.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';
import '../quests/quest_api.dart';
import 'app_blocker_window.dart';

/// Причина штрафа за повторные попытки (QuestService.award reasonKey).
const blockedAttemptReasonKey = 'blockedAttempt';

/// Штраф с [blockPenaltyFromAttempt]-й попытки за ночь, ◆ за попытку, не больше [blockPenaltyMaxPerNight] штрафов.
const blockPenaltyFromAttempt = 3;
const blockPenaltyDiamonds = 2;
const blockPenaltyMaxPerNight = 5;

/// Повтор той же попытки (двойное срабатывание автоматизации/оверлея) в пределах этого окна не считается.
const _attemptDedup = Duration(seconds: 10);

/// Итог записи попытки.
class BlockAttemptResult {
  const BlockAttemptResult({required this.attemptsTonight, required this.penalty, this.recorded = true});

  /// Сколько попыток за эту ночь (включая записанную).
  final int attemptsTonight;

  /// Списано ◆ (0 — без штрафа: ранние попытки, пауза, лимит).
  final int penalty;

  /// false — дубль, не записан.
  final bool recorded;
}

class AppBlockerRepository {
  AppBlockerRepository(this._db, {this._quests});

  final AppDatabase _db;
  final QuestService? _quests;

  // ---------- Приложения ----------

  Stream<List<BlockedAppRow>> watchApps(String platform) => (_db.select(_db.blockedApps)
        ..where((t) => t.platform.equals(platform) & t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch();

  Future<List<BlockedAppRow>> apps(String platform) => (_db.select(_db.blockedApps)
        ..where((t) => t.platform.equals(platform) & t.deletedAt.isNull()))
      .get();

  /// Пакеты/ключи включённых приложений платформы.
  Future<List<String>> enabledAppIds(String platform) async =>
      [for (final r in await apps(platform)) if (r.enabled) r.appId];

  /// Были ли когда-нибудь строки платформы (включая удалённые) — для отметки по умолчанию.
  Future<bool> hasAnyRows(String platform) async =>
      (await (_db.select(_db.blockedApps)
                ..where((t) => t.platform.equals(platform))
                ..limit(1))
              .getSingleOrNull()) !=
      null;

  /// Включить/выключить приложение (создаёт строку при первом выборе).
  Future<void> setEnabled({
    required String platform,
    required String appId,
    required String name,
    required bool enabled,
  }) async {
    final now = DateTime.now().toUtc();
    final device = await _db.deviceId();
    final existing = await (_db.select(_db.blockedApps)
          ..where((t) => t.platform.equals(platform) & t.appId.equals(appId))
          ..limit(1))
        .getSingleOrNull();
    if (existing == null) {
      await _db.into(_db.blockedApps).insert(BlockedAppsCompanion.insert(
            id: newId(),
            updatedAt: now,
            deviceId: device,
            platform: platform,
            appId: appId,
            name: name,
            enabled: Value(enabled),
          ));
      return;
    }
    if (existing.enabled == enabled && existing.deletedAt == null && existing.name == name) return;
    await (_db.update(_db.blockedApps)..where((t) => t.id.equals(existing.id))).write(BlockedAppsCompanion(
      enabled: Value(enabled),
      name: Value(name),
      deletedAt: const Value(null),
      updatedAt: Value(now),
      deviceId: Value(device),
      version: Value(existing.version + 1),
    ));
  }

  /// Пакетная отметка по умолчанию (одна транзакция).
  Future<void> enableAll(String platform, Map<String, String> appIdToName) =>
      _db.transaction(() async {
        for (final e in appIdToName.entries) {
          await setEnabled(platform: platform, appId: e.key, name: e.value, enabled: true);
        }
      });

  // ---------- Попытки ----------

  Stream<int> watchAttemptCount(DateTime from, DateTime until) {
    final count = _db.blockAttempts.id.count();
    final q = _db.selectOnly(_db.blockAttempts)
      ..addColumns([count])
      ..where(_db.blockAttempts.deletedAt.isNull() &
          _db.blockAttempts.at.isBiggerOrEqualValue(from.toUtc()) &
          _db.blockAttempts.at.isSmallerThanValue(until.toUtc()));
    return q.map((r) => r.read(count) ?? 0).watchSingle();
  }

  Future<int> attemptCount(DateTime from, DateTime until) async {
    final count = _db.blockAttempts.id.count();
    final q = _db.selectOnly(_db.blockAttempts)
      ..addColumns([count])
      ..where(_db.blockAttempts.deletedAt.isNull() &
          _db.blockAttempts.at.isBiggerOrEqualValue(from.toUtc()) &
          _db.blockAttempts.at.isSmallerThanValue(until.toUtc()));
    return (await q.map((r) => r.read(count) ?? 0).getSingle());
  }

  /// Записать попытку открыть [appId] в момент [at] ночи [night]. С [blockPenaltyFromAttempt]-й попытки за ночь —
  /// штраф −[blockPenaltyDiamonds] ◆ (не больше [blockPenaltyMaxPerNight] раз; на паузе award ничего не списывает).
  Future<BlockAttemptResult> recordAttempt(String appId, {required DateTime at, required BlockWindow night}) async {
    final atUtc = at.toUtc();
    final recent = await (_db.select(_db.blockAttempts)
          ..where((t) =>
              t.appId.equals(appId) &
              t.deletedAt.isNull() &
              t.at.isBiggerOrEqualValue(atUtc.subtract(_attemptDedup)) &
              t.at.isSmallerOrEqualValue(atUtc.add(_attemptDedup)))
          ..limit(1))
        .getSingleOrNull();
    if (recent != null) {
      return BlockAttemptResult(
        attemptsTonight: await attemptCount(night.from, night.until),
        penalty: 0,
        recorded: false,
      );
    }
    await _db.into(_db.blockAttempts).insert(BlockAttemptsCompanion.insert(
          id: newId(),
          updatedAt: DateTime.now().toUtc(),
          deviceId: await _db.deviceId(),
          appId: appId,
          at: atUtc,
        ));
    final n = await attemptCount(night.from, night.until);
    var penalty = 0;
    final quests = _quests;
    if (quests != null && n >= blockPenaltyFromAttempt && n < blockPenaltyFromAttempt + blockPenaltyMaxPerNight) {
      try {
        final outcomes = await quests.award(
          diamonds: -blockPenaltyDiamonds,
          reasonKey: blockedAttemptReasonKey,
          ref: 'blk:$appId:${night.nightKey}:$n',
          at: at,
        );
        for (final o in outcomes) {
          if (o is PenaltyApplied) penalty += o.diamonds.abs();
        }
      } catch (_) {
        // Движок недоступен — попытка всё равно записана.
      }
    }
    return BlockAttemptResult(attemptsTonight: n, penalty: penalty);
  }
}

final appBlockerRepositoryProvider = Provider<AppBlockerRepository>((ref) {
  QuestService? quests;
  try {
    quests = ref.watch(questServiceProvider);
  } catch (_) {
    quests = null; // в тестах/без движка — без штрафов
  }
  return AppBlockerRepository(ref.watch(databaseProvider), quests: quests);
});
