// Круглый аватар персонажа в PNG для нативного оверлея: голова и плечи в «окне» Системы,
// кольцо подсвечено по состоянию (злость — красное, радость — зелёное, иначе — голубое).
// Рисуется тем же CharacterPainter, что и живой персонаж (статичная поза, phase = 0).
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import '../../core/models/enums.dart';
import '../../ui/ui.dart';
import 'art/character_look.dart';
import 'art/character_painter.dart';
import 'art/character_pose.dart';

/// Размер PNG по умолчанию (64 dp × ~3 — чётко на большинстве экранов).
const systemOverlayAvatarPx = 192;

Color systemOverlayRingColor(CharacterState s) => switch (s) {
      CharacterState.angry => SysColors.danger,
      CharacterState.happy => SysColors.success,
      _ => SysColors.accent,
    };

/// PNG круглого аватара [archetype] в состоянии [state]. null — если отрисовка не удалась.
Future<Uint8List?> renderCharacterAvatar(
  CharacterArchetype archetype, {
  CharacterState state = CharacterState.idle,
  int size = systemOverlayAvatarPx,
}) async {
  try {
    final s = size.toDouble();
    final c = Offset(s / 2, s / 2);
    final ring = math.max(2.0, s * .035);
    final r = s / 2 - ring;
    final ringColor = systemOverlayRingColor(state);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, s, s));

    // Фон «окна» Системы.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = ui.Gradient.radial(
          c.translate(0, -r * .3),
          r * 1.3,
          const [SysColors.panelTop, SysColors.background],
        ),
    );

    // Персонаж: голова и плечи — масштаб так, чтобы верхняя часть фигуры заполнила круг.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r)));
    final h = s * 1.7;
    final w = h * CharacterPainter.designWidth / CharacterPainter.designHeight;
    canvas.translate((s - w) / 2, s * .1);
    CharacterPainter(
      look: CharacterLook.of(archetype),
      pose: CharacterPose.forState(state, 0),
      phase: 0,
      glowColor: ringColor,
    ).paint(canvas, Size(w, h));
    canvas.restore();

    // Кольцо + мягкое свечение.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring * 1.6
        ..color = ringColor.withValues(alpha: .35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, ring),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = ring
        ..color = ringColor,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size, size);
    picture.dispose();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  } catch (e) {
    debugPrint('renderCharacterAvatar: $e');
    return null;
  }
}
