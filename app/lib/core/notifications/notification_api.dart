// КОНТРАКТ каркаса этапа 2: напоминания (SPEC §7). Правит главный агент.
// Реализует сабагент B (app/lib/core/notifications/ + экран настроек в app/lib/features/reminders/).
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Идентификатор фоновой задачи (BGAppRefresh / WorkManager). Совпадает с Info.plist и AppDelegate.swift.
const backgroundRefreshTaskId = 'com.sistema.sistema.refresh';

/// Тихие часы: [startMinute]..[endMinute] (минуты суток, может переходить через полночь).
@immutable
class QuietHours {
  const QuietHours({required this.startMinute, required this.endMinute});
  final int startMinute;
  final int endMinute;
}

/// Настройки напоминаний. Хранятся в UserSettings (id = 'notifications'), JSON.
@immutable
class ReminderPrefs {
  const ReminderPrefs({
    this.enabled = true,
    this.nag = true,
    this.quiet,
    this.reproach = true,
    this.voiceSound = false,
  });

  final bool enabled;

  /// «Надоедать»: повтор каждую минуту до выполнения.
  final bool nag;
  final QuietHours? quiet;

  /// Упрёк на дедлайн+15 мин (SPEC §7).
  final bool reproach;

  /// Звук — голос персонажа (файл ≤30 с; генерация — этап 6, сейчас только флаг и TODO).
  final bool voiceSound;
}

/// Что напомнить: тексты уже локализованы вызывающей стороной.
@immutable
class ReminderRequest {
  const ReminderRequest({
    required this.instanceId,
    required this.title,
    required this.body,
    required this.dueAt,
    required this.deadlineAt,
    this.nag = true,
    this.reproachTitle,
    this.reproachBody,
  });

  final String instanceId;
  final String title;
  final String body;

  /// Первое напоминание (начало квеста или конец «+10 мин»).
  final DateTime dueAt;
  final DateTime deadlineAt;
  final bool nag;

  /// Упрёк на deadlineAt + 15 мин; null — без упрёка.
  final String? reproachTitle;
  final String? reproachBody;
}

/// Кнопки в уведомлении.
enum ReminderAction { done, snooze10, open }

@immutable
class ReminderResponse {
  const ReminderResponse({required this.instanceId, required this.action});
  final String instanceId;
  final ReminderAction action;
}

/// Планировщик локальных уведомлений. iOS держит максимум 64 запланированных — реализация
/// держит ближайшее окно и перепланирует при каждом вызове [sync].
abstract interface class ReminderScheduler {
  /// Инициализация плагина, категорий кнопок (Выполнено / +10 мин), часового пояса.
  /// [onResponse] вызывается при нажатии на уведомление/кнопку, в т.ч. из фонового isolate.
  Future<void> init({required Future<void> Function(ReminderResponse) onResponse});

  Future<bool> requestPermission();

  /// Полное перепланирование окна по списку незакрытых квестов.
  Future<void> sync(List<ReminderRequest> upcoming, ReminderPrefs prefs, {required DateTime now});

  /// Квест закрыт — снять его напоминания и упрёк.
  Future<void> cancelInstance(String instanceId);

  /// Немедленное уведомление (системное окно вне приложения: провал, штраф, уровень).
  Future<void> showNow({required String title, required String body});
}

final reminderSchedulerProvider = Provider<ReminderScheduler>(
  (ref) => throw UnimplementedError('reminderSchedulerProvider: переопределите реализацией'),
);
