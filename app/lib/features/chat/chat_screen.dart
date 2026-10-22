// Чат с персонажем (SPEC §9.3): текст и голос, ответ — пузырь + озвучка, действия ИИ с отменой.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/ai/ai_api.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/speech_input.dart';
import '../../core/voice/tts_service.dart';
import '../../core/voice/voice_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../ai_journal/ai_journal_api.dart';
import '../character/character_reaction.dart';
import '../character/model/character_profile.dart';
import '../common/ai_error_view.dart';
import 'chat_repository.dart';
import 'chat_texts.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  late final TtsService _tts;
  late final SpeechInput _speech;

  bool _busy = false;
  bool _listening = false;
  bool _speak = true;
  bool _gotVoiceText = false;
  AiFailure? _failure;
  String? _fallbackLine;

  @override
  void initState() {
    super.initState();
    _tts = ref.read(characterTtsProvider);
    _speech = ref.read(speechInputProvider);
  }

  @override
  void dispose() {
    _input.dispose();
    if (_listening) _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  Map<String, Object?> get _character =>
      ref.read(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};

  String get _lang => Localizations.localeOf(context).languageCode;

  void _say(String text) {
    if (text.trim().isEmpty) return;
    // Облачко над персонажем; голос играем сами (серверный TTS с фолбэком на системный).
    ref.read(characterSayProvider).say(text, voice: false);
    if (!_speak) return;
    final archetype = archetypeFromName(_character['archetype']);
    final voice = archetype == null ? null : CharacterProfile.of(archetype).voiceById(_character['voice'] as String?);
    _tts.speak(text, languageCode: _lang, voice: voice).catchError((Object _) {});
  }

  Future<void> _send({bool viaVoice = false}) async {
    final text = _input.text.trim();
    if (text.isEmpty || _busy) return;
    _input.clear();
    await ref.read(chatRepositoryProvider).add(ChatRole.user, text, viaVoice: viaVoice);
    await _ask();
  }

  Future<void> _ask() async {
    if (_busy) return;
    final l = AppLocalizations.of(context);
    final c = _character;
    final motivation = motivationOf(c['motivation']);
    setState(() {
      _busy = true;
      _failure = null;
      _fallbackLine = null;
    });
    try {
      final r = await ref.read(chatRepositoryProvider).ask(
        character: {
          'archetype': c['archetype'] ?? CharacterArchetype.animeGirl.name,
          'motivation': motivation,
          if (c['name'] is String && (c['name'] as String).isNotEmpty) 'name': c['name'],
        },
        lang: _lang,
      );
      _say(r.reply);
    } on AiException catch (e) {
      final line = chatFallbackLine(l, motivation);
      if (mounted) {
        setState(() {
          _failure = e.failure;
          _fallbackLine = line;
        });
      }
      _say(line);
    } catch (_) {
      if (mounted) setState(() => _failure = AiFailure.server);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _startListening() async {
    if (_listening || _busy) return;
    final l = AppLocalizations.of(context);
    await _tts.stop();
    if (!await _speech.init()) {
      if (mounted) ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.chtMicUnavailable)));
      return;
    }
    if (!mounted) return;
    setState(() {
      _listening = true;
      _gotVoiceText = false;
    });
    await _speech.start(
      languageCode: _lang,
      onText: (text, isFinal) {
        if (!mounted) return;
        _gotVoiceText = text.trim().isNotEmpty;
        _input.value = TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
      },
      onDone: () {
        if (!mounted || !_listening) return;
        setState(() => _listening = false);
        if (_gotVoiceText) _send(viaVoice: true);
      },
    );
  }

  Future<void> _stopListening() async {
    if (!_listening) return;
    await _speech.stop(); // итоговый результат и onDone придут следом
  }

  Future<void> _undo(String actionId) async {
    final l = AppLocalizations.of(context);
    try {
      await ref.read(aiJournalApiProvider).undo(actionId);
      ref.read(undoneAiActionsProvider.notifier).add(actionId);
      ref.invalidate(aiActionsProvider);
    } catch (_) {
      if (mounted) ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(l.chtUndoFailed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final messages = ref.watch(chatMessagesProvider).value ?? const <ChatMessageRow>[];
    final undone = ref.watch(undoneAiActionsProvider);
    final failure = _failure;
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  children: [
                    const SysBackButton(),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          l.chtTitle.toUpperCase(),
                          style: SysText.heading,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    SysIconButton(
                      glyph: _speak ? SysGlyph.volume : SysGlyph.volumeOff,
                      tooltip: _speak ? l.chtVoiceOn : l.chtVoiceOff,
                      onPressed: () {
                        setState(() => _speak = !_speak);
                        if (!_speak) _tts.stop();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          child: SysEmptyState(title: l.chtTitle, hint: l.chtEmpty, glyph: SysGlyph.mic),
                        ),
                      )
                    : ListView.builder(
                        reverse: true,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        itemCount: messages.length,
                        itemBuilder: (context, i) {
                          final m = messages[i];
                          if (m.role == ChatRole.system) {
                            final id = ChatRepository.actionIdOf(m);
                            return _ActionNote(
                              text: l.chtAction(m.body),
                              undone: id != null && undone.contains(id),
                              onUndo: id == null ? null : () => _undo(id),
                            );
                          }
                          return _Bubble(text: m.body, mine: m.role == ChatRole.user);
                        },
                      ),
              ),
              if (_busy)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SysLoader(size: 14),
                      const SizedBox(width: 8),
                      Flexible(child: Text(l.chtThinking, style: SysText.caption)),
                    ],
                  ),
                ),
              if (failure != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: AiErrorView(
                    failure: failure,
                    message: aiFailureText(l, failure),
                    animateIn: false,
                    extra: _fallbackLine == null ? null : Text('«$_fallbackLine»', style: SysText.body),
                    retryLabel: l.chtRetry,
                    onRetry: _busy ? null : _ask,
                  ),
                ),
              _inputRow(l),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputRow(AppLocalizations l) => Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _input,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: SysText.body,
                decoration: InputDecoration(hintText: _listening ? l.chtListening : l.chtHint),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 8),
            Tooltip(
              message: l.chtMic,
              child: GestureDetector(
                onTap: () => _listening ? _stopListening() : _startListening(),
                onLongPressStart: (_) => _startListening(),
                onLongPressEnd: (_) => _stopListening(),
                child: Container(
                  width: SysDims.minTap + 4,
                  height: SysDims.minTap + 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _listening ? SysColors.danger.withValues(alpha: .25) : SysColors.panelTop,
                    border: Border.all(color: _listening ? SysColors.dangerLight : SysColors.panelBorder),
                  ),
                  alignment: Alignment.center,
                  child: SysIcon(
                    SysGlyph.mic,
                    size: 22,
                    color: _listening ? SysColors.dangerLight : SysColors.accentLight,
                    semanticLabel: l.chtMic,
                  ),
                ),
              ),
            ),
            SysIconButton(
              glyph: SysGlyph.send,
              tooltip: l.chtSend,
              onPressed: _busy ? null : () => _send(),
            ),
          ],
        ),
      );
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.mine});

  final String text;
  final bool mine;

  @override
  Widget build(BuildContext context) => Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: mine ? SysColors.accent.withValues(alpha: .18) : SysColors.panelTop,
              border: Border.all(color: mine ? SysColors.accent.withValues(alpha: .6) : SysColors.panelBorder),
              borderRadius: BorderRadius.circular(SysDims.radius * 2),
            ),
            child: SelectableText(text, style: SysText.body),
          ),
        ),
      );
}

class _ActionNote extends StatelessWidget {
  const _ActionNote({required this.text, required this.undone, this.onUndo});

  final String text;
  final bool undone;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const SysIcon(SysGlyph.sparkle, size: 16, color: SysColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: SysText.caption.copyWith(
                color: SysColors.gold,
                decoration: undone ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (undone)
            Text(l.chtUndone, style: SysText.caption)
          else if (onUndo != null)
            TextButton(onPressed: onUndo, child: Text(l.chtUndo)),
        ],
      ),
    );
  }
}
