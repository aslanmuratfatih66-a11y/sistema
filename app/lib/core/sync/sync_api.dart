// Сервер: вход и синхронизация (SPEC §10). КОНТРАКТ каркаса этапа 5 (правит главный агент).
// Реализация — сабагент E (core/sync, features/auth). API сервера — server/api/openapi.yaml.
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Адрес сервера по умолчанию из сборки (--dart-define=SISTEMA_SERVER_URL=https://…); пользователь может сменить.
const defaultServerUrl = String.fromEnvironment('SISTEMA_SERVER_URL');

/// Вошедший пользователь.
@immutable
class Account {
  const Account({required this.userId, required this.name, required this.serverUrl, this.totpEnabled = false});

  final String userId;
  final String name;
  final String serverUrl;
  final bool totpEnabled;
}

/// Настройка TOTP: секрет и otpauth:// URI для QR.
@immutable
class TotpSetup {
  const TotpSetup({required this.secret, required this.uri});

  final String secret;
  final String uri;
}

/// Ошибки входа для UI.
enum AuthError { network, invalidCredentials, totpRequired, invalidTotp, nameTaken, weakPassword, rateLimited, server }

class AuthException implements Exception {
  const AuthException(this.error, [this.retryAfter]);

  final AuthError error;
  final Duration? retryAfter;

  @override
  String toString() => 'AuthException($error)';
}

abstract interface class AuthService {
  /// Текущий аккаунт (null — не вошли). Токены — в Keychain/Keystore (flutter_secure_storage).
  Stream<Account?> watch();
  Account? get current;

  Future<Account> register({required String serverUrl, required String name, required String password});
  Future<Account> login({required String serverUrl, required String name, required String password, String? totp});
  Future<void> logout();

  /// Шаг 1 настройки TOTP: получить секрет/URI; шаг 2 — подтвердить кодом.
  Future<TotpSetup> beginTotp();
  Future<void> confirmTotp(String code);

  /// Сброс пароля по TOTP-коду (без входа).
  Future<void> resetPassword({required String serverUrl, required String name, required String totp, required String newPassword});
}

/// Состояние синхронизации для индикатора.
enum SyncPhase { off, idle, syncing, offline, error }

@immutable
class SyncStatus {
  const SyncStatus({required this.phase, this.lastSyncAt, this.pending = 0, this.message});

  static const off = SyncStatus(phase: SyncPhase.off);

  final SyncPhase phase;
  final DateTime? lastSyncAt;

  /// Локальных изменений, ещё не отправленных на сервер.
  final int pending;
  final String? message;
}

abstract interface class SyncService {
  Stream<SyncStatus> watch();

  /// Push изменений → pull с курсора. Без аккаунта — ничего.
  Future<void> syncNow();

  /// Периодическая синхронизация и по возврату приложения.
  void start();
  void dispose();
}

/// Переопределяются в main реализацией E. По умолчанию — офлайн без аккаунта (тесты, предпросмотр).
final authServiceProvider = Provider<AuthService>((ref) => const NoAuthService());
final syncServiceProvider = Provider<SyncService>((ref) => const NoSyncService());

final accountProvider = StreamProvider<Account?>((ref) => ref.watch(authServiceProvider).watch());
final syncStatusProvider = StreamProvider<SyncStatus>((ref) => ref.watch(syncServiceProvider).watch());

class NoAuthService implements AuthService {
  const NoAuthService();

  @override
  Stream<Account?> watch() => Stream.value(null);
  @override
  Account? get current => null;
  @override
  Future<Account> register({required String serverUrl, required String name, required String password}) =>
      Future.error(const AuthException(AuthError.network));
  @override
  Future<Account> login({required String serverUrl, required String name, required String password, String? totp}) =>
      Future.error(const AuthException(AuthError.network));
  @override
  Future<void> logout() async {}
  @override
  Future<TotpSetup> beginTotp() => Future.error(const AuthException(AuthError.network));
  @override
  Future<void> confirmTotp(String code) => Future.error(const AuthException(AuthError.network));
  @override
  Future<void> resetPassword({required String serverUrl, required String name, required String totp, required String newPassword}) =>
      Future.error(const AuthException(AuthError.network));
}

class NoSyncService implements SyncService {
  const NoSyncService();

  @override
  Stream<SyncStatus> watch() => Stream.value(SyncStatus.off);
  @override
  Future<void> syncNow() async {}
  @override
  void start() {}
  @override
  void dispose() {}
}
