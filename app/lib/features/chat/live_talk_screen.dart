// Живой разговор с персонажем (решение владельца 2026-10-22, SPEC §9.2): открывается удержанием персонажа 3 с.
// Без кнопок: слушает → отвечает голосом → снова слушает. Текстовая лента — та же история, что в чате.
// Выход — крестиком или смахиванием вниз; «Текст» открывает обычный чат (по возвращении снова слушает).
// После трёх пустых попыток подряд встаёт на паузу (нажатие по экрану — продолжить).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/ai/ai_api.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/speech_input.dart';
import '../../core/voice/tts_service.dart';
import '../../core/voice/voice_providers.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../character/character_renderer.dart';
import '../character/model/character_profile.dart';
import 'chat_repository.dart';
import 'chat_texts.dart';

enum _Phase { starting, listening, thinking, speaking, paused, unavailable }

class LiveTalkScreen extends ConsumerStatefulWidget {
  const LiveTalkScreen({super.key});

  /// Сколько пустых прослушиваний подряд до паузы.
  static const maxEmptyListens = 3;

  @override
  ConsumerState<LiveTalkScreen> createState() => _LiveTalkScreenState();
}

class _LiveTalkScreenState extends ConsumerState<LiveTalkScreen> {
  late final TtsService _tts;
  late final SpeechInput _speech;

  _Phase _phase = _Phase.starting;
  String _partial = '';
  String? _fallback;
  int _empty = 0;
  bool _closed = false;

  // Каждый запуск прослушивания/ответа получает номер: устаревшие колбэки игнорируются.
  int _turn = 0;

  @override
  void initState() {
    super.initState();
    _tts = ref.read(characterTtsProvider);
    _speech = ref.read(speechInputProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) => _begin());
  }

  @override
  void dispose() {
    _closed = true;
    _turn++;
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  Map<String, Object?> get _character =>
      ref.read(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};

  String get _lang => Localizations.localeOf(context).languageCode;

  void _set(_Phase p) {
    if (mounted && !_closed) setState(() => _phase = p);
  }

  Future<void> _begin() async {
    await _tts.stop();
    if (!await _speech.init()) {
      _set(_Phase.unavailable);
      return;
    }
    _listen();
  }

  Future<void> _listen() async {
    if (!mounted || _closed) return;
    final turn = ++_turn;
    var heard = '';
    setState(() {
      _phase = _Phase.listening;
      _partial = '';
    });
    await _speech.start(
      languageCode: _lang,
      onText: (text, _) {
        if (!mounted || turn != _turn) return;
        heard = text;
        setState(() => _partial = text);
      },
      onDone: () {
        if (mounted && turn == _turn) _onHeard(heard, turn);
      },
    );
  }

  Future<void> _onHeard(String text, int turn) async {
    final t = text.trim();
    if (t.isEmpty) {
      _empty++;
      if (_empty >= LiveTalkScreen.maxEmptyListens) {
        _set(_Phase.paused);
      } else {
        _listen();
      }
      return;
    }
    _empty = 0;
    final l = AppLocalizations.of(context);
    final c = _character;
    final motivation = motivationOf(c['motivation']);
    final lang = _lang;
    setState(() {
      _phase = _Phase.thinking;
      _partial = '';
      _fallback = null;
    });
    final repo = ref.read(chatRepositoryProvider);
    String reply;
    try {
      await repo.add(ChatRole.user, t, viaVoice: true);
      reply = (await repo.ask(
        character: {
          'archetype': c['archetype'] ?? CharacterArchetype.animeGirl.name,
          'motivation': motivation,
          if (c['name'] is String && (c['name'] as String).isNotEmpty) 'name': c['name'],
        },
        lang: lang,
      ))
          .reply;
    } on AiException {
      reply = chatFallbackLine(l, motivation);
      if (mounted) setState(() => _fallback = reply);
    } catch (_) {
      reply = chatFallbackLine(l, motivation);
      if (mounted) setState(() => _fallback = reply);
    }
    if (!mounted || _closed || turn != _turn) return;
    await _speakThenListen(reply, turn);
  }

  Future<void> _speakThenListen(String text, int turn) async {
    _set(_Phase.speaking);
    final archetype = archetypeFromName(_character['archetype']);
    final voice = archetype == null ? null : CharacterProfile.of(archetype).voiceById(_character['voice'] as String?);
    await _tts.speak(text, languageCode: _lang, voice: voice).catchError((Object _) {});
    // Пауза, чтобы микрофон не поймал хвост собственной реплики.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (mounted && !_closed && turn == _turn) _listen();
  }

  /// Нажатие по экрану: перебить ответ или продолжить после паузы.
  Future<void> _poke() async {
    switch (_phase) {
      case _Phase.speaking:
        _turn++;
        await _tts.stop();
        _listen();
      case _Phase.paused:
        _empty = 0;
        _listen();
      default:
        break;
    }
  }

  Future<void> _openTextChat() async {
    _turn++;
    await _speech.cancel();
    await _tts.stop();
    if (!mounted) return;
    _set(_Phase.paused);
    await context.push(Routes.chat);
    if (mounted && !_closed && _phase == _Phase.paused) {
      _empty = 0;
      _listen();
    }
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final messages = ref.watch(chatMessagesProvider).value ?? const <ChatMessageRow>[];
    final data = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};
    final archetype = archetypeFromName(data['archetype']);
    final renderer = ref.watch(characterRendererProvider);
    final characterState = switch (_phase) {
      _Phase.speaking => CharacterState.talk,
      _Phase.thinking => CharacterState.point,
      _Phase.paused => CharacterState.sit,
      _ => CharacterState.idle,
    };
    final status = switch (_phase) {
      _Phase.starting => l.talkStarting,
      _Phase.listening => _partial.isEmpty ? l.talkListening : _partial,
      _Phase.thinking => l.chtThinking,
      _Phase.speaking => l.talkSpeaking,
      _Phase.paused => l.talkPaused,
      _Phase.unavailable => l.chtMicUnavailable,
    };
    final feed = [for (final m in messages) if (m.role != ChatRole.system) m];

    return Scaffold(
      key: const Key('live-talk'),
      backgroundColor: SysColors.background,
      body: SystemBackground(
        child: SafeArea(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _poke,
            onVerticalDragEnd: (d) {
              if ((d.primaryVelocity ?? 0) > 500) _close();
            },
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                  child: Row(
                    children: [
                      SysIconButton(glyph: SysGlyph.close, tooltip: l.commonClose, onPressed: _close),
                      Expanded(
                        child: Semantics(
                          header: true,
                          child: Text(
                            l.talkTitle.toUpperCase(),
                            style: SysText.heading,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      TextButton(
                        key: const Key('talk-text-chat'),
                        onPressed: _openTextChat,
                        child: Text(l.talkTextChat, style: SysText.label.copyWith(color: SysColors.accentLight)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 190,
                  child: Center(
                    child: archetype == null
                        ? const SysIcon(SysGlyph.mic, size: 64, color: SysColors.accentLight)
                        : renderer.build(CharacterRenderSpec(archetype: archetype, state: characterState, height: 180)),
                  ),
                ),
                _StatusLine(phase: _phase, text: status),
                if (_fallback != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
                    child: Text(l.talkOfflineHint, style: SysText.caption, textAlign: TextAlign.center),
                  ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    key: const Key('talk-feed'),
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: feed.length,
                    itemBuilder: (context, i) => _FeedLine(message: feed[i]),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(l.talkExitHint, style: SysText.caption, textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.phase, required this.text});

  final _Phase phase;
  final String text;

  @override
  Widget build(BuildContext context) {
    final listening = phase == _Phase.listening;
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (listening) ...[
              const SysIcon(SysGlyph.mic, size: 18, color: SysColors.dangerLight),
              const SizedBox(width: 8),
            ] else if (phase == _Phase.thinking) ...[
              const SysLoader(size: 14),
              const SizedBox(width: 8),
            ] else if (phase == _Phase.speaking) ...[
              const SysIcon(SysGlyph.volume, size: 18, color: SysColors.accentLight),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text,
                key: const Key('talk-status'),
                style: SysText.body.copyWith(color: listening ? SysColors.textPrimary : SysColors.textSecondary),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedLine extends StatelessWidget {
  const _FeedLine({required this.message});

  final ChatMessageRow message;

  @override
  Widget build(BuildContext context) {
    final mine = message.role == ChatRole.user;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .8),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: mine ? SysColors.accent.withValues(alpha: .14) : SysColors.panelTop,
            border: Border.all(color: mine ? SysColors.accent.withValues(alpha: .5) : SysColors.panelBorder),
            borderRadius: BorderRadius.circular(SysDims.radius * 2),
          ),
          child: Text(message.body, style: SysText.body),
        ),
      ),
    );
  }
}
