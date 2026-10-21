import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/onboarding/questionnaire_a/data/cities.dart';
import 'package:sistema/features/onboarding/questionnaire_a/data/timezones.dart';

void main() {
  test('точный поиск: регистр, ё, турецкие буквы, дефисы', () {
    expect(findCity('новосибирск')?.utcOffsetHours, 7);
    expect(findCity('Орел')?.ru, 'Орёл');
    expect(findCity('istanbul')?.latin, 'İstanbul');
    expect(findCity('İSTANBUL')?.utcOffsetHours, 3);
    expect(findCity('Стамбул')?.country, 'TR');
    expect(findCity('ростов на дону')?.utcOffsetHours, 3);
    expect(findCity('Самара')?.utcOffsetHours, 4);
    expect(findCity('Калининград')?.utcOffsetHours, 2);
    expect(findCity('Атлантида'), isNull);
  });

  test('подсказки по началу названия', () {
    expect(suggestCities('Ек').map((c) => c.ru), contains('Екатеринбург'));
    expect(suggestCities('anta').map((c) => c.latin), contains('Antalya'));
    expect(suggestCities('м'), isEmpty); // меньше двух букв
    expect(suggestCities('но', limit: 3).length, lessThanOrEqualTo(3));
  });

  test('примеры городов для пояса: сначала по одному из страны', () {
    final ex = citiesForOffset(3).map((c) => c.country).toList();
    expect(ex, ['RU', 'TR']);
  });

  test('формат пояса', () {
    expect(wholeHoursOf('UTC+3'), 3);
    expect(wholeHoursOf('UTC-12'), -12);
    expect(wholeHoursOf('UTC+5:30'), isNull);
    expect(timezoneFromOffset(const Duration(hours: 7)), 'UTC+7');
  });
}
