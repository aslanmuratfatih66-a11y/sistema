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
import 'camera/guided_capture_screen.dart';
import 'data/photo_repository.dart';
import 'data/serial_writer.dart';
import 'widgets/estimate_block.dart';
import 'widgets/photo_slot.dart';
import 'widgets/session_card.dart';

/// Этап 4 «Кожа»: фото-сессия лица (анфас, профиль слева/справа), крупные планы вручную,
/// опрос (раздел skin) + блок оценки.
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

  Future<void> _startSession() async {
    final saved = await GuidedCaptureScreen.open(context, GuidedSessionKind.face);
    if (saved) _syncPhotosTaken();
  }

  /// Крупный план — вручную, можно несколько (replace: false).
  Future<void> _addCloseup() async {
    final l = AppLocalizations.of(context);
    final saved = await captureAndSavePhoto(
      context,
      ref,
      kind: PhotoKind.skin,
      pose: PhotoPose.closeup,
      guide: CaptureGuide.closeup,
      title: l.qaPoseCloseup,
      instruction: l.qaPoseCloseupHint,
      replace: false,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[
          Text(l.qaSkinIntro, style: SysText.secondary),
          const SysFieldGap(),
        ],
        if (!camera) const CameraUnavailableNote(),
        SessionCard(
          title: l.qaShootCardFace,
          thumbs: [
            SessionThumb(l.qaPoseFaceFront, CaptureGuide.faceFront, byPose(PhotoPose.faceFront)),
            SessionThumb(l.qaPoseFaceLeft, CaptureGuide.faceLeft, byPose(PhotoPose.faceLeft)),
            SessionThumb(l.qaPoseFaceRight, CaptureGuide.faceRight, byPose(PhotoPose.faceRight)),
          ],
          onStart: camera ? _startSession : null,
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
            ],
          );
        }),
        if (camera) ...[
          if (closeups.isNotEmpty) const SizedBox(height: 10),
          SysButton.secondary(label: l.qaShootCloseupButton, icon: SysGlyph.plus, onPressed: _addCloseup, expand: true),
        ],
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
          child: EstimateBlock(
            items: [l.qaEstSkinType, l.qaEstAcne, l.qaEstBlackheads, l.qaEstPostAcne],
            aiNote: l.qaShootAiNoteSkin,
          ),
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
