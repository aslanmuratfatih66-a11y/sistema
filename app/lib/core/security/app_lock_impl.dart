// Реализация AppLock: Face ID / отпечаток (local_auth), PIN — солёный хэш (SHA-256 ×N) в flutter_secure_storage.
// Подключение в main: `appLockProvider.overrideWith((ref) => ref.watch(appLockImplProvider))` и AppLockGate.
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

import 'app_lock.dart';
import 'sha256.dart';

/// Хранилище ключей (в тестах — память).
abstract interface class LockStore {
  Future<String?> read(String key);
  Future<void> write(String key, String? value);
}

class SecureLockStore implements LockStore {
  const SecureLockStore([this._s = const FlutterSecureStorage()]);
  final FlutterSecureStorage _s;

  @override
  Future<String?> read(String key) async {
    try {
      return await _s.read(key: key);
    } catch (e) {
      debugPrint('AppLock: read $key: $e');
      return null;
    }
  }

  @override
  Future<void> write(String key, String? value) =>
      value == null ? _s.delete(key: key) : _s.write(key: key, value: value);
}

class AppLockImpl extends ChangeNotifier implements AppLock {
  AppLockImpl({this.store = const SecureLockStore(), LocalAuthentication? auth, DateTime Function()? clock})
      : _auth = auth ?? LocalAuthentication(),
        _clock = clock ?? DateTime.now;

  final LockStore store;
  final LocalAuthentication _auth;
  final DateTime Function() _clock;

  static const _kMode = 'applock.mode';
  static const _kPin = 'applock.pin';
  static const _kTimeout = 'applock.timeoutMin';
  static const _kFails = 'applock.fails';
  static const _iterations = 5000;

  /// Длина PIN.
  static const minPin = 4;
  static const maxPin = 8;

  /// После 5 ошибок подряд — пауза, растущая с каждой следующей ошибкой.
  static const freeAttempts = 5;

  AppLockMode? _mode;
  int? _timeout;

  @override
  Future<AppLockMode> mode() async {
    final cached = _mode;
    if (cached != null) return cached;
    final raw = await store.read(_kMode);
    return _mode = AppLockMode.values.firstWhere((m) => m.name == raw, orElse: () => AppLockMode.off);
  }

  bool get usesPin => _mode == AppLockMode.pin || _mode == AppLockMode.biometricOrPin;
  bool get usesBiometric => _mode == AppLockMode.biometric || _mode == AppLockMode.biometricOrPin;

  Future<bool> hasPin() async => (await store.read(_kPin)) != null;

  @override
  Future<void> setMode(AppLockMode mode, {String? pin}) async {
    final needsPin = mode == AppLockMode.pin || mode == AppLockMode.biometricOrPin;
    if (pin != null) {
      if (!validPin(pin)) throw ArgumentError.value(pin.length, 'pin', 'PIN: $minPin–$maxPin цифр');
      await store.write(_kPin, _hashNew(pin));
      await store.write(_kFails, null);
    } else if (needsPin && !await hasPin()) {
      throw ArgumentError('Для режима ${mode.name} нужен PIN');
    }
    if (mode == AppLockMode.off || mode == AppLockMode.biometric) await store.write(_kPin, null);
    await store.write(_kMode, mode.name);
    _mode = mode;
    notifyListeners();
  }

  static bool validPin(String pin) => pin.length >= minPin && pin.length <= maxPin && RegExp(r'^\d+$').hasMatch(pin);

  /// Через сколько минут в фоне снова спрашивать (0 — сразу).
  Future<int> timeoutMinutes() async => _timeout ??= int.tryParse(await store.read(_kTimeout) ?? '') ?? 1;

  Future<void> setTimeoutMinutes(int m) async {
    _timeout = m;
    await store.write(_kTimeout, '$m');
    notifyListeners();
  }

  /// Доступна ли биометрия (или код устройства как запасной вариант системы).
  Future<bool> biometricAvailable() async {
    if (kIsWeb) return false;
    try {
      return await _auth.isDeviceSupported() && (await _auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  bool _authInProgress = false;

  /// Идёт системный диалог биометрии (жизненный цикл приложения в это время не считается уходом в фон).
  bool get authInProgress => _authInProgress;

  /// Биометрия (с системным запасным вариантом — кодом устройства). PIN вводится в [AppLockGate] через [verifyPin].
  @override
  Future<bool> unlock({required String reason}) async {
    final m = await mode();
    if (m == AppLockMode.off) return true;
    if (m == AppLockMode.pin) return false;
    return authenticateBiometric(reason);
  }

  /// Системный диалог биометрии независимо от режима (проверка перед включением).
  Future<bool> authenticateBiometric(String reason) async {
    if (_authInProgress) return false;
    _authInProgress = true;
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } on LocalAuthException catch (e) {
      debugPrint('AppLock: ${e.code.name}');
      return false;
    } catch (e) {
      debugPrint('AppLock: $e');
      return false;
    } finally {
      _authInProgress = false;
    }
  }

  /// Сколько ждать до следующей попытки PIN (null — можно сейчас).
  Future<Duration?> pinCooldown() async {
    final f = _fails(await store.read(_kFails));
    if (f.count < freeAttempts) return null;
    final wait = Duration(seconds: 30 * (1 << min(6, f.count - freeAttempts)));
    final until = f.at.add(wait);
    final now = _clock();
    return until.isAfter(now) ? until.difference(now) : null;
  }

  /// Проверка PIN. true — верно (счётчик ошибок сбрасывается).
  Future<bool> verifyPin(String pin) async {
    if (await pinCooldown() != null) return false;
    final stored = await store.read(_kPin);
    if (stored == null) return false;
    final ok = _check(pin, stored);
    if (ok) {
      await store.write(_kFails, null);
    } else {
      final f = _fails(await store.read(_kFails));
      await store.write(_kFails, jsonEncode({'n': f.count + 1, 'at': _clock().toUtc().toIso8601String()}));
    }
    return ok;
  }

  ({int count, DateTime at}) _fails(String? raw) {
    if (raw == null) return (count: 0, at: _clock());
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return (count: (j['n'] as num).toInt(), at: DateTime.parse(j['at'] as String).toLocal());
    } catch (_) {
      return (count: 0, at: _clock());
    }
  }

  static String _derive(String pin, List<int> salt) {
    var h = sha256([...salt, ...utf8.encode(pin)]);
    for (var i = 1; i < _iterations; i++) {
      h = sha256([...h, ...salt]);
    }
    return hex(h);
  }

  static String _hashNew(String pin) {
    final r = Random.secure();
    final salt = [for (var i = 0; i < 16; i++) r.nextInt(256)];
    return 'v1:${base64Encode(salt)}:${_derive(pin, salt)}';
  }

  static bool _check(String pin, String stored) {
    final parts = stored.split(':');
    if (parts.length != 3 || parts[0] != 'v1') return false;
    final expect = _derive(pin, base64Decode(parts[1]));
    // Сравнение без раннего выхода.
    if (expect.length != parts[2].length) return false;
    var diff = 0;
    for (var i = 0; i < expect.length; i++) {
      diff |= expect.codeUnitAt(i) ^ parts[2].codeUnitAt(i);
    }
    return diff == 0;
  }
}

/// Реализация [AppLock] (main: `appLockProvider.overrideWith((ref) => ref.watch(appLockImplProvider))`).
final appLockImplProvider = Provider<AppLockImpl>((ref) {
  final lock = AppLockImpl();
  ref.onDispose(lock.dispose);
  return lock;
});
