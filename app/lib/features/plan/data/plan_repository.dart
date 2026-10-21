// Хранилище планов (таблица Plans). Черновик — строка без acceptedAt; принятие проставляет acceptedAt.
// Поля синхронизации (updatedAt/deviceId/version) проставляются здесь, как в ProfileRepository.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../draft_plan_builder.dart';
import '../model/plan.dart';
import 'plan_inputs_loader.dart';

/// Строка плана + разобранная модель.
class StoredPlan {
  const StoredPlan({required this.row, required this.plan});
  final PlanRow row;
  final Plan plan;

  String get id => row.id;
  DateTime? get acceptedAt => row.acceptedAt;
  bool get accepted => row.acceptedAt != null;
}

class PlanRepository {
  PlanRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$PlansTable, PlanRow> _latest({required bool accepted}) => _db.select(_db.plans)
    ..where((t) => t.deletedAt.isNull() & (accepted ? t.acceptedAt.isNotNull() : t.acceptedAt.isNull()))
    ..orderBy([
      (t) => OrderingTerm.desc(accepted ? t.acceptedAt : t.createdAt),
      (t) => OrderingTerm.desc(t.createdAt),
    ])
    ..limit(1);

  static StoredPlan? _parse(PlanRow? row) {
    if (row == null) return null;
    try {
      final json = jsonDecode(row.payload);
      if (json is! Map<String, Object?>) return null;
      return StoredPlan(row: row, plan: Plan.fromJson(json));
    } on FormatException {
      return null;
    } on TypeError {
      return null;
    }
  }

  Future<StoredPlan?> latestAccepted() async => _parse(await _latest(accepted: true).getSingleOrNull());

  Stream<StoredPlan?> watchLatestAccepted() => _latest(accepted: true).watchSingleOrNull().map(_parse);

  Future<StoredPlan?> latestDraft() async => _parse(await _latest(accepted: false).getSingleOrNull());

  /// Сохранить черновик: последний непринятый черновик перезаписывается, иначе создаётся новая строка.
  Future<String> saveDraft(Plan plan, {String source = 'local'}) async {
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    final payload = jsonEncode(plan.toJson());
    return _db.transaction(() async {
      final existing = await _latest(accepted: false).getSingleOrNull();
      if (existing == null) {
        final id = newId();
        await _db.into(_db.plans).insert(PlansCompanion.insert(
              id: id,
              updatedAt: now,
              deviceId: deviceId,
              version: const Value(1),
              createdAt: now,
              source: Value(source),
              payload: payload,
            ));
        return id;
      }
      await (_db.update(_db.plans)..where((t) => t.id.equals(existing.id))).write(PlansCompanion(
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(existing.version + 1),
            createdAt: Value(now),
            source: Value(source),
            payload: Value(payload),
          ));
      return existing.id;
    });
  }

  /// Принять план: acceptedAt = сейчас. Прежние принятые планы остаются как история.
  Future<void> accept(String id) async {
    final deviceId = await _db.deviceId();
    final now = DateTime.now().toUtc();
    await _db.transaction(() async {
      final row = await (_db.select(_db.plans)..where((t) => t.id.equals(id))).getSingle();
      await (_db.update(_db.plans)..where((t) => t.id.equals(id))).write(PlansCompanion(
            acceptedAt: Value(now),
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}

final planRepositoryProvider = Provider<PlanRepository>((ref) => PlanRepository(ref.watch(databaseProvider)));

/// Последний принятый план (для главного экрана и этапа 2).
final acceptedPlanProvider = StreamProvider<StoredPlan?>((ref) => ref.watch(planRepositoryProvider).watchLatestAccepted());

final draftPlanBuilderProvider = Provider<DraftPlanBuilder>((ref) => const DraftPlanBuilder());

/// Пересчёт чернового плана из текущих данных с сохранением черновика.
class PlanDraftService {
  PlanDraftService(this._loader, this._builder, this._repo);

  final PlanInputsLoader _loader;
  final DraftPlanBuilder _builder;
  final PlanRepository _repo;

  Future<StoredPlan> recalculate({DateTime? now}) async {
    final inputs = await _loader.load(now: now);
    final plan = _builder.build(inputs, now: now);
    await _repo.saveDraft(plan);
    return (await _repo.latestDraft())!;
  }
}

final planDraftServiceProvider = Provider<PlanDraftService>((ref) => PlanDraftService(
      ref.watch(planInputsLoaderProvider),
      ref.watch(draftPlanBuilderProvider),
      ref.watch(planRepositoryProvider),
    ));
