import '../../../core/models/enums.dart';
import '../../../core/voice/tts_service.dart';
import '../../../l10n/app_localizations.dart';

/// Режимы мотивации (character.motivation).
const motivationModes = ['soft', 'normal', 'strict', 'harsh'];

/// Профиль персонажа: голоса (системный синтез — свой тембр и скорость у каждого).
/// Характер и манера речи — в ARB (`chrDesc*`, `chrSpeech*`, `chrSample*`, `chrLine*`).
class CharacterProfile {
  const CharacterProfile(this.archetype, this.voices);

  final CharacterArchetype archetype;

  /// Первый — голос по умолчанию. id стабильны: '<архетип>.<вариант>' (хранятся в character.voice).
  final List<VoiceProfile> voices;

  VoiceProfile voiceById(String? id) => voices.firstWhere((v) => v.id == id, orElse: () => voices.first);

  static CharacterProfile of(CharacterArchetype a) => _profiles[a]!;
}

const _profiles = <CharacterArchetype, CharacterProfile>{
  CharacterArchetype.animeGirl: CharacterProfile(CharacterArchetype.animeGirl, [
    VoiceProfile(id: 'animeGirl.bright', pitch: 1.4, rate: .53, preferFemale: true),
    VoiceProfile(id: 'animeGirl.soft', pitch: 1.2, rate: .46, preferFemale: true),
    VoiceProfile(id: 'animeGirl.calm', pitch: 1.08, rate: .44, preferFemale: true),
  ]),
  CharacterArchetype.animeGuy: CharacterProfile(CharacterArchetype.animeGuy, [
    VoiceProfile(id: 'animeGuy.energetic', pitch: 1.12, rate: .56, preferFemale: false),
    VoiceProfile(id: 'animeGuy.calm', pitch: .95, rate: .47, preferFemale: false),
  ]),
  CharacterArchetype.stoicStrongman: CharacterProfile(CharacterArchetype.stoicStrongman, [
    VoiceProfile(id: 'stoicStrongman.deep', pitch: .62, rate: .40, preferFemale: false),
    VoiceProfile(id: 'stoicStrongman.calm', pitch: .78, rate: .43, preferFemale: false),
  ]),
  CharacterArchetype.grimSwordsman: CharacterProfile(CharacterArchetype.grimSwordsman, [
    VoiceProfile(id: 'grimSwordsman.low', pitch: .72, rate: .42, preferFemale: false),
    VoiceProfile(id: 'grimSwordsman.hoarse', pitch: .82, rate: .46, preferFemale: false),
    VoiceProfile(id: 'grimSwordsman.calm', pitch: .88, rate: .40, preferFemale: false),
  ]),
};

/// Архетип из значения раздела character.archetype (null — не выбран/неизвестен).
CharacterArchetype? archetypeFromName(Object? name) =>
    name is String ? enumByName(CharacterArchetype.values, name) : null;

/// Режим мотивации из раздела (по умолчанию 'normal').
String motivationOf(Object? m) => m is String && motivationModes.contains(m) ? m : 'normal';

String archetypeName(AppLocalizations l, CharacterArchetype a) => switch (a) {
      CharacterArchetype.animeGirl => l.chrNameAnimeGirl,
      CharacterArchetype.animeGuy => l.chrNameAnimeGuy,
      CharacterArchetype.stoicStrongman => l.chrNameStoicStrongman,
      CharacterArchetype.grimSwordsman => l.chrNameGrimSwordsman,
    };

String archetypeDescription(AppLocalizations l, CharacterArchetype a) => switch (a) {
      CharacterArchetype.animeGirl => l.chrDescAnimeGirl,
      CharacterArchetype.animeGuy => l.chrDescAnimeGuy,
      CharacterArchetype.stoicStrongman => l.chrDescStoicStrongman,
      CharacterArchetype.grimSwordsman => l.chrDescGrimSwordsman,
    };

String archetypeSpeech(AppLocalizations l, CharacterArchetype a) => switch (a) {
      CharacterArchetype.animeGirl => l.chrSpeechAnimeGirl,
      CharacterArchetype.animeGuy => l.chrSpeechAnimeGuy,
      CharacterArchetype.stoicStrongman => l.chrSpeechStoicStrongman,
      CharacterArchetype.grimSwordsman => l.chrSpeechGrimSwordsman,
    };

/// Фразы-примеры манеры речи (для «Прослушать»).
List<String> archetypeSamples(AppLocalizations l, CharacterArchetype a) => switch (a) {
      CharacterArchetype.animeGirl => [l.chrSampleAnimeGirl1, l.chrSampleAnimeGirl2, l.chrSampleAnimeGirl3],
      CharacterArchetype.animeGuy => [l.chrSampleAnimeGuy1, l.chrSampleAnimeGuy2, l.chrSampleAnimeGuy3],
      CharacterArchetype.stoicStrongman => [
          l.chrSampleStoicStrongman1,
          l.chrSampleStoicStrongman2,
          l.chrSampleStoicStrongman3,
        ],
      CharacterArchetype.grimSwordsman => [
          l.chrSampleGrimSwordsman1,
          l.chrSampleGrimSwordsman2,
          l.chrSampleGrimSwordsman3,
        ],
    };

/// Реплика персонажа в режиме мотивации [mode].
String modeLine(AppLocalizations l, CharacterArchetype a, String mode) => switch ((a, mode)) {
      (CharacterArchetype.animeGirl, 'soft') => l.chrLineAnimeGirlSoft,
      (CharacterArchetype.animeGirl, 'strict') => l.chrLineAnimeGirlStrict,
      (CharacterArchetype.animeGirl, 'harsh') => l.chrLineAnimeGirlHarsh,
      (CharacterArchetype.animeGirl, _) => l.chrLineAnimeGirlNormal,
      (CharacterArchetype.animeGuy, 'soft') => l.chrLineAnimeGuySoft,
      (CharacterArchetype.animeGuy, 'strict') => l.chrLineAnimeGuyStrict,
      (CharacterArchetype.animeGuy, 'harsh') => l.chrLineAnimeGuyHarsh,
      (CharacterArchetype.animeGuy, _) => l.chrLineAnimeGuyNormal,
      (CharacterArchetype.stoicStrongman, 'soft') => l.chrLineStoicStrongmanSoft,
      (CharacterArchetype.stoicStrongman, 'strict') => l.chrLineStoicStrongmanStrict,
      (CharacterArchetype.stoicStrongman, 'harsh') => l.chrLineStoicStrongmanHarsh,
      (CharacterArchetype.stoicStrongman, _) => l.chrLineStoicStrongmanNormal,
      (CharacterArchetype.grimSwordsman, 'soft') => l.chrLineGrimSwordsmanSoft,
      (CharacterArchetype.grimSwordsman, 'strict') => l.chrLineGrimSwordsmanStrict,
      (CharacterArchetype.grimSwordsman, 'harsh') => l.chrLineGrimSwordsmanHarsh,
      (CharacterArchetype.grimSwordsman, _) => l.chrLineGrimSwordsmanNormal,
    };

/// Короткие реплики по тапу на персонажа (оверлей) — по режиму мотивации.
List<String> tapLines(AppLocalizations l, String mode) => switch (mode) {
      'soft' => [l.chrTapSoft1, l.chrTapSoft2, l.chrTapSoft3],
      'strict' => [l.chrTapStrict1, l.chrTapStrict2, l.chrTapStrict3],
      'harsh' => [l.chrTapHarsh1, l.chrTapHarsh2, l.chrTapHarsh3],
      _ => [l.chrTapNormal1, l.chrTapNormal2, l.chrTapNormal3],
    };

String voiceLabel(AppLocalizations l, String voiceId) => switch (voiceId.split('.').last) {
      'bright' => l.chrVoiceBright,
      'soft' => l.chrVoiceSoft,
      'calm' => l.chrVoiceCalm,
      'energetic' => l.chrVoiceEnergetic,
      'deep' => l.chrVoiceDeep,
      'low' => l.chrVoiceLow,
      'hoarse' => l.chrVoiceHoarse,
      _ => voiceId,
    };

String motivationName(AppLocalizations l, String m) => switch (m) {
      'soft' => l.chrModeSoft,
      'strict' => l.chrModeStrict,
      'harsh' => l.chrModeHarsh,
      _ => l.chrModeNormal,
    };

String motivationDesc(AppLocalizations l, String m) => switch (m) {
      'soft' => l.chrModeSoftDesc,
      'strict' => l.chrModeStrictDesc,
      'harsh' => l.chrModeHarshDesc,
      _ => l.chrModeNormalDesc,
    };

String stateLabel(AppLocalizations l, CharacterState s) => switch (s) {
      CharacterState.idle => l.chrStateIdle,
      CharacterState.walk => l.chrStateWalk,
      CharacterState.talk => l.chrStateTalk,
      CharacterState.happy => l.chrStateHappy,
      CharacterState.angry => l.chrStateAngry,
      CharacterState.sit => l.chrStateSit,
      CharacterState.sleep => l.chrStateSleep,
      CharacterState.point => l.chrStatePoint,
    };
