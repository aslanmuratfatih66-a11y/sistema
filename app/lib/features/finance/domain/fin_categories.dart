// Встроенные категории (посев при первом открытии) и угадывание категории по мерчанту.
import '../../../core/models/enums.dart';
import '../../../ui/ui.dart' show SysGlyph;
import 'fin_math.dart';

class BuiltinCategory {
  const BuiltinCategory(this.key, this.kind, this.glyph, {this.junkFood = false, this.essential = false});

  final String key;
  final FinTxKind kind;
  final SysGlyph glyph;
  final bool junkFood;

  /// Обязательные траты (советник бюджета считает их неизбежными до конца месяца).
  final bool essential;

  /// Детерминированный id: одинаков на всех устройствах — синхронизация не плодит дубли.
  String get id => builtinCategoryId(key);
}

String builtinCategoryId(String key) => finSid('cat:$key');

/// Ключи встроенных категорий (TxDraft.categoryKey).
abstract final class FinCat {
  static const groceries = 'groceries';
  static const cafe = 'cafe';
  static const fastfood = 'fastfood';
  static const transport = 'transport';
  static const housing = 'housing';
  static const utilities = 'utilities';
  static const phone = 'phone';
  static const health = 'health';
  static const beauty = 'beauty';
  static const clothes = 'clothes';
  static const education = 'education';
  static const sport = 'sport';
  static const fun = 'fun';
  static const subscriptions = 'subscriptions';
  static const gifts = 'gifts';
  static const marketplace = 'marketplace';
  static const other = 'other';

  static const stipend = 'stipend';
  static const salary = 'salary';
  static const giftIncome = 'giftIncome';
  static const cashback = 'cashback';
  static const otherIncome = 'otherIncome';
}

const builtinCategories = <BuiltinCategory>[
  BuiltinCategory(FinCat.groceries, FinTxKind.expense, SysGlyph.nutrition, essential: true),
  BuiltinCategory(FinCat.cafe, FinTxKind.expense, SysGlyph.nutrition),
  BuiltinCategory(FinCat.fastfood, FinTxKind.expense, SysGlyph.flame, junkFood: true),
  BuiltinCategory(FinCat.transport, FinTxKind.expense, SysGlyph.walk, essential: true),
  BuiltinCategory(FinCat.housing, FinTxKind.expense, SysGlyph.home, essential: true),
  BuiltinCategory(FinCat.utilities, FinTxKind.expense, SysGlyph.bolt, essential: true),
  BuiltinCategory(FinCat.phone, FinTxKind.expense, SysGlyph.send, essential: true),
  BuiltinCategory(FinCat.health, FinTxKind.expense, SysGlyph.heart, essential: true),
  BuiltinCategory(FinCat.beauty, FinTxKind.expense, SysGlyph.sparkle),
  BuiltinCategory(FinCat.clothes, FinTxKind.expense, SysGlyph.shop),
  BuiltinCategory(FinCat.education, FinTxKind.expense, SysGlyph.book),
  BuiltinCategory(FinCat.sport, FinTxKind.expense, SysGlyph.dumbbell),
  BuiltinCategory(FinCat.fun, FinTxKind.expense, SysGlyph.star),
  BuiltinCategory(FinCat.subscriptions, FinTxKind.expense, SysGlyph.clock),
  BuiltinCategory(FinCat.gifts, FinTxKind.expense, SysGlyph.diamond),
  BuiltinCategory(FinCat.marketplace, FinTxKind.expense, SysGlyph.shop),
  BuiltinCategory(FinCat.other, FinTxKind.expense, SysGlyph.more),
  BuiltinCategory(FinCat.stipend, FinTxKind.income, SysGlyph.book),
  BuiltinCategory(FinCat.salary, FinTxKind.income, SysGlyph.wallet),
  BuiltinCategory(FinCat.giftIncome, FinTxKind.income, SysGlyph.diamond),
  BuiltinCategory(FinCat.cashback, FinTxKind.income, SysGlyph.sparkle),
  BuiltinCategory(FinCat.otherIncome, FinTxKind.income, SysGlyph.more),
];

BuiltinCategory? builtinByKey(String? key) {
  if (key == null) return null;
  for (final c in builtinCategories) {
    if (c.key == key) return c;
  }
  return null;
}

SysGlyph glyphByName(String? name, {SysGlyph fallback = SysGlyph.more}) {
  if (name == null) return fallback;
  for (final g in SysGlyph.values) {
    if (g.name == name) return g;
  }
  return fallback;
}

/// Простые правила по подстрокам мерчанта (RU/TR сети). Первое совпадение — победитель.
const _rules = <(String, List<String>)>[
  (FinCat.fastfood, [
    'mcdonald', 'макдон', 'kfc', 'burger king', 'бургер кинг', 'вкусно и точка', 'вкусно — и точка', 'вкусно-и точка',
    'rostic', 'ростикс', 'subway', 'popeyes', 'domino', 'домино', 'dodo', 'додо', 'papa john', 'шаурм', 'shawarma',
    'döner', 'doner', 'дёнер', 'донер', 'black star burger', 'teremok', 'теремок', 'carl\'s jr', 'pizza hut', 'tavuk dünyası',
  ]),
  (FinCat.groceries, [
    'пятёроч', 'пятероч', 'pyaterochka', 'магнит', 'magnit', 'перекрёст', 'перекрест', 'perekrestok', 'лента', 'lenta',
    'ашан', 'auchan', 'дикси', 'вкусвилл', 'vkusvill', 'metro c&c', 'spar', 'глобус', 'globus', 'самокат', 'samokat',
    'яндекс лавка', 'лавка', 'светофор', 'fix price', 'фикс прайс', 'a101', 'bim ', 'bim a.ş', 'şok', 'sok market',
    'migros', 'carrefour', 'file market', 'macrocenter', 'продукт',
  ]),
  (FinCat.cafe, [
    'кафе', 'cafe', 'café', 'кофе', 'coffee', 'starbucks', 'шоколадниц', 'ресторан', 'restaurant', 'cofix', 'kahve',
    'столовая', 'бар ', 'pub', 'lokanta', 'restoran',
  ]),
  (FinCat.transport, [
    'метрополитен', 'mosmetro', 'яндекс go', 'yandex go', 'yandex.taxi', 'такси', 'taxi', 'uber', 'ржд', 'rzd',
    'аэроэкспресс', 'тройка', 'troika', 'istanbulkart', 'bitaksi', 'азс', 'лукойл', 'lukoil', 'газпромнефть', 'shell',
    'opet', 'petrol ofisi', 'автобус', 'whoosh', 'urent', 'делимобиль', 'ситидрайв',
  ]),
  (FinCat.subscriptions, [
    'spotify', 'netflix', 'apple.com', 'itunes', 'youtube', 'яндекс плюс', 'yandex plus', 'кинопоиск', 'ivi.ru', 'okko',
    'google one', 'chatgpt', 'openai', 'icloud',
  ]),
  (FinCat.health, ['аптек', 'eczane', 'pharm', '36,6', '36.6', 'ригла', 'горздрав', 'клиника', 'стоматолог', 'hastane']),
  (FinCat.phone, ['мтс', 'mts', 'билайн', 'beeline', 'мегафон', 'megafon', 'tele2', 'теле2', 'turkcell', 'vodafone', 'türk telekom', 'ростелеком']),
  (FinCat.clothes, ['zara', 'lc waikiki', 'h&m', 'gloria jeans', 'глория', 'befree', 'ostin', 'остин', 'koton', 'defacto', 'mavi']),
  (FinCat.marketplace, ['ozon', 'озон', 'wildberries', 'вайлдберриз', 'яндекс маркет', 'yandex market', 'trendyol', 'hepsiburada', 'aliexpress']),
  (FinCat.fun, ['кино', 'cinema', 'steam', 'playstation', 'xbox', 'боулинг', 'sinema']),
  (FinCat.sport, ['спортмастер', 'decathlon', 'фитнес', 'fitness', 'spor salonu', 'бассейн']),
  (FinCat.beauty, ['золотое яблоко', 'летуаль', 'l\'etoile', 'рив гош', 'gratis', 'watsons', 'барбер', 'салон', 'kuaför']),
  (FinCat.education, ['книг', 'book', 'skillbox', 'stepik', 'udemy', 'coursera', 'kitap']),
];

/// Ключ встроенной категории по мерчанту/заметке; null — не угадали.
String? guessCategoryKey(String? merchant, FinTxKind kind) {
  if (merchant == null || merchant.trim().isEmpty) return null;
  final m = merchant.toLowerCase();
  if (kind == FinTxKind.income) {
    if (m.contains('стипенд') || m.contains('burs')) return FinCat.stipend;
    if (m.contains('зарплат') || m.contains('salary') || m.contains('maaş')) return FinCat.salary;
    if (m.contains('кешбэк') || m.contains('кэшбэк') || m.contains('cashback')) return FinCat.cashback;
    return null;
  }
  for (final (key, words) in _rules) {
    for (final w in words) {
      if (m.contains(w)) return key;
    }
  }
  return null;
}
