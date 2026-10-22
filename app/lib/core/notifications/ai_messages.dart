// Сообщения ИИ наперёд (SPEC §9.5): модель, клиент сервера, локальный кэш пачки, push-токены.
// Оркестрация — ai_messages_sync.dart, локальные уведомления — ai_messages_scheduler.dart.
import 'dart:convert';

import '../ai/ai_api.dart';
import '../db/database.dart';

/// Виды сообщений (как в таблице messages сервера).
abstract final class AiMessageKind {
  static const briefing = 'briefing';
  static const cheer = 'cheer';
  static const reproach = 'reproach';
  static const reminder = 'reminder';
}

class AiMessage {
  const AiMessage({
    required this.id,
    required this.kind,
    required this.deliverAt,
    required this.title,
    required this.body,
    this.questRef,
    this.hasAudio = false,
  });

  final String id;
  final String kind;
  final DateTime deliverAt;

  /// id экземпляра квеста (упрёк за пропуск).
  final String? questRef;
  final String title;
  final String body;
  final bool hasAudio;

  static AiMessage? fromJson(Object? j) {
    if (j is! Map) return null;
    final id = j['id'], kind = j['kind'], at = j['deliver_at'], body = j['body'];
    if (id is! String || kind is! String || at is! int || body is! String) return null;
    final ref = j['quest_ref'];
    final title = j['title'];
    return AiMessage(
      id: id,
      kind: kind,
      deliverAt: DateTime.fromMillisecondsSinceEpoch(at),
      questRef: ref is String && ref.isNotEmpty ? ref : null,
      title: title is String ? title : '',
      body: body,
      hasAudio: j['has_audio'] == true,
    );
  }

  Map<String, Object?> toJson() => {
        'id': id,
        'kind': kind,
        'deliver_at': deliverAt.millisecondsSinceEpoch,
        'quest_ref': questRef,
        'title': title,
        'body': body,
        'has_audio': hasAudio,
      };
}

/// Эндпоинты сервера: GET /api/v1/messages, POST /api/v1/messages/generate, POST /api/v1/push/register.
class AiMessagesApi {
  const AiMessagesApi(this._gw);

  final AiGateway _gw;

  /// Сгенерировать недостающие сообщения (сервер сам ограничивает: раз в час). Возвращает число новых.
  Future<int> generate({String? lang, int? tzOffsetMinutes}) async {
    final r = await _gw.json('POST', '/api/v1/messages/generate', body: {
      'lang': ?lang,
      'tz_offset': ?tzOffsetMinutes,
    });
    final n = r['generated'];
    return n is int ? n : 0;
  }

  Future<List<AiMessage>> fetch(DateTime from, {int hours = 24}) async {
    final r = await _gw.json('GET', '/api/v1/messages', query: {
      'from': '${from.millisecondsSinceEpoch}',
      'hours': '$hours',
    });
    final list = r['messages'];
    if (list is! List) return const [];
    return [for (final m in list) ?AiMessage.fromJson(m)];
  }

  /// platform: android | ios | ntfy (для ntfy token = topic).
  Future<void> registerPush(String platform, String token) =>
      _gw.json('POST', '/api/v1/push/register', body: {'platform': platform, 'token': token});
}

/// Локальный кэш пачки (AppSettings): работает офлайн и в фоновом isolate.
class AiMessageStore {
  AiMessageStore(this._db);

  final AppDatabase _db;
  static const _kCache = 'ai_messages.cache';
  static const _kGenerated = 'ai_messages.generate_at';
  static const _kPushToken = 'ai_messages.push_token';

  Future<List<AiMessage>> load() async {
    try {
      final raw = await _db.getSetting(_kCache);
      if (raw == null) return const [];
      final list = jsonDecode(raw);
      if (list is! List) return const [];
      return [for (final m in list) ?AiMessage.fromJson(m)];
    } catch (_) {
      return const [];
    }
  }

  /// Слить новые с кэшем (по id), выбросить прошедшие более часа назад.
  Future<List<AiMessage>> merge(List<AiMessage> fresh, DateTime now) async {
    final byId = {for (final m in await load()) m.id: m};
    for (final m in fresh) {
      byId[m.id] = m;
    }
    final keep = byId.values.where((m) => m.deliverAt.isAfter(now.subtract(const Duration(hours: 1)))).toList()
      ..sort((a, b) => a.deliverAt.compareTo(b.deliverAt));
    await _db.setSetting(_kCache, jsonEncode([for (final m in keep.take(200)) m.toJson()]));
    return keep;
  }

  /// id экземпляров, на которые есть упрёк ИИ (чтобы координатор не ставил шаблонный дубль).
  Future<Set<String>> reproachedInstances() async =>
      {for (final m in await load()) if (m.kind == AiMessageKind.reproach && m.questRef != null) m.questRef!};

  Future<DateTime?> lastGenerate() async => DateTime.tryParse(await _db.getSetting(_kGenerated) ?? '');
  Future<void> markGenerate(DateTime at) => _db.setSetting(_kGenerated, at.toIso8601String());

  Future<String?> lastPushToken() => _db.getSetting(_kPushToken);
  Future<void> savePushToken(String key) => _db.setSetting(_kPushToken, key);
}

/// Источник push-токена (Android FCM). Реализация с firebase_messaging подключается, когда владелец
/// положит google-services.json (см. отчёт этапа 6); до этого — [NoPushTokenSource].
abstract interface class PushTokenSource {
  /// 'android' | 'ios' | 'ntfy'.
  String get platform;

  /// Текущий токен; null — push недоступен.
  Future<String?> token();

  /// Обновления токена (FCM onTokenRefresh).
  Stream<String> get onTokenRefresh;
}

class NoPushTokenSource implements PushTokenSource {
  const NoPushTokenSource();

  @override
  String get platform => 'android';

  @override
  Future<String?> token() async => null;

  @override
  Stream<String> get onTokenRefresh => const Stream.empty();
}

/// Регистрирует токен на сервере, если он новый (best-effort).
Future<void> registerPushToken(PushTokenSource src, AiMessagesApi api, AiMessageStore store, {String? token}) async {
  final t = token ?? await src.token();
  if (t == null || t.isEmpty) return;
  final key = '${src.platform}|$t';
  if (await store.lastPushToken() == key) return;
  await api.registerPush(src.platform, t);
  await store.savePushToken(key);
}
