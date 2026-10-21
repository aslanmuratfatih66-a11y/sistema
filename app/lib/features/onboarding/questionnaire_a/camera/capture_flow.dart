import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/capabilities/capability_service.dart';
import '../../../../core/models/enums.dart';
import '../data/photo_repository.dart';
import 'camera_capture_screen.dart';
import 'capture_guide.dart';

/// Есть ли камера: не веб, возможность заявлена платформой. Пока возможности грузятся/с ошибкой — нет.
final cameraAvailableProvider = Provider<bool>((ref) {
  if (kIsWeb) return false;
  return ref.watch(deviceCapabilitiesProvider).value?.has(Capability.camera) ?? false;
});

/// Снять и сохранить фото позы. true — фото сохранено.
Future<bool> captureAndSavePhoto(
  BuildContext context,
  WidgetRef ref, {
  required PhotoKind kind,
  required PhotoPose pose,
  required CaptureGuide guide,
  required String title,
  required String instruction,
  bool replace = true,
  bool preferFrontCamera = false,
  String? sessionId,
}) async {
  final service = ref.read(photoServiceProvider);
  final tmp = await CameraCaptureScreen.open(
    context,
    guide: guide,
    title: title,
    instruction: instruction,
    preferFrontCamera: preferFrontCamera,
  );
  if (tmp == null) return false;
  try {
    await service.save(sourcePath: tmp, kind: kind, pose: pose, replace: replace, sessionId: sessionId);
    return true;
  } catch (e) {
    debugPrint('captureAndSavePhoto: $e');
    return false;
  } finally {
    try {
      await File(tmp).delete();
    } catch (_) {}
  }
}
