// Блокировка развлекательных приложений после отбоя в режиме дисциплины (SPEC §8.6) — ЭТАП 7.
// Реализации — app_blocker_impl.dart (Android/iOS), связка с режимом — app_blocker_sync.dart.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Блокировщик приложений. Android: Usage Access + оверлей/Accessibility; iOS: автоматизации «Команд»
/// с deep link `sistema://app/blocked?app=…`.
abstract interface class AppBlocker {
  /// Поддерживается ли блокировка на этом устройстве (и есть ли разрешения).
  Future<bool> isAvailable();

  /// Включить блокировку списка приложений с [from] до [until] (после отбоя до подъёма).
  Future<void> blockFrom(DateTime from, DateTime until, {List<String> appIds = const []});

  /// Снять блокировку (режим выключен).
  Future<void> unblock();
}

/// Заглушка: ничего не блокирует.
class NoopAppBlocker implements AppBlocker {
  const NoopAppBlocker();

  // Платформы без блокировки и тесты. В main переопределяется createPlatformAppBlocker(db).
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> blockFrom(DateTime from, DateTime until, {List<String> appIds = const []}) async {}

  @override
  Future<void> unblock() async {}
}

final appBlockerProvider = Provider<AppBlocker>((ref) => const NoopAppBlocker());
