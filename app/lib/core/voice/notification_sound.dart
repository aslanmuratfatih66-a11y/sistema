// Голос персонажа как звук уведомления (SPEC §9.5): фраза синтезируется сервером в WAV и кладётся туда,
// откуда её может взять система уведомлений. Best-effort: любая ошибка → null (уведомление со звуком по умолчанию).
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../ai/ai_api.dart';
import 'server_tts_service.dart';

/// Подготовленный звук уведомления.
class NotificationSound {
  const NotificationSound({required this.path, required this.fileName});

  /// Абсолютный путь к .wav.
  final String path;

  /// Имя файла: iOS — значение `DarwinNotificationDetails(sound: fileName)` (файл в Library/Sounds).
  final String fileName;
}

/// Синтезирует [text] голосом [voice] сервера в WAV. iOS: `Library/Sounds/<name>.wav` (≤30 с, иначе
/// система играет звук по умолчанию). Android: `<ApplicationSupport>/sounds/<name>.wav` — для канала
/// нужен content:// URI (FileProvider) или копия в общие медиа; это решает модуль уведомлений.
/// [name] — стабильное имя без расширения (по умолчанию — хэш фразы: одинаковые фразы не качаются заново).
Future<NotificationSound?> prepareNotificationSound(
  AiGateway gateway,
  String text, {
  required String lang,
  required String? voice,
  String? name,
}) async {
  if (kIsWeb || voice == null || voice.isEmpty || text.trim().isEmpty) return null;
  if (!Platform.isIOS && !Platform.isAndroid) return null;
  try {
    final Directory dir;
    if (Platform.isIOS) {
      dir = Directory('${(await getLibraryDirectory()).path}/Sounds');
    } else {
      dir = Directory('${(await getApplicationSupportDirectory()).path}/sounds');
    }
    if (!await dir.exists()) await dir.create(recursive: true);
    final fileName = '${name ?? 'sys_${ttsCacheKey(voice, lang, 'wav', text)}'}.wav';
    final f = File('${dir.path}/$fileName');
    if (await f.exists() && await f.length() > 0) return NotificationSound(path: f.path, fileName: fileName);
    final data = await ServerTtsApi(gateway).synthesize(text, voice: voice, lang: lang, format: 'wav');
    if (data.isEmpty) return null;
    await f.writeAsBytes(data, flush: true);
    return NotificationSound(path: f.path, fileName: fileName);
  } catch (e) {
    debugPrint('Звук уведомления не подготовлен: $e');
    return null;
  }
}
