// Анализ тела и кожи по фото (SPEC §5, §9.4): диапазоны, пометка «оценка», сравнение с прошлыми (PhotoAnalyses).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../nutrition/nutrition_format.dart';
import 'vision_api.dart';
import 'vision_common.dart';
import 'vision_repository.dart';

/// Итог анализа: свежий результат и предыдущий (для сравнения), если был.
@immutable
class VisionOutcome<T> {
  const VisionOutcome({required this.result, required this.analysisId, this.previous, this.previousAt});

  final T result;
  final String analysisId;
  final T? previous;
  final DateTime? previousAt;
}

/// Анализ фото тела: шлёт фото и сводки прошлых анализов, сохраняет результат в PhotoAnalyses (kind=body).
/// [read] — `ref.read` или `ProviderScope.containerOf(context).read`. Ошибки — AiException.
Future<VisionOutcome<BodyVisionResult>> analyzeBodyPhoto(
  VisionRead read, {
  required String photoPath,
  String? photoId,
  required String lang,
}) async {
  final repo = read(photoAnalysisRepositoryProvider);
  final past = await repo.recent(VisionKind.body);
  final prev = [
    for (final r in past.reversed) (at: r.createdAt, value: BodyVisionResult.fromJson(decodeAnalysis(r))),
  ];
  final reply = await read(visionApiProvider).body(
    await encodeVisionImage(photoPath),
    lang,
    previous: [for (final p in prev) (at: p.at, summary: p.value.summary)],
  );
  final id = await repo.add(VisionKind.body, reply.raw, photoId: photoId);
  return VisionOutcome(
    result: reply.value,
    analysisId: id,
    previous: prev.isEmpty ? null : prev.last.value,
    previousAt: prev.isEmpty ? null : prev.last.at,
  );
}

/// Анализ кожи по фото лица; сохраняет в PhotoAnalyses (kind=skin).
Future<VisionOutcome<SkinVisionResult>> analyzeSkinPhoto(
  VisionRead read, {
  required String photoPath,
  String? photoId,
  required String lang,
}) async {
  final repo = read(photoAnalysisRepositoryProvider);
  final past = await repo.recent(VisionKind.skin, limit: 1);
  final reply = await read(visionApiProvider).skin(await encodeVisionImage(photoPath), lang);
  final id = await repo.add(VisionKind.skin, reply.raw, photoId: photoId);
  return VisionOutcome(
    result: reply.value,
    analysisId: id,
    previous: past.isEmpty ? null : SkinVisionResult.fromJson(decodeAnalysis(past.first)),
    previousAt: past.isEmpty ? null : past.first.createdAt,
  );
}

/// Экран: анализирует уже снятое фото ([skin] — кожа, иначе тело) и показывает результат.
Future<void> showPhotoAnalysis(BuildContext context, {required String photoPath, String? photoId, bool skin = false}) =>
    Navigator.of(context).push<void>(MaterialPageRoute(
      builder: (_) => PhotoAnalysisScreen(photoPath: photoPath, photoId: photoId, skin: skin),
    ));

class PhotoAnalysisScreen extends ConsumerStatefulWidget {
  const PhotoAnalysisScreen({super.key, required this.photoPath, this.photoId, this.skin = false});

  final String photoPath;
  final String? photoId;
  final bool skin;

  @override
  ConsumerState<PhotoAnalysisScreen> createState() => _PhotoAnalysisScreenState();
}

class _PhotoAnalysisScreenState extends ConsumerState<PhotoAnalysisScreen> {
  Object? _error;
  VisionOutcome<Object>? _outcome;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    setState(() {
      _error = null;
      _outcome = null;
    });
    final lang = visionLang(context);
    try {
      final o = widget.skin
          ? await analyzeSkinPhoto(ref.read, photoPath: widget.photoPath, photoId: widget.photoId, lang: lang)
          : await analyzeBodyPhoto(ref.read, photoPath: widget.photoPath, photoId: widget.photoId, lang: lang);
      if (mounted) setState(() => _outcome = o);
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final o = _outcome;
    final Widget body;
    if (_error != null) {
      body = VisionError(error: _error!, onRetry: _run);
    } else if (o == null) {
      body = const VisionBusy();
    } else if (o.result is BodyVisionResult) {
      body = BodyAnalysisView(
        result: o.result as BodyVisionResult,
        previous: o.previous as BodyVisionResult?,
        previousAt: o.previousAt,
      );
    } else {
      body = SkinAnalysisView(
        result: o.result as SkinVisionResult,
        previous: o.previous as SkinVisionResult?,
        previousAt: o.previousAt,
      );
    }
    return NutPage(title: widget.skin ? l.visSkinTitle : l.visBodyTitle, child: body);
  }
}

String _date(AppLocalizations l, DateTime d) => DateFormat.yMMMd(l.localeName).format(d.toLocal());

String _level(AppLocalizations l, String v) => switch (v) {
      'low' => l.visLevelLow,
      'high' => l.visLevelHigh,
      _ => l.visLevelMedium,
    };

String _swelling(AppLocalizations l, String v) => switch (v) {
      'mild' => l.visSwellingMild,
      'noticeable' => l.visSwellingNoticeable,
      _ => l.visSwellingNone,
    };

String _skinType(AppLocalizations l, String v) => switch (v) {
      'dry' => l.visSkinDry,
      'oily' => l.visSkinOily,
      'combination' => l.visSkinCombination,
      'sensitive' => l.visSkinSensitive,
      _ => l.visSkinNormal,
    };

String _fat(AppLocalizations l, BodyVisionResult r) => l.visFatRange(fmtInt(l, r.fatMin), fmtInt(l, r.fatMax));

/// Результат анализа тела: диапазоны, пометка «оценка», сравнение с прошлым.
class BodyAnalysisView extends StatelessWidget {
  const BodyAnalysisView({super.key, required this.result, this.previous, this.previousAt});

  final BodyVisionResult result;
  final BodyVisionResult? previous;
  final DateTime? previousAt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = result;
    final p = previous;
    final pAt = previousAt;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysPanel(
          title: l.visBodyTitle,
          trailing: const EstimateBadge(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VisionRow(label: l.visBodyFat, value: _fat(l, r)),
              VisionRow(label: l.visMuscle, value: _level(l, r.muscle)),
              VisionRow(label: l.visSwelling, value: _swelling(l, r.swelling)),
              if (r.posture.isNotEmpty) VisionRow(label: l.visPosture, value: r.posture.join('\n')),
              if (r.notes.isNotEmpty) ...[const SizedBox(height: 8), Text(r.notes, style: SysText.body)],
            ],
          ),
        ),
        if (p != null && pAt != null) ...[
          const SizedBox(height: 12),
          SysPanel(
            title: l.visComparison,
            trailing: const EstimateBadge(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.visPreviousAt(_date(l, pAt)), style: SysText.caption),
                VisionRow(label: l.visBodyFat, value: '${_fat(l, p)} → ${_fat(l, r)}'),
                VisionRow(label: l.visMuscle, value: '${_level(l, p.muscle)} → ${_level(l, r.muscle)}'),
                VisionRow(label: l.visSwelling, value: '${_swelling(l, p.swelling)} → ${_swelling(l, r.swelling)}'),
                if (r.comparison != null) ...[const SizedBox(height: 8), Text(r.comparison!, style: SysText.body)],
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(l.visDisclaimer, style: SysText.caption),
      ],
    );
  }
}

/// Результат анализа кожи.
class SkinAnalysisView extends StatelessWidget {
  const SkinAnalysisView({super.key, required this.result, this.previous, this.previousAt});

  final SkinVisionResult result;
  final SkinVisionResult? previous;
  final DateTime? previousAt;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final r = result;
    final p = previous;
    final pAt = previousAt;
    String acne(SkinVisionResult x) => l.visAcneScore(fmt1(l, x.acneScore));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SysPanel(
          title: l.visSkinTitle,
          trailing: const EstimateBadge(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              VisionRow(label: l.visSkinType, value: _skinType(l, r.skinType)),
              VisionRow(label: l.visAcne, value: r.acneLabel.isEmpty ? acne(r) : '${acne(r)} · ${r.acneLabel}'),
              if (r.notes.isNotEmpty) ...[const SizedBox(height: 8), Text(r.notes, style: SysText.body)],
            ],
          ),
        ),
        if (p != null && pAt != null) ...[
          const SizedBox(height: 12),
          SysPanel(
            title: l.visComparison,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.visPreviousAt(_date(l, pAt)), style: SysText.caption),
                VisionRow(label: l.visAcne, value: '${acne(p)} → ${acne(r)}'),
                VisionRow(label: l.visSkinType, value: '${_skinType(l, p.skinType)} → ${_skinType(l, r.skinType)}'),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(l.visDisclaimer, style: SysText.caption),
      ],
    );
  }
}
