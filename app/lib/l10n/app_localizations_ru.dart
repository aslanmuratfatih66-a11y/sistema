// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Система';

  @override
  String get navStatus => 'Статус';

  @override
  String get navQuests => 'Квесты';

  @override
  String get navNutrition => 'Питание';

  @override
  String get navShop => 'Магазин';

  @override
  String get navMore => 'Ещё';

  @override
  String get sectionEmptyTitle => 'Раздел в разработке';

  @override
  String get sectionEmptyBody =>
      'Система откроет этот раздел на следующих этапах.';

  @override
  String certExpiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Сертификат истекает через $days дней',
      few: 'Сертификат истекает через $days дня',
      one: 'Сертификат истекает через $days день',
      zero: 'Сертификат истекает сегодня',
    );
    return '$_temp0';
  }

  @override
  String get certExpired => 'Сертификат истёк — переустановите приложение';

  @override
  String get certReinstallHint =>
      'Переустановите приложение через Sideloadly, данные сохранятся после синхронизации.';
}
