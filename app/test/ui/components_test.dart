import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/ui/ui.dart';

Widget _wrap(Widget child, {bool disableAnimations = false, double textScale = 1}) {
  return MaterialApp(
    theme: buildSystemTheme(),
    home: Builder(
      builder: (context) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          disableAnimations: disableAnimations,
          textScaler: TextScaler.linear(textScale),
        ),
        child: Scaffold(
          body: SystemBackground(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  test('buildSystemTheme — тёмная тема с акцентом', () {
    final t = buildSystemTheme();
    expect(t.brightness, Brightness.dark);
    expect(t.colorScheme.primary, SysColors.accent);
    expect(t.scaffoldBackgroundColor, SysColors.background);
    expect(SysText.heading.letterSpacing, closeTo(16 * 0.13, 1e-9));
    expect(SysText.mono.fontFeatures, isNotEmpty);
  });

  for (final scale in [1.0, 2.0]) {
    testWidgets('все компоненты рендерятся без исключений (textScale $scale)', (tester) async {
      await tester.pumpWidget(_wrap(
        textScale: scale,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final tone in PanelTone.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SysPanel(
                  title: 'Панель ${tone.name}',
                  tone: tone,
                  trailing: const Text('12:00'),
                  child: const Text('Содержимое'),
                ),
              ),
            const SysPanel(animateIn: false, child: Text('Без заголовка')),
            const StatBar(label: 'Энергия', value: 6, max: 8, icon: SysGlyph.bolt, color: SysColors.energy),
            const StatBar(label: 'Вода', value: 1.5, max: 2.5, valueText: '1.5 л'),
            const ProgressRing(progress: .4, center: Text('04:59')),
            const Wrap(children: [
              SysPill(label: 'Бодрость', icon: SysGlyph.sparkle, trailing: '12:00', tone: PanelTone.success),
              SysPill(label: 'Ранг E', tone: PanelTone.boss),
            ]),
            SysButton.primary(label: 'Выполнено', icon: SysGlyph.check, onPressed: () {}),
            SysButton.secondary(label: '+10 мин', onPressed: () {}),
            const SysButton.danger(label: 'Отказ', onPressed: null),
            SysButton(label: 'Широкая', onPressed: () {}, expand: true),
            HoldButton(label: 'Отказ', onCompleted: () {}, expand: true),
            QuestRow(
              title: 'Пресс 3×20',
              time: '07:30',
              reward: '+20 ◆',
              penalty: '−15 ◆',
              subtasks: const [QuestSubtask('Подход 1', done: true), QuestSubtask('Подход 2')],
              progress: .5,
              progressText: '1/2',
              onToggle: (_) {},
            ),
            const QuestRow(title: 'Просрочено', overdue: true, penalty: '−10 ◆'),
            const QuestRow(title: 'Готово', done: true, reward: '+5 ◆'),
            Wrap(children: [for (final g in SysGlyph.values) SysIcon(g, size: 24)]),
            const SysIcon(SysGlyph.bell, semanticLabel: 'Уведомления'),
            const SystemWindow(kind: SystemWindowKind.notice, label: 'Уведомление', message: 'Текст'),
            const SystemWindow(kind: SystemWindowKind.warning, label: 'Предупреждение', title: 'Вода', message: 'Текст'),
            SystemWindow(
              kind: SystemWindowKind.failed,
              label: 'Квест провален',
              message: 'Текст',
              actions: [
                SysButton.primary(label: 'Да', onPressed: () {}),
                SysButton.secondary(label: 'Нет', onPressed: () {}),
              ],
            ),
            SysBottomNav(
              items: const [
                SysNavItem(glyph: SysGlyph.status, label: 'Статус'),
                SysNavItem(glyph: SysGlyph.quests, label: 'Квесты'),
                SysNavItem(glyph: SysGlyph.nutrition, label: 'Питание'),
                SysNavItem(glyph: SysGlyph.shop, label: 'Магазин'),
                SysNavItem(glyph: SysGlyph.more, label: 'Ещё'),
              ],
              currentIndex: 0,
              onTap: (_) {},
            ),
          ],
        ),
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('[ УВЕДОМЛЕНИЕ ]'), findsOneWidget);
      expect(find.text('[ ПРЕДУПРЕЖДЕНИЕ ]'), findsOneWidget);
      expect(find.text('КВЕСТ ПРОВАЛЕН'), findsOneWidget);
      expect(find.bySemanticsLabel('Уведомления'), findsOneWidget);
    });
  }

  group('HoldButton', () {
    testWidgets('отпускание до 5 с не вызывает onCompleted', (tester) async {
      var done = 0;
      await tester.pumpWidget(_wrap(HoldButton(label: 'Отказ', onCompleted: () => done++)));
      final g = await tester.startGesture(tester.getCenter(find.byType(HoldButton)));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 4));
      await g.up();
      await tester.pumpAndSettle();
      expect(done, 0);
      // После сброса снова можно удерживать.
      final g2 = await tester.startGesture(tester.getCenter(find.byType(HoldButton)));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(seconds: 2));
      await g2.up();
      await tester.pumpAndSettle();
      expect(done, 0);
    });

    testWidgets('удержание 5 с вызывает onCompleted один раз', (tester) async {
      var done = 0;
      await tester.pumpWidget(_wrap(HoldButton(label: 'Отказ', onCompleted: () => done++)));
      final g = await tester.startGesture(tester.getCenter(find.byType(HoldButton)));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 100));
      expect(done, 1);
      await tester.pump(const Duration(seconds: 2));
      await g.up();
      await tester.pumpAndSettle();
      expect(done, 1);
    });

    testWidgets('работает при «Уменьшении движения» (не ускоряется)', (tester) async {
      var done = 0;
      await tester.pumpWidget(
        _wrap(HoldButton(label: 'Отказ', onCompleted: () => done++), disableAnimations: true),
      );
      final g = await tester.startGesture(tester.getCenter(find.byType(HoldButton)));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(seconds: 1));
      expect(done, 0);
      await tester.pump(const Duration(seconds: 4));
      await tester.pump(const Duration(milliseconds: 100));
      expect(done, 1);
      await g.up();
      await tester.pumpAndSettle();
    });
  });

  testWidgets('SysBottomNav вызывает onTap с индексом и отмечает выбранный', (tester) async {
    int? tapped;
    await tester.pumpWidget(MaterialApp(
      theme: buildSystemTheme(),
      home: Scaffold(
        bottomNavigationBar: SysBottomNav(
          items: const [
            SysNavItem(glyph: SysGlyph.status, label: 'Статус'),
            SysNavItem(glyph: SysGlyph.quests, label: 'Квесты'),
            SysNavItem(glyph: SysGlyph.more, label: 'Ещё'),
          ],
          currentIndex: 0,
          onTap: (i) => tapped = i,
        ),
      ),
    ));
    await tester.tap(find.text('КВЕСТЫ'));
    await tester.pump();
    expect(tapped, 1);
    final navSize = tester.getSize(find.byType(SysBottomNav));
    expect(navSize.height, lessThan(120));
    expect(navSize.height, greaterThanOrEqualTo(44));
    final handle = tester.ensureSemantics();
    expect(
      tester.getSemantics(find.bySemanticsLabel('Статус')),
      matchesSemantics(label: 'Статус', isButton: true, isSelected: true, hasSelectedState: true, hasTapAction: true),
    );
    handle.dispose();
  });

  testWidgets('QuestRow onToggle передаёт инвертированное состояние', (tester) async {
    final calls = <bool>[];
    await tester.pumpWidget(_wrap(QuestRow(title: 'Вода', time: '08:00', onToggle: calls.add)));
    await tester.tap(find.byType(InkResponse).first);
    await tester.pump();
    expect(calls, [true]);

    await tester.pumpWidget(_wrap(QuestRow(title: 'Вода', done: true, onToggle: calls.add)));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(InkResponse).first);
    await tester.pump();
    expect(calls, [true, false]);
  });

  testWidgets('WindowAppear с disableAnimations рендерит сразу', (tester) async {
    await tester.pumpWidget(_wrap(
      const WindowAppear(delay: Duration(seconds: 1), child: Text('Окно')),
      disableAnimations: true,
    ));
    final opacity = tester.widget<Opacity>(
      find.ancestor(of: find.text('Окно'), matching: find.byType(Opacity)).first,
    );
    expect(opacity.opacity, 1);
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('WindowAppear анимирует появление и завершает', (tester) async {
    await tester.pumpWidget(_wrap(const WindowAppear(child: Text('Окно'))));
    Opacity op() => tester.widget<Opacity>(
          find.ancestor(of: find.text('Окно'), matching: find.byType(Opacity)).first,
        );
    expect(op().opacity, lessThan(1));
    await tester.pumpAndSettle();
    expect(op().opacity, 1);
  });

  testWidgets('showSystemWindow открывает модальное окно', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: buildSystemTheme(),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: SysButton(
              label: 'Открыть',
              onPressed: () => showSystemWindow<void>(
                context,
                window: const SystemWindow(kind: SystemWindowKind.notice, label: 'Уведомление', message: 'Новый квест'),
              ),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('ОТКРЫТЬ'));
    await tester.pumpAndSettle();
    expect(find.text('Новый квест'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(find.text('Новый квест'), findsNothing);
  });

  testWidgets('SysButton: disabled не реагирует, кнопка ≥44px', (tester) async {
    var n = 0;
    await tester.pumpWidget(_wrap(Column(children: [
      SysButton.primary(label: 'А', onPressed: () => n++),
      const SysButton.secondary(label: 'Б', onPressed: null),
    ])));
    await tester.tap(find.text('А'));
    await tester.tap(find.text('Б'), warnIfMissed: false);
    expect(n, 1);
    expect(tester.getSize(find.byType(SysButton).first).height, greaterThanOrEqualTo(44));
  });
}
