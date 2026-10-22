// Провайдеры голоса персонажа (этап 6). Переопределения для main — см. комментарий у каждого.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../ai/ai_api.dart';
import '../data/questionnaire_repository.dart';
import '../models/enums.dart';
import 'notification_sound.dart';
import 'server_tts_service.dart';
import 'speech_input.dart';
import 'tts_service.dart';

/// Ключ раздела анкеты `character` (синхронизируется): id голоса сервера. Нет ключа — системный голос.
/// Рядом лежит `voice` — id системного профиля (тембр/скорость для фолбэка).
const serverVoiceKey = 'serverVoice';

/// Выбранный голос сервера (null — не выбран).
final serverVoiceIdProvider = Provider<String?>((ref) {
  final v = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value?[serverVoiceKey];
  return v is String && v.isNotEmpty ? v : null;
});

Future<void> setServerVoice(QuestionnaireRepository repo, String? voiceId) =>
    repo.patch(QuestionnaireSection.character, {serverVoiceKey: voiceId});

final serverTtsApiProvider = Provider<ServerTtsApi>((ref) => ServerTtsApi(ref.watch(aiGatewayProvider)));

/// Голос персонажа (реплики, чат). По умолчанию — общий [ttsServiceProvider] (системный);
/// в main — [buildServerTts]. Голосовые подсказки тренировок остаются на [ttsServiceProvider].
final characterTtsProvider = Provider<TtsService>((ref) => ref.watch(ttsServiceProvider));

/// Фабрика для main: `characterTtsProvider.overrideWith(buildServerTts)`.
TtsService buildServerTts(Ref ref) {
  final s = ServerTtsService(
    cache: ServerTtsCache(ref.watch(serverTtsApiProvider)),
    fallback: ref.watch(ttsServiceProvider),
    serverVoice: () => ref.read(serverVoiceIdProvider),
  );
  ref.onDispose(s.dispose);
  return s;
}

/// Распознавание речи. По умолчанию недоступно; в main — `speechInputProvider.overrideWith((ref) => SttSpeechInput())`.
final speechInputProvider = Provider<SpeechInput>((ref) => const NoSpeechInput());

/// Звук уведомления голосом выбранного персонажа (для модуля уведомлений). null — звук по умолчанию.
final notificationSoundPreparerProvider =
    Provider<Future<NotificationSound?> Function(String text, String lang, {String? name})>((ref) {
  return (text, lang, {name}) => prepareNotificationSound(
        ref.read(aiGatewayProvider),
        text,
        lang: lang,
        voice: ref.read(serverVoiceIdProvider),
        name: name,
      );
});
