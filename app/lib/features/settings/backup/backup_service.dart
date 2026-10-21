// Экспорт/импорт всех данных в JSON (SPEC §3: данные переживают переустановку).
// Чистая логика: без UI и платформенных вызовов (файлы фото — через [BackupPhotoStore]).
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/db/database.dart';

/// Доступ к файлам фото по пути относительно каталога документов приложения.
abstract interface class BackupPhotoStore {
  /// null — файла нет.
  Future<Uint8List?> read(String relPath);
  Future<void> write(String relPath, Uint8List bytes);
}

enum BackupError {
  /// Не JSON / не UTF-8.
  notJson,

  /// JSON, но не резервная копия Системы.
  wrongFormat,

  /// Неизвестная версия формата файла.
  unsupportedFormatVersion,

  /// Файл создан более новой версией схемы БД.
  newerSchema,

  /// Структура повреждена (таблицы/строки/фото не того типа).
  invalid,
}

class BackupException implements Exception {
  const BackupException(this.error, [this.detail]);
  final BackupError error;
  final String? detail;

  @override
  String toString() => 'BackupException(${error.name}${detail == null ? '' : ': $detail'})';
}

/// Разобранный и проверенный файл — для предпросмотра перед импортом.
class BackupPreview {
  const BackupPreview._({
    required this.schemaVersion,
    required this.exportedAt,
    required this.tables,
    required this.photos,
  });

  final int schemaVersion;
  final DateTime? exportedAt;

  /// Таблица → строки (колонка → значение), только таблицы текущей схемы.
  final Map<String, List<Map<String, Object?>>> tables;

  /// Относительный путь → содержимое.
  final Map<String, Uint8List> photos;

  Map<String, int> get rowCounts => {for (final e in tables.entries) e.key: e.value.length};
  int get photoCount => photos.length;
}

class BackupService {
  BackupService(this._db, {this.photoStore, DateTime Function()? now}) : _now = now ?? DateTime.now;

  final AppDatabase _db;

  /// null — фото не переносятся (веб).
  final BackupPhotoStore? photoStore;
  final DateTime Function() _now;

  static const format = 'sistema-backup';
  static const formatVersion = 1;

  /// Ключи AppSettings, привязанные к устройству: не экспортируются и не перезаписываются импортом.
  static const deviceLocalSettings = {'device.id'};

  static const _appSettingsTable = 'app_settings';

  /// sistema-backup-YYYYMMDD-HHMM.json (локальное время).
  static String fileName(DateTime t) {
    String two(int v) => v.toString().padLeft(2, '0');
    return 'sistema-backup-${t.year}${two(t.month)}${two(t.day)}-${two(t.hour)}${two(t.minute)}.json';
  }

  String suggestedFileName() => fileName(_now());

  /// Все таблицы БД генерически: SELECT * → объекты колонка→значение.
  /// Даты — как их хранит Drift (int, unix-секунды), булевы — 0/1.
  Future<Map<String, Object?>> exportData({bool includePhotos = true}) async {
    final tables = <String, Object?>{};
    for (final table in _db.allTables) {
      final name = table.actualTableName;
      final rows = await _db.customSelect('SELECT * FROM "$name"').get();
      tables[name] = [
        for (final r in rows)
          if (!(name == _appSettingsTable && deviceLocalSettings.contains(r.data['key']))) _jsonRow(r.data),
      ];
    }

    final photos = <String, String>{};
    final store = photoStore;
    if (includePhotos && store != null) {
      final rows = await (_db.select(_db.photos)..where((t) => t.deletedAt.isNull())).get();
      for (final row in rows) {
        if (photos.containsKey(row.localPath) || !_isSafeRelPath(row.localPath)) continue;
        final bytes = await store.read(row.localPath);
        if (bytes != null) photos[row.localPath] = base64Encode(bytes);
      }
    }

    return {
      'format': format,
      'formatVersion': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': _now().toUtc().toIso8601String(),
      'dateTimeStorage': 'unixSeconds',
      'boolStorage': 'int01',
      'tables': tables,
      'photos': photos,
    };
  }

  Future<Uint8List> exportBytes({bool includePhotos = true}) async =>
      utf8.encode(const JsonEncoder.withIndent(' ').convert(await exportData(includePhotos: includePhotos)));

  Map<String, Object?> _jsonRow(Map<String, Object?> data) => {
        for (final e in data.entries)
          // BLOB-колонок пока нет; на будущее — base64.
          e.key: e.value is Uint8List ? {'\$blob': base64Encode(e.value as Uint8List)} : e.value,
      };

  /// Разобрать и проверить файл. Бросает [BackupException].
  BackupPreview parse(Uint8List bytes) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const BackupException(BackupError.notJson);
    }
    if (json is! Map<String, Object?> || json['format'] != format) {
      throw const BackupException(BackupError.wrongFormat);
    }
    if (json['formatVersion'] != formatVersion) {
      throw BackupException(BackupError.unsupportedFormatVersion, '${json['formatVersion']}');
    }
    final schema = json['schemaVersion'];
    if (schema is! int || schema < 1) throw const BackupException(BackupError.invalid, 'schemaVersion');
    if (schema > _db.schemaVersion) throw BackupException(BackupError.newerSchema, '$schema');

    final rawTables = json['tables'];
    if (rawTables is! Map<String, Object?>) throw const BackupException(BackupError.invalid, 'tables');
    final known = {for (final t in _db.allTables) t.actualTableName: t};
    final tables = <String, List<Map<String, Object?>>>{};
    for (final e in rawTables.entries) {
      final table = known[e.key];
      if (table == null) continue; // таблица из будущей/чужой схемы — пропускаем
      final rows = e.value;
      if (rows is! List) throw BackupException(BackupError.invalid, e.key);
      final columns = {for (final c in table.$columns) c.name};
      tables[e.key] = [
        for (final row in rows)
          if (row is Map<String, Object?>)
            {
              for (final c in row.entries)
                if (columns.contains(c.key)) c.key: _sqlValue(c.value, e.key),
            }
          else
            throw BackupException(BackupError.invalid, e.key),
      ];
    }

    final photos = <String, Uint8List>{};
    final rawPhotos = json['photos'];
    if (rawPhotos != null) {
      if (rawPhotos is! Map<String, Object?>) throw const BackupException(BackupError.invalid, 'photos');
      for (final e in rawPhotos.entries) {
        final v = e.value;
        if (v is! String || !_isSafeRelPath(e.key)) throw BackupException(BackupError.invalid, 'photo ${e.key}');
        try {
          photos[e.key] = base64Decode(v);
        } on FormatException {
          throw BackupException(BackupError.invalid, 'photo ${e.key}');
        }
      }
    }

    final exportedAt = json['exportedAt'];
    return BackupPreview._(
      schemaVersion: schema,
      exportedAt: exportedAt is String ? DateTime.tryParse(exportedAt) : null,
      tables: tables,
      photos: photos,
    );
  }

  Object? _sqlValue(Object? v, String table) => switch (v) {
        null || int() || double() || String() => v,
        bool() => v ? 1 : 0,
        {'\$blob': final String b} => base64Decode(b),
        _ => throw BackupException(BackupError.invalid, table),
      };

  /// Заменить все данные содержимым [preview]. Атомарно для БД: при ошибке данные не меняются.
  /// Ключи [deviceLocalSettings] этого устройства сохраняются.
  Future<void> importData(BackupPreview preview) async {
    // Сначала файлы фото: они только добавляются, БД ещё не тронута.
    final store = photoStore;
    if (store != null) {
      for (final e in preview.photos.entries) {
        await store.write(e.key, e.value);
      }
    }

    final tables = _db.allTables.toList();
    await _db.transaction(() async {
      for (final table in tables) {
        final name = table.actualTableName;
        if (name == _appSettingsTable) {
          final keep = deviceLocalSettings.toList();
          await _db.customStatement(
            'DELETE FROM "$name" WHERE "key" NOT IN (${List.filled(keep.length, '?').join(', ')})',
            keep,
          );
        } else {
          await _db.customStatement('DELETE FROM "$name"');
        }
        for (final row in preview.tables[name] ?? const <Map<String, Object?>>[]) {
          if (row.isEmpty) continue;
          if (name == _appSettingsTable && deviceLocalSettings.contains(row['key'])) continue;
          final cols = row.keys.toList();
          await _db.customStatement(
            'INSERT OR REPLACE INTO "$name" (${cols.map((c) => '"$c"').join(', ')}) '
            'VALUES (${List.filled(cols.length, '?').join(', ')})',
            [for (final c in cols) row[c]],
          );
        }
      }
    });
    // customStatement не знает о затронутых таблицах — обновим стримы вручную.
    _db.notifyUpdates({for (final t in tables) TableUpdate.onTable(t)});
  }

  /// Только относительные пути внутри каталога документов.
  static bool _isSafeRelPath(String path) {
    if (path.isEmpty || path.contains('\\')) return false;
    if (p.posix.isAbsolute(path) || p.windows.isAbsolute(path)) return false;
    return !p.posix.split(path).any((s) => s == '..' || s == '.');
  }
}
