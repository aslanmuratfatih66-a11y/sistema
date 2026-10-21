import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/capabilities/certificate_status.dart';

void main() {
  final now = DateTime(2026, 10, 21, 10, 46);

  test('null — профиля нет', () {
    expect(CertificateStatus.from(null, now), isNull);
  });

  test('7 дней — показываем, info', () {
    final s = CertificateStatus.from(now.add(const Duration(days: 7)), now)!;
    expect(s.daysLeft, 7);
    expect(s.expired, isFalse);
    expect(s.visible, isTrue);
    expect(s.level, CertificateLevel.info);
  });

  test('больше 7 дней — не показываем', () {
    final s = CertificateStatus.from(now.add(const Duration(days: 30)), now)!;
    expect(s.visible, isFalse);
  });

  test('4 дня — info, 3 и 2 — warning', () {
    expect(CertificateStatus.from(DateTime(2026, 10, 25, 9), now)!.level, CertificateLevel.info);
    expect(CertificateStatus.from(DateTime(2026, 10, 24, 9), now)!.level, CertificateLevel.warning);
    expect(CertificateStatus.from(DateTime(2026, 10, 23, 9), now)!.level, CertificateLevel.warning);
  });

  test('1 день — по календарным суткам, critical', () {
    // Завтра в 09:00, сейчас 10:46 — меньше 24 ч, но календарно «через 1 день».
    final s = CertificateStatus.from(DateTime(2026, 10, 22, 9), now)!;
    expect(s.daysLeft, 1);
    expect(s.level, CertificateLevel.critical);
  });

  test('0 — истекает сегодня, critical', () {
    final s = CertificateStatus.from(DateTime(2026, 10, 21, 23, 59), now)!;
    expect(s.daysLeft, 0);
    expect(s.expired, isFalse);
    expect(s.visible, isTrue);
    expect(s.level, CertificateLevel.critical);
  });

  test('истёк', () {
    final s = CertificateStatus.from(now.subtract(const Duration(minutes: 1)), now)!;
    expect(s.expired, isTrue);
    expect(s.daysLeft, 0);
    expect(s.visible, isTrue);
    expect(s.level, CertificateLevel.critical);
    expect(CertificateStatus.from(now, now)!.expired, isTrue);
  });
}
