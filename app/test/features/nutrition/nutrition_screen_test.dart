import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/nutrition/nutrition_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';

import '../home/tab_test_utils.dart';

const _scrollKey = Key('nutrition-scroll');

void main() {
  testWidgets('ru: сводка калорий, вода и пометка о дневнике', (tester) async {
    await pumpTab(tester, const NutritionScreen(), const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(find.text(l.navNutrition.toUpperCase()), findsOneWidget);
    expect(panelTitles(tester), containsAll(<String>[l.hqCaloriesTodayTitle, l.homeWater, l.hqNutritionDiaryTitle]));
    expect(find.text(l.homeEaten), findsOneWidget);
    expect(find.text(l.homeBurned), findsOneWidget);
    expect(find.text(l.homeDeficit), findsOneWidget);
    // Демо: съедено 640, сожжено 1 420, дефицит 450.
    expect(find.text(l.homeKcalValue('640')), findsOneWidget);
    expect(find.text(l.homeKcalValue('450')), findsOneWidget);
    expect(find.text(l.hqNutritionDiarySoon), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tr: рендерится', (tester) async {
    await pumpTab(tester, const NutritionScreen(), const Locale('tr'));
    final l = await AppLocalizations.delegate.load(const Locale('tr'));
    expect(panelTitles(tester), contains(l.hqCaloriesTodayTitle));
    expect(tester.takeException(), isNull);
  });

  testWidgets('крупный шрифт (×2) не ломает вёрстку вкладки «Питание»', (tester) async {
    await expectNoOverflowAtLargeText(tester, const NutritionScreen(), _scrollKey);
  });
}
