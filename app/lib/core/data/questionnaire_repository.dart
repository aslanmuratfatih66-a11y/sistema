import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/database.dart';
import '../models/enums.dart';

/// Разделы анкеты без собственных таблиц: JSON-объект на раздел.
/// Сохраняет сразу (SPEC §5: «всё сохраняется сразу»), поля синхронизации проставляет сам.
class QuestionnaireRepository {
  QuestionnaireRepository(this._db);

  final AppDatabase _db;

  Future<Map<String, Object?>> read(QuestionnaireSection section) async {
    final row = await (_db.select(_db.questionnaireSections)
          ..where((t) => t.id.equals(section.name) & t.deletedAt.isNull()))
        .getSingleOrNull();
    return row == null ? {} : _decode(row.payload);
  }

  Stream<Map<String, Object?>> watch(QuestionnaireSection section) => (_db.select(_db.questionnaireSections)
        ..where((t) => t.id.equals(section.name) & t.deletedAt.isNull()))
      .watchSingleOrNull()
      .map((row) => row == null ? <String, Object?>{} : _decode(row.payload));

  /// Полная замена содержимого раздела.
  Future<void> write(QuestionnaireSection section, Map<String, Object?> data) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final existing = await (_db.select(_db.questionnaireSections)..where((t) => t.id.equals(section.name)))
          .getSingleOrNull();
      await _db.into(_db.questionnaireSections).insertOnConflictUpdate(QuestionnaireSectionsCompanion.insert(
            id: section.name,
            updatedAt: DateTime.now().toUtc(),
            deviceId: deviceId,
            version: Value((existing?.version ?? 0) + 1),
            payload: jsonEncode(data),
          ));
    });
  }

  /// Обновление части полей: `patch` сливается с текущим содержимым (null удаляет ключ).
  Future<void> patch(QuestionnaireSection section, Map<String, Object?> patch) async {
    final current = await read(section);
    for (final e in patch.entries) {
      if (e.value == null) {
        current.remove(e.key);
      } else {
        current[e.key] = e.value;
      }
    }
    await write(section, current);
  }

  static Map<String, Object?> _decode(String payload) {
    try {
      final v = jsonDecode(payload);
      return v is Map<String, Object?> ? v : {};
    } on FormatException {
      return {};
    }
  }
}

final questionnaireRepositoryProvider =
    Provider<QuestionnaireRepository>((ref) => QuestionnaireRepository(ref.watch(databaseProvider)));

/// Текущее содержимое раздела анкеты.
final questionnaireSectionProvider = StreamProvider.family<Map<String, Object?>, QuestionnaireSection>(
  (ref, section) => ref.watch(questionnaireRepositoryProvider).watch(section),
);
