// История чата (ChatMessages, синхронизируется) и запрос к ИИ (POST /api/v1/ai/chat).
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/db/database.dart';

/// Роли ChatMessages: 'system' — запись «Система изменила план: …» (actionIds = ["<id>"]).
abstract final class ChatRole {
  static const user = 'user';
  static const assistant = 'assistant';
  static const system = 'system';
}

class ChatAction {
  const ChatAction(this.id, this.summary);
  final String id;
  final String summary;
}

class ChatReply {
  const ChatReply(this.reply, this.actions);
  final String reply;
  final List<ChatAction> actions;
}

class ChatRepository {
  ChatRepository(this._db, this._gateway);

  final AppDatabase _db;
  final AiGateway _gateway;

  /// Сколько последних реплик уходит в запрос.
  static const contextSize = 20;

  Stream<List<ChatMessageRow>> watch({int limit = 300}) => (_db.select(_db.chatMessages)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
        ..limit(limit))
      .watch();

  Future<void> add(String role, String body, {bool viaVoice = false, List<String>? actionIds}) async {
    final now = DateTime.now().toUtc();
    await _db.into(_db.chatMessages).insert(ChatMessagesCompanion.insert(
          id: newId(),
          updatedAt: now,
          deviceId: await _db.deviceId(),
          role: role,
          body: body,
          createdAt: now,
          viaVoice: Value(viaVoice),
          actionIds: Value(actionIds == null || actionIds.isEmpty ? null : jsonEncode(actionIds)),
        ));
  }

  Future<List<ChatMessageRow>> _recent() async {
    final rows = await (_db.select(_db.chatMessages)
          ..where((t) => t.deletedAt.isNull() & t.role.isIn([ChatRole.user, ChatRole.assistant]))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(contextSize))
        .get();
    return rows.reversed.toList();
  }

  /// Отправляет последние [contextSize] реплик (включая только что сохранённую) и сохраняет ответ
  /// и действия ИИ. Ошибки — [AiException] (сообщение пользователя уже сохранено).
  Future<ChatReply> ask({required Map<String, Object?> character, required String lang}) async {
    final history = await _recent();
    final j = await _gateway.json('POST', '/api/v1/ai/chat', body: {
      'messages': [
        for (final m in history) {'role': m.role, 'text': m.body},
      ],
      'character': character,
      'lang': lang,
    });
    final reply = '${j['reply'] ?? ''}'.trim();
    final actions = [
      for (final a in (j['actions'] as List? ?? const []))
        if (a is Map) ChatAction('${a['id']}', '${a['summary'] ?? ''}'),
    ];
    if (reply.isNotEmpty) {
      await add(ChatRole.assistant, reply, actionIds: [for (final a in actions) a.id]);
    }
    for (final a in actions) {
      await add(ChatRole.system, a.summary, actionIds: [a.id]);
    }
    return ChatReply(reply, actions);
  }

  static String? actionIdOf(ChatMessageRow m) {
    final raw = m.actionIds;
    if (raw == null) return null;
    try {
      final v = jsonDecode(raw);
      return v is List && v.isNotEmpty ? '${v.first}' : null;
    } catch (_) {
      return null;
    }
  }
}

final chatRepositoryProvider =
    Provider<ChatRepository>((ref) => ChatRepository(ref.watch(databaseProvider), ref.watch(aiGatewayProvider)));

/// Сообщения чата, новые первыми.
final chatMessagesProvider = StreamProvider.autoDispose<List<ChatMessageRow>>(
  (ref) => ref.watch(chatRepositoryProvider).watch(),
);
