// Общие помощники виджет-тестов вкладок «Статус», «Квесты», «Питание».
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/domain/day_modes/day_modes.dart';
import 'package:sistema/domain/quests/quest_api.dart';
import 'package:sistema/features/habits/habit_repository.dart';
import 'package:sistema/features/home/data/demo_home_data.dart';
import 'package:sistema/features/home/data/home_live_data.dart';
import 'package:sistema/features/home/data/home_providers.dart';
import 'package:sistema/features/quests/outcomes/outcome_windows_host.dart';
import 'package:sistema/l10n/app_localizations.dart';
import 'package:sistema/ui/ui.dart';

import '../quests/fake_quest_service.dart';

final fixedNow = DateTime(2026, 10, 21, 10, 46);

/// iPhone 15 Pro: 393×852 pt, верхний safe area 59, нижняя навигация 56 + home indicator 34.
const iphoneSize = Size(393, 852);
const iphoneTopInset = 59.0;
const shellBottomBar = 56.0 + 34.0;

/// Видимая область вкладки (в глобальных координатах) — как в AppShell.
const visibleTabBottom = 852.0 - shellBottomBar;

/// Контекст «Статуса» без БД: лента дня и начало программы — как в демо.
HomeContext testHomeContext() {
  final demo = buildDemoHomeData(fixedNow);
  return HomeContext(
    programStart: demo.programStart,
    day: demo.day,
    playerName: 'Мурат',
    waterGoalMl: 2500,
    kcalGoal: 2200,
  );
}

/// Приложение с вкладкой, размещённой как в оболочке: сверху safe area, снизу навигация.
/// Движок — [service] (по умолчанию фейк с данными «утро первого дня»), окна — OutcomeWindowsHost.
Widget tabApp(Widget screen, Locale locale, {double textScale = 1, QuestService? service}) => ProviderScope(
      overrides: [
        homeNowSourceProvider.overrideWithValue(() => fixedNow),
        questServiceProvider.overrideWithValue(service ?? FakeQuestService(now: fixedNow)),
        homeContextProvider.overrideWithValue(testHomeContext()),
        // Режимы дня и привычки — без БД.
        dayModesPrefsProvider.overrideWith((ref) => Stream.value(const DayModesPrefs())),
        dayBusyProvider.overrideWith((ref) => Stream.value(null)),
        habitsProvider.overrideWith((ref) => Stream.value(const <Habit>[])),
      ],
      child: MaterialApp(
        theme: buildSystemTheme(),
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: OutcomeWindowsHost(
          child: Scaffold(
            body: Column(
              children: [
                const SizedBox(height: iphoneTopInset),
                Expanded(child: screen),
                const SizedBox(height: shellBottomBar),
              ],
            ),
          ),
        ),
      ),
    );

bool _fontsLoaded = false;

/// Подгружает настоящие шрифты приложения (Oswald, Inter, JetBrains Mono), чтобы
/// замеры высоты были как на устройстве, а не по тестовому шрифту с квадратными глифами.
Future<void> loadAppFonts() async {
  if (_fontsLoaded) return;
  for (final (family, asset) in const [
    ('Oswald', 'assets/fonts/Oswald.ttf'),
    ('Inter', 'assets/fonts/Inter.ttf'),
    ('JetBrainsMono', 'assets/fonts/JetBrainsMono.ttf'),
  ]) {
    await (FontLoader(family)..addFont(rootBundle.load(asset))).load();
  }
  _fontsLoaded = true;
}

Future<void> pumpTab(
  WidgetTester tester,
  Widget screen,
  Locale locale, {
  double textScale = 1,
  QuestService? service,
}) async {
  tester.view.physicalSize = iphoneSize * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.runAsync(loadAppFonts);
  await tester.pumpWidget(tabApp(screen, locale, textScale: textScale, service: service));
  // Бесконечные анимации (пульс) — pumpAndSettle не дождётся, крутим вручную.
  // Второй шаг — панели, появившиеся после данных движка: пока идёт проявление (WindowAppear),
  // клип не пропускает нажатия.
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

Set<String?> panelTitles(WidgetTester tester) =>
    tester.widgetList<SysPanel>(find.byType(SysPanel)).map((p) => p.title).toSet();

Future<void> scrollToBottom(WidgetTester tester, Key scrollKey) async {
  final scroll = find.byKey(scrollKey);
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
/// от ошибок самих экранов.
const _designSystemWidgets = ['StatBar', 'SysPill', 'QuestRow', 'SysButton', 'HoldButton', 'SysBottomNav'];

bool _fromDesignSystem(FlutterErrorDetails e) {
  final text = TextTreeRenderer(wrapWidth: 4000).render(e.toDiagnosticsNode(style: DiagnosticsTreeStyle.error));
  final names = _designSystemWidgets.join('|');
  return RegExp('← ($names)\\b').hasMatch(text);
}

/// Крупный шрифт ×2: прокрутка до низа без собственных ошибок вёрстки экрана.
Future<void> expectNoOverflowAtLargeText(WidgetTester tester, Widget screen, Key scrollKey) async {
  final errors = <FlutterErrorDetails>[];
  final previous = FlutterError.onError;
  FlutterError.onError = errors.add;
  try {
    await pumpTab(tester, screen, const Locale('ru'), textScale: 2);
    await scrollToBottom(tester, scrollKey);
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
}

/// Удержание кнопки отказа [duration] (кадрами по 100 мс) и отпускание.
Future<void> holdFor(WidgetTester tester, Finder target, Duration duration) async {
  final g = await tester.startGesture(tester.getCenter(target));
  for (var t = Duration.zero; t < duration; t += const Duration(milliseconds: 100)) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await g.up();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}
