// Вход на сервер «Системы» (SPEC §10): JWT access + refresh, токены — в Keychain/Keystore.
// Авто-refresh: перед запросом, если access истёк, и при 401 — один общий запрос refresh на всех.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'sync_api.dart';

/// Сетевая ошибка (нет связи/таймаут) — для индикатора «офлайн».
class OfflineException implements Exception {
  const OfflineException(this.cause);
  final Object cause;
  @override
  String toString() => 'OfflineException($cause)';
}

/// Имя не подходит (3–32: буквы, цифры, _ - .). В контракте — AuthError.server, UI различает по типу.
class InvalidNameException extends AuthException {
  const InvalidNameException() : super(AuthError.server);
}

/// TOTP уже включена (409 на totp/setup).
class TotpAlreadyEnabledException extends AuthException {
  const TotpAlreadyEnabledException() : super(AuthError.server);
}

/// Ответ сервера с неожиданным кодом.
class ApiException implements Exception {
  const ApiException(this.status, [this.code]);
  final int status;
  final String? code;
  @override
  String toString() => 'ApiException($status, $code)';
}

class HttpAuthService implements AuthService {
  HttpAuthService({
    required this.deviceId,
    FlutterSecureStorage? storage,
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
  })  : _storage = storage ?? const FlutterSecureStorage(),
        _client = client ?? http.Client() {
    ready = _load();
  }

  static const _kAccount = 'sistema.account';
  static const _kAccess = 'sistema.access';
  static const _kAccessExp = 'sistema.access_exp';
  static const _kRefresh = 'sistema.refresh';
  static const _kServer = 'sistema.server';

  /// ID устройства (db.deviceId).
  final Future<String> Function() deviceId;
  final FlutterSecureStorage _storage;
  final http.Client _client;
  final Duration timeout;

  late final Future<void> ready;
  final _ctl = StreamController<Account?>.broadcast();
  Account? _current;
  String? _access;
  DateTime? _accessExp;
  String? _refresh;
  String? _lastServerUrl;
  Future<bool>? _refreshing;

  /// Последний адрес сервера (для формы входа), иначе — из сборки.
  String get lastServerUrl => _lastServerUrl ?? defaultServerUrl;

  @override
  Account? get current => _current;

  @override
  Stream<Account?> watch() async* {
    await ready;
    yield _current;
    yield* _ctl.stream;
  }

  Future<void> _load() async {
    try {
      _lastServerUrl = await _storage.read(key: _kServer);
      final raw = await _storage.read(key: _kAccount);
      _refresh = await _storage.read(key: _kRefresh);
      _access = await _storage.read(key: _kAccess);
      _accessExp = DateTime.tryParse(await _storage.read(key: _kAccessExp) ?? '');
      if (raw != null && _refresh != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _current = Account(
          userId: m['userId'] as String,
          name: m['name'] as String,
          serverUrl: m['serverUrl'] as String,
          totpEnabled: m['totpEnabled'] as bool? ?? false,
        );
      }
    } catch (_) {
      _current = null; // повреждённое хранилище — просто не вошли
    }
  }

  void _emit(Account? a) {
    _current = a;
    _ctl.add(a);
  }

  static String _normalize(String url) {
    var u = url.trim();
    while (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    if (u.isNotEmpty && !u.contains('://')) u = 'https://$u';
    return u;
  }

  // ---------- HTTP ----------

  Future<http.Response> _send(String method, Uri uri,
      {Map<String, String>? headers, Object? json, List<int>? bytes}) async {
    final req = http.Request(method, uri);
    if (headers != null) req.headers.addAll(headers);
    if (json != null) {
      req.headers['Content-Type'] = 'application/json';
      req.body = jsonEncode(json);
    } else if (bytes != null) {
      req.bodyBytes = bytes;
    }
    try {
      final streamed = await _client.send(req).timeout(timeout);
      return await http.Response.fromStream(streamed).timeout(timeout);
    } on TimeoutException catch (e) {
      throw OfflineException(e);
    } on http.ClientException catch (e) {
      throw OfflineException(e);
    }
  }

  static String? _errorCode(http.Response r) {
    try {
      final m = jsonDecode(r.body);
      if (m is Map && m['error'] is String) return m['error'] as String;
    } catch (_) {}
    return null;
  }

  static AuthException _authError(http.Response r) {
    final code = _errorCode(r);
    switch (code) {
      case 'totp_required':
        return const AuthException(AuthError.totpRequired);
      case 'invalid_totp':
        return const AuthException(AuthError.invalidTotp);
      case 'invalid_credentials':
        return const AuthException(AuthError.invalidCredentials);
      case 'name_taken':
        return const AuthException(AuthError.nameTaken);
      case 'weak_password' || 'invalid_password':
        return const AuthException(AuthError.weakPassword);
      case 'invalid_name':
        return const InvalidNameException();
      case 'totp_already_enabled':
        return const TotpAlreadyEnabledException();
    }
    if (r.statusCode == 429) {
      final s = int.tryParse(r.headers['retry-after'] ?? '');
      return AuthException(AuthError.rateLimited, s == null ? null : Duration(seconds: s));
    }
    if (r.statusCode == 401) return const AuthException(AuthError.invalidCredentials);
    if (r.statusCode == 409) return const AuthException(AuthError.nameTaken);
    return const AuthException(AuthError.server);
  }

  Future<Map<String, dynamic>> _publicPost(String serverUrl, String path, Map<String, Object?> body) async {
    final http.Response r;
    try {
      r = await _send('POST', Uri.parse('$serverUrl$path'), json: body);
    } on OfflineException {
      throw const AuthException(AuthError.network);
    } on FormatException {
      throw const AuthException(AuthError.network);
    }
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return r.body.isEmpty ? const {} : jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw _authError(r);
  }

  Future<Account> _applyTokens(String serverUrl, Map<String, dynamic> m) async {
    final user = m['user'] as Map<String, dynamic>;
    final account = Account(
      userId: '${user['id']}',
      name: user['name'] as String,
      serverUrl: serverUrl,
      totpEnabled: user['totp_enabled'] as bool? ?? false,
    );
    await _saveTokens(m);
    await _saveAccount(account);
    _lastServerUrl = serverUrl;
    await _storage.write(key: _kServer, value: serverUrl);
    _emit(account);
    return account;
  }

  Future<void> _saveTokens(Map<String, dynamic> m) async {
    _access = m['access_token'] as String;
    _refresh = m['refresh_token'] as String? ?? _refresh;
    final exp = (m['access_expires_in'] as num?)?.toInt() ?? 900;
    // Запас 30 с, чтобы не отправлять почти истёкший токен.
    _accessExp = DateTime.now().add(Duration(seconds: exp > 60 ? exp - 30 : exp));
    await _storage.write(key: _kAccess, value: _access);
    await _storage.write(key: _kAccessExp, value: _accessExp!.toIso8601String());
    if (_refresh != null) await _storage.write(key: _kRefresh, value: _refresh);
  }

  Future<void> _saveAccount(Account a) => _storage.write(
        key: _kAccount,
        value: jsonEncode({'userId': a.userId, 'name': a.name, 'serverUrl': a.serverUrl, 'totpEnabled': a.totpEnabled}),
      );

  Future<void> _clearSession() async {
    _access = null;
    _accessExp = null;
    _refresh = null;
    for (final k in [_kAccess, _kAccessExp, _kRefresh, _kAccount]) {
      await _storage.delete(key: k);
    }
    _emit(null);
  }

  /// Обновить пару токенов (один запрос на всех ожидающих). false — refresh отклонён, сессия сброшена.
  Future<bool> _refreshTokens() {
    final a = _current;
    final rt = _refresh;
    if (a == null || rt == null) return Future.value(false);
    return _refreshing ??= () async {
      try {
        await Future<void>.value(); // finally — только после присваивания _refreshing
        final r = await _send('POST', Uri.parse('${a.serverUrl}/api/v1/auth/refresh'), json: {'refresh_token': rt});
        if (r.statusCode >= 200 && r.statusCode < 300) {
          final m = jsonDecode(r.body) as Map<String, dynamic>;
          await _saveTokens(m);
          final u = m['user'];
          if (u is Map && u['totp_enabled'] is bool && u['totp_enabled'] != a.totpEnabled) {
            final upd = Account(userId: a.userId, name: a.name, serverUrl: a.serverUrl, totpEnabled: u['totp_enabled'] as bool);
            await _saveAccount(upd);
            _emit(upd);
          }
          return true;
        }
        if (r.statusCode == 401 || r.statusCode == 403) {
          await _clearSession();
          return false;
        }
        throw ApiException(r.statusCode, _errorCode(r));
      } finally {
        _refreshing = null;
      }
    }();
  }

  /// Запрос с Bearer-токеном и авто-refresh. Без аккаунта — AuthException(invalidCredentials).
  /// Сетевые сбои — [OfflineException].
  Future<http.Response> authorized(String method, String path,
      {Map<String, String>? query, Object? json, List<int>? bytes, String? contentType}) async {
    await ready;
    final a = _current;
    if (a == null) throw const AuthException(AuthError.invalidCredentials);
    var uri = Uri.parse('${a.serverUrl}$path');
    if (query != null) uri = uri.replace(queryParameters: query);
    final exp = _accessExp;
    if (_access == null || exp == null || DateTime.now().isAfter(exp)) {
      if (!await _refreshTokens()) throw const AuthException(AuthError.invalidCredentials);
    }
    Future<http.Response> go() => _send(method, uri, json: json, bytes: bytes, headers: {
          'Authorization': 'Bearer $_access',
          'Content-Type': ?contentType,
        });
    var r = await go();
    if (r.statusCode == 401) {
      if (!await _refreshTokens()) throw const AuthException(AuthError.invalidCredentials);
      r = await go();
      if (r.statusCode == 401) {
        await _clearSession();
        throw const AuthException(AuthError.invalidCredentials);
      }
    }
    return r;
  }

  Future<Map<String, dynamic>> _authorizedJson(String method, String path, [Object? body]) async {
    final http.Response r;
    try {
      r = await authorized(method, path, json: body);
    } on OfflineException {
      throw const AuthException(AuthError.network);
    } on ApiException {
      throw const AuthException(AuthError.server);
    }
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return r.body.isEmpty ? const {} : jsonDecode(r.body) as Map<String, dynamic>;
    }
    throw _authError(r);
  }

  // ---------- AuthService ----------

  @override
  Future<Account> register({required String serverUrl, required String name, required String password}) async {
    final url = _normalize(serverUrl);
    final m = await _publicPost(url, '/api/v1/auth/register',
        {'name': name.trim(), 'password': password, 'device_id': await deviceId()});
    return _applyTokens(url, m);
  }

  @override
  Future<Account> login({required String serverUrl, required String name, required String password, String? totp}) async {
    final url = _normalize(serverUrl);
    final m = await _publicPost(url, '/api/v1/auth/login', {
      'name': name.trim(),
      'password': password,
      if (totp != null && totp.trim().isNotEmpty) 'totp': totp.trim(),
      'device_id': await deviceId(),
    });
    return _applyTokens(url, m);
  }

  @override
  Future<void> logout() async {
    if (_current != null) {
      try {
        await authorized('POST', '/api/v1/auth/logout');
      } catch (_) {
        // best-effort: локально выходим в любом случае
      }
    }
    await _clearSession();
  }

  @override
  Future<TotpSetup> beginTotp() async {
    final Map<String, dynamic> m;
    try {
      m = await _authorizedJson('POST', '/api/v1/auth/totp/setup');
    } on TotpAlreadyEnabledException {
      await _markTotpEnabled();
      rethrow;
    }
    return TotpSetup(secret: m['secret'] as String, uri: m['uri'] as String);
  }

  @override
  Future<void> confirmTotp(String code) async {
    await _authorizedJson('POST', '/api/v1/auth/totp/confirm', {'code': code.trim()});
    await _markTotpEnabled();
  }

  Future<void> _markTotpEnabled() async {
    final a = _current;
    if (a != null) {
      final upd = Account(userId: a.userId, name: a.name, serverUrl: a.serverUrl, totpEnabled: true);
      await _saveAccount(upd);
      _emit(upd);
    }
  }

  @override
  Future<void> resetPassword(
      {required String serverUrl, required String name, required String totp, required String newPassword}) async {
    await _publicPost(_normalize(serverUrl), '/api/v1/auth/reset',
        {'name': name.trim(), 'totp': totp.trim(), 'new_password': newPassword});
  }

  void dispose() {
    _ctl.close();
    _client.close();
  }
}
