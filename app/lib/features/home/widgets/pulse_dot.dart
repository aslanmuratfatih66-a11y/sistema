import 'package:flutter/widgets.dart';

import '../../../ui/ui.dart';

/// Пульсирующая точка-индикатор «онлайн». При «Уменьшении движения» — статичная.
class PulseDot extends StatefulWidget {
  const PulseDot({super.key, this.color = SysColors.success, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.stop();
      _c.value = 0.5;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: s * 2.2,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeInOut.transform(_c.value);
            return Center(
              child: Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.65 + 0.35 * t),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withValues(alpha: 0.25 + 0.45 * t),
                      blurRadius: 3 + 7 * t,
                      spreadRadius: 0.5 + 1.5 * t,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
