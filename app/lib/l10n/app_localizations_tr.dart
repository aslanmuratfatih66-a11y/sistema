// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sistem';

  @override
  String get navStatus => 'Durum';

  @override
  String get navQuests => 'Görevler';

  @override
  String get navNutrition => 'Beslenme';

  @override
  String get navShop => 'Mağaza';

  @override
  String get navMore => 'Daha fazla';

  @override
  String get sectionEmptyTitle => 'Bölüm geliştiriliyor';

  @override
  String get sectionEmptyBody => 'Sistem bu bölümü sonraki aşamalarda açacak.';

  @override
  String certExpiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Sertifikanın süresi $days gün içinde doluyor',
      one: 'Sertifikanın süresi $days gün içinde doluyor',
      zero: 'Sertifikanın süresi bugün doluyor',
    );
    return '$_temp0';
  }

  @override
  String get certExpired =>
      'Sertifikanın süresi doldu — uygulamayı yeniden yükleyin';

  @override
  String get certReinstallHint =>
      'Uygulamayı Sideloadly ile yeniden yükleyin, veriler senkronizasyondan sonra korunur.';
}
