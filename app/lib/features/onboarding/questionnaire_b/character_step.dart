import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'character/archetypes.dart';
import 'common/section_state.dart';

/// Этап 11 — персонаж и голос (раздел character). Обязательно: выбрать архетип.
class CharacterStep extends ConsumerStatefulWidget {
  const CharacterStep({super.key});

  @override
  ConsumerState<CharacterStep> createState() => _CharacterStepState();
}

class _CharacterStepState extends SectionStepState<CharacterStep> {
  @override
  QuestionnaireSection get section => QuestionnaireSection.character;

  @override
  Map<String, Object?> initialDefaults(Map<String, Object?> current) => {
        if (!motivationModes.contains(current['motivation'])) 'motivation': 'normal',
        if (current['profanityAllowed'] is! bool ||
            (current['motivation'] != 'harsh' && current['profanityAllowed'] == true))
          'profanityAllowed': false,
      };

  String? get _archetype {
    final a = data['archetype'];
    return a is String && characterArchetypes.contains(a) ? a : null;
  }

  void _selectArchetype(String a) {
    final voices = characterVoices[a]!;
    final voice = str('voice');
    setValues({'archetype': a, 'voice': voices.contains(voice) ? voice : voices.first});
  }

  void _selectMotivation(String m) {
    setValues({
      'motivation': m,
      // Мат имеет смысл только в жёстком режиме; при выходе из него — сбрасываем.
      if (m != 'harsh') 'profanityAllowed': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    final editing = scope?.editing ?? false;
    final archetype = _archetype;
    scope?.setCanProceed(loaded && archetype != null);
    if (!loaded) return const SectionLoading();

    final motivation = motivationModes.contains(data['motivation']) ? data['motivation']! as String : 'normal';
    final profanity = data['profanityAllowed'] == true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!editing) StepIntro(l.qbCharacterIntro, style: SysText.secondary),
        SysFieldLabel(l.qbArchetype, hint: archetype == null ? l.qbArchetypeRequired : null),
        for (final a in characterArchetypes)
          _SelectCard(
            key: ValueKey('qbArchetype_$a'),
            selected: a == archetype,
            onTap: () => _selectArchetype(a),
            leading: ArchetypeSilhouette(archetype: a, size: 56, active: a == archetype),
            title: archetypeName(l, a),
            lines: [archetypeCharacter(l, a), l.qbArchSpeechLabel(archetypeSpeech(l, a))],
          ),
        if (archetype != null) ...[
          const SysFieldGap(),
          SysFieldLabel(l.qbVoice, hint: l.qbVoiceLater),
          SysChoiceChips<String>(
            choices: [for (final v in characterVoices[archetype]!) SysChoice(v, voiceLabel(l, v), glyph: SysGlyph.mic)],
            selected: {if (characterVoices[archetype]!.contains(str('voice'))) str('voice')},
            allowEmpty: false,
            onChanged: (s) => setValue('voice', s.first),
          ),
        ],
        const SysFieldGap(),
        SysFieldLabel(l.qbMotivation),
        for (final m in motivationModes)
          _SelectCard(
            key: ValueKey('qbMotivation_$m'),
            selected: m == motivation,
            onTap: () => _selectMotivation(m),
            title: motivationName(l, m),
            lines: [motivationDesc(l, m)],
            tone: m == 'harsh' ? PanelTone.danger : PanelTone.accent,
          ),
        if (motivation == 'harsh') ...[
          const SizedBox(height: 4),
          SysSwitchRow(
            key: const ValueKey('qbProfanitySwitch'),
            label: l.qbProfanity,
            hint: l.qbProfanityHint,
            value: profanity,
            onChanged: (v) => setValue('profanityAllowed', v),
          ),
        ],
      ],
    );
  }
}

/// Карточка выбора (архетип, режим мотивации).
class _SelectCard extends StatelessWidget {
  const _SelectCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.title,
    required this.lines,
    this.leading,
    this.tone = PanelTone.accent,
  });

  final bool selected;
  final VoidCallback onTap;
  final String title;
  final List<String> lines;
  final Widget? leading;
  final PanelTone tone;

  @override
  Widget build(BuildContext context) {
    final p = tone.palette;
    final lead = leading;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        button: true,
        selected: selected,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(SysDims.radius),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              constraints: const BoxConstraints(minHeight: SysDims.minTap),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SysDims.radius),
                color: selected ? p.main.withValues(alpha: .18) : p.main.withValues(alpha: .05),
                border: Border.all(color: selected ? p.light : p.main.withValues(alpha: .35)),
                boxShadow: selected ? [BoxShadow(color: p.glow, blurRadius: 12)] : null,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (lead != null) ...[lead, const SizedBox(width: 12)],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title.toUpperCase(),
                                style: SysText.label.copyWith(color: selected ? SysColors.textPrimary : p.light),
                              ),
                            ),
                            if (selected) SysIcon(SysGlyph.check, size: 16, color: p.light),
                          ],
                        ),
                        for (final line in lines) ...[
                          const SizedBox(height: 4),
                          Text(line, style: SysText.secondary),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
