// Реализация StepCounter поверх нативного канала `sistema/steps` (iOS CMPedometer, Android Health Connect / датчик).
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/daily.dart';
import '../models/enums.dart';
import 'activity_api.dart';

class ChannelStepCounter implements StepCounter {
  ChannelStepCounter({MethodChannel? channel, TargetPlatform? platform})
      : _channel = channel ?? const MethodChannel(channelName),
        _kind = _defaultKind(platform ?? defaultTargetPlatform);

  static const channelName = 'sistema/steps';

  final MethodChannel _channel;
  StepSourceKind _kind;

  static StepSourceKind _defaultKind(TargetPlatform platform) => switch (platform) {
        TargetPlatform.iOS => StepSourceKind.coreMotion,
        TargetPlatform.android => StepSourceKind.healthConnect,
        _ => StepSourceKind.manual,
      };

  /// Тип источника. На Android уточняется после [isAvailable]: Health Connect или датчик шагов.
  @override
  StepSourceKind get kind => _kind;

  @override
  Future<bool> isAvailable() async {
    try {
      final ok = await _channel.invokeMethod<bool>('isAvailable') ?? false;
      if (ok) await _refreshKind();
      return ok;
    } on PlatformException catch (e) {
      debugPrint('steps.isAvailable: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Дополнительный метод канала `kind` → StepSourceKind.name. Старые сборки без него — тип по платформе.
  Future<void> _refreshKind() async {
    try {
      final name = await _channel.invokeMethod<String>('kind');
      final parsed = StepSourceKind.values.where((k) => k.name == name);
      if (parsed.isNotEmpty) _kind = parsed.first;
    } on Object catch (_) {
      // Нет метода `kind` или ошибка канала — остаётся тип по платформе.
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestPermission') ?? false;
    } on PlatformException catch (e) {
      debugPrint('steps.requestPermission: $e');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  @override
  Future<StepDay?> query(DateTime from, DateTime to) async {
    try {
      final raw = await _channel.invokeMapMethod<String, Object?>('query', {
        'from': from.millisecondsSinceEpoch,
        'to': to.millisecondsSinceEpoch,
      });
      if (raw == null) return null;
      final steps = raw['steps'];
      if (steps is! num) return null;
      final distance = raw['distanceM'];
      final floors = raw['floors'];
      return StepDay(
        day: DateTime(from.year, from.month, from.day),
        steps: steps.round(),
        distanceM: distance is num ? distance.toDouble() : null,
        floors: floors is num ? floors.round() : null,
      );
    } on PlatformException catch (e) {
      debugPrint('steps.query: $e');
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
