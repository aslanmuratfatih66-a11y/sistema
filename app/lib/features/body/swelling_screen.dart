// Отёки (SPEC §8.3): утреннее фото лица анфас (Photos kind=skin, pose=faceFront, серия «swelling-день»),
// короткие подсказки (соль, вода, сон) без медицины и цифр, тренд — лента утренних фото.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart' show PhotoRow;
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../onboarding/questionnaire_a/camera/capture_flow.dart' show cameraAvailableProvider;
import '../onboarding/questionnaire_a/data/photo_repository.dart';
import 'data/body_photos.dart';
import 'data/care_repository.dart' show bodyTodayProvider;
import 'domain/sleep_math.dart';
import 'photo_diary_screen.dart';
import 'widgets/body_common.dart';

/// Подсказки отёков: строки l10n.
List<String> swellingTips(AppLocalizations l) => [l.bdySwellTipSalt, l.bdySwellTipWater, l.bdySwellTipSleep];

/// Есть ли утреннее фото за день.
bool hasSwellingPhoto(List<PhotoRow> skinPhotos, DateTime day) =>
    swellingFeed(skinPhotos).any((p) => dayOf(p.takenAt) == dayOf(day));

class SwellingScreen extends ConsumerWidget {
  const SwellingScreen({super.key});

  static Future<void> open(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SwellingScreen()));

  /// Утреннее фото: одно на день (повторный снимок заменяет).
  static Future<bool> takeMorningPhoto(BuildContext context, WidgetRef ref, {required bool fromCamera}) {
    final day = ref.read(bodyTodayProvider);
    return addBodyPhoto(
      context,
      ref,
      kind: PhotoKind.skin,
      pose: PhotoPose.faceFront,
      sessionId: BodyPhotoSessions.swelling(day),
      fromCamera: fromCamera,
      replace: true,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final camera = ref.watch(cameraAvailableProvider);
    final skin = ref.watch(activePhotosProvider(PhotoKind.skin)).value ?? const <PhotoRow>[];
    final feed = swellingFeed(skin);
    final today = ref.watch(bodyTodayProvider);
    final takenToday = hasSwellingPhoto(skin, today);

    return ScheduleSubPage(
      title: l.bdySwellTitle,
      onBack: () => Navigator.of(context).maybePop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SysPanel(
            title: l.bdySwellMorningPhoto,
            animateIn: false,
            tone: takenToday ? PanelTone.success : PanelTone.accent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(takenToday ? l.bdySwellTakenToday : l.bdySwellPhotoHint, style: SysText.secondary),
                BodyActions(children: [
                  if (camera)
                    SysButton.secondary(
                      label: l.bdyPhotoCamera,
                      icon: SysGlyph.plus,
                      onPressed: () => takeMorningPhoto(context, ref, fromCamera: true),
                    ),
                  SysButton.secondary(
                    label: l.bdyPhotoGallery,
                    icon: SysGlyph.plus,
                    onPressed: () => takeMorningPhoto(context, ref, fromCamera: false),
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SysPanel(
            title: l.bdySwellTipsTitle,
            animateIn: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final t in swellingTips(l))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(padding: EdgeInsets.only(top: 6, right: 8), child: SysDiamond(size: 5)),
                        Expanded(child: Text(t, style: SysText.secondary)),
                      ],
                    ),
                  ),
                Text(l.bdySwellNote, style: SysText.caption),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SysPanel(
            title: l.bdySwellTrend,
            animateIn: false,
            child: feed.isEmpty
                ? SysEmptyState.inline(l.bdySwellEmpty, glyph: SysGlyph.water)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 150,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: feed.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 8),
                          itemBuilder: (context, i) {
                            final p = feed[i];
                            return SizedBox(
                              width: 96,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(SysDims.radius),
                                      child: SizedBox(width: 96, child: BodyPhotoThumb(photo: p)),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(formatDayMonth(p.takenAt.toLocal()), style: SysText.monoSmall),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      if (feed.length >= 2) ...[
                        const SizedBox(height: 10),
                        SysButton.secondary(
                          label: l.bdySwellCompareFirst,
                          expand: true,
                          onPressed: () => PhotoCompareScreen.open(context, before: feed.last, after: feed.first),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
