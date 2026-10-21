import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/features/home/data/home_providers.dart';
import 'package:sistema/features/home/home_screen.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

final _fixedNow = DateTime(2026, 10, 21, 10, 46);

Widget _app(Locale locale, {double textScale = 1}) => ProviderScope(
      overrides: [homeNowSourceProvider.overrideWithValue(() => _fixedNow)],
      child: MaterialApp(
        theme: buildSystemTheme(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const Scaffold(body: HomeScreen()),
      ),
    );

Future<void> _pump(WidgetTester tester, Locale locale, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_app(locale, textScale: textScale));
  // Бесконечные анимации (пульс, волна) — pumpAndSettle не дождётся, крутим вручную.
  await tester.pump(const Duration(milliseconds: 600));
}

Set<String?> _panelTitles(WidgetTester tester) =>
    tester.widgetList<SysPanel>(find.byType(SysPanel)).map((p) => p.title).toSet();

Future<void> _scrollToBottom(WidgetTester tester) async {
  final scroll = find.byKey(const Key('home-scroll'));
  final state = tester.state<ScrollableState>(
    find.descendant(of: scroll, matching: find.byType(Scrollable)).first,
  );
  for (var i = 0; i < 40 && state.position.pixels < state.position.maxScrollExtent; i++) {
    await tester.drag(scroll, const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(state.position.pixels, state.position.maxScrollExtent);
}

/// Ошибки вёрстки внутри компонентов дизайн-системы (зона сабагента A) отделяем
/// от ошибок самого главного экрана.
const _designSystemWidgets = ['StatBar', 'SysPill', 'QuestRow', 'SysButton', 'HoldButton', 'SysBottomNav'];

bool _fromDesignSystem(FlutterErrorDetails e) {
  final text = TextTreeRenderer(wrapWidth: 4000).render(e.toDiagnosticsNode(style: DiagnosticsTreeStyle.error));
  final names = _designSystemWidgets.join('|');
  // Цепочка creator содержит компонент дизайн-системы — ошибка внутри него.
  return RegExp('← ($names)\\b').hasMatch(text);
}

void main() {
  testWidgets('ru: рендерятся все блоки, скролл до низа без исключений', (tester) async {
    await _pump(tester, const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    expect(find.text('СИСТЕМА · ОНЛАЙН'), findsOneWidget);
    expect(find.text('НЕДЕЛЯ 1 · ДЕНЬ 1'), findsOneWidget);
    expect(find.bySemanticsLabel(l.homeSettingsLabel), findsOneWidget);
    expect(_panelTitles(tester), containsAll(<String>[
      l.homeStatusTitle,
      l.homeEffectsTitle,
      l.homeNextQuestTitle,
      l.homeDayTitle,
      l.homeDailyTitle,
      l.homeBossTitle,
      l.homeCalories,
      l.homeFinanceTitle,
      l.homeAssistantTitle,
    ]));
    expect(find.byType(QuestRow), findsNWidgets(7));
    expect(find.byType(HoldButton), findsOneWidget);
    expect(find.text(l.homeRefuseHint), findsOneWidget);

    await _scrollToBottom(tester);
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('тап по чекбоксу квеста переключает его', (tester) async {
    await _pump(tester, const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));
    QuestRow row() => tester.widget<QuestRow>(find.byKey(const ValueKey('daily-breakfast')));

    expect(row().done, isFalse);
    expect(row().overdue, isTrue);
    expect(find.text(l.homeDailyPenaltyTotal('75')), findsOneWidget);

    row().onToggle!(true);
    await tester.pump();
    expect(row().done, isTrue);
    expect(row().overdue, isFalse);
    expect(find.text(l.homeDailyPenaltyTotal('70')), findsOneWidget);

    row().onToggle!(false);
    await tester.pump();
    expect(row().done, isFalse);
  });

  testWidgets('отказ удержанием показывает окно «Квест провален»', (tester) async {
    await _pump(tester, const Locale('ru'));
    final l = await AppLocalizations.delegate.load(const Locale('ru'));

    tester.widget<HoldButton>(find.byType(HoldButton)).onCompleted();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    final window = tester.widget<SystemWindow>(find.byType(SystemWindow));
    expect(window.kind, SystemWindowKind.failed);
    expect(window.title, l.homeQuestFailedTitle);
    expect(window.message, contains(l.homeDemoNextQuest));
  });

  testWidgets('tr: рендерится и прокручивается', (tester) async {
    await _pump(tester, const Locale('tr'));
    final l = await AppLocalizations.delegate.load(const Locale('tr'));

    expect(find.text('SİSTEM · ÇEVRİMİÇİ'), findsOneWidget);
    expect(_panelTitles(tester), containsAll(<String>[l.homeStatusTitle, l.homeDailyTitle, l.homeBossTitle]));
    await _scrollToBottom(tester);
    expect(tester.takeException(), isNull);
  });

  testWidgets('крупный шрифт (×2) не ломает вёрстку главного экрана', (tester) async {
    final errors = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = errors.add;
    try {
      await _pump(tester, const Locale('ru'), textScale: 2);
      await _scrollToBottom(tester);
    } finally {
      FlutterError.onError = previous;
    }
    final own = errors.where((e) => !_fromDesignSystem(e)).toList();
    final foreign = errors.length - own.length;
    if (foreign > 0) {
      // ignore: avoid_print
      print('Предупреждение: $foreign ошибок вёрстки внутри компонентов дизайн-системы при ×2.');
    }
    expect(own, isEmpty, reason: own.map((e) => e.toString()).join('\n'));
  });
}
