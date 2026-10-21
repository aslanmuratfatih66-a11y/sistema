// Персонаж поверх всех вкладок (SPEC §9.2). Минимальная версия этапа 1.1: живёт внизу над нижней
// навигацией, гуляет, садится, засыпает без касаний, по тапу говорит реплику, свайпом вниз прячется в «карман».
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/tts_service.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import 'character_reaction.dart';
import 'character_view.dart';
import 'model/character_profile.dart';

/// Оверлей персонажа. Не перехватывает нажатия вне самого персонажа и его облачка:
/// пустая область Stack не участвует в hit-test, касания проходят к интерфейсу ниже.
class CharacterOverlay extends ConsumerStatefulWidget {
  const CharacterOverlay({
    super.key,
    this.characterHeight = 90,
    this.sleepAfter = const Duration(minutes: 2),
    this.autonomous = true,
    this.random,
  });

  final double characterHeight;

  /// Через сколько без касаний персонаж засыпает.
  final Duration sleepAfter;

  /// Сам ли гуляет/садится (в тестах можно выключить).
  final bool autonomous;
  final math.Random? random;

  /// Ключ AppSettings: персонаж убран в карман ('true'/'false').
  static const pocketSettingKey = 'character.pocketed';

  @override
  ConsumerState<CharacterOverlay> createState() => _CharacterOverlayState();
}

class _CharacterOverlayState extends ConsumerState<CharacterOverlay> with SingleTickerProviderStateMixin {
  late final math.Random _rnd = widget.random ?? math.Random();
  late final AnimationController _walk = AnimationController(vsync: this)..addStatusListener(_onWalkStatus);
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

  @override
  void initState() {
    super.initState();
    _tts = ref.read(ttsServiceProvider);
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
    _walk.dispose();
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

  void _onTap() {
    _resetSleep();
    final l = AppLocalizations.of(context);
    final lines = tapLines(l, motivationOf(_section['motivation']));
    _say(lines[_rnd.nextInt(lines.length)], CharacterState.talk);
  }

  void _react(CharacterReaction r) {
    if (_pocketed != false || archetypeFromName(_section['archetype']) == null) return;
    _resetSleep();
    final line = r.line;
    if (line != null && line.trim().isNotEmpty) {
      _say(line, r.state);
    } else {
      _stopWalking();
      _setState(r.state);
      _stateTimer?.cancel();
      _stateTimer = Timer(const Duration(seconds: 3), () => _setState(CharacterState.idle));
    }
  }

  /// Реплика в облачке + озвучка. Персонаж в состоянии [state] минимум ~2.5 с и до конца фразы.
  void _say(String line, CharacterState state) {
    _stopWalking();
    final archetype = archetypeFromName(_section['archetype']);
    if (archetype == null) return;
    final voice = CharacterProfile.of(archetype).voiceById(_section['voice'] as String?);
    final lang = Localizations.localeOf(context).languageCode;
    final serial = ++_speechSerial;
    setState(() {
      _state = state;
      _bubble = line;
      _speaking = true;
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
    _tts.speak(line, languageCode: lang, voice: voice).catchError((Object _) {}).whenComplete(() {
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
    final w = CharacterView.widthFor(h);

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
                Positioned(
                  left: left,
                  bottom: 0,
                  width: w,
                  height: h,
                  child: Transform.translate(
                    offset: Offset(0, _dragDy),
                    child: Semantics(
                      button: true,
                      label: l.chrSemantics(archetypeName(l, archetype)),
                      child: GestureDetector(
                        key: const ValueKey('chrOverlayCharacter'),
                        behavior: HitTestBehavior.opaque,
                        onTap: _onTap,
                        onVerticalDragUpdate: (d) => setState(() => _dragDy = math.max(0.0, _dragDy + d.delta.dy)),
                        onVerticalDragEnd: (d) {
                          if (_dragDy > 28 || (d.primaryVelocity ?? 0) > 400) {
                            _setPocketed(true);
                          } else {
                            setState(() => _dragDy = 0);
                          }
                        },
                        child: ExcludeSemantics(
                          child: CharacterView(
                            archetype: archetype,
                            state: _state,
                            height: h,
                            facingLeft: _facingLeft,
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
