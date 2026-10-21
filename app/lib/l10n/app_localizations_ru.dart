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

  @override
  String get planNoticeLabel => 'Уведомление';

  @override
  String get planTitle => 'План составлен';

  @override
  String get planDraftNote =>
      'Черновой план — Система уточнит его после подключения ИИ.';

  @override
  String planAcceptedAt(String date) {
    return 'План принят $date';
  }

  @override
  String get planAccept => 'Принять';

  @override
  String get planEditData => 'Изменить данные';

  @override
  String get planRecalculate => 'Пересчитать';

  @override
  String get planChooseSection => 'Какой раздел изменить?';

  @override
  String get planLoadError => 'Не удалось составить план';

  @override
  String get planRetry => 'Повторить';

  @override
  String get planNormsTitle => 'Нормы';

  @override
  String get planCalories => 'Калории';

  @override
  String planKcal(String value) {
    return '$value ккал';
  }

  @override
  String get planModeDeficit => 'Дефицит';

  @override
  String get planModeSurplus => 'Профицит';

  @override
  String get planModeMaintenance => 'Поддержание';

  @override
  String planBmrTdee(String bmr, String tdee) {
    return 'Базовый обмен $bmr · расход $tdee ккал';
  }

  @override
  String get planProtein => 'Белки';

  @override
  String get planFat => 'Жиры';

  @override
  String get planCarbs => 'Углеводы';

  @override
  String planGrams(String value) {
    return '$value г';
  }

  @override
  String get planWater => 'Вода';

  @override
  String planMl(String value) {
    return '$value мл';
  }

  @override
  String planWaterTrainingDay(String value) {
    return 'В день тренировки — $value мл';
  }

  @override
  String get planSleep => 'Сон';

  @override
  String planHours(String value) {
    return '$value ч';
  }

  @override
  String planHoursMinutes(String h, String m) {
    return '$h ч $m мин';
  }

  @override
  String planWakeBed(String wake, String bed) {
    return 'Подъём $wake · отбой $bed';
  }

  @override
  String get planRoutineTitle => 'Распорядок дня';

  @override
  String planWeek(String n) {
    return 'Неделя $n';
  }

  @override
  String get planWdMon => 'Пн';

  @override
  String get planWdTue => 'Вт';

  @override
  String get planWdWed => 'Ср';

  @override
  String get planWdThu => 'Чт';

  @override
  String get planWdFri => 'Пт';

  @override
  String get planWdSat => 'Сб';

  @override
  String get planWdSun => 'Вс';

  @override
  String get planRoutineWake => 'Подъём';

  @override
  String get planRoutineSkincareAm => 'Уход за кожей (утро)';

  @override
  String planRoutineMeal(String n) {
    return 'Приём пищи $n';
  }

  @override
  String get planRoutineLeaveHome => 'Выход из дома';

  @override
  String get planRoutineLesson => 'Пара';

  @override
  String get planRoutineWork => 'Работа';

  @override
  String get planRoutineOther => 'Дело';

  @override
  String get planRoutineReturnHome => 'Дома';

  @override
  String get planRoutineTraining => 'Тренировка';

  @override
  String get planRoutineSkincarePm => 'Уход за кожей (вечер)';

  @override
  String get planRoutineBed => 'Отбой';

  @override
  String get planQuestsTitle => 'Квесты';

  @override
  String get planQuestsNote =>
      'Выполнение квестов появится в следующем обновлении.';

  @override
  String planQuestLeaveHome(String time) {
    return 'Выйти из дома к $time';
  }

  @override
  String planQuestAttendLesson(String title) {
    return 'Пара: $title';
  }

  @override
  String planQuestAttendWork(String title) {
    return 'Работа: $title';
  }

  @override
  String planQuestWater(String ml) {
    return 'Выпить $ml мл воды';
  }

  @override
  String planQuestSleep(String time, String hours) {
    return 'Лечь спать в $time (сон $hours ч)';
  }

  @override
  String planQuestMeals(String count) {
    return 'Приёмы пищи по плану: $count';
  }

  @override
  String planQuestTraining(String minutes) {
    return 'Тренировка $minutes мин';
  }

  @override
  String get planQuestSkincareMorning => 'Утренний уход за кожей';

  @override
  String get planQuestSkincareEvening => 'Вечерний уход за кожей';

  @override
  String planQuestWakeOnTime(String time) {
    return 'Подъём в $time без отсрочек';
  }

  @override
  String planQuestStudy(String minutes) {
    return 'Учёба $minutes мин';
  }

  @override
  String get planQuestTrackExpenses => 'Записать траты за день';

  @override
  String get planQuestEveryDay => 'каждый день';

  @override
  String planQuestWeekOnly(String n) {
    return 'неделя $n';
  }

  @override
  String planQuestReward(String diamonds, String xp) {
    return '+$diamonds ◆ · +$xp опыта';
  }

  @override
  String get planWarningsTitle => 'Предупреждения';

  @override
  String planWarnSleepShort(String scheduled, String target, String bed) {
    return 'По расписанию сна $scheduled — меньше нормы $target. Рекомендуемый отбой — $bed.';
  }

  @override
  String get planWarnDeficitFloor =>
      'Дефицит калорий ограничен безопасным минимумом — ниже Система не урезает.';

  @override
  String get planWarnActivityDefaulted =>
      'Уровень активности не указан — взят «сидячий».';

  @override
  String planWarnNoTrainingWindow(String day) {
    return '$day: нет свободного окна для тренировки.';
  }

  @override
  String get planWarnInjuries =>
      'Указаны травмы или ограничения — нагрузку подбирайте осторожно, при сомнениях посоветуйтесь с врачом.';

  @override
  String planMissingMessage(String fields) {
    return 'Для расчёта калорий и БЖУ заполните: $fields.';
  }

  @override
  String get planMissingSex => 'пол';

  @override
  String get planMissingBirthDate => 'дата рождения';

  @override
  String get planMissingHeight => 'рост';

  @override
  String get planMissingWeight => 'вес';

  @override
  String planFillSection(String section) {
    return 'Заполнить: $section';
  }

  @override
  String get qaUnitCm => 'см';

  @override
  String get qaUnitKg => 'кг';

  @override
  String qaRangeHint(int min, int max) {
    return 'Допустимо от $min до $max';
  }

  @override
  String get qaProfileIntro =>
      'Система должна знать, как к вам обращаться и где вы находитесь.';

  @override
  String get qaProfileName => 'Имя';

  @override
  String get qaProfileNameHint => 'Как к вам обращаться';

  @override
  String get qaProfileLanguage => 'Язык';

  @override
  String get qaLangRu => 'Русский';

  @override
  String get qaLangTr => 'Türkçe';

  @override
  String get qaLangSystem => 'Как в системе';

  @override
  String get qaProfileSex => 'Пол';

  @override
  String get qaSexMale => 'Мужской';

  @override
  String get qaSexFemale => 'Женский';

  @override
  String get qaProfileBirthDate => 'Дата рождения';

  @override
  String get qaProfileTimezone => 'Часовой пояс';

  @override
  String get qaProfileTimezoneHint => 'Определён по устройству — проверьте';

  @override
  String get qaProfileCity => 'Город';

  @override
  String get qaProfileCityHint => 'Для погоды и магазинов рядом';

  @override
  String get qaBodyIntro =>
      'Исходные параметры тела. По ним Система рассчитает нормы калорий и воды.';

  @override
  String get qaBodyHeight => 'Рост';

  @override
  String get qaBodyWeight => 'Вес';

  @override
  String get qaBodyGirths => 'Обхваты';

  @override
  String get qaBodyGirthsHint =>
      'Измерьте сантиметровой лентой утром, без одежды. Можно пропустить.';

  @override
  String get qaBodyWaist => 'Талия';

  @override
  String get qaBodyHips => 'Бёдра';

  @override
  String get qaBodyChest => 'Грудь';

  @override
  String get qaBodyNeck => 'Шея';

  @override
  String get qaBodyArm => 'Рука (бицепс)';

  @override
  String get qaBodyActivity => 'Уровень активности';

  @override
  String get qaActivitySedentary => 'Минимальный';

  @override
  String get qaActivitySedentaryHint => 'Почти весь день сидя, тренировок нет';

  @override
  String get qaActivityLight => 'Низкий';

  @override
  String get qaActivityLightHint =>
      'Лёгкие тренировки или прогулки 1–3 раза в неделю';

  @override
  String get qaActivityModerate => 'Средний';

  @override
  String get qaActivityModerateHint => 'Тренировки 3–5 раз в неделю';

  @override
  String get qaActivityActive => 'Высокий';

  @override
  String get qaActivityActiveHint => 'Интенсивные тренировки 6–7 раз в неделю';

  @override
  String get qaActivityVeryActive => 'Очень высокий';

  @override
  String get qaActivityVeryActiveHint =>
      'Тяжёлый физический труд или по две тренировки в день';

  @override
  String get qaBodyWorkload => 'Нагрузка на учёбе / работе';

  @override
  String get qaBodyWorkloadHint => 'Как вы проводите основную часть дня';

  @override
  String get qaWorkloadSitting => 'Сидячая';

  @override
  String get qaWorkloadMixed => 'Смешанная';

  @override
  String get qaWorkloadStanding => 'На ногах';

  @override
  String get qaWorkloadPhysical => 'Физический труд';

  @override
  String get qaBodyPhotosIntro =>
      'Фото помогут Системе оценить состав тела и осанку и отслеживать прогресс. Этап можно пропустить. Снимки хранятся на устройстве.';

  @override
  String get qaPhotoTipsTitle => 'Как снимать';

  @override
  String get qaBodyTipLight =>
      'Ровный свет спереди, без яркого окна за спиной.';

  @override
  String get qaBodyTipClothes => 'Облегающая одежда или бельё, волосы убраны.';

  @override
  String get qaBodyTipPose =>
      'Стойте прямо, руки чуть в стороны, смотрите вперёд. Тело — внутри контура.';

  @override
  String get qaBodyTipCamera =>
      'Камера на уровне пояса, в 2–3 метрах. Удобнее со штативом или с помощником.';

  @override
  String get qaPoseBodyFront => 'Спереди';

  @override
  String get qaPoseBodyFrontHint =>
      'Встаньте лицом к камере, руки немного в стороны, ноги на ширине плеч.';

  @override
  String get qaPoseBodySide => 'Сбоку';

  @override
  String get qaPoseBodySideHint =>
      'Повернитесь боком, руки вдоль тела, смотрите прямо.';

  @override
  String get qaPoseBodyBack => 'Сзади';

  @override
  String get qaPoseBodyBackHint =>
      'Встаньте спиной к камере, руки немного в стороны.';

  @override
  String get qaPhotoTap => 'Нажмите, чтобы снять';

  @override
  String get qaPhotoTaken => 'Снято';

  @override
  String get qaPhotoNotTaken => 'Нет фото';

  @override
  String get qaPhotoRetakeHint => 'Снято · нажмите, чтобы переснять';

  @override
  String get qaEstimateTitle => 'Оценка';

  @override
  String get qaEstBodyFat => '% жира';

  @override
  String get qaEstMuscle => 'Мышечная масса';

  @override
  String get qaEstPosture => 'Осанка';

  @override
  String get qaEstFigure => 'Тип фигуры';

  @override
  String get qaEstFaceSwelling => 'Отёчность лица';

  @override
  String get qaExactTitle => 'Знаю точные цифры';

  @override
  String get qaExactHint =>
      'Если есть данные с умных весов или от врача — укажите их, Система будет опираться на них.';

  @override
  String get qaExactFat => '% жира';

  @override
  String get qaExactMuscle => 'Мышечная масса';

  @override
  String get qaCameraWarningLabel => 'Предупреждение';

  @override
  String get qaCameraUnavailable =>
      'Камера недоступна на этом устройстве. Этап можно пропустить и вернуться к нему позже в настройках.';

  @override
  String get qaCameraUnavailableInline =>
      'Камера недоступна — фото можно сделать позже в настройках. Остальные поля работают.';

  @override
  String get qaCameraDenied =>
      'Нет доступа к камере. Разрешите доступ в настройках, затем вернитесь сюда.';

  @override
  String get qaCameraOpenSettings => 'Открыть настройки';

  @override
  String get qaCameraRetake => 'Переснять';

  @override
  String get qaCameraShutter => 'Сделать снимок';

  @override
  String get qaCameraSwitch => 'Сменить камеру';

  @override
  String get qaSkinIntro =>
      'Фото лица и несколько вопросов помогут Системе подобрать уход. Фото необязательны.';

  @override
  String get qaSkinTipLight => 'Дневной свет у окна, без фильтров и вспышки.';

  @override
  String get qaSkinTipClean => 'Чистое лицо без макияжа и крема.';

  @override
  String get qaSkinTipHair => 'Уберите волосы со лба и щёк.';

  @override
  String get qaSkinFacePhotos => 'Фото лица';

  @override
  String get qaPoseFaceFront => 'Анфас';

  @override
  String get qaPoseFaceFrontHint =>
      'Смотрите прямо в камеру, лицо — внутри овала.';

  @override
  String get qaPoseFaceLeft => 'Профиль слева';

  @override
  String get qaPoseFaceLeftHint =>
      'Поверните голову вправо, чтобы в кадре была левая сторона лица.';

  @override
  String get qaPoseFaceRight => 'Профиль справа';

  @override
  String get qaPoseFaceRightHint =>
      'Поверните голову влево, чтобы в кадре была правая сторона лица.';

  @override
  String get qaSkinCloseups => 'Проблемные зоны крупно';

  @override
  String get qaSkinCloseupsHint => 'Можно несколько снимков';

  @override
  String get qaPoseCloseup => 'Крупный план';

  @override
  String get qaPoseCloseupHint =>
      'Поднесите камеру близко к зоне, дождитесь фокуса.';

  @override
  String get qaSkinAddCloseup => 'Добавить';

  @override
  String get qaSkinOily => 'Жирность к обеду';

  @override
  String get qaSkinOilyNo => 'Нет';

  @override
  String get qaSkinOilyTzone => 'Т-зона';

  @override
  String get qaSkinOilyAll => 'Всё лицо';

  @override
  String get qaSkinTightness => 'Стянутость после умывания';

  @override
  String get qaSkinTightNever => 'Никогда';

  @override
  String get qaSkinTightSometimes => 'Иногда';

  @override
  String get qaSkinTightOften => 'Часто';

  @override
  String get qaSkinReactions => 'Реакции на средства';

  @override
  String get qaSkinReactionsHint => 'Что вызывало покраснение, зуд, высыпания';

  @override
  String get qaSkinRoutine => 'Текущий уход';

  @override
  String get qaSkinRoutineHint => 'Чем умываетесь, какие средства используете';

  @override
  String get qaEstSkinType => 'Тип кожи';

  @override
  String get qaEstAcne => 'Акне';

  @override
  String get qaEstBlackheads => 'Чёрные точки';

  @override
  String get qaEstPostAcne => 'Постакне';

  @override
  String get qaSkinDermTitle => 'Рекомендация';

  @override
  String get qaSkinDermAdvice =>
      'При выраженных воспалениях, болезненных высыпаниях или рубцах покажитесь дерматологу. Система подберёт уход, но не заменяет врача.';

  @override
  String get qaHealthIntro =>
      'Всё необязательно. Ответы нужны, чтобы план был безопасным.';

  @override
  String get qaHealthChronic => 'Хронические состояния';

  @override
  String get qaHealthChronicHint => 'Например: гастрит, астма';

  @override
  String get qaHealthMedications => 'Лекарства';

  @override
  String get qaHealthMedicationsHint => 'Что принимаете постоянно';

  @override
  String get qaHealthAllergies => 'Аллергии';

  @override
  String get qaHealthAllergiesHint => 'Продукты, лекарства, средства';

  @override
  String get qaHealthIntolerances => 'Непереносимости';

  @override
  String get qaHealthIntolerancesHint => 'Например: лактоза, глютен';

  @override
  String get qaHealthInjuries => 'Травмы и ограничения';

  @override
  String get qaHealthInjuriesHint =>
      'Что нельзя или трудно делать на тренировках';

  @override
  String get qaHealthSleep => 'Качество сна';

  @override
  String get qaHealthSleepHint => '1 — очень плохо, 5 — отлично';

  @override
  String get qaHealthStress => 'Уровень стресса';

  @override
  String get qaHealthStressHint => '1 — почти нет, 5 — очень высокий';

  @override
  String get qaGoalsIntro =>
      'Чего вы хотите добиться? Система построит квесты вокруг этих целей.';

  @override
  String get qaGoalsPick => 'Цели';

  @override
  String get qaGoalsPickHint => 'Можно выбрать несколько';

  @override
  String get qaGoalAcne => 'Избавиться от прыщей';

  @override
  String get qaGoalBlackheads => 'Убрать чёрные точки';

  @override
  String get qaGoalSwelling => 'Убрать отёки';

  @override
  String get qaGoalWeightLoss => 'Сбросить лишний вес';

  @override
  String get qaGoalMuscle => 'Набрать мышцы';

  @override
  String get qaGoalDiscipline => 'Дисциплина';

  @override
  String get qaGoalStudy => 'Учёба';

  @override
  String get qaGoalMoney => 'Деньги';

  @override
  String get qaGoalCustom => 'Своя цель';

  @override
  String get qaGoalsOwn => 'Свои цели';

  @override
  String get qaGoalsOwnHint => 'Например: выучить турецкий';

  @override
  String get qaGoalsEmpty => 'Выберите хотя бы одну цель';

  @override
  String get qaGoalPriority => 'Приоритет';

  @override
  String get qaGoalPriorityHigh => 'Высокий';

  @override
  String get qaGoalPriorityMedium => 'Средний';

  @override
  String get qaGoalPriorityLow => 'Низкий';

  @override
  String get qaGoalDeadline => 'Срок';

  @override
  String get qaGoalDeadlineClear => 'Убрать срок';

  @override
  String get qbScheduleIntro =>
      'Система построит день вокруг учёбы, работы и сна. Укажите пары, дорогу, подъём и отбой.';

  @override
  String get qbNutritionIntro =>
      'Эти данные нужны для норм калорий, меню и списка покупок.';

  @override
  String get qbMealsPerDay => 'Приёмов пищи в день';

  @override
  String get qbPreferences => 'Предпочтения';

  @override
  String get qbPreferencesHint => 'Что любите, какую кухню, режим питания';

  @override
  String get qbExcluded => 'Что не едите';

  @override
  String get qbExcludedHint => 'Продукты, которые исключить из меню';

  @override
  String get qbFoodBudget => 'Бюджет на еду';

  @override
  String get qbRubPerWeek => '₽/нед';

  @override
  String get qbCanCook => 'Умеете готовить?';

  @override
  String get qbCookNo => 'Нет';

  @override
  String get qbCookBasic => 'Простое';

  @override
  String get qbCookGood => 'Хорошо';

  @override
  String get qbStores => 'Где покупаете продукты';

  @override
  String get qbStoresHint => 'Можно выбрать несколько';

  @override
  String get qbStorePyaterochka => 'Пятёрочка';

  @override
  String get qbStoreMagnit => 'Магнит';

  @override
  String get qbStorePerekrestok => 'Перекрёсток';

  @override
  String get qbStoreVkusvill => 'ВкусВилл';

  @override
  String get qbStoreLenta => 'Лента';

  @override
  String get qbStoreAuchan => 'Ашан';

  @override
  String get qbStoreMarket => 'Рынок';

  @override
  String get qbStoreDelivery => 'Доставка';

  @override
  String get qbStoreOther => 'Другое (через запятую)';

  @override
  String get qbWaterNow => 'Сколько воды пьёте сейчас';

  @override
  String get qbWaterNowHint => 'Примерно, в миллилитрах в день';

  @override
  String get qbWaterExact => 'Точное значение';

  @override
  String get qbMlPerDay => 'мл/день';

  @override
  String get qbTrainingIntro =>
      'Тренировки — дома. Система подберёт программу под ваш инвентарь и время.';

  @override
  String get qbPlace => 'Место';

  @override
  String get qbPlaceHome => 'Дом';

  @override
  String get qbPlaceHomeNote => 'Программа рассчитана на домашние тренировки';

  @override
  String get qbEquipment => 'Инвентарь';

  @override
  String get qbEquipNone => 'Нет инвентаря';

  @override
  String get qbEquipDumbbells => 'Гантели';

  @override
  String get qbEquipPullupBar => 'Турник';

  @override
  String get qbEquipBands => 'Резинки';

  @override
  String get qbEquipMat => 'Коврик';

  @override
  String get qbEquipKettlebell => 'Гиря';

  @override
  String get qbEquipOther => 'Другое';

  @override
  String get qbLevel => 'Уровень подготовки';

  @override
  String get qbLevelBeginner => 'Новичок';

  @override
  String get qbLevelIntermediate => 'Средний';

  @override
  String get qbLevelAdvanced => 'Опытный';

  @override
  String get qbMinutesPerDay => 'Минут в день';

  @override
  String get qbMinutesExact => 'Своё значение';

  @override
  String get qbMinutesUnit => 'мин';

  @override
  String get qbTrainingDays => 'Дни тренировок';

  @override
  String get qbDayMon => 'Пн';

  @override
  String get qbDayTue => 'Вт';

  @override
  String get qbDayWed => 'Ср';

  @override
  String get qbDayThu => 'Чт';

  @override
  String get qbDayFri => 'Пт';

  @override
  String get qbDaySat => 'Сб';

  @override
  String get qbDaySun => 'Вс';

  @override
  String get qbFinanceIntro =>
      'Всё необязательно. Доходы и счета помогут Системе следить за бюджетом и лимитами.';

  @override
  String get qbFinIncomes => 'Доходы';

  @override
  String get qbFinIncomesHint =>
      'Стипендия, зарплата, переводы — и когда приходят';

  @override
  String get qbFinAddIncome => 'Добавить доход';

  @override
  String get qbFinAccounts => 'Счета';

  @override
  String get qbFinAddAccount => 'Добавить счёт';

  @override
  String get qbFinCurrencies => 'Валюты';

  @override
  String get qbFinCurrenciesHint => 'RUB — основная, отчёты в рублях';

  @override
  String get qbFinCrypto => 'Криптовалюта';

  @override
  String get qbFinAddCrypto => 'Добавить монету';

  @override
  String get qbFinDebts => 'Долги';

  @override
  String get qbFinAddDebt => 'Добавить долг';

  @override
  String get qbFinIncome => 'Доход';

  @override
  String get qbFinAccount => 'Счёт';

  @override
  String get qbFinCryptoItem => 'Монета';

  @override
  String get qbFinDebt => 'Долг';

  @override
  String get qbIncomeStipend => 'Стипендия';

  @override
  String get qbIncomeSalary => 'Зарплата';

  @override
  String get qbIncomeTransfer => 'Переводы';

  @override
  String get qbIncomeOther => 'Другое';

  @override
  String get qbFinIncomeKind => 'Вид дохода';

  @override
  String get qbFinTitle => 'Название';

  @override
  String get qbFinAmount => 'Сумма';

  @override
  String get qbFinDayOfMonth => 'Число месяца поступления';

  @override
  String qbFinDayOfMonthShort(int day) {
    return '$day-го числа';
  }

  @override
  String get qbFinCash => 'Наличные';

  @override
  String get qbFinCard => 'Карта';

  @override
  String get qbFinBank => 'Банк';

  @override
  String get qbFinCurrency => 'Валюта';

  @override
  String get qbFinBalance => 'Баланс';

  @override
  String get qbFinCryptoSymbol => 'Тикер';

  @override
  String get qbFinCryptoAmount => 'Количество';

  @override
  String get qbFinCryptoRateNote =>
      'Количество — вручную, курс будет подтягиваться автоматически';

  @override
  String get qbFinIOwe => 'Я должен';

  @override
  String get qbFinOweMe => 'Мне должны';

  @override
  String get qbFinDebtToWhom => 'Кому';

  @override
  String get qbFinDebtWho => 'Кто';

  @override
  String get qbFinDueDate => 'Срок';

  @override
  String get qbFinClearDate => 'Убрать срок';

  @override
  String qbFinDueShort(String date) {
    return 'до $date';
  }

  @override
  String get qbCharacterIntro =>
      'Выберите спутника. Он будет напоминать, хвалить и ругать — в выбранном режиме.';

  @override
  String get qbArchetype => 'Персонаж';

  @override
  String get qbArchetypeRequired => 'Выберите персонажа, чтобы продолжить';

  @override
  String get qbArchAnimeGirl => 'Аниме-девушка';

  @override
  String get qbArchAnimeGirlDesc =>
      'Жизнерадостная и упрямая. Радуется каждой победе и не даёт сдаться.';

  @override
  String get qbArchAnimeGirlSpeech =>
      'живая, с восклицаниями и подбадриваниями';

  @override
  String get qbArchAnimeGuy => 'Аниме-парень';

  @override
  String get qbArchAnimeGuyDesc =>
      'Соперник и напарник. Вызывает на спор и тянет вперёд.';

  @override
  String get qbArchAnimeGuySpeech => 'дерзкая, с вызовом и азартом';

  @override
  String get qbArchStoicStrongman => 'Невозмутимый силач';

  @override
  String get qbArchStoicStrongmanDesc =>
      'Спокоен как скала. Верит в дисциплину и повторения.';

  @override
  String get qbArchStoicStrongmanSpeech => 'короткие фразы, без лишних слов';

  @override
  String get qbArchGrimSwordsman => 'Мрачный мечник';

  @override
  String get qbArchGrimSwordsmanDesc =>
      'Суровый наставник. Каждый день — тренировка воли.';

  @override
  String get qbArchGrimSwordsmanSpeech => 'сдержанная, с мрачной иронией';

  @override
  String qbArchSpeechLabel(String speech) {
    return 'Манера речи: $speech';
  }

  @override
  String get qbVoice => 'Голос';

  @override
  String get qbVoiceLater => 'Голос подключится позже';

  @override
  String get qbVoiceBright => 'Звонкий';

  @override
  String get qbVoiceSoft => 'Мягкий';

  @override
  String get qbVoiceCalm => 'Спокойный';

  @override
  String get qbVoiceEnergetic => 'Энергичный';

  @override
  String get qbVoiceDeep => 'Глубокий';

  @override
  String get qbVoiceLow => 'Низкий';

  @override
  String get qbVoiceHoarse => 'Хриплый';

  @override
  String get qbMotivation => 'Режим мотивации';

  @override
  String get qbMotSoft => 'Мягкий';

  @override
  String get qbMotSoftDesc => 'Поддержка и мягкие напоминания, без давления.';

  @override
  String get qbMotNormal => 'Обычный';

  @override
  String get qbMotNormalDesc =>
      'Похвала за успехи, спокойные замечания за пропуски.';

  @override
  String get qbMotStrict => 'Строгий';

  @override
  String get qbMotStrictDesc =>
      'Чёткие требования и прямая критика за провалы.';

  @override
  String get qbMotHarsh => 'Жёсткий';

  @override
  String get qbMotHarshDesc =>
      'Ругает по всей строгости, но без унижений внешности и здоровья.';

  @override
  String get qbProfanity => 'Допускать мат';

  @override
  String get qbProfanityHint => 'Редко и только в жёстком режиме';

  @override
  String get qbPermissionsIntro =>
      'Система запросит разрешения по одному. Любое можно выдать позже в настройках.';

  @override
  String qbPermProgress(int done, int total) {
    return 'Обработано $done из $total';
  }

  @override
  String get qbPermAllow => 'Разрешить';

  @override
  String get qbPermLater => 'Позже';

  @override
  String get qbPermOpenSettings => 'Открыть настройки';

  @override
  String get qbPermGranted => 'Выдано';

  @override
  String get qbPermDenied => 'Отказано';

  @override
  String get qbPermSkipped => 'Позже';

  @override
  String get qbPermUnavailable => 'Недоступно';

  @override
  String get qbPermAllDone =>
      'Готово. Изменить разрешения можно в любой момент.';

  @override
  String get qbPermNoneAvailable =>
      'На этом устройстве разрешения не требуются.';

  @override
  String get qbPermNotifications => 'Уведомления';

  @override
  String get qbPermNotificationsWhy =>
      'Напоминания о квестах, воде, сне и сообщения персонажа.';

  @override
  String get qbPermMotion => 'Движение и фитнес';

  @override
  String get qbPermMotionWhy =>
      'Подсчёт шагов и активности для квестов и калорий.';

  @override
  String get qbPermLocationAlways => 'Геолокация «Всегда»';

  @override
  String get qbPermLocationAlwaysWhy =>
      'Запись прогулок в фоне и подсказки маршрута. Сначала система спросит доступ «При использовании», затем «Всегда».';

  @override
  String get qbPermCamera => 'Камера';

  @override
  String get qbPermCameraWhy =>
      'Фото тела, кожи, еды и чеков для оценки прогресса.';

  @override
  String get qbPermMicrophone => 'Микрофон';

  @override
  String get qbPermMicrophoneWhy => 'Голосовое общение с персонажем.';

  @override
  String get qbPermMediaLibrary => 'Медиатека';

  @override
  String get qbPermMediaLibraryWhy =>
      'Показ текущего трека Apple Music на прогулке и тренировке.';

  @override
  String get qbPermAlarms => 'Будильники';

  @override
  String get qbPermAlarmsWhy =>
      'Точные будильники для подъёма и важных квестов.';

  @override
  String get qbPermAlarmsLater => 'Настроим на этапе будильника.';

  @override
  String get schTitle => 'Расписание';

  @override
  String get schInstitution => 'Учебное заведение';

  @override
  String get schInstSchool => 'Школа';

  @override
  String get schInstCollege => 'Колледж';

  @override
  String get schInstUniversity => 'Вуз';

  @override
  String get schInstNone => 'Не учусь';

  @override
  String get schInstitutionName => 'Название';

  @override
  String get schInstitutionNameHint => 'Например: МГУ, школа № 5';

  @override
  String get schWake => 'Подъём';

  @override
  String get schBed => 'Отбой';

  @override
  String get schCommute => 'Дорога до учёбы';

  @override
  String get schCommuteHint => 'В одну сторону, в минутах';

  @override
  String get schMinutesUnit => 'мин';

  @override
  String get schWeekends => 'Выходные дни';

  @override
  String get schAlternation => 'Чередование недель (неделя 1/2)';

  @override
  String get schAlternationHint => 'Разные пары по чётным и нечётным неделям';

  @override
  String schCurrentWeek(int week) {
    return 'Сейчас: неделя $week';
  }

  @override
  String get schSwitchWeek => 'Переключить неделю';

  @override
  String schWeekN(int week) {
    return 'Неделя $week';
  }

  @override
  String get schItemsTitle => 'Пункты расписания';

  @override
  String get schDayEmpty => 'Нет пунктов';

  @override
  String get schAddItem => 'Добавить пункт';

  @override
  String schAddItemTo(String day) {
    return 'Добавить пункт: $day';
  }

  @override
  String get schCopyDay => 'Копировать день';

  @override
  String schCopyDayFrom(String day) {
    return 'Копировать день: $day';
  }

  @override
  String get schCopyDayTo => 'На какой день скопировать?';

  @override
  String schCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Скопировано $count пункта',
      many: 'Скопировано $count пунктов',
      few: 'Скопировано $count пункта',
      one: 'Скопирован $count пункт',
    );
    return '$_temp0';
  }

  @override
  String get schItemNew => 'Новый пункт';

  @override
  String get schItemEdit => 'Пункт расписания';

  @override
  String get schItemTitle => 'Название';

  @override
  String get schItemTitleHint => 'Например: Матанализ';

  @override
  String get schKind => 'Тип';

  @override
  String get schKindLesson => 'Пара / урок';

  @override
  String get schKindWork => 'Работа';

  @override
  String get schKindOther => 'Другое';

  @override
  String get schDay => 'День недели';

  @override
  String get schStart => 'Начало';

  @override
  String get schDuration => 'Длительность, мин';

  @override
  String schEndsAt(String time) {
    return 'Окончание: $time';
  }

  @override
  String get schParity => 'Неделя';

  @override
  String get schParityEvery => 'Каждую';

  @override
  String get schLocation => 'Место';

  @override
  String get schLocationHint => 'Аудитория, адрес';

  @override
  String get schRequiresCommute => 'Нужна дорога';

  @override
  String get schRequiresCommuteHint => 'Учитывать во времени выхода из дома';

  @override
  String get schDeleteConfirm => 'Удалить пункт?';

  @override
  String get schWd1 => 'Пн';

  @override
  String get schWd2 => 'Вт';

  @override
  String get schWd3 => 'Ср';

  @override
  String get schWd4 => 'Чт';

  @override
  String get schWd5 => 'Пт';

  @override
  String get schWd6 => 'Сб';

  @override
  String get schWd7 => 'Вс';

  @override
  String get schWdFull1 => 'Понедельник';

  @override
  String get schWdFull2 => 'Вторник';

  @override
  String get schWdFull3 => 'Среда';

  @override
  String get schWdFull4 => 'Четверг';

  @override
  String get schWdFull5 => 'Пятница';

  @override
  String get schWdFull6 => 'Суббота';

  @override
  String get schWdFull7 => 'Воскресенье';

  @override
  String get schWeekend => 'Выходной';

  @override
  String schHeader(int week, String day) {
    return 'Неделя $week · $day';
  }

  @override
  String schHeaderNoAlt(String day) {
    return 'Без чередования · $day';
  }

  @override
  String get schPrevWeek => 'Предыдущая неделя';

  @override
  String get schNextWeek => 'Следующая неделя';

  @override
  String get schToday => 'Сегодня';

  @override
  String get schDayFeed => 'День';

  @override
  String get schSlotSleep => 'Сон';

  @override
  String get schSlotCommute => 'Дорога';

  @override
  String get schSlotFree => 'Свободно';

  @override
  String schLeaveHome(String time) {
    return 'Выход из дома в $time';
  }

  @override
  String get schNoLeave => 'В этот день выходить не нужно';

  @override
  String schFreeTotal(String duration) {
    return 'Свободно: $duration';
  }

  @override
  String schHoursMinutes(int hours, int minutes) {
    return '$hours ч $minutes мин';
  }

  @override
  String schMinutes(int minutes) {
    return '$minutes мин';
  }

  @override
  String schTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String get schEditSchedule => 'Редактировать расписание';

  @override
  String get schBack => 'Назад';

  @override
  String get schWarningLabel => 'Предупреждение';

  @override
  String get setSectionQuestionnaire => 'Анкета';

  @override
  String get setSectionPlan => 'План';

  @override
  String get setPlan => 'План';

  @override
  String get setPlanHint => 'Предпросмотр и принятие плана';

  @override
  String get setSchedule => 'Расписание';

  @override
  String get setScheduleHint => 'Пары, работа, сон';

  @override
  String get setSectionLanguage => 'Язык';

  @override
  String get setLangRu => 'Русский';

  @override
  String get setLangTr => 'Türkçe';

  @override
  String get setLangSystem => 'Как в системе';

  @override
  String get setSectionData => 'Данные';

  @override
  String get setExport => 'Экспорт в JSON';

  @override
  String get setExportHint =>
      'Все данные одним файлом — сохраните его в «Файлы» или отправьте себе';

  @override
  String get setIncludePhotos => 'Включить фото';

  @override
  String get setIncludePhotosHint => 'Файл станет больше';

  @override
  String get setPhotosWebNote => 'В браузере фото не переносятся';

  @override
  String get setImport => 'Импорт из JSON';

  @override
  String get setImportHint => 'Заменит все данные на этом устройстве';

  @override
  String get setRestart => 'Пройти анкету заново';

  @override
  String get setRestartHint => 'Ответы сохранятся, их можно будет изменить';

  @override
  String get setRestartMessage =>
      'Анкета начнётся с первого этапа. Введённые данные не удаляются.';

  @override
  String get setRestartConfirm => 'Начать заново';

  @override
  String get setSectionAbout => 'О приложении';

  @override
  String get setVersion => 'Версия';

  @override
  String get setPlatform => 'Платформа';

  @override
  String get setPlatformOther => 'Другая';

  @override
  String get setCertExpires => 'Сертификат действует до';

  @override
  String setGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count цели',
      many: '$count целей',
      few: '$count цели',
      one: '$count цель',
    );
    return '$_temp0';
  }

  @override
  String setHeightValue(String value) {
    return '$value см';
  }

  @override
  String setWeightValue(String value) {
    return '$value кг';
  }

  @override
  String get setNoticeLabel => 'Уведомление';

  @override
  String get setWarningLabel => 'Предупреждение';

  @override
  String get setErrorLabel => 'Ошибка';

  @override
  String get setExportReady => 'Файл резервной копии готов';

  @override
  String get setExportFailed =>
      'Не удалось подготовить файл. Попробуйте ещё раз.';

  @override
  String get setShareUnavailable =>
      'Отправка файлов недоступна на этом устройстве.';

  @override
  String get setPickUnavailable => 'Выбор файла недоступен на этом устройстве.';

  @override
  String get setImportPreviewTitle => 'Что будет импортировано';

  @override
  String setImportExportedAt(String date) {
    return 'Создан: $date';
  }

  @override
  String setImportRows(String table, int count) {
    return '$table: $count';
  }

  @override
  String setImportPhotos(int count) {
    return 'Файлов фото: $count';
  }

  @override
  String get setImportNoPhotos => 'Фото в файле нет';

  @override
  String get setImportWarning =>
      'Все текущие данные на этом устройстве будут заменены.';

  @override
  String get setImportReplace => 'Заменить все данные';

  @override
  String get setImportHoldHint => 'Удерживайте, чтобы подтвердить';

  @override
  String get setImportDone => 'Данные импортированы';

  @override
  String get setImportFailed => 'Импорт не удался. Данные не изменены.';

  @override
  String get setErrNotJson => 'Файл не читается как JSON.';

  @override
  String get setErrWrongFormat => 'Это не резервная копия Системы.';

  @override
  String get setErrFormatVersion => 'Версия формата файла не поддерживается.';

  @override
  String get setErrNewerSchema =>
      'Файл создан более новой версией приложения. Обновите приложение и повторите.';

  @override
  String get setErrInvalid => 'Файл повреждён.';

  @override
  String get setTableAppSettings => 'Настройки';

  @override
  String get setTableProfiles => 'Профиль';

  @override
  String get setTableBodyMeasurements => 'Замеры тела';

  @override
  String get setTablePhotos => 'Записи фото';

  @override
  String get setTableGoals => 'Цели';

  @override
  String get setTableScheduleSettings => 'Параметры расписания';

  @override
  String get setTableScheduleItems => 'Пункты расписания';

  @override
  String get setTablePlans => 'Планы';

  @override
  String get setTableQuestionnaireSections => 'Разделы анкеты';
}
