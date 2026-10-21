import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/db/database.dart';
import '../../../../core/models/enums.dart';

/// Файлы фото в каталоге документов приложения: `photos/<kind>/<uuid>.jpg` (или `.png` — отражённые
/// снимки фронтальной камеры перекодируются в PNG, см. camera/mirror.dart).
/// В БД хранится относительный путь (абсолютный путь на iOS меняется при переустановке).
class PhotoStorage {
  PhotoStorage({Future<Directory> Function()? rootDir}) : _rootDir = rootDir ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _rootDir;

  /// Новый относительный путь (всегда с '/', не зависит от ОС).
  static String newRelativePath(PhotoKind kind, {String ext = '.jpg'}) =>
      p.posix.join('photos', kind.name, '${newId()}$ext');

  /// Расширение для хранилища по исходному файлу: .png сохраняется, всё остальное — .jpg.
  static String extFor(String sourcePath) => p.extension(sourcePath).toLowerCase() == '.png' ? '.png' : '.jpg';

  Future<String> rootPath() async => (await _rootDir()).path;

  Future<File> resolve(String relativePath) async => File(p.joinAll([await rootPath(), ...p.posix.split(relativePath)]));

  /// Скопировать снимок (например, временный файл камеры) в хранилище. Возвращает относительный путь.
  Future<String> import(String sourcePath, PhotoKind kind) async {
    final rel = newRelativePath(kind, ext: extFor(sourcePath));
    final target = await resolve(rel);
    await target.parent.create(recursive: true);
    await File(sourcePath).copy(target.path);
    return rel;
  }

  Future<void> delete(String relativePath) async {
    try {
      final f = await resolve(relativePath);
      if (await f.exists()) await f.delete();
    } on FileSystemException catch (e) {
      debugPrint('PhotoStorage.delete: $e');
    }
  }
}

/// Таблица Photos: только записи, без файлов.
class PhotoRepository {
  PhotoRepository(this._db);

  final AppDatabase _db;

  SimpleSelectStatement<$PhotosTable, PhotoRow> _byKind(PhotoKind kind, {PhotoPose? pose}) => _db.select(_db.photos)
    ..where((t) => t.kind.equals(kind.name) & t.deletedAt.isNull() & (pose == null ? const Constant(true) : t.pose.equals(pose.name)))
    ..orderBy([(t) => OrderingTerm.asc(t.takenAt)]);

  Future<List<PhotoRow>> active(PhotoKind kind, {PhotoPose? pose}) => _byKind(kind, pose: pose).get();

  Stream<List<PhotoRow>> watchActive(PhotoKind kind) => _byKind(kind).watch();

  Future<String> add({
    required PhotoKind kind,
    required PhotoPose pose,
    required String localPath,
    String? sessionId,
    DateTime? takenAt,
  }) async {
    final id = newId();
    final now = DateTime.now().toUtc();
    await _db.into(_db.photos).insert(PhotosCompanion.insert(
          id: id,
          updatedAt: now,
          deviceId: await _db.deviceId(),
          kind: kind.name,
          pose: pose.name,
          localPath: localPath,
          takenAt: takenAt?.toUtc() ?? now,
          sessionId: Value(sessionId),
        ));
    return id;
  }

  Future<void> softDelete(String id) async {
    final deviceId = await _db.deviceId();
    await _db.transaction(() async {
      final row = await (_db.select(_db.photos)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (row == null || row.deletedAt != null) return;
      final now = DateTime.now().toUtc();
      await (_db.update(_db.photos)..where((t) => t.id.equals(id))).write(PhotosCompanion(
            deletedAt: Value(now),
            updatedAt: Value(now),
            deviceId: Value(deviceId),
            version: Value(row.version + 1),
          ));
    });
  }
}

/// Сохранение снимков: файл + запись. Переиспользуется «контрольным фото» (этап 3) через [sessionId].
class PhotoService {
  PhotoService(this.repo, this.storage);

  final PhotoRepository repo;
  final PhotoStorage storage;

  /// Сохранить снимок позы. [replace] — мягко удалить прежние активные снимки этой позы той же серии
  /// ([sessionId]; null — анкета) и их файлы
  /// (для «крупно проблемные зоны» передавайте false — их может быть несколько).
  Future<String> save({
    required String sourcePath,
    required PhotoKind kind,
    required PhotoPose pose,
    bool replace = true,
    String? sessionId,
  }) async {
    final rel = await storage.import(sourcePath, kind);
    if (replace) {
      for (final old in await repo.active(kind, pose: pose)) {
        if (old.sessionId != sessionId) continue; // другие серии не трогаем
        await delete(old);
      }
    }
    return repo.add(kind: kind, pose: pose, localPath: rel, sessionId: sessionId);
  }

  Future<void> delete(PhotoRow row) async {
    await repo.softDelete(row.id);
    await storage.delete(row.localPath);
  }
}

final photoStorageProvider = Provider<PhotoStorage>((ref) => PhotoStorage());

final photoRepositoryProvider = Provider<PhotoRepository>((ref) => PhotoRepository(ref.watch(databaseProvider)));

final photoServiceProvider =
    Provider<PhotoService>((ref) => PhotoService(ref.watch(photoRepositoryProvider), ref.watch(photoStorageProvider)));

/// Активные фото вида (по времени съёмки).
final activePhotosProvider = StreamProvider.family<List<PhotoRow>, PhotoKind>(
  (ref, kind) => ref.watch(photoRepositoryProvider).watchActive(kind),
);

/// Абсолютный путь каталога документов (для показа миниатюр). На вебе не используется.
final photoRootProvider = FutureProvider<String>((ref) => ref.watch(photoStorageProvider).rootPath());
