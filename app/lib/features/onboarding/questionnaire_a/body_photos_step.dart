import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/models/enums.dart';
import '../../../l10n/app_localizations.dart';
import '../../../ui/ui.dart';
import '../step_scope.dart';
import 'camera/capture_flow.dart';
import 'camera/capture_guide.dart';
import 'camera/guided_capture_screen.dart';
import 'data/measurement_repository.dart';
import 'data/photo_repository.dart';
import 'data/serial_writer.dart';
import 'widgets/estimate_block.dart';
import 'widgets/photo_slot.dart';
import 'widgets/session_card.dart';

/// Диапазоны «знаю точные цифры».
const _fatRange = (2.0, 70.0);
const _muscleRange = (10.0, 150.0);

/// Этап 3 «Фото тела» (необязательный): фото-сессия из трёх ракурсов под руководством Системы, блок оценки,
/// точные цифры.
class BodyPhotosStep extends ConsumerStatefulWidget {
  const BodyPhotosStep({super.key});

  @override
  ConsumerState<BodyPhotosStep> createState() => _BodyPhotosStepState();
}

class _BodyPhotosStepState extends ConsumerState<BodyPhotosStep> {
  final _writer = SerialWriter();
  bool _loaded = false;
  num? _fat;
  num? _muscle;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final m = await ref.read(onboardingMeasurementRepositoryProvider).get();
    if (!mounted) return;
    setState(() {
      _loaded = true;
      _fat = m?.bodyFatPct;
      _muscle = m?.muscleMassKg;
    });
  }

  static bool _ok(num? v, (double, double) r) => v != null && v >= r.$1 && v <= r.$2;

  void _saveMeasurement(BodyMeasurementsCompanion patch) =>
      _writer.run(() => ref.read(onboardingMeasurementRepositoryProvider).patch(patch));

  Future<void> _startSession() => GuidedCaptureScreen.open(context, GuidedSessionKind.body);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scope = StepScope.maybeOf(context);
    scope?.setCanProceed(true);
    final camera = ref.watch(cameraAvailableProvider);
    final photos = (ref.watch(activePhotosProvider(PhotoKind.body)).value ?? const <PhotoRow>[])
        .where((p) => p.sessionId == null)
        .toList();
    PhotoRow? byPose(PhotoPose pose) {
      PhotoRow? last;
      for (final p in photos) {
        if (p.pose == pose.name) last = p;
      }
      return last;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (scope?.editing != true) ...[
          Text(l.qaBodyPhotosIntro, style: SysText.secondary),
          const SysFieldGap(),
        ],
        if (!camera) const CameraUnavailableNote(),
        SessionCard(
          title: l.qaShootCardBody,
          thumbs: [
            SessionThumb(l.qaPoseBodyFront, CaptureGuide.bodyFront, byPose(PhotoPose.bodyFront)),
            SessionThumb(l.qaPoseBodySide, CaptureGuide.bodySide, byPose(PhotoPose.bodySide)),
            SessionThumb(l.qaPoseBodyBack, CaptureGuide.bodyBack, byPose(PhotoPose.bodyBack)),
          ],
          onStart: camera ? _startSession : null,
        ),
        const SysFieldGap(),
        SysPanel(
          title: l.qaEstimateTitle,
          animateIn: false,
          child: EstimateBlock(items: [
            l.qaEstBodyFat,
            l.qaEstMuscle,
            l.qaEstPosture,
            l.qaEstFigure,
            l.qaEstFaceSwelling,
          ], aiNote: l.qaShootAiNoteBody),
        ),
        const SysFieldGap(),
        SysPanel(
          title: l.qaExactTitle,
          animateIn: false,
          child: !_loaded
              ? const SizedBox(height: 44)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.qaExactHint, style: SysText.caption),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SysFieldLabel(l.qaExactFat, optional: true, optionalLabel: l.commonOptional),
                              SysNumberField(
                                value: _fat,
                                unit: '%',
                                min: _fatRange.$1,
                                max: _fatRange.$2,
                                outOfRangeText: l.qaRangeHint(_fatRange.$1.round(), _fatRange.$2.round()),
                                onChanged: (v) {
                                  setState(() => _fat = v);
                                  _saveMeasurement(BodyMeasurementsCompanion(
                                    bodyFatPct: Value(_ok(v, _fatRange) ? v!.toDouble() : null),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SysFieldLabel(l.qaExactMuscle, optional: true, optionalLabel: l.commonOptional),
                              SysNumberField(
                                value: _muscle,
                                unit: l.qaUnitKg,
                                min: _muscleRange.$1,
                                max: _muscleRange.$2,
                                outOfRangeText: l.qaRangeHint(_muscleRange.$1.round(), _muscleRange.$2.round()),
                                onChanged: (v) {
                                  setState(() => _muscle = v);
                                  _saveMeasurement(BodyMeasurementsCompanion(
                                    muscleMassKg: Value(_ok(v, _muscleRange) ? v!.toDouble() : null),
                                  ));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
