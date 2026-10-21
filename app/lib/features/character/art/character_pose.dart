import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import '../../../core/models/enums.dart';

/// «Скелет» персонажа: набор параметров позы и мимики.
///
/// Все координаты — в условной системе 96×160 (см. CharacterPainter), углы — в радианах.
/// Углы рук: 0 — вниз вдоль тела, π/2 — горизонтально наружу, π — вверх.
/// Состояния переключаются плавно через [CharacterPose.lerp].
class CharacterPose {
  const CharacterPose({
    this.lift = 0,
    this.sway = 0,
    this.lean = 0,
    this.breath = 0,
    this.sit = 0,
    this.headTilt = 0,
    this.headTurn = 0,
    this.armLA = .12,
    this.armLE = .15,
    this.armRA = .12,
    this.armRE = .15,
    this.legLiftL = 0,
    this.legLiftR = 0,
    this.pointR = 0,
    this.eyeOpen = 1,
    this.mouthOpen = 0,
    this.smile = .2,
    this.brow = 0,
    this.blush = 0,
    this.zzz = 0,
    this.anger = 0,
    this.cape = 0,
  });

  /// Смещение всей фигуры по вертикали (отрицательное — вверх, прыжок).
  final double lift;

  /// Смещение корпуса по горизонтали.
  final double sway;

  /// Наклон корпуса (положительный — вперёд по направлению взгляда).
  final double lean;

  /// Дыхание: удлинение корпуса.
  final double breath;

  /// 0 — стоит, 1 — сидит на земле.
  final double sit;
  final double headTilt;

  /// Поворот лица в сторону (−1..1), сдвигает черты лица.
  final double headTurn;

  /// Левая/правая рука: угол плеча (A) и сгиб локтя (E).
  final double armLA;
  final double armLE;
  final double armRA;
  final double armRE;

  /// Подъём колена при шаге, 0..1.
  final double legLiftL;
  final double legLiftR;

  /// Указательный палец правой руки, 0..1.
  final double pointR;

  /// Глаза: 1 — открыты, 0 — закрыты.
  final double eyeOpen;
  final double mouthOpen;

  /// −1 — недовольство, 1 — широкая улыбка.
  final double smile;

  /// 1 — нахмурены (злость), −1 — подняты (удивление/грусть).
  final double brow;
  final double blush;

  /// Прозрачность «z» во сне.
  final double zzz;

  /// Знак злости у головы.
  final double anger;

  /// Колыхание плаща/шарфа/хвоста.
  final double cape;

  static CharacterPose lerp(CharacterPose a, CharacterPose b, double t) {
    double l(double x, double y) => lerpDouble(x, y, t)!;
    return CharacterPose(
      lift: l(a.lift, b.lift),
      sway: l(a.sway, b.sway),
      lean: l(a.lean, b.lean),
      breath: l(a.breath, b.breath),
      sit: l(a.sit, b.sit),
      headTilt: l(a.headTilt, b.headTilt),
      headTurn: l(a.headTurn, b.headTurn),
      armLA: l(a.armLA, b.armLA),
      armLE: l(a.armLE, b.armLE),
      armRA: l(a.armRA, b.armRA),
      armRE: l(a.armRE, b.armRE),
      legLiftL: l(a.legLiftL, b.legLiftL),
      legLiftR: l(a.legLiftR, b.legLiftR),
      pointR: l(a.pointR, b.pointR),
      eyeOpen: l(a.eyeOpen, b.eyeOpen),
      mouthOpen: l(a.mouthOpen, b.mouthOpen),
      smile: l(a.smile, b.smile),
      brow: l(a.brow, b.brow),
      blush: l(a.blush, b.blush),
      zzz: l(a.zzz, b.zzz),
      anger: l(a.anger, b.anger),
      cape: l(a.cape, b.cape),
    );
  }

  /// Поза состояния [state] в фазе цикла [phase] (0..2π, цикл анимации ~2.4 с).
  /// Все частоты — целые кратные фазы, поэтому цикл бесшовный. При phase = 0 — «статичная» поза
  /// (используется при «Уменьшении движения»).
  static CharacterPose forState(CharacterState state, double phase) {
    final s = math.sin(phase);
    final blink = (phase > 5.95 && phase < 6.15) ? .08 : 1.0;
    switch (state) {
      case CharacterState.idle:
        return CharacterPose(
          breath: s * 1.0,
          sway: math.sin(phase) * .5,
          armLA: .14 + s * .03,
          armRA: .14 + s * .03,
          eyeOpen: blink,
          smile: .25,
          cape: s * .3,
        );
      case CharacterState.walk:
        final st = math.sin(phase * 3);
        return CharacterPose(
          lift: -(math.sin(phase * 3).abs()) * 1.6,
          lean: .06,
          headTurn: .6,
          legLiftL: math.max(0, st),
          legLiftR: math.max(0, -st),
          armLA: .18 + .3 * st,
          armLE: .3,
          armRA: .18 - .3 * st,
          armRE: .3,
          eyeOpen: blink,
          smile: .25,
          cape: .5 + st * .3,
        );
      case CharacterState.talk:
        return CharacterPose(
          breath: s * .6,
          mouthOpen: (math.sin(phase * 8)).abs() * .85,
          armLA: .14,
          armRA: .45 + .15 * math.sin(phase * 2),
          armRE: -1.0,
          headTilt: math.sin(phase * 2) * .04,
          eyeOpen: blink,
          smile: .35,
          brow: -.2,
          cape: s * .3,
        );
      case CharacterState.happy:
        final j = math.max(0.0, math.sin(phase * 3));
        return CharacterPose(
          lift: -12 * j,
          armLA: 2.55 + .15 * j,
          armLE: .25,
          armRA: 2.55 + .15 * j,
          armRE: .25,
          legLiftL: .35 * j,
          legLiftR: .35 * j,
          eyeOpen: 0,
          mouthOpen: .6,
          smile: 1,
          brow: -.4,
          blush: 1,
          cape: .4 + j * .4,
        );
      case CharacterState.angry:
        final shake = math.sin(phase * 16);
        return CharacterPose(
          sway: shake * .6,
          armLA: .55 + shake * .07,
          armLE: -2.2,
          armRA: .55 - shake * .07,
          armRE: -2.2,
          eyeOpen: .85,
          mouthOpen: .3,
          smile: -.9,
          brow: 1,
          anger: 1,
          cape: shake * .2,
        );
      case CharacterState.sit:
        return CharacterPose(
          sit: 1,
          breath: s * .8,
          armLA: .75,
          armLE: -.35,
          armRA: .75,
          armRE: -.35,
          eyeOpen: blink,
          smile: .15,
        );
      case CharacterState.sleep:
        return CharacterPose(
          sit: 1,
          breath: s * 1.4,
          lean: .08,
          headTilt: .28,
          armLA: .5,
          armLE: -.7,
          armRA: .5,
          armRE: -.7,
          eyeOpen: 0,
          mouthOpen: .15 + s * .05,
          smile: 0,
          zzz: 1,
        );
      case CharacterState.point:
        return CharacterPose(
          breath: s * .6,
          lift: -(s.abs()) * .5,
          headTurn: .4,
          armLA: .6,
          armLE: -1.9,
          armRA: 1.95 + s * .04,
          armRE: .1,
          pointR: 1,
          eyeOpen: blink,
          mouthOpen: .2,
          smile: .45,
          brow: .15,
          cape: s * .3,
        );
    }
  }
}
