// Заготовки будущих источников для уведомлений (только интерфейсы, реализация — этапы 5–6).
import 'notification_api.dart';

/// Звук уведомления голосом персонажа (SPEC §7): файл ≤30 с, на iOS — в Library/Sounds.
abstract interface class ReminderSoundSource {
  /// Имя звукового файла для уведомления квеста; null — стандартный звук.
  String? soundFor(String instanceId);
}

/// Пока голоса нет — стандартный звук. TODO(этап 6): генерация аудио персонажа.
class NoVoiceSound implements ReminderSoundSource {
  const NoVoiceSound();

  @override
  String? soundFor(String instanceId) => null;
}

/// Пачка сообщений ИИ на ближайшие часы с сервера (SPEC §9.5) — ставятся локальными уведомлениями.
abstract interface class ServerReminderSource {
  /// TODO(этапы 5–6): брифинги, подбадривания, заранее написанные упрёки, аудио.
  Future<List<ReminderRequest>> fetchBatch(DateTime now, Duration horizon);
}
