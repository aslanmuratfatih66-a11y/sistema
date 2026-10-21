// Мини-график шагов: столбики по дням, линия цели. Данные — stepsHistoryProvider.
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/models/daily.dart';
import '../../ui/ui.dart';

class StepsWeekChart extends StatelessWidget {
  const StepsWeekChart({super.key, required this.days, required this.goal, this.height = 84});

  /// По возрастанию даты; последний — сегодня.
  final List<StepDay> days;
  final int goal;
  final double height;

  @override
  Widget build(BuildContext context) {
    final maxSteps = days.fold<int>(0, (m, d) => math.max(m, d.steps));
    final maxY = math.max(maxSteps, goal).toDouble() * 1.1;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY <= 0 ? 1 : maxY,
          minY: 0,
          alignment: BarChartAlignment.spaceAround,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(enabled: false),
          extraLinesData: ExtraLinesData(horizontalLines: [
            if (goal > 0)
              HorizontalLine(
                y: goal.toDouble(),
                color: SysColors.accentLight.withValues(alpha: .5),
                strokeWidth: 1,
                dashArray: const [4, 4],
              ),
          ]),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 16,
                getTitlesWidget: (value, meta) {
                  final i = value.round();
                  if (i < 0 || i >= days.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text('${days[i].day.day}', style: SysText.monoSmall),
                  );
                },
              ),
            ),
          ),
          barGroups: [
            for (var i = 0; i < days.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: days[i].steps.toDouble(),
                  width: 10,
                  borderRadius: BorderRadius.circular(SysDims.radius),
                  color: goal > 0 && days[i].steps >= goal
                      ? SysColors.success
                      : (i == days.length - 1 ? SysColors.accentLight : SysColors.accent),
                ),
              ]),
          ],
        ),
        duration: Duration.zero,
      ),
    );
  }
}
