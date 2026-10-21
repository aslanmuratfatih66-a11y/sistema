import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';

/// Архетипы персонажа (раздел character.archetype). Все персонажи оригинальные.
const characterArchetypes = ['animeGirl', 'animeGuy', 'stoicStrongman', 'grimSwordsman'];

/// Режимы мотивации (character.motivation).
const motivationModes = ['soft', 'normal', 'strict', 'harsh'];

/// Голоса-заглушки: id = '<архетип>.<вариант>'. Реальный TTS подключается позже.
const characterVoices = <String, List<String>>{
  'animeGirl': ['animeGirl.bright', 'animeGirl.soft', 'animeGirl.calm'],
  'animeGuy': ['animeGuy.energetic', 'animeGuy.calm'],
  'stoicStrongman': ['stoicStrongman.deep', 'stoicStrongman.calm'],
  'grimSwordsman': ['grimSwordsman.low', 'grimSwordsman.hoarse', 'grimSwordsman.calm'],
};

String archetypeName(AppLocalizations l, String a) => switch (a) {
      'animeGirl' => l.qbArchAnimeGirl,
      'animeGuy' => l.qbArchAnimeGuy,
      'stoicStrongman' => l.qbArchStoicStrongman,
      _ => l.qbArchGrimSwordsman,
    };

String archetypeCharacter(AppLocalizations l, String a) => switch (a) {
      'animeGirl' => l.qbArchAnimeGirlDesc,
      'animeGuy' => l.qbArchAnimeGuyDesc,
      'stoicStrongman' => l.qbArchStoicStrongmanDesc,
      _ => l.qbArchGrimSwordsmanDesc,
    };

String archetypeSpeech(AppLocalizations l, String a) => switch (a) {
      'animeGirl' => l.qbArchAnimeGirlSpeech,
      'animeGuy' => l.qbArchAnimeGuySpeech,
      'stoicStrongman' => l.qbArchStoicStrongmanSpeech,
      _ => l.qbArchGrimSwordsmanSpeech,
    };

String voiceLabel(AppLocalizations l, String voiceId) => switch (voiceId.split('.').last) {
      'bright' => l.qbVoiceBright,
      'soft' => l.qbVoiceSoft,
      'calm' => l.qbVoiceCalm,
      'energetic' => l.qbVoiceEnergetic,
      'deep' => l.qbVoiceDeep,
      'low' => l.qbVoiceLow,
      'hoarse' => l.qbVoiceHoarse,
      _ => voiceId,
    };

String motivationName(AppLocalizations l, String m) => switch (m) {
      'soft' => l.qbMotSoft,
      'normal' => l.qbMotNormal,
      'strict' => l.qbMotStrict,
      _ => l.qbMotHarsh,
    };

String motivationDesc(AppLocalizations l, String m) => switch (m) {
      'soft' => l.qbMotSoftDesc,
      'normal' => l.qbMotNormalDesc,
      'strict' => l.qbMotStrictDesc,
      _ => l.qbMotHarshDesc,
    };

/// Силуэт-заглушка архетипа. Простые фигуры, без чужих ассетов;
/// позже заменяется на Rive/спрайты без переделки экрана.
class ArchetypeSilhouette extends StatelessWidget {
  const ArchetypeSilhouette({super.key, required this.archetype, this.size = 72, this.active = false});

  final String archetype;
  final double size;
  final bool active;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          size: Size(size, size * 1.25),
          painter: _SilhouettePainter(archetype, active ? SysColors.accentLighter : SysColors.accentLight),
        ),
      );
}

class _SilhouettePainter extends CustomPainter {
  _SilhouettePainter(this.archetype, this.color);

  final String archetype;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final fill = Paint()..color = color.withValues(alpha: .22);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = SysDims.iconStroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final broad = archetype == 'stoicStrongman';
    final headR = w * (broad ? .13 : .14);
    final headC = Offset(w / 2, h * .24);
    final shoulder = w * (broad ? .46 : (archetype == 'animeGirl' ? .30 : .36));
    final waist = w * (broad ? .30 : .22);

    // Оружие мечника — за спиной, рисуется первым.
    if (archetype == 'grimSwordsman') {
      final blade = Path()
        ..moveTo(w * .80, h * .06)
        ..lineTo(w * .22, h * .90);
      canvas.drawPath(blade, stroke..strokeWidth = SysDims.iconStroke * 1.6);
      stroke.strokeWidth = SysDims.iconStroke;
      canvas.drawLine(Offset(w * .66, h * .20), Offset(w * .80, h * .30), stroke);
    }

    // Корпус.
    final body = Path()
      ..moveTo(w / 2 - shoulder / 2, h * .44)
      ..quadraticBezierTo(w / 2, h * .38, w / 2 + shoulder / 2, h * .44)
      ..lineTo(w / 2 + waist / 2, h * .98)
      ..lineTo(w / 2 - waist / 2, h * .98)
      ..close();
    if (archetype == 'grimSwordsman') {
      // Плащ — расширение книзу.
      body
        ..reset()
        ..moveTo(w / 2 - shoulder / 2, h * .44)
        ..quadraticBezierTo(w / 2, h * .38, w / 2 + shoulder / 2, h * .44)
        ..lineTo(w * .86, h * .98)
        ..lineTo(w * .14, h * .98)
        ..close();
    }
    canvas
      ..drawPath(body, fill)
      ..drawPath(body, stroke);

    // Шея и голова.
    canvas.drawLine(Offset(w / 2, headC.dy + headR), Offset(w / 2, h * .41), stroke);
    canvas
      ..drawCircle(headC, headR, fill)
      ..drawCircle(headC, headR, stroke);

    // Причёски.
    switch (archetype) {
      case 'animeGirl':
        final hair = Path()
          ..moveTo(headC.dx - headR, headC.dy)
          ..quadraticBezierTo(headC.dx - headR * 1.6, headC.dy + headR * 2.2, headC.dx - headR * 1.1, h * .50)
          ..moveTo(headC.dx + headR, headC.dy)
          ..quadraticBezierTo(headC.dx + headR * 1.6, headC.dy + headR * 2.2, headC.dx + headR * 1.1, h * .50);
        canvas.drawPath(hair, stroke);
        canvas.drawArc(Rect.fromCircle(center: headC, radius: headR * 1.08), math.pi, math.pi, false, stroke);
      case 'animeGuy':
        final spikes = Path()..moveTo(headC.dx - headR, headC.dy - headR * .2);
        for (var i = 0; i < 4; i++) {
          final x0 = headC.dx - headR + i * headR / 2;
          spikes
            ..lineTo(x0 + headR / 4, headC.dy - headR * 1.7)
            ..lineTo(x0 + headR / 2, headC.dy - headR * .7);
        }
        spikes.lineTo(headC.dx + headR, headC.dy - headR * .2);
        canvas.drawPath(spikes, stroke);
      case 'stoicStrongman':
        // Сложенные руки.
        canvas.drawLine(Offset(w * .30, h * .62), Offset(w * .70, h * .62), stroke);
        canvas.drawLine(Offset(w * .30, h * .68), Offset(w * .70, h * .68), stroke);
      default:
        // Капюшон.
        canvas.drawArc(
          Rect.fromCircle(center: headC, radius: headR * 1.35),
          math.pi * .9,
          math.pi * 1.2,
          false,
          stroke,
        );
    }
  }

  @override
  bool shouldRepaint(_SilhouettePainter old) => old.archetype != archetype || old.color != color;
}
