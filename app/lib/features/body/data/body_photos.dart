// Фото-дневник тела и кожи, утренние фото отёков (SPEC §8.3). Файлы и записи — через PhotoService анкеты
// (photos/<kind>/<uuid>.jpg относительно документов). Чтобы не смешиваться с фото анкеты (sessionId == null),
// снимки раздела пишутся с sessionId: «diary-ГГГГММДД» (дневник) и «swelling-ГГГГММДД» (утро отёков).
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../onboarding/questionnaire_a/camera/camera_capture_screen.dart';
import '../../onboarding/questionnaire_a/camera/capture_guide.dart';
import '../../onboarding/questionnaire_a/data/photo_repository.dart';
import '../domain/sleep_math.dart';

/// Откуда взять снимок. Камера и галерея недоступны в тестах — подменяются фейком.
abstract interface class BodyPhotoSource {
  /// Снимок с камеры с контуром позы. Путь к временному файлу или null (отмена).
  Future<String?> capture(BuildContext context, {required PhotoPose pose, required String title, required String instruction});

  /// Фото из галереи. Путь или null.
  Future<String?> pickFromGallery();
}

/// Камера — экран съёмки с контуром из анкеты; галерея — image_picker.
class DeviceBodyPhotoSource implements BodyPhotoSource {
  const DeviceBodyPhotoSource();

  static CaptureGuide guideFor(PhotoPose pose) => switch (pose) {
        PhotoPose.bodyFront => CaptureGuide.bodyFront,
        PhotoPose.bodySide => CaptureGuide.bodySide,
        PhotoPose.bodyBack => CaptureGuide.bodyBack,
        PhotoPose.faceFront => CaptureGuide.faceFront,
        PhotoPose.faceLeft => CaptureGuide.faceLeft,
        PhotoPose.faceRight => CaptureGuide.faceRight,
        PhotoPose.closeup || PhotoPose.other => CaptureGuide.closeup,
      };

  static bool isFace(PhotoPose pose) =>
      pose == PhotoPose.faceFront || pose == PhotoPose.faceLeft || pose == PhotoPose.faceRight || pose == PhotoPose.closeup;

  @override
  Future<String?> capture(BuildContext context, {required PhotoPose pose, required String title, required String instruction}) =>
      CameraCaptureScreen.open(
        context,
        guide: guideFor(pose),
        title: title,
        instruction: instruction,
        preferFrontCamera: isFace(pose),
      );

  @override
  Future<String?> pickFromGallery() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 2400, imageQuality: 90);
    return file?.path;
  }
}

final bodyPhotoSourceProvider = Provider<BodyPhotoSource>((ref) => const DeviceBodyPhotoSource());

/// Серии раздела.
abstract final class BodyPhotoSessions {
  static const diaryPrefix = 'diary-';
  static const swellingPrefix = 'swelling-';

  static String _stamp(DateTime day) {
    final d = dayOf(day);
    return '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
  }

  static String diary(DateTime day) => '$diaryPrefix${_stamp(day)}';
  static String swelling(DateTime day) => '$swellingPrefix${_stamp(day)}';

  static bool isSwelling(PhotoRow p) => p.sessionId?.startsWith(swellingPrefix) ?? false;
}

/// Позы, доступные для вида фото.
List<PhotoPose> posesFor(PhotoKind kind) => kind == PhotoKind.body
    ? const [PhotoPose.bodyFront, PhotoPose.bodySide, PhotoPose.bodyBack]
    : const [PhotoPose.faceFront, PhotoPose.faceLeft, PhotoPose.faceRight, PhotoPose.closeup];

/// Лента дневника: фото вида (анкета + дневник), без утренних фото отёков, новые сверху.
List<PhotoRow> diaryFeed(List<PhotoRow> photos) =>
    photos.where((p) => !BodyPhotoSessions.isSwelling(p)).toList()..sort((a, b) => b.takenAt.compareTo(a.takenAt));

/// Лента отёков: утренние фото анфас, новые сверху.
List<PhotoRow> swellingFeed(List<PhotoRow> skinPhotos) =>
    skinPhotos.where(BodyPhotoSessions.isSwelling).toList()..sort((a, b) => b.takenAt.compareTo(a.takenAt));

/// Группировка ленты по дням (порядок дней сохраняется).
List<(DateTime, List<PhotoRow>)> groupByDay(List<PhotoRow> photos) {
  final out = <(DateTime, List<PhotoRow>)>[];
  for (final p in photos) {
    final d = dayOf(p.takenAt);
    if (out.isNotEmpty && out.last.$1 == d) {
      out.last.$2.add(p);
    } else {
      out.add((d, [p]));
    }
  }
  return out;
}

/// Сохранить снимок раздела. [replace] — заменить снимок той же позы в той же серии (утро отёков).
Future<bool> saveBodyPhoto(
  WidgetRef ref, {
  required String sourcePath,
  required PhotoKind kind,
  required PhotoPose pose,
  required String sessionId,
  bool replace = false,
}) async {
  try {
    await ref.read(photoServiceProvider).save(
          sourcePath: sourcePath,
          kind: kind,
          pose: pose,
          replace: replace,
          sessionId: sessionId,
        );
    return true;
  } catch (e) {
    debugPrint('saveBodyPhoto: $e');
    return false;
  }
}
