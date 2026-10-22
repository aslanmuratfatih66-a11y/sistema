// Сообщения Системы наперёд (SPEC §9.5): при старте/возврате и в фоне (BGAppRefresh) — POST generate
// (best-effort) + GET пачки → локальные уведомления; упрёк снимается при выполнении квеста;
// если запаса нет — шаблонные реплики из l10n. Если приложение открыто в момент сообщения — облачко персонажа.
import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/service_factory.dart';
import '../../domain/quests/quest_api.dart';
import '../../features/character/character_reaction.dart';
import '../../l10n/app_localizations.dart';
import '../ai/ai_api.dart';
import '../db/database.dart';
import '../models/enums.dart';
import '../sync/http_auth_service.dart';
import '../voice/voice_providers.dart';
import 'ai_messages.dart';
import 'ai_messages_scheduler.dart';
import 'notification_api.dart';
import 'reminder_prefs_repository.dart';
import 'reminder_texts.dart';
import 'reminder_window.dart' show fnv1a32, isQuietAt, quietEndAfter;

/// Хук звука голосом персонажа (prepareNotificationSound, core/voice). Возвращает имя файла
/// для iOS (Library/Sounds) или null — стандартный звук. Android — всегда стандартный.
typedef NotificationSoundHook = Future<String?> Function(String text, String lang, String name);

/// Шаблоны: утро и подбадривания по местному времени (как на сервере).
const _briefingMinute = 7 * 60 + 30;
const _cheerMinutes = [10 * 60 + 30, 14 * 60 + 30, 18 * 60 + 30];
const _cheerGap = Duration(minutes: 90);
const _horizon = Duration(hours: 24);
const _generateEvery = Duration(hours: 1);

class AiMessageSync with WidgetsBindingObserver {
  AiMessageSync({
    required AppDatabase db,
    required AiGateway gateway,
    required this._quests,
    required this._l10n,
    AiMessageScheduler? scheduler,
    this._push = const NoPushTokenSource(),
    this.sound,
    this.onForeground,
    this.observeLifecycle = true,
    DateTime Function()? clock,
  })  : _api = AiMessagesApi(gateway),
        _store = AiMessageStore(db),
        _prefs = ReminderPrefsRepository(db),
        _scheduler = scheduler ?? AiMessageScheduler(),
        _clock = clock ?? DateTime.now;

  final QuestService _quests;
  final Future<AppLocalizations> Function() _l10n;
  final AiMessagesApi _api;
  final AiMessageStore _store;
  final ReminderPrefsRepository _prefs;
  final AiMessageScheduler _scheduler;
  final PushTokenSource _push;
  final DateTime Function() _clock;
  final NotificationSoundHook? sound;

  /// Сообщение наступило, пока приложение на переднем плане (облачко персонажа).
  final void Function(AiMessage m)? onForeground;
  final bool observeLifecycle;

  final _subs = <StreamSubscription<Object?>>[];
  Future<void> _chain = Future.value();
  Timer? _fgTimer;
  bool _foreground = true;
  bool _started = false;
  bool _disposed = false;
  final _shown = <String>{};

  AiMessageStore get store => _store;

  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    if (observeLifecycle) WidgetsBinding.instance.addObserver(this);
    _subs
      ..add(_quests.outcomes.listen(_onOutcome, onError: _log))
      ..add(_push.onTokenRefresh.listen((t) => unawaited(_registerPush(t)), onError: _log));
    unawaited(_registerPush(null));
    await refresh();
  }

  Future<void> dispose() async {
    _disposed = true;
    if (observeLifecycle && _started) WidgetsBinding.instance.removeObserver(this);
    _fgTimer?.cancel();
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
  }

  /// Забрать пачку с сервера (best-effort) и перепланировать уведомления. Вызовы — по очереди.
  Future<void> refresh({bool pull = true}) => _chain = _chain.then((_) async {
        if (_disposed) return;
        try {
          if (pull) await _pull();
          await _plan();
        } catch (e, st) {
          _log(e, st);
        }
      });

  Future<void> _registerPush(String? token) async {
    try {
      await registerPushToken(_push, _api, _store, token: token);
    } catch (e) {
      _log(e); // не вошли / офлайн — повторим при следующем старте
    }
  }

  Future<void> _pull() async {
    final now = _clock();
    try {
      final last = await _store.lastGenerate();
      if (last == null || now.difference(last).abs() >= _generateEvery) {
        await _store.markGenerate(now);
        final l = await _l10n();
        await _api.generate(lang: l.localeName, tzOffsetMinutes: now.timeZoneOffset.inMinutes);
      }
    } on AiException catch (e) {
      _log(e); // нет ИИ/бюджета/сети — используем то, что есть
    }
    try {
      await _store.merge(await _api.fetch(now, hours: 24), now);
    } on AiException catch (e) {
      _log(e);
    }
  }

  /// Экземпляры, закрытые игроком (упрёк не нужен), — сегодня и завтра.
  Future<Set<String>> _closedInstances(DateTime now) async {
    final today = DateTime(now.year, now.month, now.day);
    final closed = <String>{};
    for (final day in [today.subtract(const Duration(days: 1)), today, today.add(const Duration(days: 1))]) {
      try {
        for (final q in await _quests.watchDay(day).first) {
          if (q.status == QuestStatus.done || q.status == QuestStatus.refused || q.status == QuestStatus.excused) {
            closed.add(q.instanceId);
          }
        }
      } catch (e) {
        _log(e);
      }
    }
    return closed;
  }

  Future<void> _plan() async {
    final now = _clock();
    final prefs = await _prefs.load();
    final l = await _l10n();
    if (!prefs.enabled) {
      await _scheduler.cancelAll();
      return;
    }
    final messages = await _store.load();
    final closed = await _closedInstances(now);
    final quiet = prefs.quiet;
    final plan = <AiPlanned>[];
    final ai = <AiMessage>[];

    for (final m in messages) {
      var at = m.deliverAt;
      if (!at.isAfter(now)) continue;
      if (m.kind == AiMessageKind.reproach) {
        if (!prefs.reproach || (m.questRef != null && closed.contains(m.questRef))) continue;
        if (quiet != null && isQuietAt(at, quiet)) at = quietEndAfter(at, quiet);
      } else if (quiet != null && isQuietAt(at, quiet)) {
        continue;
      }
      ai.add(m);
      plan.add(AiPlanned(
        key: m.id,
        at: at,
        title: m.title.isEmpty ? l.msgTplCheerTitle : m.title,
        body: m.body,
        questRef: m.questRef,
        sound: prefs.voiceSound && m.kind != AiMessageKind.cheer
            ? await _sound(m.body, l.localeName, '${m.kind}_${m.id}')
            : null,
      ));
    }

    // Шаблоны там, где у ИИ нет сообщений (запас кончился / ИИ недоступен).
    final end = now.add(_horizon);
    for (var d = 0; d <= 1; d++) {
      final day = DateTime(now.year, now.month, now.day + d);
      final dayKey = '${day.year}-${day.month}-${day.day}';
      final b = day.add(const Duration(minutes: _briefingMinute));
      if (b.isAfter(now) && b.isBefore(end) && !isQuietAt(b, quiet) &&
          !ai.any((m) => m.kind == AiMessageKind.briefing && _sameDay(m.deliverAt, day))) {
        final texts = [l.msgTplBriefing1, l.msgTplBriefing2, l.msgTplBriefing3];
        plan.add(AiPlanned(
          key: 'tpl:b:$dayKey',
          at: b,
          title: l.msgTplBriefingTitle,
          body: texts[fnv1a32('b$dayKey') % texts.length],
        ));
      }
      for (final (i, minute) in _cheerMinutes.indexed) {
        final at = day.add(Duration(minutes: minute));
        if (!at.isAfter(now) || !at.isBefore(end) || isQuietAt(at, quiet)) continue;
        if (ai.any((m) => m.kind == AiMessageKind.cheer && m.deliverAt.difference(at).abs() < _cheerGap)) continue;
        final texts = [l.msgTplCheer1, l.msgTplCheer2, l.msgTplCheer3, l.msgTplCheer4];
        plan.add(AiPlanned(
          key: 'tpl:c$i:$dayKey',
          at: at,
          title: l.msgTplCheerTitle,
          body: texts[fnv1a32('c$i$dayKey') % texts.length],
        ));
      }
    }
    plan.sort((a, b) => a.at.compareTo(b.at));
    await _scheduler.sync(plan, l);
    _armForeground(ai, now);
  }

  Future<String?> _sound(String text, String lang, String name) async {
    final hook = sound;
    if (hook == null || defaultTargetPlatform != TargetPlatform.iOS) return null;
    try {
      return await hook(text, lang, name);
    } catch (e) {
      _log(e);
      return null;
    }
  }

  static bool _sameDay(DateTime a, DateTime day) => a.year == day.year && a.month == day.month && a.day == day.day;

  /// Таймер до ближайшего сообщения ИИ — показать его в облачке, если приложение открыто.
  void _armForeground(List<AiMessage> ai, DateTime now) {
    _fgTimer?.cancel();
    final cb = onForeground;
    if (cb == null || _disposed) return;
    final next = ai.where((m) => m.deliverAt.isAfter(now) && !_shown.contains(m.id)).firstOrNull;
    if (next == null) return;
    _fgTimer = Timer(next.deliverAt.difference(now), () {
      if (_disposed) return;
      _shown.add(next.id);
      if (_foreground) cb(next);
      unawaited(refresh(pull: false));
    });
  }

  void _onOutcome(GameOutcome o) {
    final closed = switch (o) {
      QuestCompleted(:final quest) => quest.instanceId,
      QuestRefused(:final quest) => quest.instanceId,
      BossResult(:final quest) => quest.instanceId,
      _ => null,
    };
    if (closed != null) unawaited(_scheduler.cancelQuest(closed).catchError(_log));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _foreground = true;
        unawaited(refresh());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _foreground = false;
      case AppLifecycleState.inactive:
        break;
    }
  }

  static void _log(Object e, [StackTrace? st]) => debugPrint('AiMessageSync: $e${st == null ? '' : '\n$st'}');
}

/// Источник push-токена. Android FCM — переопределить реализацией на firebase_messaging (TODO, нужен
/// google-services.json от владельца).
final pushTokenSourceProvider = Provider<PushTokenSource>((ref) => const NoPushTokenSource());

/// Звук голосом персонажа (best-effort, только упрёки и брифинги, только iOS).
final notificationSoundHookProvider = Provider<NotificationSoundHook?>(
  (ref) => (text, lang, name) async =>
      (await ref.read(notificationSoundPreparerProvider)(text, lang, name: name))?.fileName,
);

/// Сервис для main: `unawaited(container.read(aiMessageSyncProvider).start())` после init уведомлений.
final aiMessageSyncProvider = Provider<AiMessageSync>((ref) {
  final db = ref.watch(databaseProvider);
  final s = AiMessageSync(
    db: db,
    gateway: ref.watch(aiGatewayProvider),
    quests: ref.watch(questServiceProvider),
    l10n: () => reminderL10n(db),
    push: ref.watch(pushTokenSourceProvider),
    sound: ref.watch(notificationSoundHookProvider),
    onForeground: (m) => ref.read(characterSayProvider).say(
          m.body,
          state: switch (m.kind) {
            AiMessageKind.reproach => CharacterState.angry,
            AiMessageKind.cheer => CharacterState.happy,
            _ => CharacterState.talk,
          },
        ),
  );
  ref.onDispose(s.dispose);
  return s;
});

/// Фон (BGAppRefresh / WorkManager): своя БД, вход из secure storage, без таймеров.
/// Вызывать в callbackDispatcher после runReminderBackground (плагин уведомлений уже инициализирован).
Future<void> runAiMessagesBackground() async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  final db = AppDatabase();
  final auth = HttpAuthService(deviceId: db.deviceId);
  try {
    final s = AiMessageSync(
      db: db,
      gateway: HttpAiGateway(auth),
      quests: await createQuestService(db),
      l10n: () => reminderL10n(db),
      observeLifecycle: false,
    );
    await s.refresh();
    await s.dispose();
  } finally {
    auth.dispose();
    await db.close();
  }
}

/// Для ReminderCoordinator: экземпляры с упрёком ИИ — шаблонный упрёк окна не ставить (без дубля).
Future<Set<String>> aiReproachedInstances(AppDatabase db) => AiMessageStore(db).reproachedInstances();

/// templateFilter для ReminderCoordinator: без шаблонного упрёка там, где упрекает ИИ.
Future<List<ReminderRequest>> Function(List<ReminderRequest>) aiReproachFilter(AppDatabase db) => (requests) async {
      final ai = await aiReproachedInstances(db);
      return ai.isEmpty ? requests : [for (final r in requests) withoutTemplateReproach(r, ai)];
    };

/// Убрать шаблонный упрёк из запроса окна, если на этот квест есть упрёк ИИ.
ReminderRequest withoutTemplateReproach(ReminderRequest r, Set<String> aiReproached) => aiReproached.contains(r.instanceId)
    ? ReminderRequest(
        instanceId: r.instanceId,
        title: r.title,
        body: r.body,
        dueAt: r.dueAt,
        deadlineAt: r.deadlineAt,
        nag: r.nag,
      )
    : r;
