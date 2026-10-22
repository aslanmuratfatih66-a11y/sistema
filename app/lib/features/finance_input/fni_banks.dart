// Каталог банков для чтения уведомлений/SMS (SPEC §8.7, Android) и настройки источников.
import 'dart:convert';

/// Банк: ключ совпадает с FinAccounts.bank (sber, vtb, tbank, alfa, ziraat, isbank, garanti).
class BankInfo {
  const BankInfo({
    required this.key,
    required this.name,
    required this.packages,
    required this.smsSenders,
    required this.currency,
  });

  final String key;
  final String name;

  /// Пакеты Android-приложений банка.
  final List<String> packages;

  /// Имена/номера SMS-отправителей.
  final List<String> smsSenders;

  /// Валюта по умолчанию для сообщений без валюты.
  final String currency;
}

/// Ключ «другого» банка — пакеты и отправители вводит пользователь.
const otherBankKey = 'other';

// TODO(проверить на устройствах): имена SMS-отправителей ниже — известные, но банки их меняют
// (Тинькофф → Т-Банк и т.п.); турецкие отправители не подтверждены. Пользователь может добавить свои.
const bankCatalog = <BankInfo>[
  BankInfo(key: 'vtb', name: 'ВТБ', packages: ['ru.vtb24.mobilebanking.android'], smsSenders: ['VTB'], currency: 'RUB'),
  BankInfo(key: 'sber', name: 'Сбер', packages: ['ru.sberbankmobile'], smsSenders: ['900', 'SberBank'], currency: 'RUB'),
  BankInfo(
    key: 'tbank',
    name: 'Т-Банк',
    packages: ['com.idamob.tinkoff.android'],
    smsSenders: ['T-Bank', 'Tinkoff'],
    currency: 'RUB',
  ),
  BankInfo(
    key: 'alfa',
    name: 'Альфа-Банк',
    packages: ['ru.alfabank.mobile.android'],
    smsSenders: ['Alfa-Bank', 'AlfaBank'],
    currency: 'RUB',
  ),
  // TODO(проверить): SMS-отправитель Ziraat.
  BankInfo(key: 'ziraat', name: 'Ziraat', packages: ['com.ziraat.ziraatmobil'], smsSenders: ['ZIRAAT'], currency: 'TRY'),
  // TODO(проверить): SMS-отправитель İş Bankası.
  BankInfo(key: 'isbank', name: 'İş Bankası', packages: ['com.pozitron.iscep'], smsSenders: ['ISBANK'], currency: 'TRY'),
  // TODO(проверить): SMS-отправитель Garanti BBVA.
  BankInfo(key: 'garanti', name: 'Garanti BBVA', packages: ['com.garanti.cepsubesi'], smsSenders: ['GARANTI BBVA', 'GARANTI'], currency: 'TRY'),
];

BankInfo? bankByKey(String? key) {
  for (final b in bankCatalog) {
    if (b.key == key) return b;
  }
  return null;
}

String _norm(String s) {
  final t = s.trim().toLowerCase();
  final d = t.replaceAll(RegExp(r'\D'), '');
  return d.isNotEmpty && d.length >= t.replaceAll(RegExp(r'[^\p{L}\p{N}]', unicode: true), '').length ? d : t;
}

bool _senderMatch(String a, String b) {
  final x = _norm(a), y = _norm(b);
  if (x == y) return true;
  final digits = RegExp(r'^\d{4,}$');
  return digits.hasMatch(x) && digits.hasMatch(y) && (x.endsWith(y) || y.endsWith(x));
}

/// Включённые источники одного банка.
class BankToggle {
  const BankToggle({this.notifications = false, this.sms = false, this.extraSenders = const [], this.extraPackages = const []});

  factory BankToggle.fromJson(Map<String, dynamic> j) => BankToggle(
        notifications: j['n'] == true,
        sms: j['s'] == true,
        extraSenders: [for (final s in (j['xs'] as List? ?? const [])) '$s'],
        extraPackages: [for (final s in (j['xp'] as List? ?? const [])) '$s'],
      );

  final bool notifications;
  final bool sms;

  /// Свои отправители/пакеты (для «другого» — единственные).
  final List<String> extraSenders;
  final List<String> extraPackages;

  bool get any => notifications || sms;

  Map<String, Object?> toJson() => {'n': notifications, 's': sms, 'xs': extraSenders, 'xp': extraPackages};

  BankToggle copyWith({bool? notifications, bool? sms, List<String>? extraSenders, List<String>? extraPackages}) => BankToggle(
        notifications: notifications ?? this.notifications,
        sms: sms ?? this.sms,
        extraSenders: extraSenders ?? this.extraSenders,
        extraPackages: extraPackages ?? this.extraPackages,
      );
}

/// Настройки источников (AppSettings 'fni.sources', локально — не синхронизируются: зависят от устройства).
class BankSources {
  const BankSources({this.banks = const {}});

  factory BankSources.decode(String? s) {
    if (s == null || s.isEmpty) return const BankSources();
    try {
      final j = jsonDecode(s) as Map<String, dynamic>;
      return BankSources(banks: {
        for (final e in (j['banks'] as Map<String, dynamic>? ?? const {}).entries)
          e.key: BankToggle.fromJson(e.value as Map<String, dynamic>),
      });
    } catch (_) {
      return const BankSources();
    }
  }

  final Map<String, BankToggle> banks;

  String encode() => jsonEncode({'banks': {for (final e in banks.entries) e.key: e.value.toJson()}});

  BankToggle of(String key) => banks[key] ?? const BankToggle();

  BankSources withBank(String key, BankToggle t) => BankSources(banks: {...banks, key: t});

  List<String> packagesOf(String key) => [...?bankByKey(key)?.packages, ...of(key).extraPackages];

  List<String> sendersOf(String key) => [...?bankByKey(key)?.smsSenders, ...of(key).extraSenders];

  /// Пакеты с включёнными уведомлениями.
  List<String> get enabledPackages => [
        for (final e in banks.entries)
          if (e.value.notifications) ...packagesOf(e.key),
      ];

  List<String> get enabledSenders => [
        for (final e in banks.entries)
          if (e.value.sms) ...sendersOf(e.key),
      ];

  /// Банк по пакету приложения или SMS-отправителю (null — «другой»/неизвестный).
  String? bankFor(String channel, String sender) {
    final keys = [for (final b in bankCatalog) b.key, otherBankKey];
    for (final k in keys) {
      if (channel == 'notification' ? packagesOf(k).contains(sender) : sendersOf(k).any((s) => _senderMatch(s, sender))) {
        return k == otherBankKey ? null : k;
      }
    }
    return null;
  }
}
