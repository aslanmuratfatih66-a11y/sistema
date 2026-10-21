// Замеры тела (BodyMeasurements, SPEC §8.3): новая строка на каждый замер, мягкое удаление.
// Замер из анкеты (OnboardingMeasurementRepository) — обычная строка этой же таблицы, попадает в историю.
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';

/// Показатель замера.
enum MeasureField { weight, waist, hips, chest, neck, arm, bodyFat }

extension MeasureFieldX on MeasureField {
  double? of(BodyMeasurementRow r) => switch (this) {
        MeasureField.weight => r.weightKg,
        MeasureField.waist => r.waistCm,
        MeasureField.hips => r.hipsCm,
        MeasureField.chest => r.chestCm,
        MeasureField.neck => r.neckCm,
        MeasureField.arm => r.armCm,
        MeasureField.bodyFat => r.bodyFatPct,
      };

  /// Допустимый диапазон ввода.
  (double, double) get range => switch (this) {
        MeasureField.weight => (25, 350),
        MeasureField.bodyFat => (2, 70),
        _ => (10, 250),
      };
}

/// Значения нового замера (null — не измерялось).
class MeasurementInput {
  const MeasurementInput(this.values, {this.measuredAt});

  final Map<MeasureField, double?> values;
  final DateTime? measuredAt;

  bool get isEmpty => values.values.every((v) => v == null);

  /// Первое поле вне диапазона или null.
  MeasureField? get invalidField {
    for (final e in values.entries) {
      final v = e.value;
      if (v == null) continue;
      final (lo, hi) = e.key.range;
      if (v < lo || v > hi) return e.key;
    }
    return null;
  }
}

/// Точка ряда показателя.
typedef MeasurePoint = ({DateTime at, double value});

class BodyMeasurementRepository {
  BodyMeasurementRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$BodyMeasurementsTable, BodyMeasurementRow> _all() => _db.select(_db.bodyMeasurements)
    ..where((t) => t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.asc(t.measuredAt)]);

  Future<List<BodyMeasurementRow>> all() => _all().get();

  Stream<List<BodyMeasurementRow>> watchAll() => _all().watch();

  /// Добавить замер. Бросает [ArgumentError], если все поля пустые или значение вне диапазона.
  Future<String> add(MeasurementInput input, {MeasurementSource source = MeasurementSource.manual}) async {
    if (input.isEmpty) throw ArgumentError('Пустой замер');
    final bad = input.invalidField;
    if (bad != null) throw ArgumentError.value(input.values[bad], bad.name);
    final id = newId();
    final now = DateTime.now().toUtc();
    Value<double?> v(MeasureField f) => Value(input.values[f]);
    await _db.into(_db.bodyMeasurements).insert(BodyMeasurementsCompanion.insert(
          id: id,
          updatedAt: now,
          deviceId: await _db.deviceId(),
          measuredAt: input.measuredAt ?? DateTime.now(),
          weightKg: v(MeasureField.weight),
          waistCm: v(MeasureField.waist),
          hipsCm: v(MeasureField.hips),
          chestCm: v(MeasureField.chest),
          neckCm: v(MeasureField.neck),
          armCm: v(MeasureField.arm),
          bodyFatPct: v(MeasureField.bodyFat),
          source: Value(source.name),
        ));
    return id;
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final row = await (_db.select(_db.bodyMeasurements)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null || row.deletedAt != null) return;
      final now = DateTime.now().toUtc();
      await (_db.update(_db.bodyMeasurements)..where((t) => t.id.equals(id))).write(BodyMeasurementsCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}

/// Ряд показателя по возрастанию времени (пропуски отброшены), начиная с [since] (null — весь).
List<MeasurePoint> measureSeries(List<BodyMeasurementRow> rows, MeasureField field, {DateTime? since}) => [
      for (final r in rows)
        if (field.of(r) != null && (since == null || !r.measuredAt.isBefore(since)))
          (at: r.measuredAt.toLocal(), value: field.of(r)!),
    ]..sort((a, b) => a.at.compareTo(b.at));

/// Изменение показателя за период: последнее значение минус первое в периоде. null — меньше двух точек.
double? measureChange(List<BodyMeasurementRow> rows, MeasureField field, {DateTime? since}) {
  final s = measureSeries(rows, field, since: since);
  if (s.length < 2) return null;
  return s.last.value - s.first.value;
}

/// Последнее известное значение показателя.
MeasurePoint? measureLatest(List<BodyMeasurementRow> rows, MeasureField field) {
  final s = measureSeries(rows, field);
  return s.isEmpty ? null : s.last;
}

final bodyMeasurementRepositoryProvider =
    Provider<BodyMeasurementRepository>((ref) => BodyMeasurementRepository(ref.watch(databaseProvider)));

/// Все активные замеры по возрастанию времени.
final bodyMeasurementsProvider =
    StreamProvider<List<BodyMeasurementRow>>((ref) => ref.watch(bodyMeasurementRepositoryProvider).watchAll());
