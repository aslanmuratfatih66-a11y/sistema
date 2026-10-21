// КАРКАС: заглушка. Реализует сабагент A.
import 'package:flutter/widgets.dart';

/// Анимация появления окна: масштаб 0.96→1 + прозрачность + «скан» сверху вниз 250 мс.
/// Уважает «Уменьшение движения» (MediaQuery.disableAnimations).
class WindowAppear extends StatelessWidget {
  const WindowAppear({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) => child;
}
