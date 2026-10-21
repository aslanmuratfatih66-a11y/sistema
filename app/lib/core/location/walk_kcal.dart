// Расход энергии на прогулке: MET ходьбы по средней скорости × вес × часы (Compendium of Physical Activities).

/// Вес по умолчанию, если замеров нет.
const double walkFallbackWeightKg = 70;

/// MET ходьбы по скорости, км/ч.
double walkingMet(double speedKmh) {
  if (speedKmh < 3.2) return 2.0;
  if (speedKmh < 4.0) return 2.8;
  if (speedKmh < 4.8) return 3.0;
  if (speedKmh < 5.6) return 3.5;
  if (speedKmh < 6.4) return 4.3;
  if (speedKmh < 7.2) return 5.0;
  if (speedKmh < 8.0) return 6.3;
  return 8.0; // уже бег трусцой
}

/// Ккал за прогулку; 0 — если не было активного времени.
double walkKcal({required double distanceM, required int activeSeconds, required double weightKg}) {
  if (activeSeconds <= 0 || weightKg <= 0) return 0;
  final hours = activeSeconds / 3600;
  final speedKmh = distanceM / 1000 / hours;
  return walkingMet(speedKmh) * weightKg * hours;
}
