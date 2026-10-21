import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../core/voice/tts_service.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../../character/character_view.dart';
import '../../character/model/character_profile.dart';
import '../step_scope.dart';
import 'character/character_widgets.dart';
import 'common/section_state.dart';

/// Этап 11 — персонаж и голос (раздел character: archetype, voice, motivation, profanityAllowed).
///
/// Живые персонажи в карточках; у выбранного — крупный просмотр всех анимаций, выбор голоса
/// и «Прослушать» (системный синтез, язык интерфейса). Обязательно: выбрать архетип.
class CharacterStep extends ConsumerStatefulWidget {
  const CharacterStep({super.key});

  @override
  ConsumerState<CharacterStep> createState() => _CharacterStepState();
}

class _CharacterStepState extends SectionStepState<CharacterStep> {
  /// Порядок кнопок-состояний под крупным персонажем.
  static const _previewStates = [
    CharacterState.idle,
    CharacterState.happy,
    CharacterState.angry,
    CharacterState.talk,
    CharacterState.sleep,
    CharacterState.point,
    CharacterState.sit,
    CharacterState.walk,
  ];

  late final TtsService _tts;
  CharacterState _preview = CharacterState.idle;
  String? _lang;
  bool? _ttsAvailable;
  bool _speaking = false;
  int _speechSerial = 0;
  int _sampleIndex = 0;

  @override
  QuestionnaireSection get section => QuestionnaireSection.character;

  @override
  void initState() {
    super.initState();
    _tts = ref.read(ttsServiceProvider);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lang = Localizations.localeOf(context).languageCode;
    if (lang != _lang) {
      _lang = lang;
      _ttsAvailable = null;
      _tts.isAvailable(lang).then((ok) {
        if (mounted && _lang == lang) setState(() => _ttsAvailable = ok);
      }, onError: (Object _) {
        if (mounted && _lang == lang) setState(() => _ttsAvailable = false);
      });
    }
  }

  @override
  void dispose() {
    if (_speaking) _tts.stop();
    super.dispose();
  }

  @override
  Map<String, Object?> initialDefaults(Map<String, Object?> current) {
    final a = archetypeFromName(current['archetype']);
    final voices = a == null ? null : CharacterProfile.of(a).voices.map((v) => v.id).toList();
    return {
      if (!motivationModes.contains(current['motivation'])) 'motivation': 'normal',
      if (current['profanityAllowed'] is! bool ||
          (current['motivation'] != 'harsh' && current['profanityAllowed'] == true))
        'profanityAllowed': false,
      // Голос из старой версии/другого архетипа — заменить на голос по умолчанию.
      if (voices != null && !voices.contains(current['voice'])) 'voice': voices.first,
    };
  }

  CharacterArchetype? get _archetype => archetypeFromName(data['archetype']);

  void _selectArchetype(CharacterArchetype a) {
    if (a == _archetype) return;
    final profile = CharacterProfile.of(a);
    final voice = str('voice');
    _stopSpeech();
    _sampleIndex = 0;
    setValues({'archetype': a.name, 'voice': profile.voices.any((v) => v.id == voice) ? voice : profile.voices.first.id});
  }

  void _selectMotivation(String m) {
    setValues({
      'motivation': m,
      // Мат имеет смысл только в жёстком режиме; при выходе из него — сбрасываем.
      if (m != 'harsh') 'profanityAllowed': false,
    });
  }

  void _stopSpeech() {
    if (!_speaking) return;
    _speechSerial++;
    _tts.stop();
    _speaking = false;
    _preview = CharacterState.idle;
  }

  /// Персонаж произносит [text] своим голосом на языке интерфейса; во время речи — [state], потом idle.
  Future<void> _speak(String text, {CharacterState state = CharacterState.talk}) async {
    final a = _archetype;
    final lang = _lang;
    if (a == null || lang == null) return;
    final voice = CharacterProfile.of(a).voiceById(str('voice'));
    final serial = ++_speechSerial;
    setState(() {
      _speaking = true;
      _preview = state;
    });
    try {
      await _tts.speak(text, languageCode: lang, voice: voice);
    } catch (_) {
      // Синтез не удался — просто молчим.
    }
    if (!mounted || serial != _speechSerial) return;
    setState(() {
      _speaking = false;
      _preview = CharacterState.idle;
    });
  }

  void _listen(AppLocalizations l, CharacterArchetype a) {
    if (_speaking) {
      setState(_stopSpeech);
      return;
    }
    final samples = archetypeSamples(l, a);
    final text = samples[_sampleIndex % samples.length];
    _sampleIndex++;
    _speak(text);
  }

  static CharacterState _modeState(String m) => switch (m) {
        'harsh' => CharacterState.angry,
        'strict' => CharacterState.point,
        _ => CharacterState.talk,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    final editing = scope?.editing ?? false;
    final archetype = _archetype;
    scope?.setCanProceed(loaded && archetype != null);
    if (!loaded) return const SectionLoading();

    final motivation = motivationOf(data['motivation']);
    final profanity = data['profanityAllowed'] == true;
    final canSpeak = _ttsAvailable == true;

    Widget card(CharacterArchetype a) => ArchetypeCard(
          key: ValueKey('qbArchetype_${a.name}'),
          archetype: a,
          name: archetypeName(l, a),
          selected: a == archetype,
          onTap: () => _selectArchetype(a),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.chrIntro, style: SysText.secondary),
        SysFieldLabel(l.chrArchetype, hint: archetype == null ? l.chrArchetypeRequired : null),
        for (var row = 0; row < 2; row++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: card(CharacterArchetype.values[row * 2])),
              const SizedBox(width: 8),
              Expanded(child: card(CharacterArchetype.values[row * 2 + 1])),
            ],
          ),
          const SizedBox(height: 8),
        ],
        if (archetype != null) ...[
          const SizedBox(height: 8),
          SysPanel(
            key: const ValueKey('chrPreview'),
            title: archetypeName(l, archetype),
            animateIn: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: ExcludeSemantics(
                    child: CharacterView(archetype: archetype, state: _preview, height: 200),
                  ),
                ),
                const SizedBox(height: 10),
                Text(archetypeDescription(l, archetype), style: SysText.body),
                const SizedBox(height: 4),
                Text(l.chrSpeechLabel(archetypeSpeech(l, archetype)), style: SysText.secondary),
                const SizedBox(height: 12),
                SysFieldLabel(l.chrPreviewStates),
                SysChoiceChips<CharacterState>(
                  choices: [for (final s in _previewStates) SysChoice(s, stateLabel(l, s))],
                  selected: {_preview},
                  allowEmpty: false,
                  onChanged: (s) => setState(() {
                    _stopSpeech();
                    _preview = s.first;
                  }),
                ),
              ],
            ),
          ),
          const SysFieldGap(),
          SysFieldLabel(l.chrVoice, hint: l.chrVoiceNote),
          SysChoiceChips<String>(
            choices: [
              for (final v in CharacterProfile.of(archetype).voices) SysChoice(v.id, voiceLabel(l, v.id), glyph: SysGlyph.mic),
            ],
            selected: {CharacterProfile.of(archetype).voiceById(str('voice')).id},
            allowEmpty: false,
            onChanged: (s) => setValue('voice', s.first),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: SysButton.secondary(
              key: const ValueKey('chrListen'),
              label: _speaking ? l.chrStop : l.chrListen,
              icon: SysGlyph.mic,
              onPressed: canSpeak ? () => _listen(l, archetype) : null,
            ),
          ),
          if (_ttsAvailable == false) ...[
            const SizedBox(height: 6),
            Text(l.chrTtsUnavailable, key: const ValueKey('chrTtsUnavailable'), style: SysText.caption),
          ],
        ],
        const SysFieldGap(),
        SysFieldLabel(l.chrMotivation),
        for (final m in motivationModes)
          SelectCard(
            key: ValueKey('qbMotivation_$m'),
            selected: m == motivation,
            onTap: () => _selectMotivation(m),
            title: motivationName(l, m),
            lines: [motivationDesc(l, m)],
            tone: m == 'harsh' ? PanelTone.danger : PanelTone.accent,
            footer: m == motivation && archetype != null
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l.chrModeExample.toUpperCase(), style: SysText.caption),
                      const SizedBox(height: 4),
                      QuoteLine(modeLine(l, archetype, m), tone: m == 'harsh' ? PanelTone.danger : PanelTone.accent),
                      const SizedBox(height: 8),
                      SysButton.secondary(
                        key: const ValueKey('chrModeTry'),
                        label: l.chrModeTry,
                        icon: SysGlyph.mic,
                        onPressed: canSpeak
                            ? () {
                                if (_speaking) setState(_stopSpeech);
                                _speak(modeLine(l, archetype, m), state: _modeState(m));
                              }
                            : null,
                      ),
                    ],
                  )
                : null,
          ),
        if (motivation == 'harsh') ...[
          const SizedBox(height: 4),
          SysSwitchRow(
            key: const ValueKey('qbProfanitySwitch'),
            label: l.chrProfanity,
            hint: l.chrProfanityHint,
            value: profanity,
            onChanged: (v) => setValue('profanityAllowed', v),
          ),
        ],
      ],
    );
  }
}
