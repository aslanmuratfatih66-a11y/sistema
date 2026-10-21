// Реализация WidgetSync через home_widget (SPEC §8.12): iOS — UserDefaults App Group + WidgetKit,
// Android — SharedPreferences HomeWidgetPreferences + SistemaWidgetProvider.
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';

import '../../l10n/app_localizations.dart';
import 'live_api.dart';
import 'live_codec.dart';

class HomeWidgetSync implements WidgetSync {
  HomeWidgetSync({
    required this.platform,
    this._l10n,
    MethodChannel? liveChannel,
    DateTime Function()? now,
  })  : _live = liveChannel ?? const MethodChannel(liveChannelName),
        _now = now ?? DateTime.now;

  /// TargetPlatform.iOS или TargetPlatform.android.
  final TargetPlatform platform;
  final Future<AppLocalizations> Function()? _l10n;
  final MethodChannel _live;
  final DateTime Function() _now;

  bool _groupSet = false;
  String? _lastSignature;

  bool get _ios => platform == TargetPlatform.iOS;

  static const androidQualifiedName = 'com.sistema.sistema.${WidgetKinds.androidProvider}';

  Future<void> _ensureGroup() async {
    if (!_ios || _groupSet) return;
    await HomeWidget.setAppGroupId(sistemaAppGroupId);
    _groupSet = true;
  }

  @override
  Future<void> update(WidgetSnapshot snapshot) async {
    try {
      await _ensureGroup();
      final now = _now();
      final labels = _l10n == null ? const <String, String>{} : widgetLabels(await _l10n());
      final signature = [widgetSnapshotSignature(snapshot), dayKey(now), ...labels.values].join('|');
      if (signature == _lastSignature) return;
      final pending = await _readPending();
      final data = widgetData(snapshot, now: now, pendingWaterMl: pending, labels: labels);
      for (final e in data.entries) {
        await HomeWidget.saveWidgetData<Object>(e.key, e.value, deleteFile: false);
      }
      await _reload();
      _lastSignature = signature;
    } on PlatformException catch (e) {
      debugPrint('WidgetSync: update: $e');
    } on MissingPluginException {
      // Нет нативной части (тест/другая платформа).
    }
  }

  @override
  Future<int> takePendingWater() async {
    try {
      await _ensureGroup();
      int ml;
      if (_ios) {
        // Атомарно в нативе (SistemaAppGroup.takePendingWater).
        ml = await _live.invokeMethod<int>('takePendingWater') ?? 0;
      } else {
        ml = await _readPending();
        if (ml != 0) await HomeWidget.saveWidgetData<int>(WidgetKeys.pendingWater, 0);
      }
      if (ml > 0) _lastSignature = null; // следующая запись снимка обязательна
      return ml < 0 ? 0 : ml;
    } on PlatformException catch (e) {
      debugPrint('WidgetSync: takePendingWater: $e');
      return 0;
    } on MissingPluginException {
      return 0;
    }
  }

  Future<int> _readPending() async {
    final v = await HomeWidget.getWidgetData<Object>(WidgetKeys.pendingWater);
    return v is num ? v.toInt() : 0;
  }

  Future<void> _reload() async {
    if (_ios) {
      for (final kind in WidgetKinds.ios) {
        await HomeWidget.updateWidget(iOSName: kind);
      }
    } else {
      await HomeWidget.updateWidget(qualifiedAndroidName: androidQualifiedName);
    }
  }
}
