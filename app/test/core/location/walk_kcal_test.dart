import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/location/walk_kcal.dart';

void main() {
  test('MET по скорости', () {
    expect(walkingMet(2), 2.0);
    expect(walkingMet(5), 3.5);
    expect(walkingMet(9), 8.0);
  });

  test('ккал: 5 км за час, 70 кг → 3.5×70', () {
    expect(walkKcal(distanceM: 5000, activeSeconds: 3600, weightKg: 70), closeTo(245, 0.01));
    expect(walkKcal(distanceM: 100, activeSeconds: 0, weightKg: 70), 0);
  });
}
