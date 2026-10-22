// Офлайн-реплики персонажа на события (шаблоны l10n с именем игрока и названием квеста).
// Режим мотивации задаёт тон; «жёсткий» — строго, но без унижения внешности/здоровья (SPEC §9.2).
import 'dart:math' as math;

import '../../core/models/enums.dart';
import '../../domain/quests/quest_api.dart';
import '../../domain/quests/quest_l10n.dart';
import '../../l10n/app_localizations.dart';

/// Реакция на событие: состояние + реплика.
typedef CharacterLine = ({CharacterState state, String line});

String _pick(math.Random rnd, List<String> lines) => lines[rnd.nextInt(lines.length)];

String doneLine(AppLocalizations l, String mode, String name, String quest, math.Random rnd) => _pick(rnd, switch (mode) {
      'soft' => [l.chrDoneSoft1(name, quest), l.chrDoneSoft2(name, quest)],
      'strict' => [l.chrDoneStrict1(name, quest), l.chrDoneStrict2(name, quest)],
      'harsh' => [l.chrDoneHarsh1(name, quest), l.chrDoneHarsh2(name, quest)],
      _ => [l.chrDoneNormal1(name, quest), l.chrDoneNormal2(name, quest)],
    });

String failLine(AppLocalizations l, String mode, String name, String quest, math.Random rnd) => _pick(rnd, switch (mode) {
      'soft' => [l.chrFailSoft1(name, quest), l.chrFailSoft2(name, quest)],
      'strict' => [l.chrFailStrict1(name, quest), l.chrFailStrict2(name, quest)],
      'harsh' => [l.chrFailHarsh1(name, quest), l.chrFailHarsh2(name, quest)],
      _ => [l.chrFailNormal1(name, quest), l.chrFailNormal2(name, quest)],
    });

String penaltyLine(AppLocalizations l, String mode) => switch (mode) {
      'soft' => l.chrPenaltySoft,
      'strict' => l.chrPenaltyStrict,
      'harsh' => l.chrPenaltyHarsh,
      _ => l.chrPenaltyNormal,
    };

String idleLine(AppLocalizations l, String mode, String name, math.Random rnd) => _pick(rnd, switch (mode) {
      'soft' => [l.chrIdleSoft1(name), l.chrIdleSoft2(name)],
      'strict' => [l.chrIdleStrict1(name), l.chrIdleStrict2(name)],
      'harsh' => [l.chrIdleHarsh1(name), l.chrIdleHarsh2(name)],
      _ => [l.chrIdleNormal1(name), l.chrIdleNormal2(name)],
    });

/// Провал/штраф в мягком режиме — разочарование (talk), иначе злость (angry).
CharacterState _upset(String mode) => mode == 'soft' ? CharacterState.talk : CharacterState.angry;

/// Реакция на итог движка квестов; null — не реагируем (например, смена режима дисциплины).
CharacterLine? outcomeLine(AppLocalizations l, GameOutcome o, String mode, String name, math.Random rnd) {
  String q(QuestItem quest) => questTitleText(l, quest.title);
  return switch (o) {
    QuestCompleted(:final quest) => (state: CharacterState.happy, line: doneLine(l, mode, name, q(quest), rnd)),
    QuestFailed(:final quest) || QuestRefused(:final quest) =>
      (state: _upset(mode), line: failLine(l, mode, name, q(quest), rnd)),
    PenaltyApplied() => (state: _upset(mode), line: penaltyLine(l, mode)),
    LevelUp(:final level) => (state: CharacterState.happy, line: l.chrLevelUp(level, name)),
    BossResult(:final quest, won: true) => (state: CharacterState.happy, line: doneLine(l, mode, name, q(quest), rnd)),
    BossResult(:final quest) => (state: _upset(mode), line: failLine(l, mode, name, q(quest), rnd)),
    _ => null,
  };
}

/// Вес события при пачке итогов (tick): реагируем на самое значимое.
int outcomeWeight(GameOutcome o) => switch (o) {
      LevelUp() => 5,
      BossResult() => 4,
      QuestFailed() || QuestRefused() || PenaltyApplied() => 3,
      QuestCompleted() => 2,
      _ => 0,
    };
