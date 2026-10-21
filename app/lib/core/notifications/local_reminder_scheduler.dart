// ReminderScheduler на flutter_local_notifications (SPEC §7): окно ≤60 уведомлений, кнопки Выполнено / +10 мин.
// В тестах не используется — логика окна в reminder_window.dart.
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../app/service_factory.dart';
import '../../l10n/app_localizations.dart';
import '../db/database.dart';
import 'notification_api.dart';
import 'reminder_coordinator.dart';
import 'reminder_prefs_repository.dart';
import 'reminder_sources.dart';
import 'reminder_texts.dart';
import 'reminder_window.dart';

const _channelQuests = 'sistema_quests';
const _channelNag = 'sistema_nag';
const _categoryQuest = 'sistema_quest';
const _actionDone = 'done';
const _actionSnooze = 'snooze10';

/// Состояние разрешений для экрана настроек. null — неизвестно / неприменимо на платформе.
@immutable
class ReminderPermissionState {
  const ReminderPermissionState({this.notifications, this.exactAlarms});
  final bool? notifications;

  /// Только Android: точные будильники (SCHEDULE_EXACT_ALARM).
  final bool? exactAlarms;
}

/// Расширение реализации для экрана настроек (вне контракта).
abstract interface class ReminderPermissionProbe {
  Future<ReminderPermissionState> permissionState();
}

bool get _supported =>
    !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

class LocalReminderScheduler implements ReminderScheduler, ReminderPermissionProbe {
  LocalReminderScheduler({required this._l10n, this.sound = const NoVoiceSound()});

  final Future<AppLocalizations> Function() _l10n;

  /// Голос персонажа как звук (этап 6). Пока всегда стандартный звук.
  final ReminderSoundSource sound;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  bool _exact = false;
  AppLocalizations? _l;
  Future<void> Function(ReminderResponse)? _onResponse;

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

  IOSFlutterLocalNotificationsPlugin? get _ios =>
      _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

  @override
  Future<void> init({required Future<void> Function(ReminderResponse) onResponse}) async {
    _onResponse = onResponse;
    if (!_supported || _ready) return;
    await initReminderTimeZone();
    final l = _l = await _l10n();
    final darwin = DarwinInitializationSettings(
      // Разрешение спрашиваем явно (requestPermission), не при инициализации — в т.ч. в фоновом isolate.
      requestAlertPermission: false,
      requestSoundPermission: false,
      requestBadgePermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          _categoryQuest,
          actions: [
            DarwinNotificationAction.plain(_actionDone, l.ntfActionDone),
            DarwinNotificationAction.plain(_actionSnooze, l.ntfActionSnooze),
          ],
        ),
      ],
    );
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: darwin,
      ),
      onDidReceiveNotificationResponse: _onForegroundResponse,
      onDidReceiveBackgroundNotificationResponse: reminderBackgroundResponse,
    );
    final android = _android;
    if (android != null) {
      await android.createNotificationChannel(AndroidNotificationChannel(
        _channelQuests,
        l.ntfChannelQuests,
        description: l.ntfChannelQuestsDesc,
        importance: Importance.high,
      ));
      await android.createNotificationChannel(AndroidNotificationChannel(
        _channelNag,
        l.ntfChannelNag,
        description: l.ntfChannelNagDesc,
        importance: Importance.high,
      ));
      _exact = await android.canScheduleExactNotifications() ?? false;
    }
    _ready = true;
    // Приложение запущено нажатием на уведомление.
    try {
      final launch = await _plugin.getNotificationAppLaunchDetails();
      final resp = launch?.notificationResponse;
      if (launch?.didNotificationLaunchApp == true && resp != null) _onForegroundResponse(resp);
    } on PlatformException catch (e) {
      debugPrint('LocalReminderScheduler: launch details: $e');
    }
  }

  void _onForegroundResponse(NotificationResponse resp) {
    final r = parseReminderResponse(resp);
    final cb = _onResponse;
    if (r != null && cb != null) unawaited(cb(r));
  }

  @override
  Future<bool> requestPermission() async {
    if (!_supported) return false;
    final ios = _ios;
    if (ios != null) return await ios.requestPermissions(alert: true, sound: true, badge: true) ?? false;
    final android = _android;
    if (android == null) return false;
    final granted = await android.requestNotificationsPermission() ?? false;
    // Точные будильники: если не выданы — открываем системный экран; отказ — работаем с неточными.
    if (!(await android.canScheduleExactNotifications() ?? false)) {
      try {
        await android.requestExactAlarmsPermission();
      } on PlatformException catch (e) {
        debugPrint('LocalReminderScheduler: exact alarms: $e');
      }
    }
    _exact = await android.canScheduleExactNotifications() ?? false;
    return granted;
  }

  @override
  Future<ReminderPermissionState> permissionState() async {
    if (!_supported) return const ReminderPermissionState();
    final ios = _ios;
    if (ios != null) {
      final o = await ios.checkPermissions();
      return ReminderPermissionState(notifications: o?.isEnabled);
    }
    final android = _android;
    if (android == null) return const ReminderPermissionState();
    return ReminderPermissionState(
      notifications: await android.areNotificationsEnabled(),
      exactAlarms: await android.canScheduleExactNotifications(),
    );
  }

  @override
  Future<void> sync(List<ReminderRequest> upcoming, ReminderPrefs prefs, {required DateTime now}) async {
    if (!_supported || !_ready) return;
    final pending = [
      for (final p in await _plugin.pendingNotificationRequests()) PendingReminder(id: p.id, payload: p.payload),
    ];
    final diff = diffReminderWindow(pending, upcoming, prefs, now: now);
    for (final id in diff.cancel) {
      await _plugin.cancel(id: id);
    }
    final android = _android;
    if (android != null) _exact = await android.canScheduleExactNotifications() ?? false;
    for (final p in diff.schedule) {
      await _schedule(p, prefs);
    }
  }

  Future<void> _schedule(PlannedReminder p, ReminderPrefs prefs) async {
    final when = tz.TZDateTime.from(p.at, tz.local);
    final details = _details(nag: p.isNag, thread: p.instanceId, actions: true, prefs: prefs);
    Future<void> run(AndroidScheduleMode mode) => _plugin.zonedSchedule(
          id: p.id,
          scheduledDate: when,
          notificationDetails: details,
          androidScheduleMode: mode,
          title: p.title,
          body: p.body,
          payload: p.payload,
        );
    try {
      await run(_exact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle);
    } on PlatformException catch (e) {
      // Разрешение на точные отозвано между проверкой и вызовом — ставим неточное.
      if (!_exact) rethrow;
      debugPrint('LocalReminderScheduler: exact failed, fallback: $e');
      _exact = false;
      await run(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  NotificationDetails _details({
    required bool nag,
    required ReminderPrefs prefs,
    String? thread,
    bool actions = false,
  }) {
    final l = _l;
    // TODO(этап 6): prefs.voiceSound → sound.soundFor(...) (файл ≤30 с в Library/Sounds / res/raw).
    return NotificationDetails(
      android: AndroidNotificationDetails(
        nag ? _channelNag : _channelQuests,
        nag ? l?.ntfChannelNag ?? 'Nag' : l?.ntfChannelQuests ?? 'Quests',
        channelDescription: nag ? l?.ntfChannelNagDesc : l?.ntfChannelQuestsDesc,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
        groupKey: thread,
        actions: !actions || l == null
            ? null
            : [
                AndroidNotificationAction(_actionDone, l.ntfActionDone),
                AndroidNotificationAction(_actionSnooze, l.ntfActionSnooze),
              ],
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBanner: true,
        presentList: true,
        presentSound: true,
        threadIdentifier: thread,
        categoryIdentifier: actions ? _categoryQuest : null,
        interruptionLevel: InterruptionLevel.active,
      ),
    );
  }

  @override
  Future<void> cancelInstance(String instanceId) async {
    if (!_supported || !_ready) return;
    final ids = <int>{};
    for (final p in await _plugin.pendingNotificationRequests()) {
      if (ReminderPayload.decode(p.payload)?.instanceId == instanceId) ids.add(p.id);
    }
    // Уже показанные повторы тоже убираем из шторки.
    try {
      for (final a in await _plugin.getActiveNotifications()) {
        final id = a.id;
        if (id != null && ReminderPayload.decode(a.payload)?.instanceId == instanceId) ids.add(id);
      }
    } on PlatformException catch (e) {
      debugPrint('LocalReminderScheduler: active notifications: $e');
    }
    for (final id in ids) {
      await _plugin.cancel(id: id);
    }
  }

  @override
  Future<void> showNow({required String title, required String body}) async {
    if (!_supported || !_ready) return;
    final key = '$title|$body|${DateTime.now().microsecondsSinceEpoch}';
    await _plugin.show(
      id: immediateNotificationId(key),
      title: title,
      body: body,
      notificationDetails: _details(nag: false, prefs: const ReminderPrefs()),
    );
  }
}

/// Часовой пояс для zonedSchedule. Мгновение уведомления не зависит от пояса (TZDateTime.from),
/// поэтому при сбое — UTC.
Future<void> initReminderTimeZone() async {
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (e) {
    debugPrint('LocalReminderScheduler: time zone: $e');
    tz.setLocalLocation(tz.UTC);
  }
}

/// Нажатие → ReminderResponse; null — не наше уведомление (showNow, другие этапы).
ReminderResponse? parseReminderResponse(NotificationResponse resp) {
  final payload = ReminderPayload.decode(resp.payload);
  if (payload == null) return null;
  final action = switch (resp.actionId) {
    _actionDone => ReminderAction.done,
    _actionSnooze => ReminderAction.snooze10,
    _ => ReminderAction.open,
  };
  return ReminderResponse(instanceId: payload.instanceId, action: action);
}

/// Сервисы для фонового isolate: своя БД, движок, планировщик и координатор без таймеров.
Future<T> runReminderBackground<T>(Future<T> Function(ReminderCoordinator c) body) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final db = AppDatabase();
  try {
    final prefs = ReminderPrefsRepository(db);
    final scheduler = LocalReminderScheduler(l10n: () => reminderL10n(db));
    await scheduler.init(onResponse: (_) async {});
    final c = ReminderCoordinator(
      quests: await createQuestService(db),
      scheduler: scheduler,
      loadPrefs: prefs.load,
      l10n: () => reminderL10n(db),
      observeLifecycle: false,
      foreground: false,
    );
    return await body(c);
  } finally {
    await db.close();
  }
}

/// Кнопка в уведомлении, когда приложение в фоне или выгружено (отдельный isolate).
@pragma('vm:entry-point')
Future<void> reminderBackgroundResponse(NotificationResponse resp) async {
  final r = parseReminderResponse(resp);
  if (r == null || r.action == ReminderAction.open) return;
  try {
    await runReminderBackground((c) => c.handleResponse(r));
  } catch (e, st) {
    debugPrint('reminderBackgroundResponse: $e\n$st');
  }
}

/// Реализация планировщика. reminderSchedulerProvider переопределяет главный агент в main
/// тем же экземпляром, у которого вызван init.
final localReminderSchedulerProvider = Provider<ReminderScheduler>((ref) {
  final db = ref.watch(databaseProvider);
  return LocalReminderScheduler(l10n: () => reminderL10n(db));
});
