import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/live/live_api.dart';
import 'package:sistema/core/live/live_codec.dart';
import 'package:sistema/core/live/widget_sync.dart';
import 'package:sistema/l10n/app_localizations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const hw = MethodChannel('home_widget');
  const live = MethodChannel(liveChannelName);
  late Map<String, Object?> store;
  late List<MethodCall> calls;

  setUp(() {
    store = {};
    calls = [];
    messenger.setMockMethodCallHandler(hw, (call) async {
      calls.add(call);
      final a = call.arguments is Map ? call.arguments as Map : const {};
      switch (call.method) {
        case 'saveWidgetData':
          final v = a['data'];
          if (v == null) {
            store.remove(a['id']);
          } else {
            store[a['id'] as String] = v;
          }
          return true;
        case 'getWidgetData':
          return store[a['id']];
        default:
          return true;
      }
    });
  });
  tearDown(() {
    messenger.setMockMethodCallHandler(hw, null);
    messenger.setMockMethodCallHandler(live, null);
  });

  HomeWidgetSync sync(TargetPlatform p) => HomeWidgetSync(
        platform: p,
        l10n: () async => lookupAppLocalizations(const Locale('ru')),
        now: () => DateTime(2026, 5, 1, 12),
      );

  test('Android: запись данных с учётом очереди и обновление провайдера', () async {
    store[WidgetKeys.pendingWater] = 250;
    final s = sync(TargetPlatform.android);
    await s.update(const WidgetSnapshot(nextQuestTitle: 'Q', steps: 100, waterMl: 500));
    expect(store[WidgetKeys.nextQuestTitle], 'Q');
    expect(store[WidgetKeys.steps], 100);
    expect(store[WidgetKeys.waterMl], 750);
    expect(store[WidgetKeys.day], '2026-05-01');
    expect(store[WidgetKeys.lblWater], 'Вода');
    final upd = calls.where((c) => c.method == 'updateWidget').single;
    expect(upd.arguments['qualifiedAndroidName'], HomeWidgetSync.androidQualifiedName);
    expect(calls.any((c) => c.method == 'setAppGroupId'), isFalse);

    // Тот же снимок — без повторной записи.
    final n = calls.length;
    await s.update(const WidgetSnapshot(nextQuestTitle: 'Q', steps: 100, waterMl: 500));
    expect(calls.length, n);
  });

  test('Android: takePendingWater забирает и обнуляет очередь', () async {
    store[WidgetKeys.pendingWater] = 500;
    final s = sync(TargetPlatform.android);
    expect(await s.takePendingWater(), 500);
    expect(store[WidgetKeys.pendingWater], 0);
    expect(await s.takePendingWater(), 0);
  });

  test('iOS: App Group, перерисовка всех kind, вода через канал', () async {
    messenger.setMockMethodCallHandler(live, (call) async => call.method == 'takePendingWater' ? 250 : null);
    final s = sync(TargetPlatform.iOS);
    await s.update(const WidgetSnapshot(level: 4));
    expect(calls.first.method, 'setAppGroupId');
    expect(calls.first.arguments['groupId'], sistemaAppGroupId);
    final kinds = calls.where((c) => c.method == 'updateWidget').map((c) => c.arguments['ios']).toList();
    expect(kinds, WidgetKinds.ios);
    expect(store[WidgetKeys.level], 4);
    expect(await s.takePendingWater(), 250);
  });

  test('нет плагина — без исключений', () async {
    messenger.setMockMethodCallHandler(hw, null);
    final s = sync(TargetPlatform.android);
    await s.update(const WidgetSnapshot());
    expect(await s.takePendingWater(), 0);
  });
}
