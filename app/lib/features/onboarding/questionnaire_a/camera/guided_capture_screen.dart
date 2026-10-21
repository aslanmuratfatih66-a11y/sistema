import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../core/data/questionnaire_repository.dart';
import '../../../../core/db/database.dart';
import '../../../../core/models/enums.dart';
import '../../../../core/voice/tts_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import '../../../character/character_view.dart';
import '../../../character/model/character_profile.dart';
import '../data/photo_repository.dart';
import '../widgets/tip_line.dart';
import 'capture_guide.dart';
import 'guided_session.dart';
import 'mirror.dart';

/// Вид сессии: тело (3 ракурса, ~2 м) или лицо (3 ракурса, ~50 см).
enum GuidedSessionKind { body, face }

extension on GuidedSessionKind {
  List<SessionShot> get shots => this == GuidedSessionKind.body ? SessionShot.body : SessionShot.face;
  PhotoKind get photoKind => this == GuidedSessionKind.body ? PhotoKind.body : PhotoKind.skin;
  int get defaultDelay => this == GuidedSessionKind.body ? 10 : 5;
  String get settingKey => 'photoSession.delay.$name';
}

/// Название ракурса для экрана и голоса.
String poseLabel(AppLocalizations l, PhotoPose pose) => switch (pose) {
      PhotoPose.bodyFront => l.qaPoseBodyFront,
      PhotoPose.bodySide => l.qaPoseBodySide,
      PhotoPose.bodyBack => l.qaPoseBodyBack,
      PhotoPose.faceFront => l.qaPoseFaceFront,
      PhotoPose.faceLeft => l.qaPoseFaceLeft,
      PhotoPose.faceRight => l.qaPoseFaceRight,
      _ => l.qaPoseCloseup,
    };

/// Фразы сессии из локализации.
class L10nSessionPhrases implements SessionPhrases {
  const L10nSessionPhrases(this.l);

  final AppLocalizations l;

  @override
  String instruction(SessionShot shot, {required bool first}) => switch (shot.pose) {
        PhotoPose.bodyFront => l.qaShootSayBodyFront,
        PhotoPose.bodySide => l.qaShootSayBodySide,
        PhotoPose.bodyBack => l.qaShootSayBodyBack,
        PhotoPose.faceFront => l.qaShootSayFaceFront,
        PhotoPose.faceLeft => l.qaShootSayFaceLeft,
        PhotoPose.faceRight => l.qaShootSayFaceRight,
        _ => l.qaPoseCloseupHint,
      };

  @override
  String count(int n) => '$n';

  @override
  String taken(SessionShot? next) => next == null ? l.qaShootTakenLast : l.qaShootTaken(poseLabel(l, next.pose));

  @override
  String failed() => l.qaShootFailed;
}

enum _CameraError { none, unavailable, denied }

/// Фото-сессия «под руководством Системы»: подготовка → ракурсы подряд с голосом и обратным отсчётом →
/// просмотр с «Переснять» → «Готово» сохраняет все снимки через [PhotoService]. Возвращает true, если сохранено.
class GuidedCaptureScreen extends ConsumerStatefulWidget {
  const GuidedCaptureScreen({super.key, required this.kind});

  final GuidedSessionKind kind;

  static Future<bool> open(BuildContext context, GuidedSessionKind kind) async =>
      await Navigator.of(context).push<bool>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => GuidedCaptureScreen(kind: kind),
      )) ??
      false;

  @override
  ConsumerState<GuidedCaptureScreen> createState() => _GuidedCaptureScreenState();
}

class _GuidedCaptureScreenState extends ConsumerState<GuidedCaptureScreen>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin
    implements ShotSource {
  List<CameraDescription>? _cameras;
  CameraController? _camera;
  bool _starting = false;
  _CameraError _error = _CameraError.none;

  /// Снимает другой человек — основная камера, можно без отсчёта.
  bool _operator = false;
  GuidedSessionController? _session;
  late final AnimationController _flash =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 450), value: 0);
  bool _saving = false;
  bool _saveFailed = false;

  bool get _front => _camera?.description.lensDirection == CameraLensDirection.front;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_session != null) return;
    final s = GuidedSessionController(
      shots: widget.kind.shots,
      source: this,
      tts: ref.read(ttsServiceProvider),
      phrases: L10nSessionPhrases(AppLocalizations.of(context)),
      languageCode: Localizations.localeOf(context).languageCode,
      countdownSeconds: widget.kind.defaultDelay,
      onTick: (_) {
        SystemSound.play(SystemSoundType.click);
        HapticFeedback.selectionClick();
      },
      onCaptured: () => _flash.reverse(from: 1).then((_) {}, onError: (_) {}),
    )..addListener(_onSession);
    _session = s;
    _loadDelay(s);
  }

  Future<void> _loadDelay(GuidedSessionController s) async {
    try {
      final v = int.tryParse(await ref.read(databaseProvider).getSetting(widget.kind.settingKey) ?? '');
      if (v != null && const [3, 5, 10].contains(v) && mounted && s.phase == SessionPhase.preparing) {
        s.countdownSeconds = v;
      }
    } catch (e) {
      debugPrint('GuidedCapture delay: $e');
    }
  }

  void _setDelay(int v) {
    _session?.countdownSeconds = v;
    if (v > 0) unawaited(ref.read(databaseProvider).setSetting(widget.kind.settingKey, '$v').catchError((_) {}));
  }

  void _onSession() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    final s = _session;
    if (s != null) {
      s.removeListener(_onSession);
      if (s.phase != SessionPhase.cancelled) unawaited(s.cancel()); // удалит временные снимки
      s.dispose();
    }
    _flash.dispose();
    _camera?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _session?.pause();
      final c = _camera;
      if (c != null && !_starting) {
        _camera = null;
        c.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed) {
      if (_camera == null && !_starting) _initCamera();
    }
  }

  // ---- камера ----

  Future<void> _initCamera() async {
    _starting = true;
    if (_error != _CameraError.none) setState(() => _error = _CameraError.none);
    try {
      final cams = _cameras ??= await availableCameras();
      if (cams.isEmpty) return _fail(_CameraError.unavailable);
      final want = _operator ? CameraLensDirection.back : CameraLensDirection.front;
      final i = cams.indexWhere((c) => c.lensDirection == want);
      await _start(cams[i < 0 ? 0 : i]);
    } on CameraException catch (e) {
      _fail(e.code.startsWith('CameraAccess') ? _CameraError.denied : _CameraError.unavailable);
    } catch (e) {
      debugPrint('GuidedCapture camera: $e');
      _fail(_CameraError.unavailable);
    } finally {
      _starting = false;
    }
  }

  void _fail(_CameraError e) {
    if (mounted) setState(() => _error = e);
  }

  Future<void> _start(CameraDescription d) async {
    _starting = true;
    final old = _camera;
    if (old != null) {
      setState(() => _camera = null);
      await old.dispose();
    }
    final c = CameraController(d, ResolutionPreset.high, enableAudio: false);
    try {
      await c.initialize();
    } catch (_) {
      await c.dispose();
      rethrow;
    } finally {
      _starting = false;
    }
    if (!mounted) {
      await c.dispose();
      return;
    }
    setState(() => _camera = c);
  }

  void _setOperator(bool v) {
    setState(() => _operator = v);
    final s = _session;
    if (s != null) {
      if (!v && s.countdownSeconds == 0) s.countdownSeconds = widget.kind.defaultDelay;
    }
    if (!_starting) _initCamera();
  }

  // ---- ShotSource ----

  @override
  Future<String?> capture() async {
    final c = _camera;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture) return null;
    final front = c.description.lensDirection == CameraLensDirection.front;
    try {
      final x = await c.takePicture();
      // Снимок сохраняем «как видит другой»: на iOS фронтальный снимок зеркальный — отражаем (mirror.dart).
      if (captureIsMirrored(frontCamera: front)) return await mirrorImageFile(x.path);
      return x.path;
    } on CameraException catch (e) {
      debugPrint('takePicture: ${e.code} ${e.description}');
      return null;
    } catch (e) {
      debugPrint('takePicture/mirror: $e');
      return null;
    }
  }

  @override
  Future<void> discard(String path) async {
    try {
      await File(path).delete();
    } catch (_) {}
  }

  // ---- сохранение ----

  Future<void> _done() async {
    final s = _session;
    if (s == null || _saving) return;
    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    final service = ref.read(photoServiceProvider);
    final kind = widget.kind.photoKind;
    try {
      for (final (i, shot) in s.shots.indexed) {
        final path = s.results[i];
        if (path == null) continue;
        await service.save(sourcePath: path, kind: kind, pose: shot.pose);
      }
    } catch (e) {
      debugPrint('GuidedCapture save: $e');
      if (mounted) {
        setState(() {
          _saving = false;
          _saveFailed = true;
        });
      }
      return;
    }
    // Файлы скопированы в хранилище — временные удаляем.
    for (final path in s.takeResults().values) {
      await discard(path);
    }
    if (mounted) Navigator.of(context).pop(true);
  }

  Future<void> _close() async {
    await _session?.cancel();
    if (mounted) Navigator.of(context).pop(false);
  }

  // ---- UI ----

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = _session!;
    final total = s.shots.length;
    // Ассистент выбран в начале анкеты — он и ведёт съёмку своим голосом.
    final character = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};
    final archetype = archetypeFromName(character['archetype']);
    s.voice = archetype == null ? null : CharacterProfile.of(archetype).voiceById(character['voice'] as String?);
    return PopScope(
      canPop: !s.running,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) s.pause();
      },
      child: Scaffold(
        backgroundColor: SysColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (widget.kind == GuidedSessionKind.body ? l.qaShootTitleBody : l.qaShootTitleFace).toUpperCase(),
                        style: SysText.heading,
                      ),
                    ),
                    if (s.running) Text(l.qaShootShotOf(s.index + 1, total), style: SysText.monoSmall),
                    IconButton(
                      tooltip: l.commonClose,
                      onPressed: _close,
                      icon: const SysIcon(SysGlyph.close, size: 20),
                    ),
                  ],
                ),
              ),
              Expanded(child: _body(l, s, archetype)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l, GuidedSessionController s, CharacterArchetype? archetype) {
    if (_error != _CameraError.none) {
      final denied = _error == _CameraError.denied;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SystemWindow(
            kind: SystemWindowKind.warning,
            label: l.qaCameraWarningLabel,
            message: denied ? l.qaCameraDenied : l.qaCameraUnavailable,
            actions: [
              if (denied) SysButton.primary(label: l.qaCameraOpenSettings, onPressed: () => openAppSettings()),
              SysButton.secondary(label: l.commonClose, onPressed: _close),
            ],
          ),
        ),
      );
    }
    return switch (s.phase) {
      SessionPhase.preparing => _prepare(l, s),
      SessionPhase.review || SessionPhase.cancelled => _review(l, s),
      _ => _running(l, s, archetype),
    };
  }

  /// Превью + контур текущего ракурса (с учётом зеркальности превью фронтальной камеры).
  Widget _preview(CaptureGuide guide) {
    final c = _camera;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: SysColors.accent));
    }
    return Center(
      child: CameraPreview(
        c,
        child: IgnorePointer(
          child: CustomPaint(
            painter: CaptureGuidePainter(guide, mirrored: previewIsMirrored(frontCamera: _front)),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _prepare(AppLocalizations l, GuidedSessionController s) {
    final body = widget.kind == GuidedSessionKind.body;
    final tips = body
        ? [l.qaShootPrepPhoneBody, l.qaShootPrepDistanceBody, l.qaShootPrepLight, l.qaBodyTipClothes, l.qaShootPrepSound]
        : [l.qaShootPrepPhoneFace, l.qaShootPrepLight, l.qaSkinTipClean, l.qaSkinTipHair, l.qaShootPrepSound];
    final delays = [3, 5, 10, if (_operator) 0];
    final ready = _camera?.value.isInitialized == true;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(flex: 2, child: _preview(s.shots.first.guide)),
        Expanded(
          flex: 3,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            children: [
              SysPanel(
                title: l.qaShootPrepTitle,
                animateIn: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (final t in tips) TipLine(t)],
                ),
              ),
              const SysFieldGap(),
              SysFieldLabel(l.qaShootDelay),
              SysSegmented<int>(
                choices: [
                  for (final d in delays) SysChoice(d, d == 0 ? l.qaShootDelayManual : l.qaShootDelaySec(d)),
                ],
                value: s.countdownSeconds,
                onChanged: _setDelay,
              ),
              const SysFieldGap(),
              if ((_cameras?.length ?? 0) > 1) ...[
                SysSwitchRow(
                  label: l.qaShootOperator,
                  hint: l.qaShootOperatorHint,
                  value: _operator,
                  onChanged: _starting ? (_) {} : _setOperator,
                ),
                const SysFieldGap(),
              ],
              SysButton.primary(label: l.qaShootStart, onPressed: ready ? s.start : null, expand: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _running(AppLocalizations l, GuidedSessionController s, CharacterArchetype? archetype) {
    final countdown = s.phase == SessionPhase.countdown && !s.paused;
    return Stack(
      fit: StackFit.expand,
      children: [
        _preview(s.current.guide),
        // Вспышка-подтверждение снимка.
        IgnorePointer(
          child: FadeTransition(
            opacity: _flash,
            child: const ColoredBox(color: Color(0xCCFFFFFF)),
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 8,
          child: SysPanel(
            title: poseLabel(l, s.current.pose),
            animateIn: false,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (archetype != null) ...[
                  CharacterView(
                    archetype: archetype,
                    state: s.speaking ? CharacterState.talk : CharacterState.idle,
                    height: 72,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(child: Text(s.caption, style: SysText.body)),
              ],
            ),
          ),
        ),
        if (countdown)
          Center(
            child: Text(
              '${s.remaining}',
              style: SysText.monoLarge.copyWith(
                fontSize: 140,
                color: SysColors.accentLighter,
                shadows: const [Shadow(color: SysColors.accent, blurRadius: 24)],
              ),
            ),
          ),
        if (s.phase == SessionPhase.capturing)
          const Center(child: CircularProgressIndicator(color: SysColors.accentLighter)),
        if (s.paused)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SystemWindow(
                kind: SystemWindowKind.notice,
                label: l.qaShootPause,
                title: l.qaShootPausedTitle,
                message: l.qaShootPausedHint,
                actions: [
                  SysButton.primary(label: l.qaShootResume, onPressed: _camera == null ? null : s.resume),
                  SysButton.secondary(label: l.qaShootStop, onPressed: _close),
                ],
              ),
            ),
          ),
        Positioned(left: 16, right: 16, bottom: 16, child: _runningControls(l, s)),
      ],
    );
  }

  Widget _runningControls(AppLocalizations l, GuidedSessionController s) {
    if (s.paused) return const SizedBox.shrink();
    if (s.phase == SessionPhase.failed) {
      return Row(
        children: [
          Expanded(child: SysButton.primary(label: l.qaShootRetry, onPressed: s.retry, expand: true)),
          const SizedBox(width: 12),
          Expanded(child: SysButton.secondary(label: l.qaShootStop, onPressed: _close, expand: true)),
        ],
      );
    }
    final manual = s.phase == SessionPhase.waitingShutter;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (manual) ...[
          Text(l.qaShootWaitShutter, style: SysText.secondary, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          SysButton.primary(label: l.qaCameraShutter, onPressed: s.shutter, expand: true),
          const SizedBox(height: 8),
        ],
        SysButton.secondary(label: l.qaShootPause, onPressed: s.pause, expand: true),
      ],
    );
  }

  Widget _review(AppLocalizations l, GuidedSessionController s) {
    final results = s.results;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l.qaShootReviewTitle.toUpperCase(), style: SysText.title),
        const SizedBox(height: 4),
        Text(l.qaShootReviewHint, style: SysText.secondary),
        const SysFieldGap(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final (i, shot) in s.shots.indexed) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AspectRatio(
                      aspectRatio: 3 / 4,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(SysDims.radius),
                          border: Border.all(color: SysColors.accentLight),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SysDims.radius),
                          child: results[i] == null
                              ? CustomPaint(painter: CaptureGuidePainter(shot.guide, color: SysColors.textInactive))
                              : Image.file(File(results[i]!), fit: BoxFit.cover, cacheWidth: 360),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(poseLabel(l, shot.pose), style: SysText.caption, textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    SysButton.secondary(
                      label: l.qaCameraRetake,
                      onPressed: _saving || _camera == null ? null : () => s.retake(i),
                      expand: true,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SysFieldGap(),
        if (_saveFailed) ...[
          Text(l.qaShootSaveFailed, style: SysText.secondary.copyWith(color: SysColors.dangerLight)),
          const SizedBox(height: 8),
        ],
        SysButton.primary(
          label: l.commonDone,
          onPressed: _saving || results.every((r) => r == null) ? null : _done,
          expand: true,
        ),
      ],
    );
  }
}
