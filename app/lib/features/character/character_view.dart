// КОНТРАКТ каркаса: отрисовка персонажа. Векторно в коде (CustomPainter); позже — Rive
// за тем же интерфейсом. Публичное API менять нельзя, можно добавлять параметры со значениями по умолчанию.
import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../core/models/enums.dart';
import 'art/character_look.dart';
import 'art/character_painter.dart';
import 'art/character_pose.dart';

/// Живой персонаж: бесконечный цикл анимации состояния [state] и плавный (~250 мс) переход
/// между состояниями через интерполяцию «скелета» позы. При «Уменьшении движения»
/// (MediaQuery.disableAnimations) — статичная поза состояния без перехода.
class CharacterView extends StatefulWidget {
  const CharacterView({
    super.key,
    required this.archetype,
    this.state = CharacterState.idle,
    this.height = 160,
    this.facingLeft = false,
  });

  final CharacterArchetype archetype;
  final CharacterState state;

  /// Высота персонажа в логических пикселях; ширина — по пропорциям.
  final double height;
  final bool facingLeft;

  /// Ширина виджета при высоте [height].
  static double widthFor(double height) => height * .6;

  @override
  State<CharacterView> createState() => _CharacterViewState();
}

class _CharacterViewState extends State<CharacterView> with TickerProviderStateMixin {
  static const _loopDuration = Duration(milliseconds: 2400);
  static const _transitionDuration = Duration(milliseconds: 250);

  late final AnimationController _loop = AnimationController(vsync: this, duration: _loopDuration);
  late final AnimationController _transition =
      AnimationController(vsync: this, duration: _transitionDuration, value: 1);
  CharacterPose? _from;
  bool _still = false;

  double get _phase => _still ? 0 : _loop.value * 2 * math.pi;

  CharacterPose _currentPose() {
    final target = CharacterPose.forState(widget.state, _phase);
    final from = _from;
    if (from == null || _still || _transition.value >= 1) return target;
    return CharacterPose.lerp(from, target, Curves.easeInOut.transform(_transition.value));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_still) {
      _loop.stop();
      _transition.value = 1;
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void didUpdateWidget(CharacterView old) {
    super.didUpdateWidget(old);
    if (old.state != widget.state && !_still) {
      // Снимок текущей позы (по старому состоянию) — от него плавно к новому.
      final target = CharacterPose.forState(old.state, _phase);
      final from = _from;
      _from = (from != null && _transition.value < 1)
          ? CharacterPose.lerp(from, target, Curves.easeInOut.transform(_transition.value))
          : target;
      _transition.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _transition.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final look = CharacterLook.of(widget.archetype);
    return SizedBox(
      height: widget.height,
      width: CharacterView.widthFor(widget.height),
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _transition]),
        builder: (context, _) => CustomPaint(
          painter: CharacterPainter(
            look: look,
            pose: _currentPose(),
            phase: _phase,
            facingLeft: widget.facingLeft,
          ),
        ),
      ),
    );
  }
}
