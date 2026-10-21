import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/db/database.dart';
import 'package:sistema/core/models/enums.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/features/shop/data/reward_repository.dart';
import 'package:sistema/features/shop/shop_providers.dart';
import 'package:sistema/features/shop/shop_rules.dart';
import 'package:sistema/features/shop/shop_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../../helpers/test_db.dart';
import 'fake_quest_service.dart';

final _now = DateTime(2026, 10, 21, 12);

Widget _app(AppDatabase db, FakeQuestService service) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        questServiceProvider.overrideWithValue(service),
        shopClockProvider.overrideWithValue(() => _now),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ru'),
        home: const Scaffold(body: ShopScreen()),
      ),
    );

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _dispose(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(Duration.zero);
}

SysButton _button(WidgetTester tester, String key) => tester.widget<SysButton>(find.byKey(Key(key)));

void main() {
  testWidgets('отрицательный баланс — магазин закрыт, кнопки неактивны', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final id = await tester.runAsync(
      () => RewardRepository(db).create(const RewardDraft(title: 'Шоколадка', price: 50)),
    );
    await tester.pumpWidget(_app(db, FakeQuestService(db: db, diamonds: -20)));
    await _settle(tester);

    expect(find.byKey(const Key('shp-closed')), findsOneWidget);
    expect(find.text('[ ПРЕДУПРЕЖДЕНИЕ ]'), findsOneWidget);
    expect(find.text('Магазин закрыт: баланс отрицательный'), findsOneWidget);
    expect(find.text('-20 ◆'), findsOneWidget);
    expect(_button(tester, 'shp-buy-$id').onPressed, isNull);
    await _dispose(tester);
  });

  testWidgets('нехватка ◆ — кнопка неактивна и подсказка', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final id = await tester.runAsync(
      () => RewardRepository(db).create(const RewardDraft(title: 'Час игр', price: 100)),
    );
    await tester.pumpWidget(_app(db, FakeQuestService(db: db, diamonds: 30)));
    await _settle(tester);

    expect(find.byKey(const Key('shp-closed')), findsNothing);
    expect(find.text('не хватает 70 ◆'), findsOneWidget);
    expect(_button(tester, 'shp-buy-$id').onPressed, isNull);
    await _dispose(tester);
  });

  testWidgets('покупка: подтверждение, вызов движка, история, лимит', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    final id = await tester.runAsync(
      () => RewardRepository(db).create(
        const RewardDraft(title: 'Фастфуд', price: 50, limitCount: 1, limitPeriod: RewardLimitPeriod.day),
      ),
    );
    final service = FakeQuestService(db: db, diamonds: 200);
    await tester.pumpWidget(_app(db, service));
    await _settle(tester);

    expect(find.text('200 ◆'), findsOneWidget);
    expect(find.text('Покупок пока нет'), findsOneWidget);
    expect(_button(tester, 'shp-buy-$id').onPressed, isNotNull);

    await tester.tap(find.byKey(Key('shp-buy-$id')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byKey(const Key('shp-confirm')), findsOneWidget);
    expect(find.text('«Фастфуд» за 50 ◆. Баланс после покупки: 150 ◆.'), findsOneWidget);

    await tester.tap(find.byKey(const Key('shp-confirm-buy')));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 400));
    expect(service.purchases.single, (rewardId: id!, title: 'Фастфуд', price: 50));
    expect(find.byKey(const Key('shp-bought')), findsOneWidget);

    await tester.tap(find.text('ГОТОВО'));
    await _settle(tester);
    expect(find.text('150 ◆'), findsOneWidget);
    expect(find.text('−50 ◆'), findsOneWidget); // история
    // Лимит 1 в день исчерпан.
    expect(find.textContaining('лимит исчерпан до 22.10'), findsOneWidget);
    expect(_button(tester, 'shp-buy-$id').onPressed, isNull);
    await _dispose(tester);
  });

  testWidgets('пустое состояние: примеры заполняют форму, без автосоздания', (tester) async {
    final db = memoryDb();
    addTearDown(db.close);
    await tester.pumpWidget(_app(db, FakeQuestService(db: db, diamonds: 10)));
    await _settle(tester);

    expect(find.byKey(const Key('shp-empty')), findsOneWidget);
    expect(find.text('Шоколадка'), findsOneWidget);
    expect(find.text('Вечер без квестов'), findsOneWidget);
    expect(await tester.runAsync(() => RewardRepository(db).getRewards()), isEmpty);

    await tester.tap(find.text('Час игр'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const Key('shp-editor-title')), findsOneWidget);
    await tester.tap(find.byKey(const Key('shp-editor-save')));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
    await tester.pump(const Duration(milliseconds: 500));
    await _settle(tester);

    final list = await tester.runAsync(() => RewardRepository(db).getRewards());
    expect(list!.single.title, 'Час игр');
    expect(list.single.price, 100);
    expect(find.byKey(const Key('shp-empty')), findsNothing);
    await _dispose(tester);
  });
}
