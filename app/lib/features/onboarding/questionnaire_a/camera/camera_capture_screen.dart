import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../ui/ui.dart';
import 'capture_guide.dart';
import 'mirror.dart';

enum _CameraError { none, unavailable, denied }

/// Экран съёмки: превью камеры + контурная подсказка + инструкция, снимок, смена камеры,
/// предпросмотр «Переснять / Сохранить». Возвращает путь к временному файлу снимка (или null).
/// Переиспользуется: анкета (тело, кожа), «контрольное фото» (этап 3).
class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({
    super.key,
    required this.guide,
    required this.title,
    required this.instruction,
    this.preferFrontCamera = false,
  });

  final CaptureGuide guide;
  final String title;
  final String instruction;
  final bool preferFrontCamera;

  static Future<String?> open(
    BuildContext context, {
    required CaptureGuide guide,
    required String title,
    required String instruction,
    bool preferFrontCamera = false,
  }) =>
      Navigator.of(context).push<String>(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => CameraCaptureScreen(
          guide: guide,
          title: title,
          instruction: instruction,
          preferFrontCamera: preferFrontCamera,
        ),
      ));

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> with WidgetsBindingObserver {
  List<CameraDescription>? _cameras;
  int _index = 0;
  CameraController? _controller;
  bool _starting = false;
  bool _busy = false;
  _CameraError _error = _CameraError.none;
  XFile? _shot;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    final shot = _shot;
    if (shot != null && !_saved) _deleteTemp(shot);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      final c = _controller;
      if (c != null && !_starting) {
        _controller = null;
        c.dispose();
        if (mounted) setState(() {});
      }
    } else if (state == AppLifecycleState.resumed) {
      // Вернулись (в т.ч. из настроек после выдачи разрешения) — запустить камеру заново.
      if (_controller == null && !_starting && _shot == null) _init();
    }
  }

  Future<void> _init() async {
    _starting = true;
    if (_error != _CameraError.none) setState(() => _error = _CameraError.none);
    try {
      final cams = _cameras ??= await availableCameras();
      if (cams.isEmpty) {
        _fail(_CameraError.unavailable);
        return;
      }
      final want = widget.preferFrontCamera ? CameraLensDirection.front : CameraLensDirection.back;
      final i = cams.indexWhere((c) => c.lensDirection == want);
      _index = i < 0 ? 0 : i;
      await _start(cams[_index]);
    } on CameraException catch (e) {
      _fail(e.code.startsWith('CameraAccess') ? _CameraError.denied : _CameraError.unavailable);
    } catch (e) {
      debugPrint('Camera init: $e');
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
    final old = _controller;
    if (old != null) {
      setState(() => _controller = null);
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
    setState(() => _controller = c);
  }

  Future<void> _switchCamera() async {
    final cams = _cameras;
    if (cams == null || cams.length < 2 || _busy) return;
    _index = (_index + 1) % cams.length;
    try {
      await _start(cams[_index]);
    } on CameraException catch (e) {
      _fail(e.code.startsWith('CameraAccess') ? _CameraError.denied : _CameraError.unavailable);
    }
  }

  Future<void> _take() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized || c.value.isTakingPicture || _busy) return;
    setState(() => _busy = true);
    try {
      var x = await c.takePicture();
      // Сохраняем «как видит другой»: фронтальный снимок на iOS зеркальный — отражаем (см. mirror.dart).
      if (captureIsMirrored(frontCamera: c.description.lensDirection == CameraLensDirection.front)) {
        x = XFile(await mirrorImageFile(x.path));
      }
      if (mounted) {
        setState(() => _shot = x);
      } else {
        _deleteTemp(x);
      }
    } on CameraException catch (e) {
      debugPrint('takePicture: ${e.code} ${e.description}');
    } catch (e) {
      debugPrint('takePicture/mirror: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _retake() {
    final shot = _shot;
    if (shot != null) _deleteTemp(shot);
    setState(() => _shot = null);
    if (_controller == null && !_starting) _init();
  }

  void _save() {
    final shot = _shot;
    if (shot == null) return;
    _saved = true;
    Navigator.of(context).pop(shot.path);
  }

  static void _deleteTemp(XFile f) {
    File(f.path).delete().then((_) {}, onError: (_) {});
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: SysColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: Row(
                children: [
                  Expanded(child: Text(widget.title.toUpperCase(), style: SysText.heading, maxLines: 2, overflow: TextOverflow.ellipsis)),
                  SysIconButton(
                    glyph: SysGlyph.close,
                    tooltip: l.commonClose,
                    size: 20,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.instruction, style: SysText.secondary),
            ),
            const SizedBox(height: 8),
            Expanded(child: _body(l)),
            _controls(l),
          ],
        ),
      ),
    );
  }

  Widget _body(AppLocalizations l) {
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
              SysButton.secondary(label: l.commonClose, onPressed: () => Navigator.of(context).maybePop()),
            ],
          ),
        ),
      );
    }
    final shot = _shot;
    if (shot != null) {
      return Center(child: Image.file(File(shot.path), fit: BoxFit.contain));
    }
    final c = _controller;
    if (c == null || !c.value.isInitialized) {
      return const Center(child: SysLoader(color: SysColors.accent));
    }
    return Center(
      child: CameraPreview(
        c,
        child: IgnorePointer(
          child: CustomPaint(
            painter: CaptureGuidePainter(
              widget.guide,
              mirrored: previewIsMirrored(frontCamera: c.description.lensDirection == CameraLensDirection.front),
            ),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }

  Widget _controls(AppLocalizations l) {
    if (_error != _CameraError.none) return const SizedBox(height: 16);
    if (_shot != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(child: SysButton.secondary(label: l.qaCameraRetake, onPressed: _retake, expand: true)),
            const SizedBox(width: 12),
            Expanded(child: SysButton.primary(label: l.commonSave, onPressed: _save, expand: true)),
          ],
        ),
      );
    }
    final ready = _controller?.value.isInitialized == true && !_busy;
    final canSwitch = (_cameras?.length ?? 0) > 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 56),
          Semantics(
            button: true,
            label: l.qaCameraShutter,
            excludeSemantics: true,
            child: GestureDetector(
              onTap: ready ? _take : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 160),
                opacity: ready ? 1 : .4,
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: SysColors.accentLighter, width: 3),
                    boxShadow: const [BoxShadow(color: SysColors.panelOuterGlow, blurRadius: 18, spreadRadius: 2)],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(shape: BoxShape.circle, color: SysColors.accent),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 56,
            height: 56,
            child: canSwitch
                ? SysIconButton(
                    glyph: SysGlyph.cameraSwitch,
                    tooltip: l.qaCameraSwitch,
                    size: 26,
                    onPressed: ready ? _switchCamera : null,
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
