// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Система';

  @override
  String get navStatus => 'Статус';

  @override
  String get navQuests => 'Квесты';

  @override
  String get navNutrition => 'Питание';

  @override
  String get navShop => 'Магазин';

  @override
  String get navMore => 'Ещё';

  @override
  String get sectionEmptyTitle => 'Раздел в разработке';

  @override
  String get sectionEmptyBody =>
      'Система откроет этот раздел на следующих этапах.';

  @override
  String certExpiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Сертификат истекает через $days дней',
      few: 'Сертификат истекает через $days дня',
      one: 'Сертификат истекает через $days день',
      zero: 'Сертификат истекает сегодня',
    );
    return '$_temp0';
  }

  @override
  String get certExpired => 'Сертификат истёк — переустановите приложение';

  @override
  String get certReinstallHint =>
      'Переустановите приложение через Sideloadly, данные сохранятся после синхронизации.';

  @override
  String get homeSystemOnline => 'Система · онлайн';

  @override
  String homeNotificationsLabel(int count) {
    return 'Уведомления: $count';
  }

  @override
  String get homeSettingsLabel => 'Настройки';

  @override
  String homeWeekDay(int week, int day) {
    return 'Неделя $week · день $day';
  }

  @override
  String get homeStatusTitle => 'Статус';

  @override
  String get homeLevelShort => 'LV';

  @override
  String homeLevelSemantics(int level) {
    return 'Уровень $level';
  }

  @override
  String homeRank(String rank) {
    return 'Ранг $rank';
  }

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня подряд',
      many: '$count дней подряд',
      few: '$count дня подряд',
      one: '$count день подряд',
    );
    return '$_temp0';
  }

  @override
  String homeXpLabel(int level) {
    return 'Опыт · до LV $level';
  }

  @override
  String homeXpValue(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String get homeEnergy => 'Энергия';

  @override
  String get homeWater => 'Вода';

  @override
  String get homeCalories => 'Калории';

  @override
  String homePercentValue(String value) {
    return '$value%';
  }

  @override
  String homeLitersProgress(String current, String total) {
    return '$current / $total л';
  }

  @override
  String homeKcalProgress(String current, String total) {
    return '$current / $total ккал';
  }

  @override
  String homeKcalValue(String value) {
    return '$value ккал';
  }

  @override
  String get homeStatStrength => 'Сила';

  @override
  String get homeStatEndurance => 'Выносливость';

  @override
  String get homeStatDiscipline => 'Дисциплина';

  @override
  String get homeStatIntellect => 'Интеллект';

  @override
  String get homeStatHealth => 'Здоровье';

  @override
  String get homeStatLooks => 'Внешность';

  @override
  String homeStatDeltaSemantics(String stat, String value, String delta) {
    return '$stat: $value, за сегодня $delta';
  }

  @override
  String get homePointsLabel => 'Баллы';

  @override
  String homePointsValue(String points) {
    return '$points ◆';
  }

  @override
  String homeStatPointsButton(int count) {
    return 'Очки характ.: $count';
  }

  @override
  String get homeEffectsTitle => 'Эффекты';

  @override
  String get homeEffectsEmpty => 'Активных эффектов нет';

  @override
  String get homeNextQuestTitle => 'Следующий квест';

  @override
  String homeQuestDeadline(String time) {
    return 'до $time';
  }

  @override
  String homeTimeLeftSemantics(String time) {
    return 'Осталось $time';
  }

  @override
  String get homeRewardLabel => 'Награда';

  @override
  String get homePenaltyLabel => 'Штраф';

  @override
  String homeRewardPoints(String points) {
    return '+$points ◆';
  }

  @override
  String homePenaltyPoints(String points) {
    return '−$points ◆';
  }

  @override
  String homeRewardXp(String xp) {
    return '+$xp XP';
  }

  @override
  String get homeActionDone => 'Выполнено';

  @override
  String get homeActionSnooze => '+10 мин';

  @override
  String get homeActionNoWater => 'Нет воды';

  @override
  String get homeActionRefuse => 'Отказ';

  @override
  String get homeRefuseHint => 'Отказ: удерживать 5 сек';

  @override
  String get homeNoticeLabel => 'Уведомление';

  @override
  String get homeWarningLabel => 'Предупреждение';

  @override
  String get homeQuestCompletedTitle => 'Квест выполнен';

  @override
  String homeQuestCompletedMessage(String points, String xp) {
    return 'Награда: +$points ◆, +$xp XP.';
  }

  @override
  String get homeQuestFailedTitle => 'Квест провален';

  @override
  String homeQuestRefusedMessage(String quest, String points) {
    return 'Отказ от квеста «$quest». Штраф: −$points ◆.';
  }

  @override
  String get homeNoWaterMessage =>
      'Квест отложен: Система напомнит, когда вода будет рядом.';

  @override
  String get homeOk => 'Понятно';

  @override
  String get homeDayTitle => 'День';

  @override
  String get homeSegSleep => 'Сон';

  @override
  String get homeSegClasses => 'Пары';

  @override
  String get homeSegWorkout => 'Тренировка';

  @override
  String get homeSegFree => 'Свободно';

  @override
  String get homeSegCommute => 'Дорога';

  @override
  String homeNow(String time) {
    return 'Сейчас $time';
  }

  @override
  String homeLeaveHome(String time) {
    return 'Выход из дома: $time';
  }

  @override
  String homeSegmentSemantics(String type, String start, String end) {
    return '$type: $start–$end';
  }

  @override
  String get homeDailyTitle => 'Ежедневные квесты';

  @override
  String homeDailyCounter(int done, int total) {
    return '$done / $total';
  }

  @override
  String homeDailyPenaltyTotal(String points) {
    return 'Штраф при провале: −$points ◆';
  }

  @override
  String homeMinutesProgress(String current, String total) {
    return '$current / $total мин';
  }

  @override
  String homeStepsProgress(String current, String total) {
    return '$current / $total шагов';
  }

  @override
  String get homeBossTitle => 'Босс недели';

  @override
  String homeBossTimeLeft(String days, String time) {
    return '$days д $time';
  }

  @override
  String homeBossProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String homeBossReward(String points, String title) {
    return 'Награда: +$points ◆ и титул «$title»';
  }

  @override
  String get homeEaten => 'Съедено';

  @override
  String get homeBurned => 'Сожжено';

  @override
  String get homeDeficit => 'Дефицит';

  @override
  String get homeFinanceTitle => 'Финансы';

  @override
  String get homeFoodSpent => 'Траты на еду';

  @override
  String get homeLimit => 'Лимит';

  @override
  String get homeUntilStipend => 'До стипендии';

  @override
  String homeDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count дня',
      many: '$count дней',
      few: '$count дня',
      one: '$count день',
    );
    return '$_temp0';
  }

  @override
  String get homeAssistantTitle => 'Ассистент';

  @override
  String get homeAssistantAvatar => 'Персонаж-ассистент';

  @override
  String get homeAssistantSpeaking => 'Ассистент говорит';

  @override
  String get homeMicLabel => 'Голосовой ввод';

  @override
  String get homeReplyHint => 'Ответить…';

  @override
  String get homeSendLabel => 'Отправить';

  @override
  String get homeDemoPlayerName => 'Мурат';

  @override
  String get homeDemoPlayerTitle => 'Пробуждённый';

  @override
  String get homeDemoEffectVigor => 'Бодрость +5% опыта';

  @override
  String get homeDemoEffectDehydration => 'Обезвоживание −10% выносливости';

  @override
  String get homeDemoNextQuest => 'Выпить 500 мл воды';

  @override
  String get homeDemoQuestWakeUp => 'Подъём до 07:00';

  @override
  String get homeDemoQuestBreakfast => 'Завтрак с белком';

  @override
  String get homeDemoQuestWater => 'Выпить 2,5 л воды';

  @override
  String get homeDemoQuestWorkout => 'Тренировка дома';

  @override
  String get homeDemoSubWarmup => 'Разминка 5 мин';

  @override
  String get homeDemoSubPushups => 'Отжимания 3×15';

  @override
  String get homeDemoSubPlank => 'Планка 3×45 с';

  @override
  String get homeDemoQuestReading => 'Читать 20 минут';

  @override
  String get homeDemoQuestSteps => 'Пройти 8 000 шагов';

  @override
  String get homeDemoQuestSleep => 'Отбой до 23:00';

  @override
  String get homeDemoBossGoal => 'Провести 5 тренировок за неделю';

  @override
  String get homeDemoBossRewardTitle => 'Несгибаемый';

  @override
  String get homeDemoAssistantLine =>
      'Вода — 48% нормы. Выпей стакан до 11:30, и «Бодрость» продлится ещё час.';

  @override
  String get commonNext => 'Далее';

  @override
  String get commonBack => 'Назад';

  @override
  String get commonDone => 'Готово';

  @override
  String get commonClose => 'Закрыть';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonSkip => 'Пропустить';

  @override
  String get commonOptional => 'необязательно';

  @override
  String get commonOutOfRange => 'Проверьте значение';

  @override
  String get commonRequired => 'Обязательное поле';

  @override
  String get commonEstimateNote => 'оценка по фото, не медицинское измерение';

  @override
  String get commonCalculatedBySystem => 'Будет рассчитано Системой';

  @override
  String get onbIntroLabel => 'Уведомление';

  @override
  String get onbIntroTitle => 'Вы получили право стать Игроком';

  @override
  String get onbIntroMessage =>
      'Система соберёт сведения о вас, чтобы составить план. Ответы сохраняются сразу — можно прерваться и продолжить позже. Любой раздел можно изменить в настройках.';

  @override
  String get onbIntroAccept => 'Принять';

  @override
  String onbStepCounter(int current, int total) {
    return 'Этап $current/$total';
  }

  @override
  String get onbFinish => 'Завершить';

  @override
  String get onbStepProfile => 'Профиль';

  @override
  String get onbStepBody => 'Тело';

  @override
  String get onbStepBodyPhotos => 'Фото тела';

  @override
  String get onbStepSkin => 'Кожа';

  @override
  String get onbStepHealth => 'Здоровье';

  @override
  String get onbStepGoals => 'Цели';

  @override
  String get onbStepSchedule => 'Расписание';

  @override
  String get onbStepNutrition => 'Питание';

  @override
  String get onbStepTraining => 'Тренировки';

  @override
  String get onbStepFinance => 'Финансы';

  @override
  String get onbStepCharacter => 'Персонаж и голос';

  @override
  String get onbStepPermissions => 'Разрешения';
}
