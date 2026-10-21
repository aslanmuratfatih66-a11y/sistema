// Подключение реальных AuthService/SyncService (переопределения в main).
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;

import '../db/database.dart';
import 'drift_sync_service.dart';
import 'http_auth_service.dart';
import 'sync_api.dart';

/// Конкретный HTTP-сервис входа (нужен синхронизации для запросов с токеном).
final httpAuthServiceProvider = Provider<HttpAuthService>((ref) {
  final db = ref.watch(databaseProvider);
  final s = HttpAuthService(deviceId: db.deviceId);
  ref.onDispose(s.dispose);
  return s;
});

/// Переопределения для ProviderScope в main. [readPhoto] — байты фото по PhotoRow.localPath.
List<Override> syncOverrides({Future<Uint8List?> Function(String localPath)? readPhoto}) => [
      authServiceProvider.overrideWith((ref) => ref.watch(httpAuthServiceProvider)),
      syncServiceProvider.overrideWith((ref) {
        final s = DriftSyncService(
          db: ref.watch(databaseProvider),
          auth: ref.watch(httpAuthServiceProvider),
          readPhoto: readPhoto,
        )..start();
        ref.onDispose(s.dispose);
        return s;
      }),
    ];
