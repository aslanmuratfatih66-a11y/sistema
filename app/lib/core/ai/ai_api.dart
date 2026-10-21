// ИИ через сервер (SPEC §9.1: ключи только на сервере). КОНТРАКТ каркаса этапа 6 (правит главный агент).
// Шлюз — тонкая обёртка над авторизованными запросами; типизированные клиенты пишут фичи (чат, фото, знания).
// Эндпоинты сервера — server/api/openapi.yaml (/api/v1/ai, /vision, /messages, /learning).
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../sync/http_auth_service.dart';
import '../sync/sync_api.dart';
import '../sync/sync_providers.dart';

/// Почему ИИ недоступен — UI показывает понятное сообщение и офлайн-запасной вариант (шаблоны).
enum AiFailure { notSignedIn, offline, budget, unavailable, rateLimited, server }

class AiException implements Exception {
  const AiException(this.failure, [this.code]);

  final AiFailure failure;
  final String? code;

  @override
  String toString() => 'AiException($failure, $code)';
}

abstract interface class AiGateway {
  /// JSON-запрос → JSON-объект ответа. Ошибки — [AiException].
  Future<Map<String, dynamic>> json(String method, String path, {Object? body, Map<String, String>? query});

  /// Запрос с бинарным ответом (аудио TTS). [body] — JSON.
  Future<List<int>> bytes(String method, String path, {Object? body});
}

/// По умолчанию — «не вошли» (тесты, предпросмотр). В main — [httpAiGatewayOverride].
final aiGatewayProvider = Provider<AiGateway>((ref) => const _NoAiGateway());

class _NoAiGateway implements AiGateway {
  const _NoAiGateway();

  @override
  Future<Map<String, dynamic>> json(String method, String path, {Object? body, Map<String, String>? query}) =>
      Future.error(const AiException(AiFailure.notSignedIn));

  @override
  Future<List<int>> bytes(String method, String path, {Object? body}) =>
      Future.error(const AiException(AiFailure.notSignedIn));
}

/// Реализация поверх [HttpAuthService.authorized].
class HttpAiGateway implements AiGateway {
  HttpAiGateway(this._auth);

  final HttpAuthService _auth;

  Future<List<int>> _send(String method, String path, {Object? body, Map<String, String>? query}) async {
    try {
      final r = await _auth.authorized(method, path, query: query, json: body);
      if (r.statusCode >= 200 && r.statusCode < 300) return r.bodyBytes;
      String? code;
      try {
        code = (jsonDecode(r.body) as Map<String, dynamic>)['error'] as String?;
      } catch (_) {}
      throw AiException(
        switch (r.statusCode) {
          402 => AiFailure.budget,
          503 => AiFailure.unavailable,
          429 => AiFailure.rateLimited,
          _ => AiFailure.server,
        },
        code,
      );
    } on OfflineException {
      throw const AiException(AiFailure.offline);
    } on AuthException {
      throw const AiException(AiFailure.notSignedIn);
    }
  }

  @override
  Future<Map<String, dynamic>> json(String method, String path, {Object? body, Map<String, String>? query}) async {
    final b = await _send(method, path, body: body, query: query);
    if (b.isEmpty) return const {};
    return jsonDecode(utf8.decode(b)) as Map<String, dynamic>;
  }

  @override
  Future<List<int>> bytes(String method, String path, {Object? body}) => _send(method, path, body: body);
}

/// Переопределение для main.
final httpAiGatewayOverride = aiGatewayProvider.overrideWith((ref) => HttpAiGateway(ref.watch(httpAuthServiceProvider)));
