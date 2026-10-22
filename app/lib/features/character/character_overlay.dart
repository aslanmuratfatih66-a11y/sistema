// Персонаж поверх всех вкладок (SPEC §9.2): живёт внизу над нижней навигацией, гуляет, садится,
// засыпает без касаний; реагирует на итоги квестов (радость/злость + реплика), после долгого простоя
// подходит и указывает (point + реплика). Тап — короткая реплика (облачко + голос), удержание 3 с
// (кольцо заполнения вокруг персонажа) — живой голосовой разговор (/talk), свайп вниз — «карман».
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';
import '../../core/data/profile_repository.dart';
import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/tts_service.dart';
import '../../core/voice/voice_providers.dart';
import '../../domain/quests/quest_api.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'character_lines.dart';
import 'character_reaction.dart';
import 'character_renderer.dart';
import 'model/character_profile.dart';

/// Оверлей персонажа. Не перехватывает нажатия вне самого персонажа и его облачка:
/// пустая область Stack не участвует в hit-test, касания проходят к интерфейсу ниже.
class CharacterOverlay extends ConsumerStatefulWidget {
  const CharacterOverlay({
    super.key,
    this.characterHeight = 90,
    this.sleepAfter = const Duration(minutes: 2),
    this.nudgeAfter = const Duration(minutes: 20),
    this.autonomous = true,
    this.random,
    this.holdToTalk = const Duration(seconds: 3),
  });

  final double characterHeight;

  /// Через сколько без касаний персонаж засыпает.
  final Duration sleepAfter;

  /// Через сколько без касаний персонаж просыпается, подходит и напоминает о себе (один раз до касания).
  final Duration nudgeAfter;

  /// Сам ли гуляет/садится (в тестах можно выключить).
  final bool autonomous;
  final math.Random? random;

  /// Сколько держать палец на персонаже, чтобы начать живой разговор.
  final Duration holdToTalk;

  /// Ключ AppSettings: персонаж убран в карман ('true'/'false').
  static const pocketSettingKey = 'character.pocketed';

  @override
  ConsumerState<CharacterOverlay> createState() => _CharacterOverlayState();
}

class _CharacterOverlayState extends ConsumerState<CharacterOverlay> with TickerProviderStateMixin {
  late final math.Random _rnd = widget.random ?? math.Random();
  late final AnimationController _walk = AnimationController(vsync: this)..addStatusListener(_onWalkStatus);
  // Удержание для живого разговора: заполняется за holdToTalk, по завершении — /talk.
  late final AnimationController _hold = AnimationController(vsync: this, duration: widget.holdToTalk)
    ..addStatusListener(_onHoldStatus);
  bool _holdFired = false;
  // Фиксируем сервис в initState: ref нельзя использовать в dispose.
  late final TtsService _tts;

  bool? _pocketed;
  CharacterState _state = CharacterState.idle;
  bool _facingLeft = false;
  double _x = .85;
  double _walkFrom = .85;
  double _walkTo = .85;
  double _dragDy = 0;
  String? _bubble;
  bool _speaking = false;
  bool _still = false;
  int _speechSerial = 0;

  Timer? _brainTimer;
  Timer? _sleepTimer;
  Timer? _bubbleTimer;
  Timer? _stateTimer;
  Timer? _nudgeTimer;
  Timer? _outcomeTimer;
  StreamSubscription<GameOutcome>? _outcomeSub;
  final List<GameOutcome> _pendingOutcomes = [];
  final GlobalKey _characterKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tts = ref.read(characterTtsProvider);
    try {
      _outcomeSub = ref.read(questServiceProvider).outcomes.listen(_onOutcome);
    } on Object catch (e) {
      // Движок не подключён (предпросмотр/тест без override) — без реакций на квесты.
      debugPrint('CharacterOverlay: нет QuestService ($e)');
    }
    ref.read(databaseProvider).getSetting(CharacterOverlay.pocketSettingKey).then((v) {
      if (mounted) setState(() => _pocketed = v == 'true');
    }, onError: (Object _) {
      if (mounted) setState(() => _pocketed = false);
    });
    GestureBinding.instance.pointerRouter.addGlobalRoute(_onGlobalPointer);
    _resetSleep();
    _scheduleBrain();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (_still && _walk.isAnimating) _walk.stop();
  }

  @override
  void dispose() {
    GestureBinding.instance.pointerRouter.removeGlobalRoute(_onGlobalPointer);
    _brainTimer?.cancel();
    _sleepTimer?.cancel();
    _bubbleTimer?.cancel();
    _stateTimer?.cancel();
    _nudgeTimer?.cancel();
    _outcomeTimer?.cancel();
    _outcomeSub?.cancel();
    _walk.dispose();
    _hold.dispose();
    if (_speaking) _tts.stop();
    super.dispose();
  }

  // ---- Поведение ----

  /// Любое касание экрана: сбрасывает таймер сна и будит персонажа.
  void _onGlobalPointer(PointerEvent e) {
    if (e is! PointerDownEvent) return;
    _resetSleep();
    if (_state == CharacterState.sleep && mounted) _setState(CharacterState.idle);
  }

  void _resetSleep() {
    _nudgeTimer?.cancel();
    _nudgeTimer = Timer(widget.nudgeAfter, _nudge);
    _sleepTimer?.cancel();
    _sleepTimer = Timer(widget.sleepAfter, () {
      if (!mounted || _bubble != null) return;
      _walk.stop();
      _stateTimer?.cancel();
      _setState(CharacterState.sleep);
    });
  }

  void _scheduleBrain() {
    _brainTimer?.cancel();
    if (!widget.autonomous) return;
    _brainTimer = Timer(Duration(milliseconds: 7000 + _rnd.nextInt(9000)), () {
      if (!mounted) return;
      _think();
      _scheduleBrain();
    });
  }

  /// Сам решает, чем заняться, если сейчас свободен.
  void _think() {
    if (_pocketed != false || _state != CharacterState.idle || _bubble != null) return;
    final r = _rnd.nextDouble();
    if (r < .55 && !_still) {
      _walkToX(.05 + _rnd.nextDouble() * .9);
    } else if (r < .8) {
      _setState(CharacterState.sit);
      _stateTimer?.cancel();
      _stateTimer = Timer(Duration(seconds: 6 + _rnd.nextInt(6)), () {
        if (mounted && _state == CharacterState.sit) _setState(CharacterState.idle);
      });
    }
  }

  void _walkToX(double to) {
    final width = context.size?.width ?? 360;
    final distance = (to - _x).abs() * width;
    if (distance < 12) return;
    _walkFrom = _x;
    _walkTo = to;
    _facingLeft = to < _x;
    _walk.duration = Duration(milliseconds: math.max(1200, (distance / 38 * 1000).round()));
    _setState(CharacterState.walk);
    _walk.forward(from: 0);
  }

  void _onWalkStatus(AnimationStatus s) {
    if (s == AnimationStatus.completed && mounted) {
      _x = _walkTo;
      if (_state == CharacterState.walk) _setState(CharacterState.idle);
    }
  }

  void _stopWalking() {
    if (_walk.isAnimating) {
      _walk.stop();
      _x = _walkFrom + (_walkTo - _walkFrom) * _walk.value;
    }
  }

  void _setState(CharacterState s) {
    if (!mounted) return;
    setState(() => _state = s);
  }

  Map<String, Object?> get _section =>
      ref.read(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};

  bool get _active => _pocketed == false && archetypeFromName(_section['archetype']) != null;

  String get _mode => motivationOf(_section['motivation']);

  String _playerName(AppLocalizations l) {
    final n = ref.read(profileProvider).value?.name.trim() ?? '';
    return n.isEmpty ? l.chrPlayerFallback : n;
  }

  // ---- События квестов ----

  /// Итоги приходят пачкой (tick) — копим 600 мс и реагируем на самое значимое.
  void _onOutcome(GameOutcome o) {
    if (outcomeWeight(o) == 0) return;
    _pendingOutcomes.add(o);
    _outcomeTimer?.cancel();
    _outcomeTimer = Timer(const Duration(milliseconds: 600), _flushOutcomes);
  }

  void _flushOutcomes() {
    if (!mounted || _pendingOutcomes.isEmpty) return;
    final top = _pendingOutcomes.reduce((a, b) => outcomeWeight(b) > outcomeWeight(a) ? b : a);
    _pendingOutcomes.clear();
    if (!_active) return;
    final l = AppLocalizations.of(context);
    final r = outcomeLine(l, top, _mode, _playerName(l), _rnd);
    if (r != null) _react(CharacterReaction(r.state, line: r.line, serial: 0));
  }

  // ---- Долгий простой ----

  void _nudge() {
    if (!mounted || !_active || _bubble != null) return;
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) return;
    final l = AppLocalizations.of(context);
    final line = idleLine(l, _mode, _playerName(l), _rnd);
    _sleepTimer?.cancel();
    _stateTimer?.cancel();
    if (_state == CharacterState.sleep || _state == CharacterState.sit) _setState(CharacterState.idle);
    if (!_still) _walkToX(.5);
    final walking = _state == CharacterState.walk;
    final serial = _speechSerial;
    _stateTimer = Timer(walking ? (_walk.duration ?? Duration.zero) : Duration.zero, () {
      if (mounted && serial == _speechSerial && _active) _say(line, CharacterState.point);
    });
  }

  // ---- Жесты ----

  /// Обычный тап: короткая реплика (облачко + голос), чат не открывается.
  void _tapTalk() {
    _resetSleep();
    if (_holdFired) {
      _holdFired = false;
      return;
    }
    if (!_active) return;
    final l = AppLocalizations.of(context);
    _say(tapLine(l, _mode, _rnd), CharacterState.happy);
  }

  void _holdStart() {
    _holdFired = false;
    _hold.forward(from: 0);
  }

  void _holdCancel() {
    if (_hold.isAnimating || (_hold.value > 0 && !_holdFired)) _hold.reset();
  }

  void _onHoldStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed || !mounted) return;
    _holdFired = true;
    _hold.reset();
    HapticFeedback.mediumImpact();
    _openTalk();
  }

  /// Живой голосовой разговор (экран /talk; оттуда доступен и текстовый чат).
  void _openTalk() {
    _resetSleep();
    if (_speaking) _tts.stop();
    _speechSerial++;
    if (_bubble != null) setState(() => _bubble = null);
    GoRouter.maybeOf(context)?.push(Routes.talk);
  }

  void _react(CharacterReaction r) {
    if (!_active) return;
    _resetSleep();
    final line = r.line;
    if (line != null && line.trim().isNotEmpty) {
      _say(line, r.state, voice: r.voice);
    } else {
      _stopWalking();
      _setState(r.state);
      _stateTimer?.cancel();
      _stateTimer = Timer(const Duration(seconds: 3), () => _setState(CharacterState.idle));
    }
  }

  /// Реплика в облачке + озвучка. Персонаж в состоянии [state] минимум ~2.5 с и до конца фразы.
  void _say(String line, CharacterState state, {bool voice = true}) {
    _stopWalking();
    final archetype = archetypeFromName(_section['archetype']);
    if (archetype == null) return;
    final profileVoice = CharacterProfile.of(archetype).voiceById(_section['voice'] as String?);
    final lang = Localizations.localeOf(context).languageCode;
    final serial = ++_speechSerial;
    if (!voice && _speaking) _tts.stop();
    setState(() {
      _state = state;
      _bubble = line;
      _speaking = voice;
    });
    var minElapsed = false;
    var spoken = false;
    void maybeIdle() {
      if (minElapsed && spoken && serial == _speechSerial && _state == state) _setState(CharacterState.idle);
    }

    _stateTimer?.cancel();
    _stateTimer = Timer(const Duration(milliseconds: 2500), () {
      minElapsed = true;
      maybeIdle();
    });
    _bubbleTimer?.cancel();
    _bubbleTimer = Timer(Duration(milliseconds: math.max(4000, line.length * 70)), () {
      if (mounted && serial == _speechSerial) setState(() => _bubble = null);
    });
    final speech = voice ? _tts.speak(line, languageCode: lang, voice: profileVoice) : Future<void>.value();
    speech.catchError((Object _) {}).whenComplete(() {
      if (!mounted || serial != _speechSerial) return;
      _speaking = false;
      spoken = true;
      maybeIdle();
    });
  }

  void _hideBubble() {
    _bubbleTimer?.cancel();
    setState(() => _bubble = null);
  }

  void _setPocketed(bool v) {
    _stopWalking();
    _stateTimer?.cancel();
    _bubbleTimer?.cancel();
    if (v && _speaking) _tts.stop();
    setState(() {
      _pocketed = v;
      _dragDy = 0;
      _bubble = null;
      _speaking = false;
      _state = CharacterState.idle;
    });
    _speechSerial++;
    ref.read(databaseProvider).setSetting(CharacterOverlay.pocketSettingKey, '$v').catchError((Object e) {
      debugPrint('Не удалось сохранить карман персонажа: $e');
    });
  }

  // ---- Отрисовка ----

  @override
  Widget build(BuildContext context) {
    ref.listen<CharacterReaction?>(characterReactionProvider, (_, next) {
      if (next != null) _react(next);
    });
    final data = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};
    final archetype = archetypeFromName(data['archetype']);
    final pocketed = _pocketed;
    if (archetype == null || pocketed == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    final h = widget.characterHeight;
    final renderer = ref.watch(characterRendererProvider);
    final w = renderer.widthFor(h);

    if (pocketed) {
      return Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 16,
            child: _PocketTab(label: l.chrPocketTab, onTap: () => _setPocketed(false)),
          ),
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final maxLeft = math.max(0.0, c.maxWidth - w);
        return AnimatedBuilder(
          animation: _walk,
          builder: (context, _) {
            final x = _walk.isAnimating ? _walkFrom + (_walkTo - _walkFrom) * _walk.value : _x;
            final left = maxLeft * x;
            const bubbleW = 220.0;
            final bubbleLeft = (left + w / 2 - bubbleW / 2).clamp(4.0, math.max(4.0, c.maxWidth - bubbleW - 4)).toDouble();
            final bubble = _bubble;
            final ring = h + 16;
            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (bubble != null)
                  Positioned(
                    left: bubbleLeft,
                    bottom: h + 4,
                    width: bubbleW,
                    child: _SpeechBubble(
                      key: const ValueKey('chrBubble'),
                      text: bubble,
                      onTap: _hideBubble,
                    ),
                  ),
                // Кольцо удержания вокруг персонажа (появляется не сразу, чтобы не мигать на тапах).
                Positioned(
                  left: left + w / 2 - ring / 2,
                  bottom: h / 2 - ring / 2,
                  width: ring,
                  height: ring,
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _hold,
                      builder: (context, _) => _hold.value < .08
                          ? const SizedBox.shrink()
                          : CustomPaint(key: const ValueKey('chrHoldRing'), painter: _HoldRingPainter(_hold.value)),
                    ),
                  ),
                ),
                Positioned(
                  left: left,
                  bottom: 0,
                  width: w,
                  height: h,
                  child: Transform.translate(
                    offset: Offset(0, _dragDy),
                    child: Semantics(
                      button: true,
                      label: l.chrSemanticsTalk(archetypeName(l, archetype)),
                      onTap: _tapTalk,
                      onLongPress: _openTalk,
                      child: Listener(
                        onPointerDown: (_) => _holdStart(),
                        onPointerUp: (_) => _holdCancel(),
                        onPointerCancel: (_) => _holdCancel(),
                        child: GestureDetector(
                          key: const ValueKey('chrOverlayCharacter'),
                          behavior: HitTestBehavior.opaque,
                          excludeFromSemantics: true,
                          onTap: _tapTalk,
                          onVerticalDragStart: (_) => _holdCancel(),
                          onVerticalDragUpdate: (d) => setState(() => _dragDy = math.max(0.0, _dragDy + d.delta.dy)),
                          onVerticalDragEnd: (d) {
                            if (_dragDy > 28 || (d.primaryVelocity ?? 0) > 400) {
                              _setPocketed(true);
                            } else {
                              setState(() => _dragDy = 0);
                            }
                          },
                          child: ExcludeSemantics(
                            child: renderer.build(
                              CharacterRenderSpec(archetype: archetype, state: _state, height: h, facingLeft: _facingLeft),
                              key: _characterKey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SpeechBubble extends StatelessWidget {
  const _SpeechBubble({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.bottomCenter,
        child: Semantics(
          liveRegion: true,
          button: true,
          label: text,
          hint: AppLocalizations.of(context).commonClose,
          excludeSemantics: true,
          child: GestureDetector(
            onTap: onTap,
            child: WindowAppear(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SysDims.radius),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [SysColors.panelTop, SysColors.panelBottom],
                  ),
                  border: Border.all(color: SysColors.panelBorder),
                  boxShadow: const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 16)],
                ),
                child: Text(text, style: SysText.body),
              ),
            ),
          ),
        ),
      );
}

/// Язычок у правого края: персонаж в кармане, тап — вернуть.
class _PocketTab extends StatelessWidget {
  const _PocketTab({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: GestureDetector(
          key: const ValueKey('chrPocketTab'),
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: SizedBox(
            width: SysDims.minTap,
            height: 52,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                width: 22,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                  gradient: const LinearGradient(colors: [SysColors.panelTop, SysColors.panelBottom]),
                  border: Border.all(color: SysColors.panelBorder),
                  boxShadow: const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 12)],
                ),
                child: const Center(child: SysIcon(SysGlyph.sparkle, size: 14, color: SysColors.accentLighter)),
              ),
            ),
          ),
        ),
      );
}

/// Кольцо заполнения при удержании персонажа: тонкий трек + светящаяся дуга по часовой.
class _HoldRingPainter extends CustomPainter {
  const _HoldRingPainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(3);
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..color = SysColors.accent.withValues(alpha: .18);
    canvas.drawOval(rect, track);
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = SysColors.accentLighter
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 3);
    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * value.clamp(0.0, 1.0), false, arc);
  }

  @override
  bool shouldRepaint(_HoldRingPainter old) => old.value != value;
}
