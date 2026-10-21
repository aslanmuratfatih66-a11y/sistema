// Круговой маршрут: опорные точки на окружности через старт и подгонка радиуса под нужную длину.
import 'dart:math' as math;

import '../../../domain/walks/walk_api.dart';
import 'geo.dart';

/// Допуск длины круга (±15%).
const double loopTolerance = 0.15;

/// Начальный радиус: длина окружности ≈ целевой длине.
double initialLoopRadius(double targetM) => targetM / (2 * math.pi);

/// Опорные точки окружности радиуса [radiusM], проходящей через [start].
/// Центр — в [radiusM] от старта по азимуту [rotationDeg]; [count] точек равномерно между стартом и стартом
/// (по часовой). Старт в список не входит — маршрут: старт → точки → старт.
List<GeoPoint> loopWaypoints(GeoPoint start, double radiusM, double rotationDeg, {int count = 3}) {
  final center = destination(start, rotationDeg, radiusM);
  // Азимут из центра на старт.
  final back = (rotationDeg + 180) % 360;
  final step = 360 / (count + 1);
  return [for (var k = 1; k <= count; k++) destination(center, (back + k * step) % 360, radiusM)];
}

/// Следующий радиус по фактической длине: пропорция, ограниченная ×0.5…×2 (одна точка — не повод прыгать).
double adjustLoopRadius(double radiusM, double targetM, double actualM) {
  if (actualM <= 0) return radiusM;
  final k = (targetM / actualM).clamp(0.5, 2.0);
  return radiusM * k;
}

bool loopWithinTolerance(double targetM, double actualM) =>
    targetM > 0 && (actualM - targetM).abs() / targetM <= loopTolerance;

/// Кандидат лучше — ближе к цели.
bool loopCloser(double targetM, double candidateM, double? bestM) =>
    bestM == null || (candidateM - targetM).abs() < (bestM - targetM).abs();
