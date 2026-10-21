// Блокировка развлекательных приложений после отбоя в режиме дисциплины (SPEC §8.6) — ЭТАП 7.
// Сейчас только интерфейс и заглушка.
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Блокировщик приложений. Android: Usage Access + оверлей/Accessibility; iOS: автоматизации «Команд»
/// с deep link `sistema://blocked?app=…`.
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

  // TODO(этап 7): Android — UsageStats + оверлей «Система: отбой»; iOS — мастер автоматизаций «Команд».
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> blockFrom(DateTime from, DateTime until, {List<String> appIds = const []}) async {}

  @override
  Future<void> unblock() async {}
}

final appBlockerProvider = Provider<AppBlocker>((ref) => const NoopAppBlocker());
