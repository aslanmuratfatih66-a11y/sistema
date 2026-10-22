// Фото-дневник тела и кожи (SPEC §8.3): добавить снимок (поза, камера или галерея), лента по датам,
// сравнение двух фото (рядом или шторка).
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart' show PhotoRow;
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../onboarding/questionnaire_a/camera/capture_flow.dart' show cameraAvailableProvider;
import '../onboarding/questionnaire_a/data/photo_repository.dart';
import 'data/body_photos.dart';
import 'data/sleep_repository.dart' show bodyClockProvider;
import 'widgets/body_common.dart';
import '../vision/vision.dart';

/// Откуда добавить снимок.
enum _Origin { camera, gallery }

/// Снять/выбрать фото позы и сохранить в серию [sessionId]. true — сохранено.
Future<bool> addBodyPhoto(
  BuildContext context,
  WidgetRef ref, {
  required PhotoKind kind,
  required PhotoPose pose,
  required String sessionId,
  required bool fromCamera,
  bool replace = false,
}) async {
  final l = AppLocalizations.of(context);
  final source = ref.read(bodyPhotoSourceProvider);
  final path = fromCamera
      ? await source.capture(context, pose: pose, title: poseLabel(l, pose), instruction: poseHint(l, pose))
      : await source.pickFromGallery();
  if (path == null) return false;
  final ok = await saveBodyPhoto(ref, sourcePath: path, kind: kind, pose: pose, sessionId: sessionId, replace: replace);
  if (fromCamera) {
    try {
      await File(path).delete();
    } catch (_) {}
  }
  return ok;
}

class PhotoDiaryScreen extends ConsumerStatefulWidget {
  const PhotoDiaryScreen({super.key, this.initialKind = PhotoKind.body});

  final PhotoKind initialKind;

  static Future<void> open(BuildContext context, {PhotoKind kind = PhotoKind.body}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PhotoDiaryScreen(initialKind: kind)));

  @override
  ConsumerState<PhotoDiaryScreen> createState() => _PhotoDiaryScreenState();
}

class _PhotoDiaryScreenState extends ConsumerState<PhotoDiaryScreen> {
  late PhotoKind _kind = widget.initialKind;
  late PhotoPose _pose = posesFor(_kind).first;
  final List<PhotoRow> _selected = [];

  Future<void> _add(_Origin origin) async {
    final today = ref.read(bodyClockProvider)();
    await addBodyPhoto(
      context,
      ref,
      kind: _kind,
      pose: _pose,
      sessionId: BodyPhotoSessions.diary(today),
      fromCamera: origin == _Origin.camera,
    );
  }

  void _toggle(PhotoRow p) => setState(() {
        if (_selected.any((s) => s.id == p.id)) {
          _selected.removeWhere((s) => s.id == p.id);
        } else {
          if (_selected.length == 2) _selected.removeAt(0);
          _selected.add(p);
        }
      });

  Future<void> _analyze() async {
    final p = _selected.single;
    final file = await ref.read(photoStorageProvider).resolve(p.localPath);
    if (!mounted) return;
    await showPhotoAnalysis(context, photoPath: file.path, photoId: p.id, skin: _kind == PhotoKind.skin);
  }

  void _compare() {
    final pair = [..._selected]..sort((a, b) => a.takenAt.compareTo(b.takenAt));
    PhotoCompareScreen.open(context, before: pair.first, after: pair.last);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final camera = ref.watch(cameraAvailableProvider);
    final feed = diaryFeed(ref.watch(activePhotosProvider(_kind)).value ?? const <PhotoRow>[]);
    final days = groupByDay(feed);

    return ScheduleSubPage(
      title: l.bdyPhotoTitle,
      onBack: () => Navigator.of(context).maybePop(),
      bottom: switch (_selected.length) {
        2 => SysButton.primary(key: const Key('bdy-photo-compare'), label: l.bdyPhotoCompare, expand: true, onPressed: _compare),
        // Одно фото — анализ ИИ (оценка, SPEC §9.4).
        1 => SysButton.secondary(
            key: const Key('bdy-photo-analyze'),
            label: _kind == PhotoKind.skin ? l.visSkinTitle : l.visBodyTitle,
            expand: true,
            onPressed: _analyze,
          ),
        _ => null,
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSegmented<PhotoKind>(
            choices: [SysChoice(PhotoKind.body, l.bdyPhotoKindBody), SysChoice(PhotoKind.skin, l.bdyPhotoKindSkin)],
            value: _kind,
            onChanged: (k) => setState(() {
              _kind = k;
              _pose = posesFor(k).first;
              _selected.clear();
            }),
          ),
          const SizedBox(height: 12),
          SysPanel(
            title: l.bdyPhotoAdd,
            animateIn: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysFieldLabel(l.bdyPhotoPose),
                SysChoiceChips<PhotoPose>(
                  choices: [for (final p in posesFor(_kind)) SysChoice(p, poseLabel(l, p))],
                  selected: {_pose},
                  multi: false,
                  onChanged: (s) => setState(() => _pose = s.isEmpty ? _pose : s.first),
                ),
                BodyActions(children: [
                  if (camera)
                    SysButton.secondary(
                      key: const Key('bdy-photo-camera'),
                      label: l.bdyPhotoCamera,
                      icon: SysGlyph.plus,
                      onPressed: () => _add(_Origin.camera),
                    ),
                  SysButton.secondary(
                    key: const Key('bdy-photo-gallery'),
                    label: l.bdyPhotoGallery,
                    icon: SysGlyph.plus,
                    onPressed: () => _add(_Origin.gallery),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(feed.length < 2 ? l.bdyPhotoCompareNeedTwo : l.bdyPhotoCompareHint, style: SysText.caption),
          const SizedBox(height: 10),
          if (feed.isEmpty) SysEmptyState.inline(l.bdyPhotoEmpty, glyph: SysGlyph.camera),
          for (final (day, photos) in days) ...[
            Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 6),
              child: Text(formatDate(day), style: SysText.mono.copyWith(color: SysColors.textCaption)),
            ),
            _PhotoGrid(
              photos: photos,
              selectedIds: {for (final s in _selected) s.id},
              onTap: _toggle,
              onDelete: (p) {
                _selected.removeWhere((s) => s.id == p.id);
                ref.read(photoServiceProvider).delete(p);
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  const _PhotoGrid({required this.photos, required this.selectedIds, required this.onTap, required this.onDelete});

  final List<PhotoRow> photos;
  final Set<String> selectedIds;
  final ValueChanged<PhotoRow> onTap;
  final ValueChanged<PhotoRow> onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return LayoutBuilder(builder: (context, c) {
      final w = (c.maxWidth - 20) / 3;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          for (final p in photos)
            SizedBox(
              width: w,
              child: _SelectablePhoto(
                photo: p,
                label: poseLabel(l, enumByName(PhotoPose.values, p.pose) ?? PhotoPose.other),
                selected: selectedIds.contains(p.id),
                onTap: () => onTap(p),
                onDelete: () => onDelete(p),
              ),
            ),
        ],
      );
    });
  }
}

class _SelectablePhoto extends StatelessWidget {
  const _SelectablePhoto({
    required this.photo,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.onDelete,
  });

  final PhotoRow photo;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: DecoratedBox(
                  position: DecorationPosition.foreground,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SysDims.radius),
                    border: Border.all(
                      color: selected ? SysColors.gold : SysColors.accent.withValues(alpha: .35),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(SysDims.radius),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        BodyPhotoThumb(photo: photo),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            tooltip: l.commonDelete,
                            onPressed: onDelete,
                            icon: const SysIcon(SysGlyph.close, size: 16, color: SysColors.dangerLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(label, style: SysText.caption, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}

enum _CompareMode { sideBySide, slider }

/// Сравнение «до/после»: рядом или шторка (перетаскивание делит кадр).
class PhotoCompareScreen extends StatefulWidget {
  const PhotoCompareScreen({super.key, required this.before, required this.after});

  final PhotoRow before;
  final PhotoRow after;

  static Future<void> open(BuildContext context, {required PhotoRow before, required PhotoRow after}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PhotoCompareScreen(before: before, after: after)));

  @override
  State<PhotoCompareScreen> createState() => _PhotoCompareScreenState();
}

class _PhotoCompareScreenState extends State<PhotoCompareScreen> {
  _CompareMode _mode = _CompareMode.slider;
  double _split = .5;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final b = widget.before;
    final a = widget.after;
    Widget caption(PhotoRow p, String label) =>
        Text('$label · ${formatDate(p.takenAt.toLocal())}', style: SysText.caption, textAlign: TextAlign.center);

    return ScheduleSubPage(
      title: l.bdyPhotoCompare,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysSegmented<_CompareMode>(
            choices: [
              SysChoice(_CompareMode.slider, l.bdyCompareSlider),
              SysChoice(_CompareMode.sideBySide, l.bdyCompareSideBySide),
            ],
            value: _mode,
            onChanged: (m) => setState(() => _mode = m),
          ),
          const SizedBox(height: 12),
          if (_mode == _CompareMode.sideBySide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final (p, label) in [(b, l.bdyCompareBefore), (a, l.bdyCompareAfter)]) ...[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AspectRatio(aspectRatio: 3 / 4, child: BodyPhotoThumb(photo: p, cacheWidth: 900)),
                        const SizedBox(height: 6),
                        caption(p, label),
                      ],
                    ),
                  ),
                  if (p == b) const SizedBox(width: 8),
                ],
              ],
            )
          else ...[
            AspectRatio(
              aspectRatio: 3 / 4,
              child: LayoutBuilder(builder: (context, c) {
                return GestureDetector(
                  onHorizontalDragUpdate: (d) =>
                      setState(() => _split = (d.localPosition.dx / c.maxWidth).clamp(0.0, 1.0)),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      BodyPhotoThumb(photo: a, cacheWidth: null),
                      ClipRect(
                        clipper: _LeftClipper(_split),
                        child: BodyPhotoThumb(photo: b, cacheWidth: null),
                      ),
                      Positioned(
                        left: c.maxWidth * _split - 1,
                        top: 0,
                        bottom: 0,
                        child: const SizedBox(width: 2, child: ColoredBox(color: SysColors.accentLighter)),
                      ),
                    ],
                  ),
                );
              }),
            ),
            Slider(
              value: _split,
              onChanged: (v) => setState(() => _split = v),
              semanticFormatterCallback: (v) => '${(v * 100).round()}%',
            ),
            Row(
              children: [
                Expanded(child: caption(b, l.bdyCompareBefore)),
                Expanded(child: caption(a, l.bdyCompareAfter)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Text(l.bdyCompareNote, style: SysText.caption),
        ],
      ),
    );
  }
}

class _LeftClipper extends CustomClipper<Rect> {
  const _LeftClipper(this.fraction);

  final double fraction;

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, size.width * fraction, size.height);

  @override
  bool shouldReclip(_LeftClipper oldClipper) => oldClipper.fraction != fraction;
}
