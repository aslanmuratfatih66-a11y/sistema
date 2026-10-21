// Шаблон ухода за кожей (SPEC §8.3) по анкете: раздел skin (oilyByNoon, tightness, reactions) и цели
// (acne, blackheads, swelling). Без названий средств и медицины — только шаги ухода.
// TODO(этап 5): чек-лист и рекомендации средств от ИИ (SkinAssessment, §8.8) заменят шаблон.
import 'package:flutter/foundation.dart';

import '../../../core/models/enums.dart';

/// Тип кожи, выведенный из ответов анкеты (не диагноз).
enum SkinType { normal, oily, combination, dry, unknown }

/// Ключи пунктов чек-листа (хранятся в CareChecks.itemKey — не переименовывать).
abstract final class CareItemKeys {
  static const cleanse = 'cleanse';
  static const coldRinse = 'coldRinse';
  static const moisturize = 'moisturize';
  static const sunscreen = 'sunscreen';
  static const removeSunscreen = 'removeSunscreen';
  static const acneCare = 'acneCare';
  static const exfoliate = 'exfoliate';
  static const handsOff = 'handsOff';
}

/// Входные данные шаблона из анкеты.
@immutable
class CareProfile {
  const CareProfile({this.oilyByNoon, this.tightness, this.sensitive = false, this.goals = const {}});

  /// Из payload раздела skin и активных целей.
  factory CareProfile.from(Map<String, Object?> skin, Iterable<GoalKind> goals) => CareProfile(
        oilyByNoon: skin['oilyByNoon'] as String?,
        tightness: skin['tightness'] as String?,
        sensitive: ((skin['reactions'] as String?) ?? '').trim().isNotEmpty,
        goals: goals.toSet(),
      );

  /// 'no' | 'tzone' | 'all'.
  final String? oilyByNoon;

  /// 'never' | 'sometimes' | 'often'.
  final String? tightness;

  /// Были реакции на средства.
  final bool sensitive;
  final Set<GoalKind> goals;

  SkinType get skinType => switch (oilyByNoon) {
        'all' => SkinType.oily,
        'tzone' => SkinType.combination,
        'no' => tightness == 'often' ? SkinType.dry : SkinType.normal,
        _ => tightness == 'often' ? SkinType.dry : SkinType.unknown,
      };
}

/// Чек-лист на конкретный день.
class CareTemplate {
  const CareTemplate(this.profile);

  final CareProfile profile;

  /// Дни отшелушивания: вторник и пятница (чувствительной коже — только пятница).
  bool _exfoliationDay(DateTime day) =>
      profile.sensitive ? day.weekday == DateTime.friday : (day.weekday == DateTime.tuesday || day.weekday == DateTime.friday);

  bool get _wantsExfoliation =>
      profile.goals.contains(GoalKind.blackheads) ||
      (profile.skinType == SkinType.oily && profile.goals.contains(GoalKind.acne));

  /// Пункты рутины в порядке выполнения.
  List<String> items(CareRoutine routine, DateTime day) {
    final g = profile.goals;
    return switch (routine) {
      CareRoutine.morning => [
          if (g.contains(GoalKind.swelling)) CareItemKeys.coldRinse,
          CareItemKeys.cleanse,
          CareItemKeys.moisturize,
          CareItemKeys.sunscreen,
        ],
      CareRoutine.evening => [
          CareItemKeys.removeSunscreen,
          CareItemKeys.cleanse,
          if (_wantsExfoliation && _exfoliationDay(day)) CareItemKeys.exfoliate,
          if (g.contains(GoalKind.acne)) CareItemKeys.acneCare,
          CareItemKeys.moisturize,
          if (g.contains(GoalKind.acne) || g.contains(GoalKind.blackheads)) CareItemKeys.handsOff,
        ],
    };
  }
}
