import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/activity/channel_step_counter.dart';
import 'package:sistema/core/models/enums.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(ChannelStepCounter.channelName);
  final calls = <MethodCall>[];

  void mock(Object? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return handler(call);
    });
  }

  setUp(calls.clear);
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null));

  test('тип по платформе', () {
    expect(ChannelStepCounter(platform: TargetPlatform.iOS).kind, StepSourceKind.coreMotion);
    expect(ChannelStepCounter(platform: TargetPlatform.android).kind, StepSourceKind.healthConnect);
    expect(ChannelStepCounter(platform: TargetPlatform.windows).kind, StepSourceKind.manual);
  });

  test('isAvailable уточняет тип источника (датчик на Android)', () async {
    mock((call) => switch (call.method) {
          'isAvailable' => true,
          'kind' => 'sensor',
          _ => null,
        });
    final c = ChannelStepCounter(platform: TargetPlatform.android);
    expect(await c.isAvailable(), isTrue);
    expect(c.kind, StepSourceKind.sensor);
  });

  test('нет метода kind — тип по платформе остаётся', () async {
    mock((call) => call.method == 'isAvailable' ? true : throw MissingPluginException());
    final c = ChannelStepCounter(platform: TargetPlatform.iOS);
    expect(await c.isAvailable(), isTrue);
    expect(c.kind, StepSourceKind.coreMotion);
  });

  test('query: аргументы в мс, разбор ответа', () async {
    mock((call) => {'steps': 5321, 'distanceM': 3870.5, 'floors': 4});
    final from = DateTime(2026, 10, 21);
    final to = DateTime(2026, 10, 21, 12, 30);
    final day = await ChannelStepCounter(platform: TargetPlatform.iOS).query(from, to);

    expect(calls.single.method, 'query');
    expect(calls.single.arguments, {'from': from.millisecondsSinceEpoch, 'to': to.millisecondsSinceEpoch});
    expect(day!.day, from);
    expect(day.steps, 5321);
    expect(day.distanceM, 3870.5);
    expect(day.floors, 4);
  });

  test('query: необязательные поля и null', () async {
    mock((call) => {'steps': 10, 'distanceM': null, 'floors': null});
    final c = ChannelStepCounter(platform: TargetPlatform.android);
    final day = await c.query(DateTime(2026, 10, 21), DateTime(2026, 10, 21, 1));
    expect(day!.steps, 10);
    expect(day.distanceM, isNull);
    expect(day.floors, isNull);

    mock((call) => null);
    expect(await c.query(DateTime(2026, 10, 21), DateTime(2026, 10, 21, 1)), isNull);
  });

  test('ошибки канала → false/null', () async {
    mock((call) => throw PlatformException(code: 'x'));
    final c = ChannelStepCounter(platform: TargetPlatform.iOS);
    expect(await c.isAvailable(), isFalse);
    expect(await c.requestPermission(), isFalse);
    expect(await c.query(DateTime(2026), DateTime(2026, 1, 2)), isNull);
  });

  test('нет нативной части (MissingPlugin) → false/null', () async {
    final c = ChannelStepCounter(platform: TargetPlatform.iOS);
    expect(await c.isAvailable(), isFalse);
    expect(await c.requestPermission(), isFalse);
    expect(await c.query(DateTime(2026), DateTime(2026, 1, 2)), isNull);
  });

  test('requestPermission', () async {
    mock((call) => call.method == 'requestPermission');
    expect(await ChannelStepCounter(platform: TargetPlatform.iOS).requestPermission(), isTrue);
  });
}
