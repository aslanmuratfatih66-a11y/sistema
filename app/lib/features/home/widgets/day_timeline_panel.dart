import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../data/home_providers.dart';
import '../models/home_view_data.dart';
import '../utils/home_format.dart';

Color segmentColor(DaySegmentType t) => switch (t) {
      DaySegmentType.sleep => SysColors.bossLight,
      DaySegmentType.classes => SysColors.accent,
      DaySegmentType.workout => SysColors.gold,
      DaySegmentType.free => SysColors.success,
      DaySegmentType.commute => SysColors.textInactive,
    };

String segmentLabel(AppLocalizations l, DaySegmentType t) => switch (t) {
      DaySegmentType.sleep => l.homeSegSleep,
      DaySegmentType.classes => l.homeSegClasses,
      DaySegmentType.workout => l.homeSegWorkout,
      DaySegmentType.free => l.homeSegFree,
      DaySegmentType.commute => l.homeSegCommute,
    };

/// Блок 5: лента дня 07:00–23:00 с отрезками, маркером «сейчас» и временем выхода.
class DayTimelinePanel extends ConsumerWidget {
  const DayTimelinePanel({super.key, required this.plan});

  final DayPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final now = ref.watch(homeClockProvider);
    final nowFrac = dayFraction(now, startMinute: plan.startMinute, endMinute: plan.endMinute);
    final nowText = formatMinuteOfDay(minuteOfDay(now));
    final leave = plan.leaveHomeMinute;

    // Подписи шкалы: 5 равных шагов (07, 11, 15, 19, 23 для дня 07–23).
    final step = (plan.endMinute - plan.startMinute) / 4;
    final ticks = [for (var i = 0; i <= 4; i++) formatMinuteOfDay((plan.startMinute + step * i).round())];

    final types = <DaySegmentType>[];
    for (final s in plan.segments) {
      if (!types.contains(s.type)) types.add(s.type);
    }

    final summary = plan.segments
        .map((s) => l.homeSegmentSemantics(
            segmentLabel(l, s.type), formatMinuteOfDay(s.startMinute), formatMinuteOfDay(s.endMinute)))
        .join('; ');

    return SysPanel(
      appearDelay: const Duration(milliseconds: 180),
      title: l.homeDayTitle,
      trailing: leave == null
          ? null
          : Text(formatMinuteOfDay(leave), style: SysText.mono.copyWith(fontSize: 12, color: SysColors.accentLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Подпись «Сейчас HH:MM» над маркером.
          Align(
            alignment: Alignment(nowFrac * 2 - 1, 0),
            child: Text(
              l.homeNow(nowText),
              style: SysText.mono.copyWith(fontSize: 11, color: SysColors.accentLighter),
            ),
          ),
          const SizedBox(height: 2),
          Semantics(
            label: '${l.homeNow(nowText)}. $summary',
            excludeSemantics: true,
            child: SizedBox(
              height: 30,
              child: CustomPaint(
                painter: DayRibbonPainter(plan: plan, nowFraction: nowFrac),
                size: Size.infinite,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final t in ticks)
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(t, style: SysText.mono.copyWith(fontSize: 10, color: SysColors.textInactive)),
                  ),
                ),
            ],
          ),
          if (leave != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const SysIcon(SysGlyph.home, size: 16, color: SysColors.accentLight),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l.homeLeaveHome(formatMinuteOfDay(leave)),
                    style: SysText.secondary.copyWith(color: SysColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              for (final t in types)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: segmentColor(t).withValues(alpha: 0.75),
                        border: Border.all(color: segmentColor(t)),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(segmentLabel(l, t), style: SysText.caption),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Лента: дорожка, отрезки, деления по часам, маркер «сейчас», ромб «выход из дома».
class DayRibbonPainter extends CustomPainter {
  const DayRibbonPainter({required this.plan, required this.nowFraction});

  final DayPlan plan;
  final double nowFraction;

  @override
  void paint(Canvas canvas, Size size) {
    const barH = 14.0;
    final top = (size.height - barH) / 2;
    final track = Rect.fromLTWH(0, top, size.width, barH);
    double x(int minute) =>
        minuteFraction(minute, startMinute: plan.startMinute, endMinute: plan.endMinute) * size.width;

    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(2)),
      Paint()..color = const Color.fromRGBO(63, 180, 255, .07),
    );

    for (final s in plan.segments) {
      final l = x(s.startMinute);
      final r = x(s.endMinute);
      if (r - l <= 0) continue;
      final rect = Rect.fromLTRB(l + 0.5, top, r - 0.5, top + barH);
      final c = segmentColor(s.type);
      final isFree = s.type == DaySegmentType.free;
      canvas.drawRect(rect, Paint()..color = c.withValues(alpha: isFree ? 0.22 : 0.55));
      canvas.drawRect(
        rect,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = c.withValues(alpha: 0.9),
      );
    }

    // Деления каждый час.
    final tick = Paint()
      ..color = const Color.fromRGBO(159, 226, 255, .35)
      ..strokeWidth = 1;
    for (var m = plan.startMinute; m <= plan.endMinute; m += 60) {
      final tx = x(m);
      canvas.drawLine(Offset(tx, top + barH), Offset(tx, top + barH + 3), tick);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(track, const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = SysColors.panelBorder,
    );

    // Выход из дома — ромб над лентой.
    final leave = plan.leaveHomeMinute;
    if (leave != null) {
      final lx = x(leave);
      final d = Path()
        ..moveTo(lx, top - 7)
        ..lineTo(lx + 4, top - 3)
        ..lineTo(lx, top + 1)
        ..lineTo(lx - 4, top - 3)
        ..close();
      canvas.drawPath(d, Paint()..color = SysColors.accentLighter);
    }

    // Маркер «сейчас»: светящаяся вертикаль и треугольник сверху.
    final nx = nowFraction * size.width;
    final glow = Paint()
      ..color = SysColors.accentLighter.withValues(alpha: 0.6)
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    canvas.drawLine(Offset(nx, 0), Offset(nx, size.height), glow);
    canvas.drawLine(
      Offset(nx, 0),
      Offset(nx, size.height),
      Paint()
        ..color = SysColors.textPrimary
        ..strokeWidth = 1.5,
    );
    final tri = Path()
      ..moveTo(nx - 4, 0)
      ..lineTo(nx + 4, 0)
      ..lineTo(nx, 5)
      ..close();
    canvas.drawPath(tri, Paint()..color = SysColors.textPrimary);
  }

  @override
  bool shouldRepaint(DayRibbonPainter old) => old.plan != plan || old.nowFraction != nowFraction;
}
