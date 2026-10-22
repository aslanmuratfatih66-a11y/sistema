// Тело и здоровье (SPEC §8.3): панели — сон и «Энергия», шаги (слот, сабагент B), замеры, фото-дневник,
// уход за кожей, отёки. Подробности — внутренние экраны (Navigator.push), роутер не трогаем.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/database.dart' show BodyMeasurementRow, PhotoRow;
import '../../core/models/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../onboarding/questionnaire_a/data/photo_repository.dart';
import 'data/body_photos.dart';
import 'data/care_repository.dart';
import 'data/measurement_repository.dart';
import 'data/sleep_repository.dart';
import 'measurements_screen.dart';
import 'photo_diary_screen.dart';
import 'skin_care_screen.dart';
import '../activity/steps_panel.dart';
import 'sleep_screen.dart';
import 'swelling_screen.dart';
import 'widgets/body_common.dart';

class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ScheduleSubPage(
      title: l.setBody,
      onBack: () => Navigator.of(context).maybePop(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SleepPanel(),
          SizedBox(height: 14),
          StepsPanel(),
          SizedBox(height: 14),
          _MeasurementsPanel(),
          SizedBox(height: 14),
          _PhotoPanel(),
          SizedBox(height: 14),
          _CarePanel(),
          SizedBox(height: 14),
          _SwellingPanel(),
        ],
      ),
    );
  }
}

class _SleepPanel extends ConsumerWidget {
  const _SleepPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final today = ref.watch(bodyTodayProvider);
    final sleep = ref.watch(sleepDayProvider(today)).value;
    final energy = ref.watch(energyPercentProvider);
    final target = ref.watch(sleepTargetProvider);
    final q = sleep?.quality;
    return SysPanel(
      key: const Key('bdy-panel-sleep'),
      title: l.bdySleepTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sleep == null)
            Text(l.bdySleepNotLogged, style: SysText.secondary)
          else ...[
            BodyInfoRow(
              label: l.bdySleepLastNight,
              value: '${formatMinuteOfDay(sleep.bedAt.hour * 60 + sleep.bedAt.minute)} → '
                  '${formatMinuteOfDay(sleep.wakeAt.hour * 60 + sleep.wakeAt.minute)}',
            ),
            BodyInfoRow(
              label: l.bdySleepDuration,
              value: formatSleep(l, sleep.duration),
              valueColor: sleep.duration.inMinutes >= target.targetMinutes ? SysColors.energy : SysColors.textPrimary,
            ),
            if (q != null) BodyInfoRow(label: l.bdySleepQuality, value: '$q/5'),
          ],
          BodyInfoRow(label: l.bdySleepTarget, value: formatDuration(l, target.targetMinutes), valueColor: SysColors.gold),
          const SizedBox(height: 8),
          StatBar(
            label: l.bdyEnergy,
            value: (energy ?? 0).toDouble(),
            max: 100,
            color: SysColors.energy,
            icon: SysGlyph.bolt,
            valueText: energy == null ? '—' : '$energy%',
          ),
          BodyActions(children: [
            SysButton.primary(
              key: const Key('bdy-sleep-open-log'),
              label: l.bdySleepLog,
              icon: SysGlyph.moon,
              onPressed: () => SleepEditScreen.open(context, today),
            ),
            SysButton.secondary(label: l.bdyHistory, onPressed: () => SleepScreen.open(context)),
          ]),
        ],
      ),
    );
  }
}

class _MeasurementsPanel extends ConsumerWidget {
  const _MeasurementsPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final rows = ref.watch(bodyMeasurementsProvider).value ?? const <BodyMeasurementRow>[];
    final now = ref.watch(bodyClockProvider)();
    final since = now.subtract(const Duration(days: 30));
    final shown = [
      for (final f in MeasureField.values)
        if (measureLatest(rows, f) case final latest?) (f, latest),
    ];
    return SysPanel(
      key: const Key('bdy-panel-measure'),
      title: l.bdyMeasureTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (shown.isEmpty) SysEmptyState.inline(l.bdyMeasureEmpty, glyph: SysGlyph.heart),
          for (final (f, latest) in shown.take(4))
            BodyInfoRow(
              label: measureLabel(l, f),
              value: [
                '${formatNum(latest.value)} ${measureUnit(l, f)}',
                if (measureChange(rows, f, since: since) case final c?) '(${formatDelta(c)})',
              ].join(' '),
            ),
          if (shown.isNotEmpty) Text(l.bdyMeasureChangeNote, style: SysText.caption),
          BodyActions(children: [
            SysButton.primary(label: l.bdyMeasureAdd, icon: SysGlyph.plus, onPressed: () => MeasurementEditScreen.open(context)),
            SysButton.secondary(
              key: const Key('bdy-measure-open'),
              label: l.bdyCharts,
              onPressed: () => MeasurementsScreen.open(context),
            ),
          ]),
        ],
      ),
    );
  }
}

class _PhotoPanel extends ConsumerWidget {
  const _PhotoPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final body = diaryFeed(ref.watch(activePhotosProvider(PhotoKind.body)).value ?? const <PhotoRow>[]);
    final skin = diaryFeed(ref.watch(activePhotosProvider(PhotoKind.skin)).value ?? const <PhotoRow>[]);
    final last = [...body, ...skin]..sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return SysPanel(
      key: const Key('bdy-panel-photo'),
      title: l.bdyPhotoTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BodyInfoRow(label: l.bdyPhotoKindBody, value: '${body.length}'),
          BodyInfoRow(label: l.bdyPhotoKindSkin, value: '${skin.length}'),
          if (last.isNotEmpty) BodyInfoRow(label: l.bdyPhotoLast, value: formatDate(last.first.takenAt.toLocal())),
          BodyActions(children: [
            SysButton.secondary(
              key: const Key('bdy-photo-open'),
              label: l.bdyPhotoKindBody,
              onPressed: () => PhotoDiaryScreen.open(context),
            ),
            SysButton.secondary(
              label: l.bdyPhotoKindSkin,
              onPressed: () => PhotoDiaryScreen.open(context, kind: PhotoKind.skin),
            ),
          ]),
        ],
      ),
    );
  }
}

class _CarePanel extends ConsumerWidget {
  const _CarePanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final day = ref.watch(bodyTodayProvider);
    final template = ref.watch(careTemplateProvider);
    final marks = ref.watch(careMarksProvider(day)).value ?? const <CareMark>{};
    Widget bar(CareRoutine r) {
      final items = template.items(r, day);
      final done = items.where((k) => marks.contains((routine: r, itemKey: k))).length;
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: StatBar(
          label: routineLabel(l, r),
          value: done.toDouble(),
          max: items.length.toDouble(),
          color: done == items.length ? SysColors.success : SysColors.accent,
        ),
      );
    }

    return SysPanel(
      key: const Key('bdy-panel-care'),
      title: l.bdyCareTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BodyInfoRow(label: l.bdySkinType, value: skinTypeLabel(l, template.profile.skinType)),
          const SizedBox(height: 6),
          bar(CareRoutine.morning),
          bar(CareRoutine.evening),
          BodyActions(children: [
            SysButton.primary(
              key: const Key('bdy-care-open'),
              label: l.bdyCareOpen,
              onPressed: () => SkinCareScreen.open(context),
            ),
          ]),
        ],
      ),
    );
  }
}

class _SwellingPanel extends ConsumerWidget {
  const _SwellingPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final skin = ref.watch(activePhotosProvider(PhotoKind.skin)).value ?? const <PhotoRow>[];
    final takenToday = hasSwellingPhoto(skin, ref.watch(bodyTodayProvider));
    return SysPanel(
      key: const Key('bdy-panel-swelling'),
      title: l.bdySwellTitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(takenToday ? l.bdySwellTakenToday : l.bdySwellPhotoHint, style: SysText.secondary),
          const SizedBox(height: 6),
          Text(l.bdySwellTipShort, style: SysText.caption),
          BodyActions(children: [
            SysButton.secondary(
              key: const Key('bdy-swelling-open'),
              label: l.bdySwellOpen,
              onPressed: () => SwellingScreen.open(context),
            ),
          ]),
        ],
      ),
    );
  }
}
