// Встроенный справочник городов РФ и Турции с часовыми поясами (SPEC §5.1: пояс по городу, офлайн).
// В РФ с 2014 г. и в Турции с 2016 г. перехода на летнее время нет — пояс = постоянное смещение.
// Названия: ru — для русского интерфейса, latin — турецкое/латинское (для турецкого интерфейса и поиска).

class City {
  const City(this.ru, this.latin, this.utcOffsetHours, this.country);

  final String ru;
  final String latin;
  final int utcOffsetHours;

  /// 'RU' / 'TR'
  final String country;

  String name(String languageCode) => languageCode == 'tr' ? latin : ru;
}

const List<City> cities = [
  // UTC+2
  City('Калининград', 'Kaliningrad', 2, 'RU'),
  // UTC+3 — РФ
  City('Москва', 'Moskova', 3, 'RU'),
  City('Санкт-Петербург', 'Sankt-Peterburg', 3, 'RU'),
  City('Нижний Новгород', 'Nijniy Novgorod', 3, 'RU'),
  City('Казань', 'Kazan', 3, 'RU'),
  City('Ростов-на-Дону', 'Rostov-na-Donu', 3, 'RU'),
  City('Воронеж', 'Voronej', 3, 'RU'),
  City('Краснодар', 'Krasnodar', 3, 'RU'),
  City('Сочи', 'Soçi', 3, 'RU'),
  City('Волгоград', 'Volgograd', 3, 'RU'),
  City('Ярославль', 'Yaroslavl', 3, 'RU'),
  City('Тула', 'Tula', 3, 'RU'),
  City('Рязань', 'Ryazan', 3, 'RU'),
  City('Тверь', 'Tver', 3, 'RU'),
  City('Липецк', 'Lipetsk', 3, 'RU'),
  City('Курск', 'Kursk', 3, 'RU'),
  City('Белгород', 'Belgorod', 3, 'RU'),
  City('Брянск', 'Bryansk', 3, 'RU'),
  City('Орёл', 'Oryol', 3, 'RU'),
  City('Калуга', 'Kaluga', 3, 'RU'),
  City('Смоленск', 'Smolensk', 3, 'RU'),
  City('Иваново', 'İvanovo', 3, 'RU'),
  City('Владимир', 'Vladimir', 3, 'RU'),
  City('Кострома', 'Kostroma', 3, 'RU'),
  City('Вологда', 'Vologda', 3, 'RU'),
  City('Архангельск', 'Arhangelsk', 3, 'RU'),
  City('Мурманск', 'Murmansk', 3, 'RU'),
  City('Петрозаводск', 'Petrozavodsk', 3, 'RU'),
  City('Великий Новгород', 'Veliki Novgorod', 3, 'RU'),
  City('Псков', 'Pskov', 3, 'RU'),
  City('Тамбов', 'Tambov', 3, 'RU'),
  City('Пенза', 'Penza', 3, 'RU'),
  City('Чебоксары', 'Çeboksarı', 3, 'RU'),
  City('Йошкар-Ола', 'Yoşkar-Ola', 3, 'RU'),
  City('Саранск', 'Saransk', 3, 'RU'),
  City('Киров', 'Kirov', 3, 'RU'),
  City('Сыктывкар', 'Siktivkar', 3, 'RU'),
  City('Ставрополь', 'Stavropol', 3, 'RU'),
  City('Махачкала', 'Mahaçkale', 3, 'RU'),
  City('Грозный', 'Grozni', 3, 'RU'),
  City('Владикавказ', 'Vladikavkaz', 3, 'RU'),
  City('Нальчик', 'Nalçik', 3, 'RU'),
  City('Майкоп', 'Maykop', 3, 'RU'),
  City('Черкесск', 'Çerkessk', 3, 'RU'),
  City('Элиста', 'Elista', 3, 'RU'),
  City('Новороссийск', 'Novorossiysk', 3, 'RU'),
  City('Набережные Челны', 'Naberejnıye Çelnı', 3, 'RU'),
  City('Симферополь', 'Akmescit', 3, 'RU'),
  City('Севастополь', 'Sivastopol', 3, 'RU'),
  // UTC+4
  City('Самара', 'Samara', 4, 'RU'),
  City('Тольятти', 'Tolyatti', 4, 'RU'),
  City('Ижевск', 'İjevsk', 4, 'RU'),
  City('Ульяновск', 'Ulyanovsk', 4, 'RU'),
  City('Саратов', 'Saratov', 4, 'RU'),
  City('Астрахань', 'Astrahan', 4, 'RU'),
  // UTC+5
  City('Екатеринбург', 'Yekaterinburg', 5, 'RU'),
  City('Челябинск', 'Çelyabinsk', 5, 'RU'),
  City('Уфа', 'Ufa', 5, 'RU'),
  City('Пермь', 'Perm', 5, 'RU'),
  City('Тюмень', 'Tümen', 5, 'RU'),
  City('Оренбург', 'Orenburg', 5, 'RU'),
  City('Курган', 'Kurgan', 5, 'RU'),
  City('Магнитогорск', 'Magnitogorsk', 5, 'RU'),
  City('Сургут', 'Surgut', 5, 'RU'),
  City('Нижневартовск', 'Nijnevartovsk', 5, 'RU'),
  City('Ханты-Мансийск', 'Hantı-Mansiysk', 5, 'RU'),
  City('Салехард', 'Salehard', 5, 'RU'),
  // UTC+6
  City('Омск', 'Omsk', 6, 'RU'),
  // UTC+7
  City('Новосибирск', 'Novosibirsk', 7, 'RU'),
  City('Красноярск', 'Krasnoyarsk', 7, 'RU'),
  City('Барнаул', 'Barnaul', 7, 'RU'),
  City('Томск', 'Tomsk', 7, 'RU'),
  City('Кемерово', 'Kemerovo', 7, 'RU'),
  City('Новокузнецк', 'Novokuznetsk', 7, 'RU'),
  City('Абакан', 'Abakan', 7, 'RU'),
  City('Кызыл', 'Kızıl', 7, 'RU'),
  City('Горно-Алтайск', 'Gorno-Altaysk', 7, 'RU'),
  // UTC+8
  City('Иркутск', 'İrkutsk', 8, 'RU'),
  City('Улан-Удэ', 'Ulan-Ude', 8, 'RU'),
  City('Братск', 'Bratsk', 8, 'RU'),
  // UTC+9
  City('Якутск', 'Yakutsk', 9, 'RU'),
  City('Чита', 'Çita', 9, 'RU'),
  City('Благовещенск', 'Blagoveşçensk', 9, 'RU'),
  // UTC+10
  City('Владивосток', 'Vladivostok', 10, 'RU'),
  City('Хабаровск', 'Habarovsk', 10, 'RU'),
  City('Комсомольск-на-Амуре', 'Komsomolsk-na-Amure', 10, 'RU'),
  City('Находка', 'Nahodka', 10, 'RU'),
  // UTC+11
  City('Магадан', 'Magadan', 11, 'RU'),
  City('Южно-Сахалинск', 'Yujno-Sahalinsk', 11, 'RU'),
  // UTC+12
  City('Петропавловск-Камчатский', 'Petropavlovsk-Kamçatski', 12, 'RU'),
  City('Анадырь', 'Anadır', 12, 'RU'),
  // Турция — UTC+3
  City('Стамбул', 'İstanbul', 3, 'TR'),
  City('Анкара', 'Ankara', 3, 'TR'),
  City('Измир', 'İzmir', 3, 'TR'),
  City('Бурса', 'Bursa', 3, 'TR'),
  City('Анталья', 'Antalya', 3, 'TR'),
  City('Адана', 'Adana', 3, 'TR'),
  City('Конья', 'Konya', 3, 'TR'),
  City('Газиантеп', 'Gaziantep', 3, 'TR'),
  City('Шанлыурфа', 'Şanlıurfa', 3, 'TR'),
  City('Измит', 'İzmit', 3, 'TR'),
  City('Мерсин', 'Mersin', 3, 'TR'),
  City('Диярбакыр', 'Diyarbakır', 3, 'TR'),
  City('Кайсери', 'Kayseri', 3, 'TR'),
  City('Эскишехир', 'Eskişehir', 3, 'TR'),
  City('Самсун', 'Samsun', 3, 'TR'),
  City('Денизли', 'Denizli', 3, 'TR'),
  City('Трабзон', 'Trabzon', 3, 'TR'),
  City('Малатья', 'Malatya', 3, 'TR'),
  City('Эрзурум', 'Erzurum', 3, 'TR'),
  City('Ван', 'Van', 3, 'TR'),
  City('Сакарья', 'Sakarya', 3, 'TR'),
  City('Маниса', 'Manisa', 3, 'TR'),
  City('Балыкесир', 'Balıkesir', 3, 'TR'),
  City('Мугла', 'Muğla', 3, 'TR'),
  City('Бодрум', 'Bodrum', 3, 'TR'),
  City('Фетхие', 'Fethiye', 3, 'TR'),
  City('Мармарис', 'Marmaris', 3, 'TR'),
  City('Аланья', 'Alanya', 3, 'TR'),
  City('Кемер', 'Kemer', 3, 'TR'),
  City('Сиде', 'Side', 3, 'TR'),
  City('Айдын', 'Aydın', 3, 'TR'),
  City('Кушадасы', 'Kuşadası', 3, 'TR'),
  City('Текирдаг', 'Tekirdağ', 3, 'TR'),
  City('Эдирне', 'Edirne', 3, 'TR'),
  City('Чанаккале', 'Çanakkale', 3, 'TR'),
  City('Антакья', 'Antakya', 3, 'TR'),
  City('Кахраманмараш', 'Kahramanmaraş', 3, 'TR'),
  City('Батман', 'Batman', 3, 'TR'),
  City('Элязыг', 'Elazığ', 3, 'TR'),
  City('Сивас', 'Sivas', 3, 'TR'),
  City('Орду', 'Ordu', 3, 'TR'),
  City('Ризе', 'Rize', 3, 'TR'),
  City('Зонгулдак', 'Zonguldak', 3, 'TR'),
  City('Афьонкарахисар', 'Afyonkarahisar', 3, 'TR'),
  City('Ыспарта', 'Isparta', 3, 'TR'),
  City('Невшехир', 'Nevşehir', 3, 'TR'),
];

/// Нормализация для поиска: регистр, ё→е, турецкие буквы → латиница, без пробелов/дефисов.
String normalizeCityQuery(String s) {
  const map = {
    'ё': 'е', 'ı': 'i', 'ş': 's', 'ğ': 'g', 'ü': 'u', 'ö': 'o', 'ç': 'c', 'â': 'a', 'î': 'i', 'û': 'u',
  };
  var t = s.trim().toLowerCase().replaceAll('̇', ''); // «İ».toLowerCase() даёт i + точку сверху
  map.forEach((k, v) => t = t.replaceAll(k, v));
  return t.replaceAll(RegExp(r'[\s\-‐–—.]'), '');
}

/// Город, точно совпадающий с вводом (по любому названию), или null.
City? findCity(String query) {
  final q = normalizeCityQuery(query);
  if (q.isEmpty) return null;
  for (final c in cities) {
    if (normalizeCityQuery(c.ru) == q || normalizeCityQuery(c.latin) == q) return c;
  }
  return null;
}

/// Подсказки по началу названия (сначала совпадения с началом, затем вхождения).
List<City> suggestCities(String query, {int limit = 5}) {
  final q = normalizeCityQuery(query);
  if (q.length < 2) return const [];
  final starts = <City>[];
  final contains = <City>[];
  for (final c in cities) {
    final ru = normalizeCityQuery(c.ru);
    final la = normalizeCityQuery(c.latin);
    if (ru.startsWith(q) || la.startsWith(q)) {
      starts.add(c);
    } else if (ru.contains(q) || la.contains(q)) {
      contains.add(c);
    }
  }
  return [...starts, ...contains].take(limit).toList();
}

/// Примеры городов для пояса (для списка выбора пояса): сначала по одному из каждой страны.
List<City> citiesForOffset(int hours, {int limit = 2}) {
  final inZone = cities.where((c) => c.utcOffsetHours == hours).toList();
  final firstPerCountry = <String, City>{};
  for (final c in inZone) {
    firstPerCountry.putIfAbsent(c.country, () => c);
  }
  return [...firstPerCountry.values, ...inZone.where((c) => !firstPerCountry.containsValue(c))].take(limit).toList();
}
