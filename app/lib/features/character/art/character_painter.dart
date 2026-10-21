import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import '../../../ui/ui.dart';
import 'character_look.dart';
import 'character_pose.dart';

/// Векторная отрисовка персонажа по «скелету» [CharacterPose] и внешнему виду [CharacterLook].
///
/// Рисует в условной системе координат 96×160 (масштабируется под размер), земля — y≈156.
/// Слои сзади вперёд: плащ, меч, задние волосы, ноги, корпус, шарф, руки, голова, лицо, чёлка.
/// Сначала проход «свечения» (голубая обводка в духе интерфейса), затем фигура с тёмным контуром.
class CharacterPainter extends CustomPainter {
  CharacterPainter({
    required this.look,
    required this.pose,
    required this.phase,
    this.facingLeft = false,
    this.glowColor = SysColors.accent,
  });

  final CharacterLook look;
  final CharacterPose pose;
  final double phase;
  final bool facingLeft;
  final Color glowColor;

  static const double designWidth = 96;
  static const double designHeight = 160;
  static const _outline = Color(0xFF0B1426);
  static const _mouth = Color(0xFF7A2335);
  static const _steel = Color(0xFFC9D6E8);

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.height / designHeight;
    final shapes = <_Shape>[];
    final g = _build(shapes);

    canvas.save();
    canvas.translate((size.width - designWidth * k) / 2, 0);
    canvas.scale(k);
    canvas.save();
    if (facingLeft) {
      canvas.translate(designWidth, 0);
      canvas.scale(-1, 1);
    }

    // Свечение-обводка.
    final glow = Paint()
      ..color = glowColor.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5);
    for (final s in shapes) {
      if (!s.glow) continue;
      glow.strokeWidth = (s.width ?? 0) + 3;
      canvas.drawPath(s.path, glow);
    }

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fill = Paint()..style = PaintingStyle.fill;
    for (final s in shapes) {
      final w = s.width;
      if (s.outline) {
        stroke
          ..color = _outline
          ..strokeWidth = (w ?? 0) + 1.4;
        canvas.drawPath(s.path, stroke);
      }
      if (w == null) {
        fill.color = s.color;
        canvas.drawPath(s.path, fill);
      } else {
        stroke
          ..color = s.color
          ..strokeWidth = w;
        canvas.drawPath(s.path, stroke);
      }
    }
    canvas.restore();

    // Знаки поверх (не зеркалятся, чтобы «z» читались).
    final head = facingLeft ? Offset(designWidth - g.dx, g.dy) : g;
    _paintZzz(canvas, head);
    _paintAnger(canvas, head);
    canvas.restore();
  }

  /// Строит фигуры; возвращает центр головы (для знаков поверх).
  Offset _build(List<_Shape> out) {
    final p = pose;
    final l = look;
    final pelvis = Offset(48 + p.sway, 95 + p.sit * 30 + p.lift);
    final up = Offset(math.sin(p.lean), -math.cos(p.lean));
    final perp = Offset(math.cos(p.lean), math.sin(p.lean));
    final torsoLen = 37 + p.breath * .8;
    final shoulderC = pelvis + up * torsoLen;
    final shL = shoulderC - perp * l.shoulderHalf - up * 2;
    final shR = shoulderC + perp * l.shoulderHalf - up * 2;
    final headAngle = p.lean * .6 + p.headTilt;
    final headC = shoulderC + _rot(Offset(0, -(l.headRy + 5)), p.lean * .6);
    final head = _Affine(headC, headAngle);
    final flutter = p.cape;

    // 1. Плащ.
    if (l.cloak) {
      final bottomY = math.min(pelvis.dy + 44, 156.0);
      final path = Path()
        ..moveTo(shL.dx + 1, shL.dy)
        ..lineTo(shR.dx - 1, shR.dy)
        ..quadraticBezierTo(shR.dx + 10, pelvis.dy, shR.dx + 12 - flutter * 3, bottomY)
        ..lineTo(shL.dx - 12 - flutter * 4, bottomY + flutter * 2)
        ..quadraticBezierTo(shL.dx - 10, pelvis.dy, shL.dx + 1, shL.dy)
        ..close();
      out.add(_Shape(path, l.topShade));
    }

    // 2. Меч за спиной.
    if (l.sword) {
      final hilt = shoulderC + perp * 11 + up * 17;
      final tip = pelvis - perp * 17 - up * 6;
      final d = tip - hilt;
      final n = d / d.distance;
      final guard = hilt + n * 8;
      final across = Offset(-n.dy, n.dx);
      out
        ..add(_Shape(Path()
          ..moveTo(guard.dx, guard.dy)
          ..lineTo(tip.dx, tip.dy), _steel, width: 3.4))
        ..add(_Shape(Path()
          ..moveTo(hilt.dx, hilt.dy)
          ..lineTo(guard.dx, guard.dy), const Color(0xFF3A2E2A), width: 3))
        ..add(_Shape(Path()
          ..moveTo((guard + across * 4).dx, (guard + across * 4).dy)
          ..lineTo((guard - across * 4).dx, (guard - across * 4).dy), l.accent, width: 2.2));
    }

    // 3. Задние волосы.
    _backHair(out, head, flutter);

    // 4. Ноги.
    for (final side in const [-1.0, 1.0]) {
      final hip = Offset(pelvis.dx + side * l.hipHalf, pelvis.dy);
      final lift = side < 0 ? p.legLiftL : p.legLiftR;
      final standKnee = hip + Offset(side * (1 + 3 * lift), 29 - 9 * lift);
      final standFoot = hip + Offset(side * 2, 59 - 14 * lift);
      final sitKnee = hip + Offset(side * 17, 5);
      final sitFoot = hip + Offset(side * 5, 26);
      final knee = Offset.lerp(standKnee, sitKnee, p.sit)!;
      final foot = Offset.lerp(standFoot, sitFoot, p.sit)!;
      final legColor = l.skirt ? l.skin : l.bottom;
      out.add(_Shape(Path()
        ..moveTo(hip.dx, hip.dy)
        ..lineTo(knee.dx, knee.dy)
        ..lineTo(foot.dx, foot.dy), legColor, width: l.legWidth));
      final shoeW = l.legWidth + 4;
      out.add(_Shape(
        Path()..addOval(Rect.fromCenter(center: foot + Offset(side * 1.5, 1.5), width: shoeW, height: shoeW * .55)),
        l.shoes,
      ));
    }

    // 5. Корпус.
    final waistL = pelvis - perp * l.waistHalf + up * 12;
    final waistR = pelvis + perp * l.waistHalf + up * 12;
    final hipL = pelvis - perp * (l.hipHalf + 3.5);
    final hipR = pelvis + perp * (l.hipHalf + 3.5);
    final torso = Path()
      ..moveTo(shL.dx, shL.dy)
      ..quadraticBezierTo(shoulderC.dx, shoulderC.dy - 2.5, shR.dx, shR.dy)
      ..quadraticBezierTo(shR.dx + 1, (shR.dy + waistR.dy) / 2, waistR.dx, waistR.dy)
      ..lineTo(hipR.dx, hipR.dy)
      ..lineTo(hipL.dx, hipL.dy)
      ..lineTo(waistL.dx, waistL.dy)
      ..quadraticBezierTo(shL.dx - 1, (shL.dy + waistL.dy) / 2, shL.dx, shL.dy)
      ..close();
    out.add(_Shape(torso, l.top));
    // Шорты/брюки — нижняя часть корпуса.
    final beltL = pelvis - perp * (l.hipHalf + 3.5) + up * 5;
    final beltR = pelvis + perp * (l.hipHalf + 3.5) + up * 5;
    final shorts = Path()
      ..moveTo(beltL.dx, beltL.dy)
      ..lineTo(beltR.dx, beltR.dy)
      ..lineTo(hipR.dx + perp.dx, hipR.dy + 6)
      ..lineTo(hipL.dx - perp.dx, hipL.dy + 6)
      ..close();
    out.add(_Shape(shorts, l.bottom));
    if (l.skirt) {
      final f = flutter * 1.5;
      out.add(_Shape(
        Path()
          ..moveTo(beltL.dx, beltL.dy)
          ..lineTo(beltR.dx, beltR.dy)
          ..lineTo(hipR.dx + 5 + f, hipR.dy + 10)
          ..lineTo(hipL.dx - 5 + f, hipL.dy + 10)
          ..close(),
        l.bottom,
      ));
    }
    // Детали одежды.
    final mid = Offset.lerp(shoulderC, pelvis, .5)!;
    switch (l.hairStyle) {
      case HairStyle.sidePonytail:
        // Молния куртки и полоса.
        out.add(_Shape(_line(shoulderC + up * -1, beltL + (beltR - beltL) / 2), l.accent, width: 1.2, glow: false, outline: false));
        out.add(_Shape(_line(shL + up * -6, waistL + perp * 3), l.topShade, width: 1.6, glow: false, outline: false));
        out.add(_Shape(_line(shR + up * -6, waistR - perp * 3), l.topShade, width: 1.6, glow: false, outline: false));
      case HairStyle.spiky:
        // Карман худи и шнурки.
        out.add(_Shape(
          Path()..addRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: mid + up * -6, width: 14, height: 6), const Radius.circular(2))),
          l.topShade,
          glow: false,
        ));
        out.add(_Shape(_line(shoulderC + perp * -3 + up * -2, shoulderC + perp * -3 + up * -10), l.accent, width: 1, glow: false, outline: false));
        out.add(_Shape(_line(shoulderC + perp * 3 + up * -2, shoulderC + perp * 3 + up * -10), l.accent, width: 1, glow: false, outline: false));
      case HairStyle.buzzBeard:
        // Вырез майки.
        out.add(_Shape(
          Path()
            ..moveTo(shoulderC.dx - 6, shoulderC.dy - 1)
            ..quadraticBezierTo(shoulderC.dx, shoulderC.dy + 9, shoulderC.dx + 6, shoulderC.dy - 1),
          l.skin,
          glow: false,
        ));
      case HairStyle.longTied:
        // Запах куртки и кушак.
        out.add(_Shape(_line(shL + perp * 4, waistR - perp * 2), l.topShade, width: 2, glow: false, outline: false));
    }
    if (l.belt || l.hairStyle == HairStyle.longTied) {
      out.add(_Shape(_line(beltL + up * 1, beltR + up * 1), l.belt ? const Color(0xFF5C4033) : l.accent, width: 3, glow: false));
      if (l.belt) {
        final c = Offset.lerp(beltL, beltR, .5)! + up * 1;
        out.add(_Shape(Path()..addRect(Rect.fromCenter(center: c, width: 5, height: 4)), l.accent, glow: false));
      }
    }

    // 6. Шея.
    out.add(_Shape(_line(shoulderC, shoulderC + up * 6), l.skin, width: l.armWidth + 1, glow: false));

    // 7. Шарф.
    if (l.scarf) {
      final s0 = shoulderC + up * 2.5;
      out.add(_Shape(_line(s0 - perp * 7, s0 + perp * 7), l.accent, width: 5));
      final tailStart = s0 - perp * 5;
      out.add(_Shape(
        Path()
          ..moveTo(tailStart.dx, tailStart.dy)
          ..quadraticBezierTo(tailStart.dx - 8, tailStart.dy + 6 + flutter * 3, tailStart.dx - 14 - flutter * 4, tailStart.dy + 14),
        l.accent,
        width: 4,
      ));
    }

    // 8. Руки.
    final upperLen = l.armWidth > 8 ? 19.0 : 18.0;
    final foreLen = l.armWidth > 8 ? 18.0 : 17.0;
    for (final side in const [-1.0, 1.0]) {
      final sh = side < 0 ? shL : shR;
      final a = side < 0 ? p.armLA : p.armRA;
      final e = side < 0 ? p.armLE : p.armRE;
      final elbow = sh + _dir(side, a) * upperLen;
      final hand = elbow + _dir(side, a + e) * foreLen;
      out.add(_Shape(_line(sh, elbow), l.sleeve, width: l.armWidth));
      out.add(_Shape(_line(elbow, hand), l.bareForearms ? l.skin : l.sleeve, width: l.armWidth - .5));
      if (side > 0 && p.pointR > .05) {
        final f = hand + _dir(side, a + e) * (6 * p.pointR);
        out.add(_Shape(_line(hand, f), l.skin, width: 2, glow: false));
      }
      out.add(_Shape(Path()..addOval(Rect.fromCircle(center: hand, radius: l.armWidth * .55 + .6)), l.skin));
    }

    // 9. Голова и лицо.
    out.add(_Shape(
      head.path(Path()..addOval(Rect.fromCenter(center: Offset.zero, width: l.headRx * 2, height: l.headRy * 2))),
      l.skin,
    ));
    _face(out, head);
    _frontHair(out, head, flutter);
    return headC;
  }

  void _face(List<_Shape> out, _Affine head) {
    final p = pose;
    final l = look;
    final turn = p.headTurn * 3;
    // Борода силача — до рта.
    if (l.hairStyle == HairStyle.buzzBeard) {
      final beard = Path()
        ..moveTo(-l.headRx + .5, 0)
        ..quadraticBezierTo(-l.headRx + 1, l.headRy + 4, turn * .5, l.headRy + 5)
        ..quadraticBezierTo(l.headRx - 1, l.headRy + 4, l.headRx - .5, 0)
        ..lineTo(l.headRx - 3, 3)
        ..quadraticBezierTo(turn * .5, 6, -l.headRx + 3, 3)
        ..close();
      out.add(_Shape(head.path(beard), l.hairShade, glow: false));
    }

    // Румянец.
    if (p.blush > .05) {
      final c = const Color(0xFFFF6F91).withValues(alpha: .45 * p.blush.clamp(0, 1));
      for (final s in const [-1.0, 1.0]) {
        out.add(_Shape(head.path(Path()..addOval(Rect.fromCenter(center: Offset(s * 8.5 + turn, 6), width: 5, height: 2.6))), c,
            glow: false, outline: false));
      }
    }

    // Глаза.
    final open = p.eyeOpen.clamp(0.0, 1.0);
    for (final s in const [-1.0, 1.0]) {
      final c = Offset(s * 5.6 + turn, 2);
      if (open < .2) {
        // Закрытые: «^» от радости или «‿» во сне.
        final happy = p.smile > .5;
        final path = Path()
          ..moveTo(c.dx - 3, c.dy + (happy ? 1 : 0))
          ..quadraticBezierTo(c.dx, c.dy + (happy ? -3 : 2.5), c.dx + 3, c.dy + (happy ? 1 : 0));
        out.add(_Shape(head.path(path), _outline, width: 1.3, glow: false, outline: false));
        continue;
      }
      switch (l.eyeStyle) {
        case EyeStyle.bigRound:
        case EyeStyle.bright:
          final big = l.eyeStyle == EyeStyle.bigRound;
          final rx = big ? 3.4 : 3.0;
          final ry = (big ? 4.4 : 3.8) * open;
          out.add(_Shape(head.path(Path()..addOval(Rect.fromCenter(center: c, width: rx * 2, height: ry * 2))),
              const Color(0xFFFFFFFF), glow: false, outline: false));
          final ic = c + Offset(turn * .25, .5);
          out.add(_Shape(head.path(Path()..addOval(Rect.fromCenter(center: ic, width: rx * 1.5, height: ry * 1.6))), l.iris,
              glow: false, outline: false));
          out.add(_Shape(head.path(Path()..addOval(Rect.fromCenter(center: ic, width: rx * .7, height: ry * .9))), _outline,
              glow: false, outline: false));
          out.add(_Shape(head.path(Path()..addOval(Rect.fromCircle(center: ic + Offset(-.9, -ry * .35), radius: .9))),
              const Color(0xFFFFFFFF), glow: false, outline: false));
          // Верхнее веко/ресницы.
          final lid = Path()
            ..moveTo(c.dx - rx - .4, c.dy - ry * .3 + (big && s < 0 ? 0 : 0))
            ..quadraticBezierTo(c.dx, c.dy - ry - 1, c.dx + rx + .4, c.dy - ry * .3);
          out.add(_Shape(head.path(lid), _outline, width: big ? 1.6 : 1.3, glow: false, outline: false));
        case EyeStyle.narrowCalm:
          out.add(_Shape(head.path(Path()..addOval(Rect.fromCenter(center: c, width: 4.2, height: 2.2 * open + .4))), _outline,
              glow: false, outline: false));
        case EyeStyle.sharp:
          final h = 2.4 * open;
          final eye = Path()
            ..moveTo(c.dx - 3.4, c.dy + .6)
            ..quadraticBezierTo(c.dx, c.dy - h * 1.4, c.dx + 3.4, c.dy - .6 * s)
            ..quadraticBezierTo(c.dx, c.dy + h, c.dx - 3.4, c.dy + .6)
            ..close();
          out.add(_Shape(head.path(eye), const Color(0xFFF2F2F2), glow: false, outline: false));
          out.add(_Shape(head.path(Path()..addOval(Rect.fromCircle(center: c + Offset(turn * .2, 0), radius: 1.3 * open + .2))),
              l.iris, glow: false, outline: false));
          out.add(_Shape(head.path(Path()
            ..moveTo(c.dx - 3.6, c.dy)
            ..quadraticBezierTo(c.dx, c.dy - h * 1.5, c.dx + 3.6, c.dy - .8 * s)), _outline, width: 1.4, glow: false, outline: false));
      }
    }

    // Брови: при злости внутренние концы опускаются.
    final browW = l.hairStyle == HairStyle.buzzBeard ? 2.2 : 1.4;
    for (final s in const [-1.0, 1.0]) {
      final inner = Offset(s * 2.4 + turn, -4.6 + p.brow * 1.9);
      final outer = Offset(s * 8.6 + turn, -6.2 - p.brow * .7);
      out.add(_Shape(head.path(_line(inner, outer)), l.hairShade, width: browW, glow: false, outline: false));
    }

    // Шрам мечника.
    if (l.scar) {
      out.add(_Shape(head.path(_line(Offset(-9 + turn, -3), Offset(-3.5 + turn, 7))), const Color(0xFFC07A6A),
          width: 1, glow: false, outline: false));
    }

    // Рот.
    final m = Offset(turn * .8, 9);
    final w = 3.3 + math.max(0.0, p.smile) * 1.2;
    final sm = p.smile;
    if (p.mouthOpen > .08) {
      final mouth = Path()
        ..moveTo(m.dx - w, m.dy - sm * .6)
        ..quadraticBezierTo(m.dx, m.dy + sm * 1.6, m.dx + w, m.dy - sm * .6)
        ..quadraticBezierTo(m.dx, m.dy + sm * 1.6 + p.mouthOpen * 6, m.dx - w, m.dy - sm * .6)
        ..close();
      out.add(_Shape(head.path(mouth), _mouth, glow: false, outline: false));
      out.add(_Shape(head.path(mouth), _outline, width: .9, glow: false, outline: false));
    } else {
      final mouth = Path()
        ..moveTo(m.dx - w, m.dy - sm * .9)
        ..quadraticBezierTo(m.dx, m.dy + sm * 2.6, m.dx + w, m.dy - sm * .9);
      out.add(_Shape(head.path(mouth), _outline, width: 1.2, glow: false, outline: false));
    }
    if (l.hairStyle == HairStyle.buzzBeard) {
      // Усы.
      final must = Path()
        ..moveTo(m.dx - 5, m.dy - 1)
        ..quadraticBezierTo(m.dx, m.dy - 4, m.dx + 5, m.dy - 1);
      out.add(_Shape(head.path(must), l.hairShade, width: 2.2, glow: false, outline: false));
    }
  }

  void _backHair(List<_Shape> out, _Affine head, double flutter) {
    final l = look;
    final rx = l.headRx;
    final ry = l.headRy;
    switch (l.hairStyle) {
      case HairStyle.sidePonytail:
        final back = Path()
          ..moveTo(-rx - 2, -2)
          ..quadraticBezierTo(-rx - 4, 16, -rx - 1, 22)
          ..lineTo(rx + 1, 22)
          ..quadraticBezierTo(rx + 4, 16, rx + 2, -2)
          ..arcToPoint(Offset(-rx - 2, -2), radius: Radius.elliptical(rx + 2, ry + 2), clockwise: false)
          ..close();
        out.add(_Shape(head.path(back), l.hairShade));
        final tail = Path()
          ..moveTo(rx - 3, -12)
          ..quadraticBezierTo(rx + 16 + flutter * 2, -10, rx + 13 + flutter * 3, 14)
          ..quadraticBezierTo(rx + 11 + flutter * 3, 26, rx + 6 + flutter * 2, 32)
          ..quadraticBezierTo(rx + 7, 14, rx - 1, -4)
          ..close();
        out.add(_Shape(head.path(tail), l.hair));
      case HairStyle.longTied:
        final back = Path()
          ..moveTo(-rx - 2, -3)
          ..quadraticBezierTo(-rx - 3, 18, -rx + 1, 28)
          ..lineTo(rx - 1, 28)
          ..quadraticBezierTo(rx + 3, 18, rx + 2, -3)
          ..arcToPoint(Offset(-rx - 2, -3), radius: Radius.elliptical(rx + 2, ry + 2), clockwise: false)
          ..close();
        out.add(_Shape(head.path(back), l.hairShade));
        final tail = Path()
          ..moveTo(-4, -ry + 2)
          ..quadraticBezierTo(-rx - 10 - flutter * 3, -ry + 4, -rx - 12 - flutter * 4, 10)
          ..quadraticBezierTo(-rx - 8 - flutter * 2, 2, -2, -ry + 6)
          ..close();
        out.add(_Shape(head.path(tail), l.hair));
      case HairStyle.spiky:
      case HairStyle.buzzBeard:
        break;
    }
  }

  void _frontHair(List<_Shape> out, _Affine head, double flutter) {
    final l = look;
    final rx = l.headRx;
    final ry = l.headRy;
    switch (l.hairStyle) {
      case HairStyle.sidePonytail:
        final cap = Path()
          ..moveTo(-rx - 1.5, 4)
          ..quadraticBezierTo(-rx - 2, -ry - 2, 0, -ry - 2)
          ..quadraticBezierTo(rx + 2, -ry - 2, rx + 1.5, 4)
          ..lineTo(rx - 2, -4)
          ..lineTo(rx - 5, -2)
          ..lineTo(5, -7)
          ..lineTo(2, -3)
          ..lineTo(-2, -8)
          ..lineTo(-6, -3)
          ..lineTo(-9, -7)
          ..lineTo(-rx + 2, -2)
          ..close();
        out.add(_Shape(head.path(cap), l.hair));
        // Резинка хвоста.
        out.add(_Shape(head.path(Path()..addOval(Rect.fromCircle(center: Offset(rx - 1, -11), radius: 2.2))), l.accent, glow: false));
      case HairStyle.spiky:
        final spikes = Path()
          ..moveTo(-rx - 1.5, 3)
          ..lineTo(-rx - 7, -6)
          ..lineTo(-rx - 1, -9)
          ..lineTo(-rx - 6, -ry - 2)
          ..lineTo(-6, -ry - 1)
          ..lineTo(-4, -ry - 10)
          ..lineTo(2, -ry - 2)
          ..lineTo(8, -ry - 9)
          ..lineTo(rx - 2, -ry + 1)
          ..lineTo(rx + 8, -ry - 2)
          ..lineTo(rx + 1, -8)
          ..lineTo(rx + 6, -4)
          ..lineTo(rx + 1.5, 3)
          ..lineTo(rx - 3, -5)
          ..lineTo(5, -3)
          ..lineTo(3, -8)
          ..lineTo(-1, -2)
          ..lineTo(-4, -7)
          ..lineTo(-8, -2)
          ..lineTo(-rx + 2, -5)
          ..close();
        out.add(_Shape(head.path(spikes), l.hair));
      case HairStyle.buzzBeard:
        final cap = Path()
          ..moveTo(-rx - .5, -3)
          ..quadraticBezierTo(-rx, -ry - 1.5, 0, -ry - 1.5)
          ..quadraticBezierTo(rx, -ry - 1.5, rx + .5, -3)
          ..quadraticBezierTo(rx - 2, -9, 0, -10)
          ..quadraticBezierTo(-rx + 2, -9, -rx - .5, -3)
          ..close();
        out.add(_Shape(head.path(cap), l.hair));
      case HairStyle.longTied:
        final bangs = Path()
          ..moveTo(-rx - 2, 6)
          ..quadraticBezierTo(-rx - 2, -ry - 2, 0, -ry - 2)
          ..quadraticBezierTo(rx + 2, -ry - 2, rx + 2, 8)
          ..lineTo(rx - 1, 10)
          ..quadraticBezierTo(rx - 4, 0, 2, -6)
          ..lineTo(-2, -3)
          ..lineTo(-6, -7)
          ..lineTo(-rx + 1, -1)
          ..close();
        out.add(_Shape(head.path(bangs), l.hair));
        // Повязка.
        out.add(_Shape(head.path(_line(Offset(-rx + 1, -9), Offset(rx - 1, -9))), l.accent, width: 1.6, glow: false));
    }
  }

  void _paintZzz(Canvas canvas, Offset head) {
    if (pose.zzz < .05) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < 3; i++) {
      final t = (phase / (2 * math.pi) + i / 3) % 1.0;
      final size = 4 + t * 4;
      final o = head + Offset(14 + t * 10, -14 - t * 22);
      paint.color = SysColors.accentLighter.withValues(alpha: (pose.zzz * (1 - t)).clamp(0.0, 1.0));
      canvas.drawPath(
        Path()
          ..moveTo(o.dx, o.dy)
          ..lineTo(o.dx + size, o.dy)
          ..lineTo(o.dx, o.dy + size)
          ..lineTo(o.dx + size, o.dy + size),
        paint,
      );
    }
  }

  void _paintAnger(Canvas canvas, Offset head) {
    if (pose.anger < .05) return;
    final c = head + Offset(look.headRx - 1, -look.headRy + 1);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..color = SysColors.danger.withValues(alpha: pose.anger.clamp(0.0, 1.0));
    for (var i = 0; i < 4; i++) {
      final a = i * math.pi / 2 + math.pi / 4;
      final d = Offset(math.cos(a), math.sin(a));
      final n = Offset(-d.dy, d.dx);
      final p0 = c + d * 1.5 + n * 2.5;
      final p1 = c + d * 1.5 - n * 2.5;
      canvas.drawPath(
        Path()
          ..moveTo(p0.dx, p0.dy)
          ..quadraticBezierTo(c.dx + d.dx * 5, c.dy + d.dy * 5, p1.dx, p1.dy),
        paint,
      );
    }
  }

  static Offset _dir(double side, double a) => Offset(side * math.sin(a), math.cos(a));

  static Offset _rot(Offset v, double a) {
    final c = math.cos(a);
    final s = math.sin(a);
    return Offset(v.dx * c - v.dy * s, v.dx * s + v.dy * c);
  }

  static Path _line(Offset a, Offset b) => Path()
    ..moveTo(a.dx, a.dy)
    ..lineTo(b.dx, b.dy);

  @override
  bool shouldRepaint(CharacterPainter old) => true;
}

/// Фигура: заливка (width == null) или линия толщиной width.
class _Shape {
  _Shape(this.path, this.color, {this.width, this.glow = true, this.outline = true});

  final Path path;
  final Color color;
  final double? width;
  final bool glow;
  final bool outline;
}

/// Поворот + перенос (локальные координаты головы → координаты фигуры).
class _Affine {
  _Affine(Offset origin, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    _m = Float64List.fromList([c, s, 0, 0, -s, c, 0, 0, 0, 0, 1, 0, origin.dx, origin.dy, 0, 1]);
  }

  late final Float64List _m;

  Path path(Path local) => local.transform(_m);
}
