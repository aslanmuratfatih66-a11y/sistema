// Результаты анализа фото (таблица PhotoAnalyses): сохранение и история для сравнения.
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart';

/// Вид анализа (PhotoAnalyses.kind).
enum VisionKind { body, skin, food, receipt }

class PhotoAnalysisRepository {
  PhotoAnalysisRepository(this._db);

  final AppDatabase _db;

  Future<String> add(VisionKind kind, Map<String, dynamic> result, {String? photoId, DateTime? at}) async {
    final id = newId();
    final now = DateTime.now().toUtc();
    await _db.into(_db.photoAnalyses).insert(PhotoAnalysesCompanion.insert(
          id: id,
          updatedAt: now,
          deviceId: await _db.deviceId(),
          photoId: Value(photoId),
          kind: kind.name,
          result: jsonEncode(result),
          createdAt: at?.toUtc() ?? now,
        ));
    return id;
  }

  SimpleSelectStatement<$PhotoAnalysesTable, PhotoAnalysisRow> _byKind(VisionKind kind) => _db.select(_db.photoAnalyses)
    ..where((t) => t.kind.equals(kind.name) & t.deletedAt.isNull())
    ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]);

  /// Последние [limit] анализов (новые первыми).
  Future<List<PhotoAnalysisRow>> recent(VisionKind kind, {int limit = 5}) => (_byKind(kind)..limit(limit)).get();

  Stream<List<PhotoAnalysisRow>> watch(VisionKind kind) => _byKind(kind).watch();
}

Map<String, dynamic> decodeAnalysis(PhotoAnalysisRow r) {
  try {
    final v = jsonDecode(r.result);
    return v is Map<String, dynamic> ? v : const {};
  } on FormatException {
    return const {};
  }
}

final photoAnalysisRepositoryProvider =
    Provider<PhotoAnalysisRepository>((ref) => PhotoAnalysisRepository(ref.watch(databaseProvider)));

/// История анализов вида (для экранов тела/кожи).
final photoAnalysesProvider = StreamProvider.family<List<PhotoAnalysisRow>, VisionKind>(
    (ref, kind) => ref.watch(photoAnalysisRepositoryProvider).watch(kind));
