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
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(8),
              child: Text(e is AiException ? aiFailureText(l, e.failure) : l.chtLoadFailed, style: SysText.secondary),
            ),
            data: (all) {
              final list = [for (final v in all) if (v.lang.isEmpty || v.lang == lang) v];
              if (list.isEmpty) return Text(l.chtVoiceEmpty, style: SysText.secondary);
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
      leading: Icon(
        selected ? Icons.radio_button_checked : Icons.radio_button_off,
        color: selected ? SysColors.accent : SysColors.textInactive,
      ),
      title: Text(title, style: SysText.body),
      subtitle: subtitle == null ? null : Text(subtitle, style: SysText.caption),
      trailing: IconButton(
        tooltip: l.chtVoiceListen,
        onPressed: _playing != null ? null : () => _listen(id),
        icon: playing
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.play_arrow, color: SysColors.accentLight),
      ),
    );
  }
}
