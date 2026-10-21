import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/onboarding/questionnaire_a/camera/mirror.dart';

Future<Uint8List> _png2x1() async {
  final rec = ui.PictureRecorder();
  ui.Canvas(rec)
    ..drawRect(const ui.Rect.fromLTWH(0, 0, 1, 1), ui.Paint()..color = const ui.Color(0xFFFF0000))
    ..drawRect(const ui.Rect.fromLTWH(1, 0, 1, 1), ui.Paint()..color = const ui.Color(0xFF0000FF));
  final pic = rec.endRecording();
  final img = await pic.toImage(2, 1);
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Future<List<int>> _rgba(Uint8List png) async {
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();
  final data = await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List().toList();
}

void main() {
  testWidgets('отражение: красный пиксель слева оказывается справа', (tester) async {
    await tester.runAsync(() async {
      final src = await _png2x1();
      expect((await _rgba(src)).sublist(0, 4), [255, 0, 0, 255]);
      final out = await mirrorImageBytes(src);
      final px = await _rgba(out);
      expect(px.sublist(0, 4), [0, 0, 255, 255]);
      expect(px.sublist(4, 8), [255, 0, 0, 255]);
    });
  });

  test('зеркальность снимка: только фронтальная камера на iOS', () {
    expect(captureIsMirrored(frontCamera: true, platform: TargetPlatform.iOS), isTrue);
    expect(captureIsMirrored(frontCamera: true, platform: TargetPlatform.android), isFalse);
    expect(captureIsMirrored(frontCamera: false, platform: TargetPlatform.iOS), isFalse);
    expect(previewIsMirrored(frontCamera: true), isTrue);
    expect(previewIsMirrored(frontCamera: false), isFalse);
  });
}
