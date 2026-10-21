// DuckingSession на audio_session 0.2: iOS — AVAudioSession, Android — AudioFocus.
import 'package:audio_session/audio_session.dart';

import 'voice_prompter.dart';

/// Голос поверх музыки:
/// - iOS: категория playback (иначе в фоне TTS молчит) + mixWithOthers + duckOthers, режим voicePrompt;
///   деактивация с notifyOthersOnDeactivation — музыка возвращает громкость.
/// - Android: AudioFocus GAIN_TRANSIENT_MAY_DUCK, usage assistanceNavigationGuidance, contentType speech.
///
/// Категорию iOS flutter_tts тоже ставит сам (playback + duckOthers, FlutterTtsEngine.configure) — совпадает
/// с нашей; [prepare] повторяет её перед каждой серией фраз, чтобы чужая настройка (камера и т. п.) не мешала.
class AudioSessionDucking implements DuckingSession {
  AudioSessionDucking({Future<AudioSession> Function()? session}) : _sessionGetter = session ?? (() => AudioSession.instance);

  final Future<AudioSession> Function() _sessionGetter;

  static final configuration = AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers | AVAudioSessionCategoryOptions.duckOthers,
    avAudioSessionMode: AVAudioSessionMode.voicePrompt,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.speech,
      usage: AndroidAudioUsage.assistanceNavigationGuidance,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
    androidWillPauseWhenDucked: false,
  );

  @override
  Future<void> prepare() async => (await _sessionGetter()).configure(configuration);

  @override
  Future<bool> activate() async => (await _sessionGetter()).setActive(true);

  @override
  Future<void> deactivate() async {
    await (await _sessionGetter())
        .setActive(false, avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation);
  }
}
