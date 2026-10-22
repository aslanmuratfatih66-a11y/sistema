// Вход в приложение по Face ID / отпечатку / PIN (SPEC §8.7) — КОНТРАКТ каркаса этапа 7.
// Реализация (local_auth + PIN в secure storage, экран блокировки) — сабагент A. Подключение: main оборачивает
// приложение в [AppLockGate] из реализации.
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppLockMode { off, biometric, pin, biometricOrPin }

abstract interface class AppLock {
  Future<AppLockMode> mode();
  Future<void> setMode(AppLockMode mode, {String? pin});

  /// Запросить разблокировку (биометрия, при неудаче — PIN). true — открыто.
  Future<bool> unlock({required String reason});
}

final appLockProvider = Provider<AppLock>((ref) => throw UnimplementedError('appLockProvider (A)'));
