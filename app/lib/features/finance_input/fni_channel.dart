// Нативный канал Android "sistema/bank" (BankChannel.kt): доступ к уведомлениям, источники, очередь входящих.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Входящее сообщение из нативной очереди.
class BankIncoming {
  const BankIncoming({required this.channel, required this.sender, required this.body, required this.receivedAt});

  factory BankIncoming.fromMap(Map<Object?, Object?> m) => BankIncoming(
        channel: '${m['channel'] ?? 'notification'}',
        sender: '${m['sender'] ?? ''}',
        body: '${m['body'] ?? ''}',
        receivedAt: DateTime.fromMillisecondsSinceEpoch(((m['receivedAt'] as num?) ?? 0).toInt()),
      );

  /// notification / sms.
  final String channel;
  final String sender;
  final String body;
  final DateTime receivedAt;
}

class BankChannel {
  const BankChannel();

  static const _m = MethodChannel('sistema/bank');
  static const _e = EventChannel('sistema/bank/events');

  bool get supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  Future<T?> _call<T>(String method, [Object? args]) async {
    if (!supported) return null;
    try {
      return await _m.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  Future<bool> isListenerEnabled() async => await _call<bool>('isListenerEnabled') ?? false;

  Future<void> openListenerSettings() => _call<void>('openListenerSettings');

  Future<void> setSources({required List<String> packages, required List<String> smsSenders}) =>
      _call<void>('setSources', {'packages': packages, 'smsSenders': smsSenders});

  Future<List<BankIncoming>> drain() async => _list(await _call<List<Object?>>('drain'));

  Future<List<BankIncoming>> readSmsHistory(DateTime since) async =>
      _list(await _call<List<Object?>>('readSmsHistory', {'since': since.millisecondsSinceEpoch}));

  Future<bool> isPackageInstalled(String package) async =>
      await _call<bool>('isPackageInstalled', {'package': package}) ?? false;

  /// Живые события (пока Flutter запущен). Пустой поток вне Android.
  Stream<BankIncoming> events() {
    if (!supported) return const Stream.empty();
    return _e
        .receiveBroadcastStream()
        .where((e) => e is Map)
        .map((e) => BankIncoming.fromMap(e as Map<Object?, Object?>))
        .handleError((Object _) {});
  }

  List<BankIncoming> _list(List<Object?>? raw) => [
        for (final e in raw ?? const <Object?>[])
          if (e is Map) BankIncoming.fromMap(e),
      ];
}
