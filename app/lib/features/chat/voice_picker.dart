// Выбор голоса сервера для персонажа (SPEC §9.3). Точка входа — [showVoicePicker].
// Выбор хранится в разделе анкеты character под ключом serverVoice (синхронизируется).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/models/enums.dart';
import '../../core/voice/server_tts_service.dart';
import '../../core/voice/tts_service.dart';
import '../../core/voice/voice_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../common/ai_error_view.dart';
import '../character/model/character_profile.dart';
import 'chat_texts.dart';

Future<void> showVoicePicker(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SysColors.panelBottom,
      builder: (_) => const FractionallySizedBox(heightFactor: .8, child: VoicePicker()),
    );

final _serverVoicesProvider = FutureProvider.autoDispose<List<ServerVoice>>(
  (ref) => ref.watch(serverTtsApiProvider).voices(),
);

class VoicePicker extends ConsumerStatefulWidget {
  const VoicePicker({super.key});

  @override
  ConsumerState<VoicePicker> createState() => _VoicePickerState();
}

class _VoicePickerState extends ConsumerState<VoicePicker> {
  late final ServerTtsService _player;
  late final TtsService _system;
  String? _playing;

  @override
  void initState() {
    super.initState();
    _system = ref.read(ttsServiceProvider);
    // Своё воспроизведение: прослушивание строго голосом сервера, без фолбэка.
    _player = ServerTtsService(
      cache: ServerTtsCache(ref.read(serverTtsApiProvider)),
      fallback: const SilentTtsService(),
      serverVoice: () => null,
    );
  }

  @override
  void dispose() {
    _player.stop();
    _player.dispose();
    _system.stop();
    super.dispose();
  }

  Map<String, Object?> get _character =>
      ref.read(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};

  String _sample(AppLocalizations l) {
    final a = archetypeFromName(_character['archetype']);
    return a == null ? l.chtFallbackNormal : archetypeSamples(l, a).first;
  }

  Future<void> _listen(String? voiceId) async {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final text = _sample(l);
    setState(() => _playing = voiceId ?? '');
    try {
      if (voiceId == null) {
        final a = archetypeFromName(_character['archetype']);
        final profile = a == null ? null : CharacterProfile.of(a).voiceById(_character['voice'] as String?);
        await _system.speak(text, languageCode: lang, voice: profile);
      } else {
        await _player.speakWith(text, languageCode: lang, serverVoiceId: voiceId, strict: true);
      }
    } catch (e) {
      if (mounted) {
        final msg = e is AiException ? aiFailureText(l, e.failure) : l.chtVoiceListenFailed;
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(msg)));
      }
    } finally {
      if (mounted) setState(() => _playing = null);
    }
  }

  Future<void> _select(String? voiceId) => setServerVoice(ref.read(questionnaireRepositoryProvider), voiceId);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final selected = ref.watch(serverVoiceIdProvider);
    final voices = ref.watch(_serverVoicesProvider);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(l.chtVoiceTitle.toUpperCase(), style: SysText.heading),
          const SizedBox(height: 12),
          _tile(l, id: null, title: l.chtVoiceSystem, subtitle: l.chtVoiceSystemDesc, selected: selected == null),
          const Divider(color: SysColors.panelBorder),
          voices.when(
            loading: () => const SysLoadingView(padding: EdgeInsets.all(16)),
            error: (e, _) => SysEmptyState.inline(
              e is AiException ? aiFailureText(l, e.failure) : l.chtLoadFailed,
              glyph: aiFailureGlyph(aiFailureOf(e)),
              color: SysColors.dangerLight,
              actionLabel: l.chtRetry,
              onAction: () => ref.invalidate(_serverVoicesProvider),
            ),
            data: (all) {
              final list = [for (final v in all) if (v.lang.isEmpty || v.lang == lang) v];
              if (list.isEmpty) return SysEmptyState.inline(l.chtVoiceEmpty, glyph: SysGlyph.mic);
              return Column(
                children: [
                  for (final v in list)
                    _tile(
                      l,
                      id: v.id,
                      title: v.name,
                      subtitle: switch (v.gender) {
                        'female' => l.chtVoiceFemale,
                        'male' => l.chtVoiceMale,
                        _ => null,
                      },
                      selected: selected == v.id,
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(AppLocalizations l, {required String? id, required String title, String? subtitle, required bool selected}) {
    final playing = _playing == (id ?? '');
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: () => _select(id),
      selected: selected,
      leading: _RadioMark(selected: selected),
      title: Text(title, style: SysText.body),
      subtitle: subtitle == null ? null : Text(subtitle, style: SysText.caption),
      trailing: playing
          ? const SizedBox.square(dimension: 48, child: Center(child: SysLoader(size: 20)))
          : SysIconButton(
              glyph: SysGlyph.play,
              tooltip: l.chtVoiceListen,
              onPressed: _playing != null ? null : () => _listen(id),
            ),
    );
  }
}

/// Отметка выбора (радио) в стиле дизайн-системы.
class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: sysReduceMotion(context) ? Duration.zero : const Duration(milliseconds: 160),
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: selected ? SysColors.accentLight : SysColors.textInactive, width: 1.7),
          boxShadow: selected ? const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 8)] : null,
        ),
        child: selected
            ? const DecoratedBox(
                decoration: BoxDecoration(shape: BoxShape.circle, color: SysColors.accent),
                child: SizedBox.square(dimension: 10),
              )
            : null,
      );
}
