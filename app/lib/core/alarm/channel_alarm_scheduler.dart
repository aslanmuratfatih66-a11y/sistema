// Реализация AlarmScheduler (SPEC §8.11): канал sistema/alarm.
// Android — AlarmManager.setAlarmClock → AlarmReceiver → AlarmRingService (звук + full-screen intent).
// iOS — AlarmKit (iOS 26+). Всегда на iOS дополнительно — серия громких уведомлений (alarm_fallback_notifications):
// основной звонок, если AlarmKit недоступен, или страховка, если звонок AlarmKit выключили кнопкой «Стоп»
// без задания (серия идёт, пока задание не выполнено).
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../db/database.dart';
import '../models/enums.dart';
import 'alarm_api.dart';
import 'alarm_fallback_notifications.dart';
import 'alarm_repository.dart';
import 'alarm_schedule.dart';

/// Состояние разрешений для экрана будильников. null — неприменимо на платформе.
@immutable
class AlarmPermissionState {
  const AlarmPermissionState({
    required this.available,
    this.notifications,
    this.exactAlarms,
    this.fullScreen,
    this.alarmKit,
  });

  /// Настоящий будильник доступен (AlarmKit авторизован / точные будильники + full-screen на Android).
  final bool available;
  final bool? notifications;

  /// Android: SCHEDULE_EXACT_ALARM.
  final bool? exactAlarms;

  /// Android 14+: USE_FULL_SCREEN_INTENT.
  final bool? fullScreen;

  /// iOS: 'authorized' | 'denied' | 'notDetermined' | 'unsupported'.
  final String? alarmKit;

  bool get usesFallback => alarmKit != null && alarmKit != 'authorized';
}

/// Расширение реализации (вне контракта): разрешения и звук звонка, пока открыт экран задания.
abstract interface class AlarmRingControl {
  Future<AlarmPermissionState> permissionState();

  /// Звонить, пока открыт экран задания (если звонок не идёт: AlarmKit выключили «Стопом», фолбэк, холодный старт).
  Future<void> startRinging(String alarmId);
}

bool get _mobile =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

bool get _ios => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

/// Фабрика для main: `alarmSchedulerProvider.overrideWithValue(createAlarmScheduler(db: db, l10n: ...))`.
AlarmScheduler createAlarmScheduler({required AppDatabase db, required Future<AppLocalizations> Function() l10n}) =>
    ChannelAlarmScheduler(db: db, l10n: l10n);

class ChannelAlarmScheduler implements AlarmScheduler, AlarmRingControl {
  ChannelAlarmScheduler({required AppDatabase db, required this._l10n}) : _repo = AlarmRepository(db) {
    if (_mobile) _channel.setMethodCallHandler(_onNative);
  }

  static const _channel = MethodChannel('sistema/alarm');

  final AlarmRepository _repo;
  final Future<AppLocalizations> Function() _l10n;
  final _rings = StreamController<AlarmRing>.broadcast();
  final _fallback = AlarmFallbackNotifications();
  Timer? _foregroundTimer;

  Future<dynamic> _onNative(MethodCall call) async {
    if (call.method != 'onRing') return null;
    final ring = _parseRing(call.arguments);
    if (ring != null) _rings.add(ring);
    return null;
  }

  static AlarmRing? _parseRing(Object? raw) {
    if (raw is! Map) return null;
    final id = raw['id'];
    final at = raw['firedAtMs'];
    if (id is! String || id.isEmpty) return null;
    return AlarmRing(
      alarmId: id,
      firedAt: at is int ? DateTime.fromMillisecondsSinceEpoch(at) : DateTime.now(),
    );
  }

  Future<T?> _invoke<T>(String method, [Object? args]) async {
    if (!_mobile) return null;
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null;
    } on PlatformException catch (e) {
      debugPrint('AlarmScheduler.$method: $e');
      return null;
    }
  }

  @override
  Future<bool> isAvailable() async => await _invoke<bool>('isAvailable') ?? false;

  @override
  Future<AlarmPermissionState> permissionState() async {
    final raw = await _invoke<Map<Object?, Object?>>('permissionState') ?? const {};
    return AlarmPermissionState(
      available: raw['available'] == true,
      notifications: await _fallback.notificationsEnabled(),
      exactAlarms: raw['exactAlarms'] as bool?,
      fullScreen: raw['fullScreen'] as bool?,
      alarmKit: raw['alarmKit'] as String? ?? (_ios ? 'unsupported' : null),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (!_mobile) return false;
    // Уведомления нужны везде: Android — full-screen уведомление сервиса, iOS — фолбэк-серия.
    await _fallback.requestNotifications();
    return await _invoke<bool>('requestPermission') ?? false;
  }

  @override
  Future<void> sync(List<AlarmRow> alarms) async {
    if (!_mobile) return;
    final l = await _l10n();
    final now = DateTime.now();
    final entries = <AlarmPlanEntry>[];
    final active = <AlarmPlanEntry>[];
    for (final a in alarms) {
      if (a.deletedAt != null) continue;
      final title = (a.label?.trim().isNotEmpty ?? false) ? a.label!.trim() : l.almRingTitle;
      final body = _taskText(l, a);
      AlarmPlanEntry entry(DateTime at) => AlarmPlanEntry(alarmId: a.id, at: at, title: title, body: body);
      // Отложенный / проверочный звонок — даже если будильник выключен (проверка).
      final shot = await _repo.oneShot(a.id);
      if (shot != null && shot.isAfter(now)) entries.add(entry(shot));
      if (!a.enabled) continue;
      for (final at in alarmNextOccurrences(a, now)) {
        entries.add(entry(at));
      }
      // iOS: звонок, который идёт сейчас и не выключен заданием, — страховочная серия продолжается.
      if (_ios) {
        final last = alarmLastOccurrence(a, now);
        if (last != null &&
            now.difference(last) < alarmRingWindow &&
            a.updatedAt.isBefore(last) &&
            !await _repo.isHandled(a.id, last, now: now)) {
          active.add(entry(last));
        }
      }
    }
    entries.sort((a, b) => a.at.compareTo(b.at));
    final ok = await _invoke<bool>('schedule', {
          'entries': [for (final e in entries) e.toMap()],
          'labels': {
            'doTask': l.almDoTask,
            'stop': l.almStop,
            'channel': l.almChannelName,
            'channelDesc': l.almChannelDesc,
          },
        }) ??
        false;
    if (_ios) {
      // Ближайшие 2 срабатывания за сутки (лимит iOS — 64 уведомления на всё приложение).
      final soon = entries.where((e) => e.at.difference(now) < const Duration(hours: 24)).take(2);
      await _fallback.schedule(
        [...active, ...soon],
        backupOnly: ok,
        body: l.almFallbackBody,
        now: now,
      );
      _armForegroundTimer(ok ? null : entries.firstOrNull);
    }
  }

  /// Фолбэк iOS без AlarmKit: приложение открыто в момент звонка — сообщаем в rings.
  void _armForegroundTimer(AlarmPlanEntry? next) {
    _foregroundTimer?.cancel();
    _foregroundTimer = null;
    if (next == null) return;
    final d = next.at.difference(DateTime.now());
    if (d.isNegative || d > const Duration(hours: 24)) return;
    _foregroundTimer = Timer(d, () => _rings.add(AlarmRing(alarmId: next.alarmId, firedAt: next.at)));
  }

  @override
  Future<AlarmRing?> pendingRing() async {
    if (!_mobile) return null;
    final now = DateTime.now();
    final candidates = <AlarmRing>[];
    final native = _parseRing(await _invoke<Object?>('pendingRing'));
    if (native != null) candidates.add(native);
    final tapped = await _fallback.launchAlarm();
    if (tapped != null) candidates.add(tapped);
    if (_ios) {
      // AlarmKit не сообщает, что звонок выключили «Стопом» — определяем по времени.
      for (final a in await _repo.all()) {
        final shot = await _repo.oneShot(a.id);
        final last = [
          if (a.enabled) alarmLastOccurrence(a, now),
          if (shot != null && !shot.isAfter(now)) shot,
        ].whereType<DateTime>().fold<DateTime?>(null, (m, t) => m == null || t.isAfter(m) ? t : m);
        if (last == null || now.difference(last) >= alarmRingWindow) continue;
        if (shot == null && !a.updatedAt.isBefore(last)) continue; // будильник создан/изменён уже после
        candidates.add(AlarmRing(alarmId: a.id, firedAt: last));
      }
    }
    for (final c in candidates) {
      if (now.difference(c.firedAt) > const Duration(hours: 3)) continue;
      final alarm = await _repo.get(c.alarmId);
      if (alarm == null) continue;
      if (await _repo.isHandled(c.alarmId, c.firedAt, now: now)) continue;
      return c;
    }
    return null;
  }

  @override
  Stream<AlarmRing> get rings => _rings.stream;

  @override
  Future<void> startRinging(String alarmId) async {
    final l = await _l10n();
    final a = await _repo.get(alarmId);
    await _invoke<void>('ringStart', {
      'id': alarmId,
      'title': (a?.label?.trim().isNotEmpty ?? false) ? a!.label!.trim() : l.almRingTitle,
      'body': a == null ? '' : _taskText(l, a),
      'labels': {'doTask': l.almDoTask, 'channel': l.almChannelName, 'channelDesc': l.almChannelDesc},
    });
  }

  @override
  Future<void> stop(String alarmId) async {
    await _invoke<void>('stop', {'id': alarmId});
    if (_ios) await _fallback.cancelAlarm(alarmId);
  }

  static String _taskText(AppLocalizations l, AlarmRow a) =>
      a.task == AlarmTask.qr.name ? l.almRingBodyQr : l.almRingBodySquats(a.squats);
}
