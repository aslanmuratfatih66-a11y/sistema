// Итоги дня (SPEC §8.13): перед отбоем — что сделано, ◆ и опыт за день, ошибки, план на завтра.
// Открывается уведомлением «Итоги дня» (за 30 мин до отбоя) и из вкладки «Квесты». Ассистент озвучивает
// короткую сводку шаблоном (с ИИ — пересказ аналитика, этап 6).
import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/data/questionnaire_repository.dart';
import '../../core/db/database.dart';
import '../../core/models/enums.dart';
import '../../core/voice/tts_service.dart';
import '../../core/voice/voice_providers.dart';
import '../../domain/quests/quest_api.dart';
import '../../domain/quests/quest_l10n.dart';
import '../../l10n/app_localizations.dart';
import '../../ui/ui.dart';
import '../character/model/character_profile.dart';
import '../quests/data/quest_providers.dart';
import '../schedule/widgets/schedule_common.dart';

/// Префикс instanceId уведомления «Итоги дня» (ReminderRequest), чтобы открыть этот экран.
const daySummaryReminderPrefix = 'summary:';

class DaySummary {
  const DaySummary({
    required this.done,
    required this.failed,
    required this.pending,
    required this.diamonds,
    required this.xp,
    required this.tomorrow,
  });

  final List<QuestItem> done;
  final List<QuestItem> failed; // провал + отказ
  final List<QuestItem> pending;
  final int diamonds;
  final int xp;
  final List<QuestItem> tomorrow;

  int get total => done.length + failed.length + pending.length;
}

final daySummaryProvider = FutureProvider.autoDispose.family<DaySummary, DateTime>((ref, day) async {
  final quests = ref.watch(questServiceProvider);
  final db = ref.watch(databaseProvider);
  final d = DateTime(day.year, day.month, day.day);
  final next = DateTime(d.year, d.month, d.day + 1);
  final today = await quests.watchDay(d).first;
  final tomorrow = await quests.watchDay(next).first;
  final events = await (db.select(db.questEvents)
        ..where((t) => t.deletedAt.isNull() & t.occurredAt.isBiggerOrEqualValue(d) & t.occurredAt.isSmallerThanValue(next))
        ..orderBy([(t) => OrderingTerm(expression: t.occurredAt)]))
      .get();
  return DaySummary(
    done: [for (final q in today) if (q.status == QuestStatus.done) q],
    failed: [for (final q in today) if (q.status == QuestStatus.failed || q.status == QuestStatus.refused) q],
    pending: [for (final q in today) if (q.status == QuestStatus.pending) q],
    diamonds: events.fold(0, (a, e) => a + e.diamonds),
    xp: events.fold(0, (a, e) => a + e.xp),
    tomorrow: [...tomorrow]..sort((a, b) => (a.startsAt ?? a.deadlineAt).compareTo(b.startsAt ?? b.deadlineAt)),
  );
});

/// Короткая сводка голосом ассистента (шаблон по режиму мотивации).
String daySummaryLine(AppLocalizations l, DaySummary s, String motivation) {
  final rate = s.total == 0 ? 1.0 : s.done.length / s.total;
  final base = l.sumLine(s.done.length, s.total, s.diamonds);
  final tone = switch ((motivation, rate >= .8)) {
    ('soft', true) => l.sumToneSoftGood,
    ('soft', false) => l.sumToneSoftBad,
    ('harsh', true) => l.sumToneHarshGood,
    ('harsh', false) => l.sumToneHarshBad,
    (_, true) => l.sumToneGood,
    (_, false) => l.sumToneBad,
  };
  return '$base $tone';
}

class DaySummaryScreen extends ConsumerStatefulWidget {
  const DaySummaryScreen({super.key, this.day});

  final DateTime? day;

  @override
  ConsumerState<DaySummaryScreen> createState() => _DaySummaryScreenState();
}

class _DaySummaryScreenState extends ConsumerState<DaySummaryScreen> {
  bool _spoken = false;
  // ref нельзя трогать в dispose — сервис голоса берём заранее.
  late final TtsService _tts = ref.read(characterTtsProvider);

  void _speak(DaySummary s) {
    if (_spoken) return;
    _spoken = true;
    final l = AppLocalizations.of(context);
    final c = ref.read(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};
    final archetype = archetypeFromName(c['archetype']);
    if (archetype == null) return;
    final line = daySummaryLine(l, s, motivationOf(c['motivation']));
    final voice = CharacterProfile.of(archetype).voiceById(c['voice'] as String?);
    _tts
        .speak(line, languageCode: Localizations.localeOf(context).languageCode, voice: voice)
        .catchError((Object _) {});
  }

  @override
  void dispose() {
    if (_spoken) _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final day = widget.day ?? ref.watch(questTodayProvider);
    final async = ref.watch(daySummaryProvider(day));
    final s = async.value;
    if (s != null && !_spoken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _speak(s);
      });
    }
    final c = ref.watch(questionnaireSectionProvider(QuestionnaireSection.character)).value ?? const {};

    return ScheduleSubPage(
      key: const Key('day-summary'),
      title: l.sumTitle,
      onBack: () => Navigator.of(context).maybePop(),
      child: s == null
          ? (async.hasError ? SysErrorState(message: l.qstLoadError) : const SysSkeletonPanel(lines: 5))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SysPanel(
                  tone: s.total > 0 && s.done.length / s.total >= .8 ? PanelTone.gold : PanelTone.accent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(daySummaryLine(l, s, motivationOf(c['motivation'])), style: SysText.body),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Stat(label: l.sumDone, value: '${s.done.length}/${s.total}', color: SysColors.success),
                          _Stat(
                            label: l.sumDiamonds,
                            value: '${s.diamonds >= 0 ? '+' : ''}${s.diamonds} ◆',
                            color: s.diamonds >= 0 ? SysColors.gold : SysColors.dangerLight,
                          ),
                          _Stat(label: l.sumXp, value: '+${s.xp}', color: SysColors.accentLight),
                        ],
                      ),
                    ],
                  ),
                ),
                if (s.failed.isNotEmpty || s.pending.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SysPanel(
                    title: l.sumMistakes,
                    tone: PanelTone.danger,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final q in s.failed) _QuestLine(quest: q, glyph: SysGlyph.close, color: SysColors.dangerLight),
                        for (final q in s.pending) _QuestLine(quest: q, glyph: SysGlyph.clock, color: SysColors.textCaption),
                      ],
                    ),
                  ),
                ],
                if (s.done.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  SysPanel(
                    title: l.sumDoneTitle,
                    tone: PanelTone.success,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final q in s.done) _QuestLine(quest: q, glyph: SysGlyph.check, color: SysColors.success),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SysPanel(
                  title: l.sumTomorrow,
                  child: s.tomorrow.isEmpty
                      ? Text(l.sumTomorrowEmpty, style: SysText.secondary)
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final q in s.tomorrow.take(8)) _QuestLine(quest: q, glyph: SysGlyph.quests, color: SysColors.accentLight),
                            if (s.tomorrow.length > 8)
                              Text(l.sumMore(s.tomorrow.length - 8), style: SysText.caption),
                          ],
                        ),
                ),
              ],
            ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(
          children: [
            Text(value, style: SysText.mono.copyWith(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: SysText.caption, textAlign: TextAlign.center),
          ],
        ),
      );
}

class _QuestLine extends StatelessWidget {
  const _QuestLine({required this.quest, required this.glyph, required this.color});

  final QuestItem quest;
  final SysGlyph glyph;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final at = quest.startsAt;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SysIcon(glyph, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(questTitleText(l, quest.title), style: SysText.secondary)),
          if (at != null)
            Text(
              '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}',
              style: SysText.monoSmall.copyWith(color: SysColors.textCaption),
            ),
        ],
      ),
    );
  }
}
