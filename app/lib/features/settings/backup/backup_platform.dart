// Платформенная часть экспорта/импорта: файлы фото, «Поделиться» (share_plus), выбор файла (file_picker).
// За интерфейсами — чтобы логику и экран можно было тестировать с фейками.
import 'dart:io';
import 'dart:ui' show Rect;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/db/database.dart';
import 'backup_service.dart';

/// Отдать готовый файл пользователю (на iOS — лист «Поделиться» с «Сохранить в Файлы»).
abstract interface class BackupSaver {
  Future<void> save(String fileName, Uint8List bytes, {Rect? origin});
}

/// Выбрать файл резервной копии. null — пользователь отменил.
abstract interface class BackupPicker {
  Future<Uint8List?> pick();
}

/// Платформенная функция недоступна (нет плагина / веб без поддержки).
class BackupUnavailableException implements Exception {
  const BackupUnavailableException(this.cause);
  final Object cause;

  @override
  String toString() => 'BackupUnavailableException($cause)';
}

/// Фото в каталоге документов приложения (Photos.localPath — относительно него).
class DocumentsPhotoStore implements BackupPhotoStore {
  Future<String> _abs(String relPath) async =>
      p.joinAll([(await getApplicationDocumentsDirectory()).path, ...p.posix.split(relPath)]);

  @override
  Future<Uint8List?> read(String relPath) async {
    final f = File(await _abs(relPath));
    return await f.exists() ? f.readAsBytes() : null;
  }

  @override
  Future<void> write(String relPath, Uint8List bytes) async {
    final f = File(await _abs(relPath));
    await f.parent.create(recursive: true);
    await f.writeAsBytes(bytes, flush: true);
  }
}

class ShareBackupSaver implements BackupSaver {
  @override
  Future<void> save(String fileName, Uint8List bytes, {Rect? origin}) async {
    final XFile file;
    if (kIsWeb) {
      // В браузере — Web Share API или скачивание (downloadFallbackEnabled по умолчанию).
      file = XFile.fromData(bytes, name: fileName, mimeType: 'application/json');
    } else {
      final dir = await getTemporaryDirectory();
      final path = p.join(dir.path, fileName);
      await File(path).writeAsBytes(bytes, flush: true);
      file = XFile(path, name: fileName, mimeType: 'application/json');
    }
    try {
      await SharePlus.instance.share(ShareParams(
        files: [file],
        fileNameOverrides: kIsWeb ? [fileName] : null,
        sharePositionOrigin: origin, // нужен на iPad
      ));
    } on MissingPluginException catch (e) {
      throw BackupUnavailableException(e);
    } on UnimplementedError catch (e) {
      throw BackupUnavailableException(e);
    }
  }
}

class FilePickerBackupPicker implements BackupPicker {
  @override
  Future<Uint8List?> pick() async {
    final PlatformFile? file;
    try {
      // FileType.any: фильтр по .json на части Android-проводников прячет файл.
      file = await FilePicker.pickFile();
    } on MissingPluginException catch (e) {
      throw BackupUnavailableException(e);
    } on UnimplementedError catch (e) {
      throw BackupUnavailableException(e);
    }
    return file?.readAsBytes();
  }
}

final backupServiceProvider = Provider<BackupService>(
  (ref) => BackupService(ref.watch(databaseProvider), photoStore: kIsWeb ? null : DocumentsPhotoStore()),
);

final backupSaverProvider = Provider<BackupSaver>((ref) => ShareBackupSaver());

final backupPickerProvider = Provider<BackupPicker>((ref) => FilePickerBackupPicker());
