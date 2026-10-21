// Общие виджеты раздела «Тело»: графики (fl_chart), миниатюра фото, строки сводок, форматирование.
import 'dart:io';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/db/database.dart' show PhotoRow;
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../onboarding/questionnaire_a/data/photo_repository.dart';
import '../../schedule/widgets/schedule_common.dart' show formatDayMonth, formatDuration;

export '../../schedule/widgets/schedule_common.dart' show ScheduleSubPage, formatDayMonth, formatDuration;

/// «7 ч 30 мин».
String formatSleep(AppLocalizations l, Duration d) => formatDuration(l, d.inMinutes);

/// «21.10.2026».
String formatDate(DateTime d) => '${formatDayMonth(d)}.${d.year}';

/// Число с одним знаком после запятой без лишнего нуля: 72 → «72», 72.35 → «72.4».
String formatNum(double v) => v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

/// Изменение со знаком: «+1.2», «−0.5», «0».
String formatDelta(double v) {
  final r = double.parse(v.toStringAsFixed(1));
  if (r == 0) return '0';
  return r > 0 ? '+${formatNum(r)}' : '−${formatNum(-r)}';
}

/// Название позы фото (строки анкеты).
String poseLabel(AppLocalizations l, PhotoPose pose) => switch (pose) {
      PhotoPose.bodyFront => l.qaPoseBodyFront,
      PhotoPose.bodySide => l.qaPoseBodySide,
      PhotoPose.bodyBack => l.qaPoseBodyBack,
      PhotoPose.faceFront => l.qaPoseFaceFront,
      PhotoPose.faceLeft => l.qaPoseFaceLeft,
      PhotoPose.faceRight => l.qaPoseFaceRight,
      PhotoPose.closeup => l.qaPoseCloseup,
      PhotoPose.other => l.bdyPoseOther,
    };

String poseHint(AppLocalizations l, PhotoPose pose) => switch (pose) {
      PhotoPose.bodyFront => l.qaPoseBodyFrontHint,
      PhotoPose.bodySide => l.qaPoseBodySideHint,
      PhotoPose.bodyBack => l.qaPoseBodyBackHint,
      PhotoPose.faceFront => l.qaPoseFaceFrontHint,
      PhotoPose.faceLeft => l.qaPoseFaceLeftHint,
      PhotoPose.faceRight => l.qaPoseFaceRightHint,
      PhotoPose.closeup || PhotoPose.other => l.qaPoseCloseupHint,
    };

/// Строка «подпись — значение» для сводок панелей.
class BodyInfoRow extends StatelessWidget {
  const BodyInfoRow({super.key, required this.label, required this.value, this.valueColor = SysColors.textPrimary});

  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            Expanded(child: Text(label, style: SysText.secondary)),
            const SizedBox(width: 8),
            Text(value, style: SysText.mono.copyWith(color: valueColor)),
          ],
        ),
      );
}

/// Ряд кнопок панели (переносится на узких экранах).
class BodyActions extends StatelessWidget {
  const BodyActions({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Wrap(spacing: 10, runSpacing: 10, children: children),
      );
}

/// Миниатюра фото раздела (файл из каталога документов). Без файла — рамка с иконкой.
class BodyPhotoThumb extends ConsumerWidget {
  const BodyPhotoThumb({super.key, required this.photo, this.fit = BoxFit.cover, this.cacheWidth = 360});

  final PhotoRow photo;
  final BoxFit fit;

  /// null — без уменьшения (полноэкранное сравнение).
  final int? cacheWidth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final root = kIsWeb ? null : ref.watch(photoRootProvider).value;
    const placeholder = ColoredBox(
      color: Color.fromRGBO(63, 180, 255, .06),
      child: Center(child: SysIcon(SysGlyph.star, size: 22, color: SysColors.textInactive)),
    );
    if (root == null) return placeholder;
    return Image.file(
      File(p.joinAll([root, ...p.posix.split(photo.localPath)])),
      fit: fit,
      cacheWidth: cacheWidth,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}

/// Подписи оси X: «дд.мм» для дат (x — номер дня от [origin]).
Widget _bottomTitle(double value, TitleMeta meta, DateTime origin, {int every = 1}) {
  final i = value.round();
  if ((value - i).abs() > 0.01 || i % every != 0) return const SizedBox.shrink();
  final d = DateTime(origin.year, origin.month, origin.day + i);
  return SideTitleWidget(
    meta: meta,
    child: Text(formatDayMonth(d), style: SysText.monoSmall.copyWith(color: SysColors.textCaption, fontSize: 9)),
  );
}

Widget _leftTitle(double value, TitleMeta meta) {
  if (value == meta.min || value == meta.max) return const SizedBox.shrink();
  return SideTitleWidget(
    meta: meta,
    child: Text(formatNum(value), style: SysText.monoSmall.copyWith(color: SysColors.textCaption, fontSize: 9)),
  );
}

FlGridData _grid() => FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (_) => FlLine(color: SysColors.accent.withValues(alpha: .12), strokeWidth: 1),
    );

/// Столбики сна по дням: высота — часы, линия цели. [hours] — по дню, null — ночь не записана.
class SleepBarChart extends StatelessWidget {
  const SleepBarChart({super.key, required this.firstDay, required this.hours, required this.targetHours, this.semanticLabel});

  final DateTime firstDay;
  final List<double?> hours;
  final double targetHours;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final maxH = math.max(targetHours + 2, hours.whereType<double>().fold<double>(0, math.max) + 1).ceilToDouble();
    final every = hours.length > 8 ? 3 : 1;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: 170,
        child: BarChart(
          BarChartData(
            minY: 0,
            maxY: maxH,
            gridData: _grid(),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 26, interval: 2, getTitlesWidget: _leftTitle)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  getTitlesWidget: (v, m) => _bottomTitle(v, m, firstDay, every: every),
                ),
              ),
            ),
            extraLinesData: ExtraLinesData(horizontalLines: [
              HorizontalLine(y: targetHours, color: SysColors.gold.withValues(alpha: .8), strokeWidth: 1, dashArray: const [4, 4]),
            ]),
            barGroups: [
              for (var i = 0; i < hours.length; i++)
                BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: hours[i] ?? 0,
                    width: hours.length > 8 ? 8 : 14,
                    color: (hours[i] ?? 0) >= targetHours ? SysColors.energy : SysColors.accent,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ]),
            ],
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }
}

/// Линия показателя по времени (замеры). x — дни от первой точки.
class BodyLineChart extends StatelessWidget {
  const BodyLineChart({super.key, required this.points, this.color = SysColors.accent, this.semanticLabel});

  final List<({DateTime at, double value})> points;
  final Color color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final origin = DateTime(points.first.at.year, points.first.at.month, points.first.at.day);
    double x(DateTime t) => t.difference(origin).inMinutes / (24 * 60);
    final spots = [for (final pt in points) FlSpot(x(pt.at), pt.value)];
    final values = points.map((e) => e.value);
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final pad = math.max(1.0, (hi - lo) * 0.15);
    final maxX = math.max(1.0, spots.last.x);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        height: 180,
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxX,
            minY: (lo - pad).floorToDouble(),
            maxY: (hi + pad).ceilToDouble(),
            gridData: _grid(),
            borderData: FlBorderData(show: false),
            lineTouchData: const LineTouchData(enabled: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(),
              rightTitles: const AxisTitles(),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, getTitlesWidget: _leftTitle)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 22,
                  interval: math.max(1, (maxX / 4).ceilToDouble()),
                  getTitlesWidget: (v, m) => _bottomTitle(v, m, origin),
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                color: color,
                barWidth: 2,
                dotData: FlDotData(show: spots.length <= 20),
                belowBarData: BarAreaData(show: true, color: color.withValues(alpha: .10)),
              ),
            ],
          ),
          duration: Duration.zero,
        ),
      ),
    );
  }
}
