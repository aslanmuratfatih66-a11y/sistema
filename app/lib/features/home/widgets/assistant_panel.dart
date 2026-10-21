import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../models/home_view_data.dart';

/// Блок 9: ассистент — силуэт персонажа, облачко с репликой и голосовой волной,
/// микрофон и поле «Ответить…» (пока заглушки).
class AssistantPanel extends StatefulWidget {
  const AssistantPanel({super.key, required this.assistant});

  final AssistantState assistant;

  @override
  State<AssistantPanel> createState() => _AssistantPanelState();
}

class _AssistantPanelState extends State<AssistantPanel> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    // TODO(этап ИИ): отправка реплики ассистенту.
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return SysPanel(
      title: l.homeAssistantTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Semantics(
                image: true,
                label: l.homeAssistantAvatar,
                child: const SizedBox(
                  width: 64,
                  height: 80,
                  child: CustomPaint(painter: AssistantSilhouettePainter()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SpeechBubble(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.assistant.line.of(l), style: SysText.body.copyWith(height: 1.35)),
                      if (widget.assistant.speaking) ...[
                        const SizedBox(height: 8),
                        Semantics(
                          label: l.homeAssistantSpeaking,
                          child: const SizedBox(height: 20, child: VoiceWave()),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _RoundIconButton(glyph: SysGlyph.mic, semanticLabel: l.homeMicLabel, onTap: () {}),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _controller,
                  style: SysText.body,
                  cursorColor: SysColors.accentLight,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l.homeReplyHint,
                    hintStyle: SysText.secondary.copyWith(color: SysColors.textCaption),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
                    filled: true,
                    fillColor: const Color.fromRGBO(5, 14, 32, .8),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(SysDims.radius)),
                      borderSide: BorderSide(color: SysColors.panelBorder),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(SysDims.radius)),
                      borderSide: BorderSide(color: SysColors.accentLighter, width: 1.4),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _RoundIconButton(glyph: SysGlyph.send, semanticLabel: l.homeSendLabel, onTap: _send),
            ],
          ),
        ],
      ),
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _BubblePainter(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 12, 10),
        child: child,
      ),
    );
  }
}

/// Облачко с хвостиком слева (к персонажу).
class _BubblePainter extends CustomPainter {
  const _BubblePainter();

  @override
  void paint(Canvas canvas, Size size) {
    const tail = 6.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(tail, 0, size.width - tail, size.height),
      const Radius.circular(SysDims.radius),
    );
    final path = Path()
      ..addRRect(r)
      ..moveTo(tail, 14)
      ..lineTo(0, 20)
      ..lineTo(tail, 26)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color.fromRGBO(13, 40, 84, .75));
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = SysColors.panelBorder,
    );
    canvas.drawPath(
      Path()
        ..moveTo(tail, 14)
        ..lineTo(0, 20)
        ..lineTo(tail, 26),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = SysColors.panelBorder,
    );
  }

  @override
  bool shouldRepaint(_BubblePainter old) => false;
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.glyph, required this.semanticLabel, required this.onTap});

  final SysGlyph glyph;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromRGBO(63, 180, 255, .10),
            border: Border.all(color: SysColors.accent),
            boxShadow: const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 12)],
          ),
          alignment: Alignment.center,
          child: SysIcon(glyph, size: 22, color: SysColors.accentLighter),
        ),
      ),
    );
  }
}

/// Анимированная голосовая волна (столбики). При «Уменьшении движения» — статичная.
class VoiceWave extends StatefulWidget {
  const VoiceWave({super.key, this.color = SysColors.accentLight, this.bars = 28});

  final Color color;
  final int bars;

  @override
  State<VoiceWave> createState() => _VoiceWaveState();
}

class _VoiceWaveState extends State<VoiceWave> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduce) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(
          painter: VoiceWavePainter(phase: _c.value, color: widget.color, bars: widget.bars),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class VoiceWavePainter extends CustomPainter {
  const VoiceWavePainter({required this.phase, required this.color, required this.bars});

  final double phase;
  final Color color;
  final int bars;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || bars <= 0) return;
    final step = size.width / bars;
    final w = math.max(1.5, step * 0.45);
    final mid = size.height / 2;
    final paint = Paint()
      ..color = color
      ..strokeCap = StrokeCap.round
      ..strokeWidth = w;
    final t = phase * 2 * math.pi;
    for (var i = 0; i < bars; i++) {
      final x = step * (i + 0.5);
      // Огибающая — выше в центре, плюс две «бегущие» синусоиды.
      final env = math.sin(math.pi * (i + 0.5) / bars);
      final v = 0.55 + 0.45 * math.sin(t + i * 0.7) * math.cos(t * 0.5 + i * 0.31);
      final h = math.max(w, size.height * env * v.abs());
      paint.color = color.withValues(alpha: 0.45 + 0.55 * env);
      canvas.drawLine(Offset(x, mid - h / 2), Offset(x, mid + h / 2), paint);
    }
  }

  @override
  bool shouldRepaint(VoiceWavePainter old) => old.phase != phase || old.color != color || old.bars != bars;
}

/// Простой оригинальный силуэт-заглушка: голова с визором, плечи, светящийся контур.
class AssistantSilhouettePainter extends CustomPainter {
  const AssistantSilhouettePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    // Подсветка-ореол.
    canvas.drawCircle(
      Offset(cx, h * 0.38),
      w * 0.42,
      Paint()
        ..color = SysColors.accent.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    final body = Path()
      ..moveTo(w * 0.04, h)
      ..quadraticBezierTo(w * 0.06, h * 0.70, cx - w * 0.14, h * 0.66)
      ..lineTo(cx - w * 0.10, h * 0.58)
      ..lineTo(cx + w * 0.10, h * 0.58)
      ..lineTo(cx + w * 0.14, h * 0.66)
      ..quadraticBezierTo(w * 0.94, h * 0.70, w * 0.96, h)
      ..close();
    final head = Path()..addOval(Rect.fromCenter(center: Offset(cx, h * 0.34), width: w * 0.46, height: h * 0.42));

    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF12305E), Color(0xFF061229)],
      ).createShader(Offset.zero & size);
    canvas.drawPath(body, fill);
    canvas.drawPath(head, fill);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = SysDims.iconStroke
      ..color = SysColors.accentLight;
    canvas.drawPath(body, stroke);
    canvas.drawPath(head, stroke);

    // Визор.
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(cx, h * 0.34), width: w * 0.32, height: h * 0.07),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      visor,
      Paint()
        ..color = SysColors.accentLighter.withValues(alpha: 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawRRect(visor, Paint()..color = SysColors.accentLighter);

    // Ромб на груди.
    final d = Path()
      ..moveTo(cx, h * 0.74)
      ..lineTo(cx + 4, h * 0.80)
      ..lineTo(cx, h * 0.86)
      ..lineTo(cx - 4, h * 0.80)
      ..close();
    canvas.drawPath(d, Paint()..color = SysColors.panelHeaderDiamond);
  }

  @override
  bool shouldRepaint(AssistantSilhouettePainter old) => false;
}
