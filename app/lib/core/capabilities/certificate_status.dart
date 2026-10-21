import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Уровень срочности баннера сертификата.
enum CertificateLevel { info, warning, critical }

/// Состояние профиля подписи (iOS sideload живёт 7 дней, SPEC §3).
class CertificateStatus {
  const CertificateStatus._({required this.daysLeft, required this.expired});

  /// Порог показа баннера, дней.
  static const int showThresholdDays = 7;

  /// Целых календарных суток до дня истечения (0 — истекает сегодня).
  /// При [expired] = true — 0.
  final int daysLeft;
  final bool expired;

  /// null — профиля нет, баннер не нужен.
  static CertificateStatus? from(DateTime? expiresAt, DateTime now) {
    if (expiresAt == null) return null;
    if (!expiresAt.isAfter(now)) {
      return const CertificateStatus._(daysLeft: 0, expired: true);
    }
    final e = expiresAt.toLocal();
    final n = now.toLocal();
    // Разница по календарным датам; UTC — чтобы переход на летнее время не давал 23/25 ч.
    final days = DateTime.utc(e.year, e.month, e.day)
        .difference(DateTime.utc(n.year, n.month, n.day))
        .inDays;
    return CertificateStatus._(daysLeft: days, expired: false);
  }

  bool get visible => expired || daysLeft <= showThresholdDays;

  CertificateLevel get level {
    if (expired || daysLeft <= 1) return CertificateLevel.critical;
    if (daysLeft <= 3) return CertificateLevel.warning;
    return CertificateLevel.info;
  }
}

/// Часы для баннера (переопределяются в тестах).
final certificateClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
