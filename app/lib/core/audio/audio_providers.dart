// Фабрики реализаций аудио для override в main (voicePrompterProvider / musicControllerProvider).
//
//   voicePrompterProvider.overrideWith((ref) => buildVoicePrompter(ref, voice: () => ref.read(workoutVoiceProfileProvider))),
//   musicControllerProvider.overrideWith(buildMusicController),
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../voice/tts_service.dart';
import 'audio_api.dart';
import 'audio_session_ducking.dart';
import 'channel_music_controller.dart';
import 'voice_prompter.dart';

/// Голос поверх музыки: TTS из [ttsServiceProvider] + системная сессия с приглушением.
VoicePrompter buildVoicePrompter(Ref ref, {VoiceProfile? Function()? voice}) {
  final prompter = DuckingVoicePrompter(tts: ref.watch(ttsServiceProvider), session: AudioSessionDucking(), voice: voice);
  ref.onDispose(prompter.stop);
  return prompter;
}

/// Системный плеер через канал `sistema/audio`; Spotify — заглушка до подключения SDK.
MusicController buildMusicController(Ref ref) => ChannelMusicController();
