import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/live/live_activity_service.dart';
import 'package:sistema/core/live/live_api.dart';
import 'package:sistema/core/live/live_codec.dart';
import 'package:sistema/l10n/app_localizations.dart';

class _FakeNotifier implements LiveNotifier {
  bool isEnabled = true;
  final shown = <LiveNotification>[];
  final cancelled = <int>[];

  @override
  Future<bool> enabled() async => isEnabled;

  @override
  Future<void> show(LiveNotification n, {required String channelName, required String channelDescription}) async =>
      shown.add(n);

  @override
  Future<void> cancel(int id) async => cancelled.add(id);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final l = lookupAppLocalizations(const Locale('ru'));

  group('ChannelLiveActivityService', () {
    const channel = MethodChannel(liveChannelName);
    final calls = <MethodCall>[];
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    setUp(() {
      calls.clear();
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return switch (call.method) {
          'isSupported' => true,
          'start' => 'act-1',
          _ => null,
        };
      });
    });
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('протокол start/update/end', () async {
      final s = ChannelLiveActivityService();
      expect(await s.isSupported(), isTrue);
      final id = await s.start(LiveKind.walk, const LiveState(title: 'Прогулка', distanceM: 1200));
      expect(id, 'act-1');
      expect(calls[1].arguments['kind'], 'walk');
      expect(calls[1].arguments['distanceM'], 1200);
      await s.update('act-1', const LiveState(title: 'Т', subtitle: 'дальше'));
      expect(calls[2].method, 'update');
      expect(calls[2].arguments['id'], 'act-1');
      expect(calls[2].arguments['subtitle'], 'дальше');
      await s.end('act-1');
      expect(calls[3].method, 'end');
      expect(calls[3].arguments, {'id': 'act-1'});
    });

    test('ошибка платформы → null/false', () async {
      messenger.setMockMethodCallHandler(channel, (call) async => throw PlatformException(code: 'x'));
      final s = ChannelLiveActivityService();
      expect(await s.isSupported(), isFalse);
      expect(await s.start(LiveKind.quest, const LiveState(title: 'q')), isNull);
      await s.update('a', const LiveState(title: 'q'));
    });

    test('нет нативной части → false', () async {
      messenger.setMockMethodCallHandler(channel, null);
      expect(await ChannelLiveActivityService().isSupported(), isFalse);
    });
  });

  group('NotificationLiveActivityService', () {
    test('start/update/end через уведомление', () async {
      final n = _FakeNotifier();
      final s = NotificationLiveActivityService(l10n: () async => l, notifier: n);
      final id = await s.start(LiveKind.workout, LiveState(title: 'Планка', endsAt: DateTime(2030), progress: 0.5));
      expect(id, 'workout');
      expect(n.shown.single.id, liveNotificationId(LiveKind.workout));
      expect(n.shown.single.progressPercent, 50);
      await s.update('workout', const LiveState(title: 'Планка 2'));
      expect(n.shown.last.title, 'Планка 2');
      await s.update('unknown', const LiveState(title: 'x'));
      expect(n.shown, hasLength(2));
      await s.end('workout');
      expect(n.cancelled, [liveNotificationId(LiveKind.workout)]);
    });

    test('уведомления выключены → null', () async {
      final n = _FakeNotifier()..isEnabled = false;
      final s = NotificationLiveActivityService(l10n: () async => l, notifier: n);
      expect(await s.start(LiveKind.quest, const LiveState(title: 'q')), isNull);
      expect(n.shown, isEmpty);
    });
  });

  test('buildLiveNotification: дистанция, темп, подзаголовок', () {
    final n = buildLiveNotification(
      LiveKind.walk,
      const LiveState(title: '', subtitle: 'Через 200 м налево', distanceM: 1234, paceSecPerKm: 335.4),
      l,
    );
    expect(n.title, l.livWalk);
    expect(n.body, '1.23 ${l.livKm} · 5:35 ${l.livPerKm}\nЧерез 200 м налево');
    expect(n.progressPercent, isNull);
  });
}
