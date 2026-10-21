import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

// ЗЕРКАЛЬНОСТЬ ФРОНТАЛЬНОЙ КАМЕРЫ (выводы по исходникам плагинов из pub cache, версии на 2026-10):
//
// Превью (что человек видит на экране):
//  - iOS, camera_avfoundation 0.10.3: DefaultCamera.createConnection ставит connection.isVideoMirrored = true
//    для .front — кадры превью ЗЕРКАЛЬНЫЕ (как зеркало).
//  - Android, camera_android_camerax 0.7.5: ImageReaderRotatedPreview для facingSign == 1 (фронтальная)
//    оборачивает превью в Transform.scale(-1) — тоже ЗЕРКАЛЬНОЕ.
//  => на обеих платформах превью фронтальной камеры зеркальное, основной — нет.
//
// Снимок (takePicture):
//  - Android: ImageCaptureProxyApi использует OutputFileOptions.Builder(file).build() без
//    Metadata.setReversedHorizontal — CameraX сохраняет кадр НЕЗЕРКАЛЬНЫМ (как видит другой человек).
//  - iOS: AVCapturePhotoOutput добавляется в сессию без ручной настройки соединения; у его соединения
//    automaticallyAdjustsVideoMirroring = true, и для фронтальной камеры снимок получается ЗЕРКАЛЬНЫМ
//    (через EXIF-ориентацию *Mirrored, которую декодер Flutter применяет). Поэтому на iOS снимки
//    фронтальной камеры отражаем при сохранении.
//  НЕ ПРОВЕРЕНО НА УСТРОЙСТВЕ — если на iPhone снимок окажется отражённым дважды, поменять [captureIsMirrored].
//
// Термины: «профиль слева» = к камере обращена ЛЕВАЯ сторона лица (левая щека). На незеркальном снимке
// нос такого профиля смотрит ВЛЕВО кадра; в зеркальном превью фронтальной камеры — ВПРАВО.

/// Отдаёт ли плагин camera снимок зеркальным (тогда его нужно отразить, чтобы сохранить «как видит другой»).
bool captureIsMirrored({required bool frontCamera, TargetPlatform? platform}) {
  if (!frontCamera) return false;
  return (platform ?? defaultTargetPlatform) == TargetPlatform.iOS;
}

/// Зеркальное ли превью камеры на экране (контур рисуется с тем же отражением).
bool previewIsMirrored({required bool frontCamera}) => frontCamera;

/// Отразить изображение по горизонтали. Вход — любой формат, который декодирует Flutter (JPEG/PNG/HEIF
/// на iOS), EXIF-ориентация применяется декодером. Выход — PNG (без зависимостей JPEG-кодировщика нет).
Future<Uint8List> mirrorImageBytes(Uint8List bytes) async {
  final codec = await ui.instantiateImageCodec(bytes);
  final frame = await codec.getNextFrame();
  codec.dispose();
  final src = frame.image;
  final w = src.width;
  final h = src.height;
  final recorder = ui.PictureRecorder();
  ui.Canvas(recorder)
    ..translate(w.toDouble(), 0)
    ..scale(-1, 1)
    ..drawImage(src, ui.Offset.zero, ui.Paint()..filterQuality = ui.FilterQuality.none);
  final picture = recorder.endRecording();
  final out = await picture.toImage(w, h);
  picture.dispose();
  src.dispose();
  try {
    final data = await out.toByteData(format: ui.ImageByteFormat.png);
    if (data == null) throw StateError('mirrorImageBytes: PNG encode failed');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  } finally {
    out.dispose();
  }
}

/// Отразить файл снимка: пишет `<имя>_m.png` рядом и удаляет исходник. Возвращает путь нового файла.
Future<String> mirrorImageFile(String path) async {
  final png = await mirrorImageBytes(await File(path).readAsBytes());
  final outPath = '${p.withoutExtension(path)}_m.png';
  await File(outPath).writeAsBytes(png, flush: true);
  try {
    await File(path).delete();
  } catch (_) {}
  return outPath;
}
