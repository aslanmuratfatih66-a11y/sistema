// Синхронизация локальной БД с сервером (SPEC §10): push изменений → pull с курсора → загрузка фото.
// Таблицы — все из db.allTables с колонками SyncColumns (app_settings не синхронизируется).
// Push: строки с (updated_at, id) > курсора таблицы; pull: insert-or-update по id, если входящая
// updated_at ≥ локальной (LWW по записи; сервер мержит по полю и отдаёт полное состояние).
// Даты drift хранит int-секундами: updated_at/deleted_at в API — мс, остальные поля — как в БД.
import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/widgets.dart' show AppLifecycleListener;

import '../db/database.dart';
import 'http_auth_service.dart';
import 'sync_api.dart';

class DriftSyncService implements SyncService {
  DriftSyncService({
    required this.db,
    required this.auth,
    this.readPhoto,
    this.interval = const Duration(minutes: 5),
  });

  final AppDatabase db;
  final HttpAuthService auth;

  /// Байты фото по относительному пути (PhotoRow.localPath); null — фото не загружаются.
  final Future<Uint8List?> Function(String localPath)? readPhoto;
  final Duration interval;

  static const _batch = 500;
  static const _maxBody = 3 * 1024 * 1024;
  static const _syncCols = {'id', 'updated_at', 'deleted_at', 'device_id', 'version'};
  static const _kPull = 'sync.pull.cursor';
  static const _kPushPrefix = 'sync.push.';
  static const _kLast = 'sync.last';
  static const _kUser = 'sync.user';
  static const _kPhotos = 'sync.photos.uploaded';

  final _ctl = StreamController<SyncStatus>.broadcast();
  SyncStatus _status = SyncStatus.off;
  Timer? _timer;
  AppLifecycleListener? _lifecycle;
  StreamSubscription<Account?>? _accountSub;
  Future<void>? _running;
  bool _again = false;

  @override
  Stream<SyncStatus> watch() async* {
    yield _status;
    yield* _ctl.stream;
  }

  void _emit(SyncStatus s) {
    _status = s;
    if (!_ctl.isClosed) _ctl.add(s);
  }

  /// Синхронизируемые таблицы по SQL-имени.
  late final Map<String, TableInfo<Table, dynamic>> _tables = {
    for (final t in db.allTables)
      if (t.actualTableName != 'app_settings' &&
          _syncCols.every((c) => t.$columns.any((col) => col.name == c)))
        t.actualTableName: t,
  };

  @override
  void start() {
    _timer ??= Timer.periodic(interval, (_) => unawaited(syncNow()));
    _lifecycle ??= AppLifecycleListener(onResume: () => unawaited(syncNow()));
    _accountSub ??= auth.watch().listen((a) {
      if (a == null) {
        _emit(SyncStatus.off);
      } else {
        unawaited(syncNow()); // старт с аккаунтом и сразу после входа
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _lifecycle?.dispose();
    _accountSub?.cancel();
    _ctl.close();
  }

  @override
  Future<void> syncNow() {
    final running = _running;
    if (running != null) {
      _again = true; // изменения во время синхронизации — ещё один проход после текущего
      return running;
    }
    return _running = _loop().whenComplete(() => _running = null);
  }

  Future<void> _loop() async {
    do {
      _again = false;
      await _syncOnce();
    } while (_again && auth.current != null);
  }

  Future<void> _syncOnce() async {
    await auth.ready;
    final account = auth.current;
    if (account == null) {
      _emit(SyncStatus.off);
      return;
    }
    final last = DateTime.tryParse(await db.getSetting(_kLast) ?? '');
    _emit(SyncStatus(phase: SyncPhase.syncing, lastSyncAt: last, pending: _status.pending));
    try {
      await _resetIfOtherUser(account);
      await _push();
      await _pull();
      final now = DateTime.now();
      await db.setSetting(_kLast, now.toIso8601String());
      _emit(SyncStatus(phase: SyncPhase.idle, lastSyncAt: now, pending: await _pendingCount()));
      await _uploadPhotos(); // best-effort, статус не портит
    } on OfflineException {
      _emit(SyncStatus(phase: SyncPhase.offline, lastSyncAt: last, pending: await _pendingCount()));
    } on AuthException catch (e) {
      _emit(auth.current == null
          ? SyncStatus.off
          : SyncStatus(phase: SyncPhase.error, lastSyncAt: last, pending: await _pendingCount(), message: e.error.name));
    } catch (e) {
      _emit(SyncStatus(phase: SyncPhase.error, lastSyncAt: last, pending: await _pendingCount(), message: '$e'));
    }
  }

  /// Другой аккаунт на этом устройстве — курсоры с нуля (отправить всё, забрать всё).
  Future<void> _resetIfOtherUser(Account a) async {
    final key = '${a.serverUrl}#${a.userId}';
    if (await db.getSetting(_kUser) == key) return;
    await db.customStatement("DELETE FROM app_settings WHERE key LIKE 'sync.%' AND key <> 'sync.user'");
    await db.setSetting(_kUser, key);
  }

  // ---------- push ----------

  Future<(int, String)> _pushCursor(String table) async {
    final raw = await db.getSetting('$_kPushPrefix$table');
    if (raw == null) return (-1, '');
    final i = raw.indexOf('|');
    return (int.tryParse(raw.substring(0, i)) ?? -1, raw.substring(i + 1));
  }

  Future<void> _push() async {
    final deviceId = await db.deviceId();
    for (final table in _tables.keys) {
      while (true) {
        final (sec, id) = await _pushCursor(table);
        final rows = await db.customSelect(
          'SELECT * FROM "$table" WHERE updated_at > ? OR (updated_at = ? AND id > ?) ORDER BY updated_at, id LIMIT $_batch',
          variables: [Variable.withInt(sec), Variable.withInt(sec), Variable.withString(id)],
        ).get();
        if (rows.isEmpty) break;

        var clamped = false;
        var chunk = <Map<String, Object?>>[];
        var size = 0;
        Future<void> flush(Map<String, Object?> lastRow) async {
          if (chunk.isEmpty) return;
          final r = await auth.authorized('POST', '/api/v1/sync/push', json: {'device_id': deviceId, 'changes': chunk});
          if (r.statusCode < 200 || r.statusCode >= 300) throw ApiException(r.statusCode);
          // Строки последних секунд ещё могут меняться в ту же секунду — курсор не дальше now-2 с
          // (их повторная отправка безвредна: LWW).
          final safe = DateTime.now().millisecondsSinceEpoch ~/ 1000 - 2;
          final sec = lastRow['updated_at'] as int;
          if (sec > safe) clamped = true;
          await db.setSetting('$_kPushPrefix$table', sec > safe ? '$safe|~' : '$sec|${lastRow['id']}');
          chunk = [];
          size = 0;
        }

        for (final row in rows) {
          final change = _toChange(table, row.data);
          final len = utf8.encode(jsonEncode(change)).length;
          if (chunk.isNotEmpty && size + len > _maxBody) await flush(rows[rows.indexOf(row) - 1].data);
          chunk.add(change);
          size += len;
        }
        await flush(rows.last.data);
        if (rows.length < _batch || clamped) break;
      }
    }
  }

  Map<String, Object?> _toChange(String table, Map<String, Object?> row) {
    final deleted = row['deleted_at'] as int?;
    return {
      'table': table,
      'id': row['id'],
      'updated_at': (row['updated_at'] as int) * 1000,
      if (deleted != null) 'deleted_at': deleted * 1000, // null не шлём: null = снять удаление
      'version': row['version'],
      'data': {
        for (final e in row.entries)
          if (!_syncCols.contains(e.key)) e.key: e.value is Uint8List ? base64Encode(e.value as Uint8List) : e.value,
      },
    };
  }

  Future<int> _pendingCount() async {
    var n = 0;
    try {
      for (final table in _tables.keys) {
        final (sec, id) = await _pushCursor(table);
        final r = await db.customSelect(
          'SELECT COUNT(*) AS c FROM "$table" WHERE updated_at > ? OR (updated_at = ? AND id > ?)',
          variables: [Variable.withInt(sec), Variable.withInt(sec), Variable.withString(id)],
        ).getSingle();
        n += r.read<int>('c');
      }
    } catch (_) {}
    return n;
  }

  // ---------- pull ----------

  Future<void> _pull() async {
    final touched = <TableInfo<Table, dynamic>>{};
    try {
      while (true) {
        final since = await db.getSetting(_kPull) ?? '0';
        final r = await auth.authorized('GET', '/api/v1/sync/pull', query: {'since': since, 'limit': '$_batch'});
        if (r.statusCode < 200 || r.statusCode >= 300) throw ApiException(r.statusCode);
        final body = jsonDecode(r.body) as Map<String, dynamic>;
        final changes = (body['changes'] as List?) ?? const [];
        await db.transaction(() async {
          for (final c in changes) {
            final t = await _apply(c as Map<String, dynamic>);
            if (t != null) touched.add(t);
          }
        });
        final cursor = body['cursor'];
        if (cursor != null) await db.setSetting(_kPull, '$cursor');
        if (body['has_more'] != true || changes.isEmpty) break;
      }
    } finally {
      if (touched.isNotEmpty) db.markTablesUpdated(touched);
    }
  }

  Future<TableInfo<Table, dynamic>?> _apply(Map<String, dynamic> c) async {
    final t = _tables[c['table']];
    final id = c['id'];
    final upd = c['updated_at'];
    if (t == null || id is! String || upd is! num) return null;
    final known = {for (final col in t.$columns) col.name};
    final values = <String, Object?>{};
    final data = c['data'];
    if (data is Map) {
      for (final e in data.entries) {
        if (known.contains(e.key) && !_syncCols.contains(e.key)) values[e.key as String] = _sqlValue(e.value);
      }
    }
    final del = c['deleted_at'];
    values['id'] = id;
    values['updated_at'] = upd.toInt() ~/ 1000;
    values['deleted_at'] = del is num ? del.toInt() ~/ 1000 : null;
    values['version'] = (c['version'] as num?)?.toInt() ?? 1;
    values['device_id'] = c['device_id'] as String? ?? '';

    final cols = values.keys.toList();
    final name = t.actualTableName;
    final sql = 'INSERT INTO "$name" (${cols.map((k) => '"$k"').join(', ')}) '
        'VALUES (${List.filled(cols.length, '?').join(', ')}) '
        'ON CONFLICT(id) DO UPDATE SET ${cols.where((k) => k != 'id').map((k) => '"$k" = excluded."$k"').join(', ')} '
        'WHERE excluded.updated_at >= "$name".updated_at';
    try {
      await db.customStatement(sql, [for (final k in cols) values[k]]);
      return t;
    } catch (_) {
      return null; // несовместимая строка (например, другая версия схемы) — пропускаем
    }
  }

  static Object? _sqlValue(Object? v) => switch (v) {
        null => null,
        bool b => b ? 1 : 0,
        int _ || double _ || String _ => v,
        _ => jsonEncode(v),
      };

  // ---------- фото ----------

  Future<void> _uploadPhotos() async {
    final read = readPhoto;
    if (read == null) return;
    try {
      final done = <String>{
        ...((jsonDecode(await db.getSetting(_kPhotos) ?? '[]') as List).cast<String>()),
      };
      final rows = await db.customSelect('SELECT id, local_path FROM photos WHERE deleted_at IS NULL').get();
      for (final row in rows) {
        final id = row.read<String>('id');
        if (done.contains(id)) continue;
        final path = row.read<String>('local_path');
        final bytes = await read(path);
        if (bytes == null) continue;
        final r = await auth.authorized('PUT', '/api/v1/photos/$id',
            bytes: bytes, contentType: path.toLowerCase().endsWith('.png') ? 'image/png' : 'image/jpeg');
        if (r.statusCode >= 200 && r.statusCode < 300) {
          done.add(id);
          await db.setSetting(_kPhotos, jsonEncode(done.toList()));
        }
      }
    } catch (_) {
      // best-effort: повторим на следующей синхронизации
    }
  }
}
