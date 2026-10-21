import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/questionnaire_repository.dart';
import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'camera/capture_flow.dart';
import 'camera/capture_guide.dart';
import 'data/photo_repository.dart';
import 'data/serial_writer.dart';
import 'widgets/estimate_block.dart';
import 'widgets/photo_slot.dart';
import 'widgets/tip_line.dart';

/// Этап 4 «Кожа»: фото лица (анфас, профили, крупные планы) + опрос (раздел skin) + блок оценки.
class SkinStep extends ConsumerStatefulWidget {
  const SkinStep({super.key});

  @override
  ConsumerState<SkinStep> createState() => _SkinStepState();
}

class _SkinStepState extends ConsumerState<SkinStep> {
  final _writer = SerialWriter();
  bool _loaded = false;
  String? _oily;
  String? _tightness;
  String _reactions = '';
  String _routine = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final d = await ref.read(questionnaireRepositoryProvider).read(QuestionnaireSection.skin);
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _oily = d['oilyByNoon'] as String?;
      _tightness = d['tightness'] as String?;
      _reactions = d['reactions'] as String? ?? '';
      _routine = d['currentRoutine'] as String? ?? '';
    });
  }

  void _patch(Map<String, Object?> patch) =>
      _writer.run(() => ref.read(questionnaireRepositoryProvider).patch(QuestionnaireSection.skin, patch));

  /// photosTaken = есть ли хоть одно активное фото кожи из анкеты.
  void _syncPhotosTaken() => _writer.run(() async {
        final photos = await ref.read(photoRepositoryProvider).active(PhotoKind.skin);
        await ref
            .read(questionnaireRepositoryProvider)
            .patch(QuestionnaireSection.skin, {'photosTaken': photos.any((p) => p.sessionId == null)});
      });

  Future<void> _capture(PhotoPose pose, CaptureGuide guide, String title, String instruction, {bool replace = true}) async {
    final saved = await captureAndSavePhoto(
      context,
      ref,
      kind: PhotoKind.skin,
      pose: pose,
      guide: guide,
      title: title,
      instruction: instruction,
      replace: replace,
      preferFrontCamera: true,
    );
    if (saved) _syncPhotosTaken();
  }

  Future<void> _delete(PhotoRow photo) async {
    await ref.read(photoServiceProvider).delete(photo);
    _syncPhotosTaken();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    scope?.setCanProceed(true);
    final camera = ref.watch(cameraAvailableProvider);
    final photos = (ref.watch(activePhotosProvider(PhotoKind.skin)).value ?? const <PhotoRow>[])
        .where((p) => p.sessionId == null)
        .toList();
    PhotoRow? byPose(PhotoPose pose) {
      PhotoRow? last;
      for (final p in photos) {
        if (p.pose == pose.name) last = p;
      }
      return last;
    }

    final closeups = photos.where((p) => p.pose == PhotoPose.closeup.name).toList();

    Widget faceSlot(PhotoPose pose, CaptureGuide guide, String label, String instruction) => PhotoSlot(
          label: label,
          guide: guide,
          photo: byPose(pose),
          onTap: camera ? () => _capture(pose, guide, label, instruction) : null,
        );

    void addCloseup() =>
        _capture(PhotoPose.closeup, CaptureGuide.closeup, l.qaPoseCloseup, l.qaPoseCloseupHint, replace: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[
          Text(l.qaSkinIntro, style: SysText.secondary),
          const SysFieldGap(),
        ],
        SysPanel(
          title: l.qaPhotoTipsTitle,
          animateIn: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [for (final t in [l.qaSkinTipLight, l.qaSkinTipClean, l.qaSkinTipHair]) TipLine(t)],
          ),
        ),
        const SysFieldGap(),
        if (!camera) const CameraUnavailableNote(),
        SysFieldLabel(l.qaSkinFacePhotos, optional: true, optionalLabel: l.commonOptional),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: faceSlot(PhotoPose.faceFront, CaptureGuide.faceFront, l.qaPoseFaceFront, l.qaPoseFaceFrontHint)),
            const SizedBox(width: 10),
            Expanded(child: faceSlot(PhotoPose.faceLeft, CaptureGuide.faceLeft, l.qaPoseFaceLeft, l.qaPoseFaceLeftHint)),
            const SizedBox(width: 10),
            Expanded(child: faceSlot(PhotoPose.faceRight, CaptureGuide.faceRight, l.qaPoseFaceRight, l.qaPoseFaceRightHint)),
          ],
        ),
        const SysFieldGap(),
        SysFieldLabel(l.qaSkinCloseups, hint: l.qaSkinCloseupsHint, optional: true, optionalLabel: l.commonOptional),
        LayoutBuilder(builder: (context, c) {
          final w = (c.maxWidth - 20) / 3;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final p in closeups)
                SizedBox(
                  width: w,
                  child: PhotoSlot(
                    label: l.qaPoseCloseup,
                    guide: CaptureGuide.closeup,
                    photo: p,
                    onTap: null,
                    onDelete: () => _delete(p),
                  ),
                ),
              if (camera)
                SizedBox(
                  width: w,
                  child: PhotoSlot(label: l.qaSkinAddCloseup, guide: CaptureGuide.closeup, photo: null, onTap: addCloseup),
                ),
            ],
          );
        }),
        const SysFieldGap(),
        if (_loaded) ...[
          SysFieldLabel(l.qaSkinOily),
          SysSegmented<String>(
            choices: [
              SysChoice('no', l.qaSkinOilyNo),
              SysChoice('tzone', l.qaSkinOilyTzone),
              SysChoice('all', l.qaSkinOilyAll),
            ],
            value: _oily,
            onChanged: (v) {
              setState(() => _oily = v);
              _patch({'oilyByNoon': v});
            },
          ),
          const SysFieldGap(),
          SysFieldLabel(l.qaSkinTightness),
          SysSegmented<String>(
            choices: [
              SysChoice('never', l.qaSkinTightNever),
              SysChoice('sometimes', l.qaSkinTightSometimes),
              SysChoice('often', l.qaSkinTightOften),
            ],
            value: _tightness,
            onChanged: (v) {
              setState(() => _tightness = v);
              _patch({'tightness': v});
            },
          ),
          const SysFieldGap(),
          SysFieldLabel(l.qaSkinReactions, hint: l.qaSkinReactionsHint, optional: true, optionalLabel: l.commonOptional),
          SysTextField(
            value: _reactions,
            maxLines: 4,
            onChanged: (v) {
              _reactions = v;
              _patch({'reactions': v.trim()});
            },
          ),
          const SysFieldGap(),
          SysFieldLabel(l.qaSkinRoutine, hint: l.qaSkinRoutineHint, optional: true, optionalLabel: l.commonOptional),
          SysTextField(
            value: _routine,
            maxLines: 4,
            onChanged: (v) {
              _routine = v;
              _patch({'currentRoutine': v.trim()});
            },
          ),
          const SysFieldGap(),
        ],
        SysPanel(
          title: l.qaEstimateTitle,
          animateIn: false,
          child: EstimateBlock(items: [l.qaEstSkinType, l.qaEstAcne, l.qaEstBlackheads, l.qaEstPostAcne]),
        ),
        const SysFieldGap(),
        SysPanel(
          title: l.qaSkinDermTitle,
          tone: PanelTone.gold,
          animateIn: false,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SysIcon(SysGlyph.warning, size: 18, color: SysColors.gold),
              const SizedBox(width: 8),
              Expanded(child: Text(l.qaSkinDermAdvice, style: SysText.secondary)),
            ],
          ),
        ),
      ],
    );
  }
}
