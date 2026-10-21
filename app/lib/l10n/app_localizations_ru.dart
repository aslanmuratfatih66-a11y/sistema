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
  String get actStepsTitle => 'Шаги';

  @override
  String actGoal(String goal) {
    return 'Цель: $goal';
  }

  @override
  String get actDistance => 'Дистанция';

  @override
  String actDistanceKm(String km) {
    return '$km км';
  }

  @override
  String get actFloors => 'Этажи';

  @override
  String get actNoValue => '—';

  @override
  String get actWeek => '7 дней';

  @override
  String get actAllow => 'Разрешить';

  @override
  String get actPermissionHint =>
      'Разрешите доступ к датчикам движения — шаги будут считаться сами.';

  @override
  String get actUnavailableHint =>
      'Счётчика шагов на устройстве нет — введите шаги вручную.';

  @override
  String get actManual => 'Ввести вручную';

  @override
  String get actManualLabel => 'Шаги за сегодня';

  @override
  String get actManualRange => 'От 0 до 100 000';

  @override
  String get actSave => 'Сохранить';

  @override
  String get actCancel => 'Отмена';

  @override
  String actStepsSemantic(String steps, String goal) {
    return 'Шаги за сегодня: $steps из $goal';
  }

  @override
  String get bdyEnergy => 'Энергия';

  @override
  String get bdyHistory => 'История';

  @override
  String get bdyCharts => 'Графики';

  @override
  String get bdySleepTitle => 'Сон';

  @override
  String get bdySleepLog => 'Записать сон';

  @override
  String get bdySleepNotLogged => 'Сон за прошлую ночь не записан.';

  @override
  String get bdySleepLastNight => 'Прошлая ночь';

  @override
  String get bdySleepDuration => 'Длительность';

  @override
  String get bdySleepTarget => 'Цель плана';

  @override
  String get bdySleepAverage => 'В среднем';

  @override
  String get bdySleepVsTarget => 'Против цели';

  @override
  String get bdySleepOnTarget => 'Ночей не меньше цели';

  @override
  String get bdySleepEmpty => 'Пока нет записей сна.';

  @override
  String get bdySleepChartLabel => 'График сна по дням, линия — цель плана';

  @override
  String bdySleepHistory(int days) {
    return 'Сон за $days дн.';
  }

  @override
  String get bdySleepWakeDay => 'Утро (день подъёма)';

  @override
  String get bdySleepBed => 'Лёг';

  @override
  String get bdySleepWake => 'Встал';

  @override
  String get bdySleepQuality => 'Качество сна';

  @override
  String get bdySleepQualityHint => '1 — плохо, 5 — отлично';

  @override
  String bdySleepQualityShort(int quality) {
    return 'кач. $quality/5';
  }

  @override
  String get bdyMeasureTitle => 'Замеры';

  @override
  String get bdyMeasureAdd => 'Добавить замер';

  @override
  String get bdyMeasureHint =>
      'Заполните то, что измерили. Обхваты — сантиметровой лентой, утром, до еды.';

  @override
  String get bdyMeasureEmpty => 'Замеров пока нет.';

  @override
  String get bdyMeasureNeedTwo => 'Для графика нужно хотя бы два замера.';

  @override
  String get bdyMeasureChangeNote => 'В скобках — изменение за 30 дней';

  @override
  String bdyMeasureChartLabel(String name) {
    return 'График: $name';
  }

  @override
  String get bdyMeasureWeight => 'Вес';

  @override
  String get bdyMeasureWaist => 'Талия';

  @override
  String get bdyMeasureHips => 'Бёдра';

  @override
  String get bdyMeasureChest => 'Грудь';

  @override
  String get bdyMeasureNeck => 'Шея';

  @override
  String get bdyMeasureArm => 'Рука';

  @override
  String get bdyMeasureBodyFat => '% жира';

  @override
  String get bdyUnitKg => 'кг';

  @override
  String get bdyUnitCm => 'см';

  @override
  String get bdyPeriodAll => 'Всё';

  @override
  String bdyPeriodDays(int days) {
    return '$days дн.';
  }

  @override
  String get bdyPhotoTitle => 'Фото-дневник';

  @override
  String get bdyPhotoKindBody => 'Тело';

  @override
  String get bdyPhotoKindSkin => 'Кожа';

  @override
  String get bdyPhotoLast => 'Последнее фото';

  @override
  String get bdyPhotoAdd => 'Новое фото';

  @override
  String get bdyPhotoPose => 'Ракурс';

  @override
  String get bdyPhotoCamera => 'Снять';

  @override
  String get bdyPhotoGallery => 'Из галереи';

  @override
  String get bdyPhotoEmpty => 'Фото пока нет.';

  @override
  String get bdyPhotoCompare => 'Сравнить';

  @override
  String get bdyPhotoCompareHint =>
      'Выберите два фото, чтобы сравнить «до» и «после».';

  @override
  String get bdyPhotoCompareNeedTwo => 'Для сравнения нужно хотя бы два фото.';

  @override
  String get bdyPoseOther => 'Другое';

  @override
  String get bdyCompareSlider => 'Шторка';

  @override
  String get bdyCompareSideBySide => 'Рядом';

  @override
  String get bdyCompareBefore => 'До';

  @override
  String get bdyCompareAfter => 'После';

  @override
  String get bdyCompareNote =>
      'Снимайте при одинаковом свете и с одного расстояния — так сравнение честнее.';

  @override
  String get bdyCareTitle => 'Уход за кожей';

  @override
  String get bdyCareOpen => 'Чек-лист';

  @override
  String get bdyCareMorning => 'Утро';

  @override
  String get bdyCareEvening => 'Вечер';

  @override
  String get bdyCareTemplateNote =>
      'Базовый шаблон по анкете. Подбор средств под вашу кожу появится позже.';

  @override
  String get bdyCareSensitiveNote =>
      'Были реакции на средства: новое средство сначала пробуйте на небольшом участке кожи.';

  @override
  String get bdyCareCompleteNote => 'Рутина выполнена.';

  @override
  String bdyCareRoutineDone(String routine) {
    return '$routine: уход выполнен';
  }

  @override
  String get bdyCareCleanse => 'Умыться мягким очищающим средством';

  @override
  String get bdyCareCleanseGentle => 'без пересушивания';

  @override
  String get bdyCareColdRinse => 'Умыться прохладной водой';

  @override
  String get bdyCareMoisturize => 'Увлажняющий крем';

  @override
  String get bdyCareMoisturizeLight => 'лёгкая текстура';

  @override
  String get bdyCareMoisturizeRich => 'плотнее, питательный';

  @override
  String get bdyCareSunscreen => 'Солнцезащитный крем';

  @override
  String get bdyCareRemoveSunscreen => 'Смыть SPF и загрязнения';

  @override
  String get bdyCareAcne => 'Средство против воспалений (если есть)';

  @override
  String get bdyCareExfoliate => 'Мягкое отшелушивание';

  @override
  String get bdyCareHandsOff => 'Не трогать и не выдавливать';

  @override
  String get bdySkinType => 'Тип кожи (по анкете)';

  @override
  String get bdySkinNormal => 'Нормальная';

  @override
  String get bdySkinOily => 'Жирная';

  @override
  String get bdySkinCombination => 'Комбинированная';

  @override
  String get bdySkinDry => 'Сухая';

  @override
  String get bdySkinUnknown => 'Не определён';

  @override
  String get bdySwellTitle => 'Отёки';

  @override
  String get bdySwellOpen => 'Подробнее';

  @override
  String get bdySwellMorningPhoto => 'Утреннее фото лица';

  @override
  String get bdySwellPhotoHint =>
      'Сделайте фото анфас сразу после подъёма — по ленте снимков виден тренд.';

  @override
  String get bdySwellTakenToday => 'Утреннее фото на сегодня есть.';

  @override
  String get bdySwellTipShort =>
      'Акценты: меньше соли вечером, вода днём, сон по плану.';

  @override
  String get bdySwellTipsTitle => 'Подсказки';

  @override
  String get bdySwellTipSalt =>
      'Солёное и фастфуд лучше не есть поздно вечером.';

  @override
  String get bdySwellTipWater =>
      'Пейте воду равномерно в течение дня, а не всё перед сном.';

  @override
  String get bdySwellTipSleep =>
      'Высыпайтесь и ложитесь в одно время — недосып заметен на лице утром.';

  @override
  String get bdySwellNote =>
      'Если отёки сильные, появились внезапно или не проходят — покажитесь врачу.';

  @override
  String get bdySwellTrend => 'Тренд по утрам';

  @override
  String get bdySwellEmpty => 'Утренних фото пока нет.';

  @override
  String get bdySwellCompareFirst => 'Сравнить первое и последнее';

  @override
  String get chrIntro =>
      'Выберите спутника. Он проведёт вас через фото-сессии своим голосом, а потом будет жить внизу экрана: напоминать, хвалить и ругать — в выбранном режиме.';

  @override
  String get chrArchetype => 'Персонаж';

  @override
  String get chrArchetypeRequired => 'Выберите персонажа, чтобы продолжить';

  @override
  String get chrNameAnimeGirl => 'Аниме-девушка';

  @override
  String get chrDescAnimeGirl =>
      'Жизнерадостная и упрямая. Радуется каждой победе и не даёт сдаться.';

  @override
  String get chrSpeechAnimeGirl => 'живая, с восклицаниями и подбадриваниями';

  @override
  String get chrSampleAnimeGirl1 => 'Привет! Сегодня мы точно всё успеем!';

  @override
  String get chrSampleAnimeGirl2 =>
      'Ещё один квест — и я буду тобой гордиться!';

  @override
  String get chrSampleAnimeGirl3 =>
      'Не сдавайся, у тебя получается лучше, чем вчера!';

  @override
  String get chrLineAnimeGirlSoft =>
      'Ничего страшного, отдохни немного — и попробуем ещё раз, ладно?';

  @override
  String get chrLineAnimeGirlNormal =>
      'Хорошая работа! Осталось совсем чуть-чуть, давай закончим!';

  @override
  String get chrLineAnimeGirlStrict =>
      'Эй! Квест сам себя не выполнит. Встаём и делаем!';

  @override
  String get chrLineAnimeGirlHarsh =>
      'Опять откладываешь?! Хватит оправданий — марш выполнять, сейчас же!';

  @override
  String get chrNameAnimeGuy => 'Аниме-парень';

  @override
  String get chrDescAnimeGuy =>
      'Соперник и напарник. Вызывает на спор и тянет вперёд.';

  @override
  String get chrSpeechAnimeGuy => 'дерзкая, с вызовом и азартом';

  @override
  String get chrSampleAnimeGuy1 => 'Спорим, сегодня ты меня не обгонишь?';

  @override
  String get chrSampleAnimeGuy2 =>
      'Ха, неплохо! Но я знаю, что ты можешь больше.';

  @override
  String get chrSampleAnimeGuy3 =>
      'Вперёд, напарник, уровень сам себя не поднимет!';

  @override
  String get chrLineAnimeGuySoft =>
      'Сегодня тяжело? Бывает. Сделаем хотя бы маленький шаг вместе.';

  @override
  String get chrLineAnimeGuyNormal =>
      'Неплохо идёшь! Ещё рывок — и этот день наш.';

  @override
  String get chrLineAnimeGuyStrict =>
      'Ты же не собираешься проиграть лени? Докажи, что сильнее.';

  @override
  String get chrLineAnimeGuyHarsh =>
      'Серьёзно? Это всё, на что ты способен? Встал и сделал, без нытья!';

  @override
  String get chrNameStoicStrongman => 'Невозмутимый силач';

  @override
  String get chrDescStoicStrongman =>
      'Спокоен как скала. Верит в дисциплину и повторения.';

  @override
  String get chrSpeechStoicStrongman => 'короткие фразы, без лишних слов';

  @override
  String get chrSampleStoicStrongman1 => 'Новый день. Делаем.';

  @override
  String get chrSampleStoicStrongman2 => 'Сила — это повторения.';

  @override
  String get chrSampleStoicStrongman3 => 'Медленно, но каждый день.';

  @override
  String get chrLineStoicStrongmanSoft => 'Отдохни. Потом продолжим.';

  @override
  String get chrLineStoicStrongmanNormal => 'Хорошо. Следующий подход.';

  @override
  String get chrLineStoicStrongmanStrict => 'Пропуск. Так не пойдёт. Делай.';

  @override
  String get chrLineStoicStrongmanHarsh =>
      'Хватит болтать. Встал. Сделал. Сейчас.';

  @override
  String get chrNameGrimSwordsman => 'Мрачный мечник';

  @override
  String get chrDescGrimSwordsman =>
      'Суровый наставник. Каждый день — тренировка воли.';

  @override
  String get chrSpeechGrimSwordsman => 'сдержанная, с мрачной иронией';

  @override
  String get chrSampleGrimSwordsman1 => 'Клинок тупится без дела. Как и воля.';

  @override
  String get chrSampleGrimSwordsman2 =>
      'Ты снова здесь. Значит, ещё не сдался.';

  @override
  String get chrSampleGrimSwordsman3 =>
      'Тьма не страшна тому, кто держит слово.';

  @override
  String get chrLineGrimSwordsmanSoft =>
      'Даже клинку нужен отдых. Переведи дух и возвращайся.';

  @override
  String get chrLineGrimSwordsmanNormal =>
      'Удар засчитан. Держи ритм до конца дня.';

  @override
  String get chrLineGrimSwordsmanStrict =>
      'Слабость ищет оправдания. Сила ищет путь. Выбирай.';

  @override
  String get chrLineGrimSwordsmanHarsh =>
      'Позорно. Воин, который бросает клятву, — уже не воин. Исправь это.';

  @override
  String chrSpeechLabel(String speech) {
    return 'Манера речи: $speech';
  }

  @override
  String get chrPreviewStates => 'Анимации';

  @override
  String get chrStateIdle => 'Покой';

  @override
  String get chrStateWalk => 'Идти';

  @override
  String get chrStateTalk => 'Говорить';

  @override
  String get chrStateHappy => 'Радость';

  @override
  String get chrStateAngry => 'Злость';

  @override
  String get chrStateSit => 'Сесть';

  @override
  String get chrStateSleep => 'Сон';

  @override
  String get chrStatePoint => 'Указать';

  @override
  String get chrVoice => 'Голос';

  @override
  String get chrVoiceNote =>
      'Пока звучит системный синтез речи телефона; позже появятся голоса персонажей.';

  @override
  String get chrVoiceBright => 'Звонкий';

  @override
  String get chrVoiceSoft => 'Мягкий';

  @override
  String get chrVoiceCalm => 'Спокойный';

  @override
  String get chrVoiceEnergetic => 'Энергичный';

  @override
  String get chrVoiceDeep => 'Глубокий';

  @override
  String get chrVoiceLow => 'Низкий';

  @override
  String get chrVoiceHoarse => 'Хриплый';

  @override
  String get chrListen => 'Прослушать';

  @override
  String get chrStop => 'Остановить';

  @override
  String get chrTtsUnavailable =>
      'Синтез речи недоступен на этом устройстве для языка интерфейса — голос можно будет прослушать позже.';

  @override
  String get chrMotivation => 'Режим мотивации';

  @override
  String get chrModeSoft => 'Мягкий';

  @override
  String get chrModeSoftDesc => 'Поддержка и мягкие напоминания, без давления.';

  @override
  String get chrModeNormal => 'Обычный';

  @override
  String get chrModeNormalDesc =>
      'Похвала за успехи, спокойные замечания за пропуски.';

  @override
  String get chrModeStrict => 'Строгий';

  @override
  String get chrModeStrictDesc =>
      'Чёткие требования и прямая критика за провалы.';

  @override
  String get chrModeHarsh => 'Жёсткий';

  @override
  String get chrModeHarshDesc =>
      'Ругает по всей строгости, но без унижений внешности и здоровья.';

  @override
  String get chrModeExample => 'Пример реплики';

  @override
  String get chrModeTry => 'Услышать в этом режиме';

  @override
  String get chrProfanity => 'Допускать мат';

  @override
  String get chrProfanityHint => 'Редко и только в жёстком режиме';

  @override
  String get chrTapSoft1 => 'Я рядом. Сделаем немного — уже хорошо.';

  @override
  String get chrTapSoft2 => 'Не торопись, всё получится.';

  @override
  String get chrTapSoft3 => 'Ты молодец, что заглянул.';

  @override
  String get chrTapNormal1 => 'Как продвигаются квесты?';

  @override
  String get chrTapNormal2 => 'Хороший темп. Продолжаем.';

  @override
  String get chrTapNormal3 => 'Не забудь про воду.';

  @override
  String get chrTapStrict1 => 'Квесты ждут. Не расслабляйся.';

  @override
  String get chrTapStrict2 => 'Сначала дело, потом отдых.';

  @override
  String get chrTapStrict3 => 'Проверь список. Что ещё не сделано?';

  @override
  String get chrTapHarsh1 => 'Хватит листать. Иди выполнять.';

  @override
  String get chrTapHarsh2 => 'Оправдания не засчитываются.';

  @override
  String get chrTapHarsh3 => 'День не резиновый. Действуй.';

  @override
  String get chrPocketTab => 'Вернуть персонажа';

  @override
  String chrSemantics(String name) {
    return '$name: нажмите, чтобы услышать реплику; смахните вниз, чтобы убрать';
  }

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
  String get hqStatStrengthShort => 'СИЛ';

  @override
  String get hqStatEnduranceShort => 'ВЫН';

  @override
  String get hqStatDisciplineShort => 'ДИС';

  @override
  String get hqStatIntellectShort => 'ИНТ';

  @override
  String get hqStatHealthShort => 'ЗДР';

  @override
  String get hqStatLooksShort => 'ВНШ';

  @override
  String get hqCaloriesTodayTitle => 'Калории за день';

  @override
  String get hqNutritionDiaryTitle => 'Дневник питания';

  @override
  String get hqNutritionDiarySoon =>
      'Дневник питания, фото еды и подсчёт БЖУ Система откроет на следующем этапе.';

  @override
  String get hqFinanceFoodTitle => 'Финансы на еду';

  @override
  String ntfQuestTitle(String title) {
    return '[ Квест ] $title';
  }

  @override
  String ntfPenaltyQuestTitle(String title) {
    return '[ Штрафной квест ] $title';
  }

  @override
  String ntfBossTitle(String title) {
    return '[ Босс недели ] $title';
  }

  @override
  String ntfQuestBody(String time, int diamonds) {
    return 'Срок — до $time. Награда: +$diamonds ◆';
  }

  @override
  String ntfQuestBodyNoReward(String time) {
    return 'Срок — до $time.';
  }

  @override
  String ntfPenaltyQuestBody(String time) {
    return 'Срок — до $time. Отказ невозможен.';
  }

  @override
  String get ntfReproachTitle => '[ Система ] Квест не выполнен';

  @override
  String ntfReproachBody(String title) {
    return '«$title» просрочен. Система фиксирует бездействие. Выполни сейчас.';
  }

  @override
  String get ntfActionDone => 'Выполнено';

  @override
  String get ntfActionSnooze => '+10 мин';

  @override
  String get ntfChannelQuests => 'Квесты';

  @override
  String get ntfChannelQuestsDesc =>
      'Напоминания о квестах, упрёки и сообщения Системы';

  @override
  String get ntfChannelNag => 'Надоедать';

  @override
  String get ntfChannelNagDesc =>
      'Повтор каждую минуту, пока квест не выполнен';

  @override
  String get ntfFailedTitle => '[ Система ] Квест провален';

  @override
  String ntfFailedBody(String title, int diamonds) {
    return '«$title»: −$diamonds ◆';
  }

  @override
  String ntfPenaltyTitle(int diamonds) {
    return '[ Штраф ] −$diamonds ◆';
  }

  @override
  String get ntfLevelUpTitle => '[ Система ] Уровень повышен';

  @override
  String ntfLevelUpBody(int level, int points) {
    return 'Уровень $level. Свободных очков: $points';
  }

  @override
  String get ntfTestTitle => '[ Система ] Проверка связи';

  @override
  String get ntfTestBody => 'Уведомления работают. Игрок, жди приказов.';

  @override
  String get ntfTestSent => 'Уведомление отправлено';

  @override
  String get ntfSectionGeneral => 'Основное';

  @override
  String get ntfEnabled => 'Напоминания';

  @override
  String get ntfEnabledHint => 'Локальные уведомления о квестах';

  @override
  String get ntfNag => 'Надоедать каждую минуту';

  @override
  String get ntfNagHint => 'Повтор, пока не нажмёте «Выполнено»';

  @override
  String get ntfReproach => 'Упрёки';

  @override
  String get ntfReproachHint =>
      'Через 15 мин после срока, если квест не выполнен';

  @override
  String get ntfVoice => 'Голос персонажа как звук';

  @override
  String get ntfVoiceHint => 'Будет на этапе 6 — пока стандартный звук';

  @override
  String get ntfSectionQuiet => 'Тихие часы';

  @override
  String get ntfQuietEnabled => 'Не беспокоить';

  @override
  String get ntfQuietHint =>
      'В это время ничего не звенит, упрёк придёт после окончания';

  @override
  String get ntfQuietFrom => 'С';

  @override
  String get ntfQuietTo => 'До';

  @override
  String get ntfSectionPermission => 'Разрешение';

  @override
  String get ntfPermGranted => 'Уведомления разрешены';

  @override
  String get ntfPermDenied =>
      'Уведомления запрещены — квесты не смогут напомнить о себе';

  @override
  String get ntfPermUnknown => 'Статус разрешения неизвестен';

  @override
  String get ntfPermExactOff =>
      'Точные будильники выключены — напоминания могут опаздывать';

  @override
  String get ntfPermRequest => 'Запросить разрешение';

  @override
  String get ntfTest => 'Проверить уведомление';

  @override
  String get ntfUnavailable => 'Уведомления недоступны на этой платформе';

  @override
  String get nutYesterday => 'Вчера';

  @override
  String get nutToday => 'Сегодня';

  @override
  String get nutNoticeLabel => 'Уведомление';

  @override
  String get nutProtein => 'Белки';

  @override
  String get nutFat => 'Жиры';

  @override
  String get nutCarbs => 'Углеводы';

  @override
  String get nutBalance => 'Баланс';

  @override
  String get nutNoNorm =>
      'Нормы нет: примите план, чтобы видеть цель по калориям и БЖУ.';

  @override
  String get nutNoWaterNorm => 'Норма воды появится после принятия плана.';

  @override
  String nutGrams(String value) {
    return '$value г';
  }

  @override
  String nutGramsProgress(String current, String total) {
    return '$current / $total г';
  }

  @override
  String nutLiters(String value) {
    return '$value л';
  }

  @override
  String nutMacrosLine(String protein, String fat, String carbs) {
    return 'Б $protein · Ж $fat · У $carbs';
  }

  @override
  String nutTotalLine(String kcal, String macros) {
    return 'Итого: $kcal ккал · $macros';
  }

  @override
  String nutPerServing(String kcal, String macros) {
    return 'Порция: $kcal · $macros';
  }

  @override
  String nutWaterAdd(int ml) {
    return '+$ml мл';
  }

  @override
  String get nutWaterUndo => 'Отменить последнюю запись воды';

  @override
  String get nutTrainingDay => 'День тренировки';

  @override
  String get nutAddTitle => 'Добавить еду';

  @override
  String get nutAddBarcode => 'Штрихкод';

  @override
  String get nutAddManual => 'Вручную';

  @override
  String get nutAddPhoto => 'Фото';

  @override
  String get nutRecipes => 'Мои рецепты';

  @override
  String get nutSearching => 'Поиск…';

  @override
  String get nutDiaryEmpty =>
      'Записей за день нет. Добавьте еду — штрихкодом, вручную, фото или рецептом.';

  @override
  String get nutWithPhoto => 'с фото';

  @override
  String get nutMealBreakfast => 'Завтрак';

  @override
  String get nutMealLunch => 'Обед';

  @override
  String get nutMealDinner => 'Ужин';

  @override
  String get nutMealSnack => 'Перекус';

  @override
  String get nutNewEntry => 'Новая запись';

  @override
  String get nutEditEntry => 'Запись дневника';

  @override
  String get nutRecipeLineTitle => 'Строка рецепта';

  @override
  String get nutPhotoSaved => 'Фото сохранено';

  @override
  String get nutPhotoAiLater =>
      'Распознавание блюда по фото Система откроет позже. Пока введите название и КБЖУ сами.';

  @override
  String get nutFieldTitle => 'Название';

  @override
  String get nutFieldTitleHint => 'Например: овсянка с бананом';

  @override
  String get nutFieldMeal => 'Приём пищи';

  @override
  String get nutFieldMode => 'Как считать';

  @override
  String get nutModePortion => 'На порцию';

  @override
  String get nutModePer100 => 'На 100 г';

  @override
  String get nutFieldGrams => 'Вес порции';

  @override
  String get nutErrorGrams => 'Укажите вес в граммах';

  @override
  String get nutValuesPer100 => 'Значения на 100 г';

  @override
  String get nutValuesPortion => 'Значения на всю порцию';

  @override
  String get nutFieldKcal => 'Калории';

  @override
  String get nutFieldProtein => 'Белки';

  @override
  String get nutFieldFat => 'Жиры';

  @override
  String get nutFieldCarbs => 'Углеводы';

  @override
  String get nutUnitKcal => 'ккал';

  @override
  String get nutUnitG => 'г';

  @override
  String get nutUnitKg => 'кг';

  @override
  String get nutUnitPcs => 'шт.';

  @override
  String get nutUnitL => 'л';

  @override
  String get nutUnitMl => 'мл';

  @override
  String get nutSaveToProducts => 'Сохранить в мои продукты';

  @override
  String get nutSaveToProductsHint =>
      'Потом найдётся поиском — без повторного ввода';

  @override
  String get nutMyProducts => 'Мои продукты';

  @override
  String get nutSearchHint => 'Поиск по названию или штрихкоду';

  @override
  String get nutWithoutProduct => 'Без продукта';

  @override
  String get nutNewProduct => 'Новый продукт';

  @override
  String get nutNoProducts =>
      'Продуктов пока нет. Отсканируйте штрихкод или добавьте продукт вручную.';

  @override
  String get nutPer100Short => '100 г';

  @override
  String get nutProductNameHint => 'Например: йогурт натуральный';

  @override
  String get nutFieldBrand => 'Бренд';

  @override
  String get nutFieldBarcode => 'Штрихкод';

  @override
  String get nutFieldServing => 'Обычная порция';

  @override
  String get nutBarcodeNotFound =>
      'Продукта нет в Open Food Facts. Введите данные с упаковки — Система запомнит его по штрихкоду.';

  @override
  String get nutBarcodeOffline =>
      'Нет связи с базой продуктов. Введите данные с упаковки — Система запомнит продукт по штрихкоду.';

  @override
  String get nutScanTitle => 'Штрихкод';

  @override
  String get nutScanHint => 'Наведите камеру на штрихкод упаковки';

  @override
  String get nutScanNoCamera =>
      'Камера недоступна. Разрешите доступ к камере в настройках или введите продукт вручную.';

  @override
  String get nutPhotoTitle => 'Фото еды';

  @override
  String get nutPhotoMessage =>
      'Снимите блюдо или выберите фото из галереи. Фото сохранится в записи дневника.';

  @override
  String get nutPhotoCamera => 'Камера';

  @override
  String get nutPhotoGallery => 'Галерея';

  @override
  String get nutPortions => 'Порций';

  @override
  String get nutAddToDiary => 'Добавить в дневник';

  @override
  String get nutRecipesEmpty =>
      'Рецептов пока нет. Соберите блюдо из продуктов один раз — потом добавляйте его в один тап.';

  @override
  String get nutNewRecipe => 'Новый рецепт';

  @override
  String get nutEditRecipe => 'Рецепт';

  @override
  String get nutRecipeTitleHint => 'Например: омлет с овощами';

  @override
  String get nutServings => 'Порций в блюде';

  @override
  String get nutIngredients => 'Состав';

  @override
  String get nutIngredientsEmpty => 'Добавьте хотя бы один продукт или строку.';

  @override
  String get nutFromProducts => 'Из продуктов';

  @override
  String get nutManualLine => 'Вручную';

  @override
  String get nutShopping => 'Список покупок';

  @override
  String get nutShopNothing =>
      'Список пуст — откройте, чтобы добавить покупки.';

  @override
  String nutShopRemainingCount(int count, String sum) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Осталось купить: $count позиции · $sum',
      many: 'Осталось купить: $count позиций · $sum',
      few: 'Осталось купить: $count позиции · $sum',
      one: 'Осталось купить: $count позиция · $sum',
    );
    return '$_temp0';
  }

  @override
  String get nutShopAdd => 'Добавить покупку';

  @override
  String get nutShopEdit => 'Покупка';

  @override
  String get nutShopTotal => 'Всего (примерно)';

  @override
  String get nutShopRemaining => 'Ещё не куплено';

  @override
  String get nutShopPriceNote => 'Суммы — по ценам, которые вы указали.';

  @override
  String get nutShopFromPlan => 'От плана питания';

  @override
  String get nutShopFromPlanHint =>
      'Базовый список на неделю по нормам плана: белок, крупы, овощи, фрукты, вода. Цены укажите сами.';

  @override
  String get nutShopNoPlan =>
      'Примите план — тогда Система составит базовый список на неделю.';

  @override
  String get nutShopGenerate => 'Составить на неделю';

  @override
  String get nutShopEmpty => 'Покупок пока нет.';

  @override
  String get nutShopClearDone => 'Убрать купленное';

  @override
  String get nutShopTitleHint => 'Например: гречка';

  @override
  String get nutShopQuantity => 'Количество';

  @override
  String get nutShopPrice => 'Примерная цена';

  @override
  String get nutGroceryChicken => 'Куриная грудка / индейка';

  @override
  String get nutGroceryEggs => 'Яйца';

  @override
  String get nutGroceryCottageCheese => 'Творог';

  @override
  String get nutGroceryGrains => 'Крупы (гречка, рис)';

  @override
  String get nutGroceryOats => 'Овсяные хлопья';

  @override
  String get nutGroceryVegetables => 'Овощи';

  @override
  String get nutGroceryFruits => 'Фрукты';

  @override
  String get nutGroceryOil => 'Растительное масло';

  @override
  String get nutGroceryWater => 'Питьевая вода';

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
      'Камера на уровне пояса, примерно в 2 метрах. Удобнее со штативом или с помощником.';

  @override
  String get qaPoseBodyFront => 'Спереди';

  @override
  String get qaPoseBodyFrontHint =>
      'Встаньте лицом к камере, руки немного в стороны, ноги на ширине плеч.';

  @override
  String get qaPoseBodySide => 'Сбоку';

  @override
  String get qaPoseBodySideHint =>
      'Повернитесь к камере правым боком, руки вдоль тела, смотрите прямо.';

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
      'Повернитесь так, чтобы к камере была ЛЕВАЯ щека.';

  @override
  String get qaPoseFaceRight => 'Профиль справа';

  @override
  String get qaPoseFaceRightHint =>
      'Повернитесь так, чтобы к камере была ПРАВАЯ щека.';

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
  String get qaShootTitleBody => 'Фото-сессия: тело';

  @override
  String get qaShootTitleFace => 'Фото-сессия: лицо';

  @override
  String get qaShootCardBody => 'Фото-сессия: тело (3 ракурса)';

  @override
  String get qaShootCardFace => 'Фото-сессия: лицо (3 ракурса)';

  @override
  String get qaShootCardHint =>
      'Поставьте телефон и нажмите «Начать» — дальше Система всё скажет голосом и сама сделает снимки.';

  @override
  String get qaShootStartSession => 'Начать сессию';

  @override
  String get qaShootRestartSession => 'Пройти сессию заново';

  @override
  String get qaShootCloseupButton => 'Крупный план проблемной зоны';

  @override
  String get qaShootAiNoteBody =>
      'После съёмки ИИ оценит габариты и состав тела с учётом роста и напишет вам.';

  @override
  String get qaShootAiNoteSkin =>
      'После съёмки ИИ оценит тип кожи и выраженность высыпаний и напишет вам.';

  @override
  String get qaShootPrepTitle => 'Подготовка';

  @override
  String get qaShootPrepPhoneBody =>
      'Поставьте телефон вертикально на уровне пояса: обоприте о стену, стопку книг или поставьте на штатив. Экран — к себе.';

  @override
  String get qaShootPrepDistanceBody =>
      'Вы встанете примерно в 2 метрах. Подойдите или отойдите, чтобы тело совпало с контуром.';

  @override
  String get qaShootPrepPhoneFace =>
      'Поставьте телефон вертикально на уровне глаз, примерно в 50 см от лица.';

  @override
  String get qaShootPrepLight =>
      'Свет: встаньте лицом к окну или лампе. Яркого окна за спиной быть не должно.';

  @override
  String get qaShootPrepSound =>
      'Включите звук: Система скажет, куда встать, и сосчитает до снимка. Нажимать ничего не нужно.';

  @override
  String get qaShootDelay => 'Задержка отсчёта';

  @override
  String qaShootDelaySec(int n) {
    return '$n с';
  }

  @override
  String get qaShootDelayManual => 'Кнопкой';

  @override
  String get qaShootOperator => 'Снимает другой человек';

  @override
  String get qaShootOperatorHint =>
      'Основная камера. Отсчёт можно выключить и снимать кнопкой.';

  @override
  String get qaShootStart => 'Начать';

  @override
  String get qaShootPause => 'Пауза';

  @override
  String get qaShootResume => 'Продолжить';

  @override
  String get qaShootPausedTitle => 'Сессия на паузе';

  @override
  String get qaShootPausedHint => 'Текущий ракурс начнётся заново.';

  @override
  String get qaShootStop => 'Прервать';

  @override
  String qaShootShotOf(int n, int total) {
    return 'Ракурс $n из $total';
  }

  @override
  String get qaShootWaitShutter =>
      'Нажмите кнопку, когда человек встанет в контур.';

  @override
  String get qaShootRetry => 'Повторить';

  @override
  String get qaShootReviewTitle => 'Проверьте снимки';

  @override
  String get qaShootReviewHint =>
      'Если ракурс не получился — переснимите только его.';

  @override
  String get qaShootSaveFailed =>
      'Не удалось сохранить снимки. Попробуйте ещё раз.';

  @override
  String get qaShootSayBodyFront =>
      'Отойди примерно на 2 метра, лицом к камере. Подойди или отступи, чтобы совпасть с контуром. Руки немного в стороны.';

  @override
  String get qaShootSayBodySide =>
      'Повернись к камере правым боком. Руки вдоль тела, смотри прямо.';

  @override
  String get qaShootSayBodyBack =>
      'Повернись к камере спиной. Руки немного в стороны.';

  @override
  String get qaShootSayFaceFront =>
      'Сядь примерно в 50 сантиметрах от телефона. Смотри прямо в камеру, лицо — в овале.';

  @override
  String get qaShootSayFaceLeft =>
      'Повернись так, чтобы к камере была левая щека. Голова — в овале, держи её ровно.';

  @override
  String get qaShootSayFaceRight =>
      'Теперь повернись так, чтобы к камере была правая щека. Голова — в овале.';

  @override
  String qaShootTaken(String next) {
    return 'Снимок сделан. Следующий: $next.';
  }

  @override
  String get qaShootTakenLast => 'Снимок сделан. Съёмка завершена.';

  @override
  String get qaShootFailed => 'Не удалось сделать снимок. Попробуй ещё раз.';

  @override
  String get qaBodyGirthsOptionalTitle => 'Обхваты — если знаете';

  @override
  String get qaBodyGirthsOptionalHint =>
      'Необязательно. Если не знаете — Система примерно оценит их по фото с учётом роста и сообщит вам.';

  @override
  String get qaBodyGirthsHowTitle => 'Как мерить';

  @override
  String get qaBodyGirthsHowGeneral =>
      'Сантиметровая лента горизонтально, прилегает, но не сдавливает. Утром, на спокойном выдохе.';

  @override
  String get qaBodyWaistHow =>
      'Талия — по самому узкому месту, обычно чуть выше пупка.';

  @override
  String get qaBodyHipsHow =>
      'Бёдра — по самым выступающим точкам ягодиц, ноги вместе.';

  @override
  String get qaBodyChestHow =>
      'Грудь — по самым выступающим точкам, лента проходит под мышками.';

  @override
  String get qaBodyNeckHow => 'Шея — сразу под кадыком.';

  @override
  String get qaBodyArmHow =>
      'Рука — по самому широкому месту плеча, рука расслаблена.';

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
  String get qaTzCityHint => 'Часовой пояс подставится по городу';

  @override
  String qaTzFromCity(String city) {
    return 'Определён по городу: $city';
  }

  @override
  String get qaTzFromDevice => 'Текущий пояс телефона';

  @override
  String get qaTzDeviceBadge => 'сейчас на телефоне';

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
  String qeQuestPenaltyCleaning(String minutes) {
    return 'Штраф: уборка $minutes мин';
  }

  @override
  String qeQuestPenaltyReading(String minutes) {
    return 'Штраф: чтение $minutes мин';
  }

  @override
  String qeQuestPenaltyPlank(String seconds) {
    return 'Штраф: планка $seconds с';
  }

  @override
  String qeQuestPenaltyWalk(String minutes) {
    return 'Штраф: прогулка $minutes мин';
  }

  @override
  String get qeQuestPenaltyNoGames => 'Штраф: вечер без игр и соцсетей';

  @override
  String qeQuestBoostWalk(String minutes) {
    return 'Усиление: прогулка $minutes мин';
  }

  @override
  String qeQuestBoostWater(String ml) {
    return 'Усиление: ещё $ml мл воды';
  }

  @override
  String qeQuestBoostBedOnTime(String time) {
    return 'Усиление: отбой не позже $time';
  }

  @override
  String get qeQuestBoostPlanTomorrow => 'Усиление: распиши завтрашний день';

  @override
  String qeQuestBossAll(String count) {
    return 'Закрой $count квестов за неделю';
  }

  @override
  String qeQuestBossStrength(String count) {
    return 'Закрой $count квестов силы';
  }

  @override
  String qeQuestBossEndurance(String count) {
    return 'Закрой $count квестов выносливости';
  }

  @override
  String qeQuestBossDiscipline(String count) {
    return 'Закрой $count квестов дисциплины';
  }

  @override
  String qeQuestBossIntellect(String count) {
    return 'Закрой $count квестов интеллекта';
  }

  @override
  String qeQuestBossHealth(String count) {
    return 'Закрой $count квестов здоровья';
  }

  @override
  String qeQuestBossLooks(String count) {
    return 'Закрой $count квестов внешности';
  }

  @override
  String qeEffectVigor(String pct) {
    return 'Бодрость +$pct% опыта';
  }

  @override
  String qeEffectDehydration(String pct) {
    return 'Обезвоживание −$pct% выносливости';
  }

  @override
  String qeEffectBossAura(String pct) {
    return 'Аура победителя +$pct% ◆';
  }

  @override
  String get qeTitleStreak7 => 'Несгибаемый';

  @override
  String get qeTitleStreak30 => 'Железная воля';

  @override
  String get qeTitleBossSlayer => 'Победитель босса';

  @override
  String get qeTitleBossHunter => 'Охотник на боссов';

  @override
  String get qeTitleLevel10 => 'Пробуждённый';

  @override
  String get qeTitleLevel25 => 'Закалённый';

  @override
  String get qeTitleLevel50 => 'Легенда Системы';

  @override
  String get qeReasonFailedQuests => 'Провалы за день. Назначен штрафной квест';

  @override
  String get qeReasonMarkWalked =>
      'Отметка: гулял с друзьями. За честность штраф мягче';

  @override
  String get qeReasonMarkAlcohol =>
      'Отметка: алкоголь. Завтра — усиленный план';

  @override
  String get qeReasonMarkRelapse => 'Отметка: срыв. Завтра — усиленный план';

  @override
  String get qeReasonBossFailed => 'Босс недели не побеждён';

  @override
  String get qeReasonReproach => 'Квест не выполнен. Система недовольна';

  @override
  String get qeReasonOther => 'Штраф Системы';

  @override
  String get qstViewToday => 'Сегодня';

  @override
  String get qstViewWeek => 'Неделя';

  @override
  String get qstViewHistory => 'История';

  @override
  String get qstFilterTitle => 'Фильтр';

  @override
  String qstFilterActive(int count) {
    return 'Фильтр: $count';
  }

  @override
  String get qstFilterReset => 'Сбросить';

  @override
  String get qstFilterKind => 'Вид';

  @override
  String get qstFilterStat => 'Характеристика';

  @override
  String get qstKindDaily => 'Ежедневные';

  @override
  String get qstKindSchedule => 'Из расписания';

  @override
  String get qstKindGoal => 'По цели';

  @override
  String get qstKindPenalty => 'Штрафные';

  @override
  String get qstKindBoss => 'Босс';

  @override
  String get qstStatusPending => 'Активен';

  @override
  String get qstStatusDone => 'Выполнен';

  @override
  String get qstStatusFailed => 'Провален';

  @override
  String get qstStatusRefused => 'Отказ';

  @override
  String get qstStatusExcused => 'Пауза: без штрафа';

  @override
  String get qstEmptyDay => 'На сегодня квестов нет';

  @override
  String get qstEmptyWeek => 'На эту неделю квестов нет';

  @override
  String get qstEmptyFiltered => 'Нет квестов под фильтр';

  @override
  String get qstEmptyHistory => 'Журнал пуст';

  @override
  String get qstLoadError => 'Система не отвечает. Повторите позже.';

  @override
  String get qstActionRejected => 'Система отклонила действие.';

  @override
  String get qstNoValue => '—';

  @override
  String get qstAllDay => 'В течение дня';

  @override
  String get qstOpenQuest => 'Открыть квест';

  @override
  String get qstSubtasks => 'Подзадачи';

  @override
  String get qstProgress => 'Прогресс';

  @override
  String qstProgressAddLabel(String step) {
    return 'Добавить прогресс: $step';
  }

  @override
  String qstRefusePenalty(String points) {
    return 'Отказ: −$points ◆';
  }

  @override
  String get qstNoRefuse => 'Штрафной квест: отказ невозможен';

  @override
  String get qstArchive => 'В архив';

  @override
  String get qstArchiveConfirm =>
      'Квест уйдёт в архив и больше не будет появляться.';

  @override
  String get qstNewQuest => 'Новый квест';

  @override
  String get qstEditQuest => 'Изменить квест';

  @override
  String qstBossReward(String points, String xp) {
    return 'Награда: +$points ◆, +$xp XP';
  }

  @override
  String qstDiamondsDelta(String value) {
    return '$value ◆';
  }

  @override
  String qstXpDelta(String value) {
    return '$value XP';
  }

  @override
  String get qstHistCompleted => 'Выполнено';

  @override
  String get qstHistFailed => 'Провал';

  @override
  String get qstHistRefused => 'Отказ';

  @override
  String get qstHistPenalty => 'Штраф';

  @override
  String get qstHistBonus => 'Бонус';

  @override
  String get qstHistPurchase => 'Покупка';

  @override
  String get qstHistMark => 'Отметка дня';

  @override
  String get qstHistPauseStarted => 'Пауза';

  @override
  String get qstHistPauseEnded => 'Пауза снята';

  @override
  String get qstHistStatPoint => 'Очко характеристики';

  @override
  String get qstHistBossCompleted => 'Босс повержен';

  @override
  String get qstHistBossFailed => 'Босс не повержен';

  @override
  String get qstHistDisciplineOn => 'Дисциплина включена';

  @override
  String get qstHistDisciplineOff => 'Дисциплина снята';

  @override
  String get qstHistAdjustment => 'Корректировка';

  @override
  String get qstMarksTitle => 'Честные отметки';

  @override
  String get qstMarksHint =>
      'Честная отметка мягче скрытого срыва. Завтра — усиленный план.';

  @override
  String get qstMarkWalked => 'Гулял с друзьями';

  @override
  String get qstMarkAlcohol => 'Алкоголь';

  @override
  String get qstMarkRelapse => 'Сорвался';

  @override
  String qstMarkConfirmTitle(String mark) {
    return 'Отметить: $mark?';
  }

  @override
  String get qstMarkConfirmMessage =>
      'Честная отметка мягче скрытого срыва: небольшой штраф сейчас, завтра — усиленный план.';

  @override
  String get qstMarkConfirm => 'Отметить';

  @override
  String get qstPauseTitle => 'Пауза';

  @override
  String get qstPauseHint =>
      'Болезнь, каникулы, отпуск: штрафы не начисляются, серия не сгорает.';

  @override
  String get qstPauseStart => 'Поставить паузу';

  @override
  String get qstPauseEnd => 'Снять паузу';

  @override
  String get qstPauseConfirm => 'Начать паузу';

  @override
  String get qstPauseReason => 'Причина';

  @override
  String get qstPauseReasonIllness => 'Болезнь';

  @override
  String get qstPauseReasonVacation => 'Отпуск';

  @override
  String get qstPauseReasonHolidays => 'Каникулы';

  @override
  String get qstPauseReasonOther => 'Другое';

  @override
  String qstPauseActive(String reason) {
    return 'Пауза: $reason';
  }

  @override
  String qstPauseUntil(String date) {
    return 'до $date';
  }

  @override
  String get qstPauseUntilRemoved => 'До снятия';

  @override
  String get qstPauseUntilDate => 'До даты';

  @override
  String get qstPauseEndDate => 'Последний день паузы';

  @override
  String get qstPausedPill => 'Пауза';

  @override
  String get qstDisciplinePill => 'Дисциплина';

  @override
  String get qstPlayerNoName => 'Игрок';

  @override
  String get qstStatPointsTitle => 'Очки характеристик';

  @override
  String qstStatPointsLeft(int count) {
    return 'Свободно: $count';
  }

  @override
  String qstStatPointAdd(String stat) {
    return 'Добавить очко: $stat';
  }

  @override
  String qstWindowFailedMessage(String quest, String points) {
    return '«$quest». Штраф: −$points ◆.';
  }

  @override
  String qstWindowFailedMany(int count, String points) {
    return 'Провалено квестов: $count. Штраф: −$points ◆.';
  }

  @override
  String get qstWindowRefusedTitle => 'Отказ от квеста';

  @override
  String get qstWindowPenaltyTitle => 'Штраф';

  @override
  String qstWindowPenaltyMessage(String reason, String points) {
    return '$reason. Штраф: −$points ◆.';
  }

  @override
  String qstWindowPenaltyQuest(String quest) {
    return 'Назначен штрафной квест: «$quest».';
  }

  @override
  String get qstLevelUpTitle => 'Уровень повышен';

  @override
  String qstLevelUpLevel(int level) {
    return 'LV $level';
  }

  @override
  String qstLevelUpRank(String rank) {
    return 'Новый ранг: $rank';
  }

  @override
  String qstLevelUpPoints(int count) {
    return 'Свободные очки характеристик: $count';
  }

  @override
  String qstTitleGot(String title) {
    return 'Титул: «$title»';
  }

  @override
  String get qstBossWonTitle => 'Босс повержен';

  @override
  String get qstBossLostTitle => 'Босс не повержен';

  @override
  String get qstBossLostMessage =>
      'Неделя закрыта без победы. Новый босс — с понедельника.';

  @override
  String get qstDisciplineOnTitle => 'Режим дисциплины включён';

  @override
  String get qstDisciplineOnMessage =>
      'Подъём 6:00, отбой 22:00, дополнительная нагрузка в пределах плана. Режим снимется, когда баланс ◆ станет положительным.';

  @override
  String get qstDisciplineOffTitle => 'Режим дисциплины снят';

  @override
  String get qstDisciplineOffMessage => 'Баланс восстановлен. Обычный режим.';

  @override
  String get qstDisciplineMore => 'Подробнее';

  @override
  String get qstFormTitle => 'Название';

  @override
  String get qstFormTitleHint => 'Например: растяжка 10 минут';

  @override
  String get qstFormStat => 'Характеристика';

  @override
  String get qstFormTimed => 'Ко времени';

  @override
  String get qstFormTimedHint => 'Иначе — в течение дня';

  @override
  String get qstFormTime => 'Время';

  @override
  String get qstFormWindow => 'Окно выполнения';

  @override
  String get qstMinutesUnit => 'мин';

  @override
  String get qstFormWeekdays => 'Дни недели';

  @override
  String get qstFormWeekdaysHint => 'Не выбраны — каждый день';

  @override
  String get qstFormWeekParity => 'Чередование недель';

  @override
  String get qstWeekEvery => 'Каждую';

  @override
  String get qstWeek1 => 'Неделя 1';

  @override
  String get qstWeek2 => 'Неделя 2';

  @override
  String get qstFormSubtasks => 'Подзадачи';

  @override
  String qstFormSubtaskHint(int n) {
    return 'Подзадача $n';
  }

  @override
  String get qstFormAddSubtask => 'Добавить подзадачу';

  @override
  String get qstFormRemoveSubtask => 'Убрать подзадачу';

  @override
  String get qstFormDefaultReward => 'Награда и штраф — по правилам Системы';

  @override
  String get qstFormDefaultRewardHint =>
      'Система рассчитает ◆ и опыт по виду квеста';

  @override
  String get qstFormRewardDiamonds => 'Награда, ◆';

  @override
  String get qstFormRewardXp => 'Опыт, XP';

  @override
  String get qstFormPenalty => 'Штраф за провал, ◆';

  @override
  String get qstFormNag => 'Надоедать';

  @override
  String get qstFormNagHint => 'Напоминать каждую минуту до выполнения';

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

  @override
  String get setSectionQuests => 'Квесты';

  @override
  String get setReminders => 'Напоминания';

  @override
  String get setRemindersHint => 'Тихие часы, повтор, упрёки';

  @override
  String get setDiscipline => 'Режим дисциплины';

  @override
  String get setDisciplineHint => 'Подъём 6:00, отбой 22:00, доп. нагрузка';

  @override
  String get setBody => 'Тело и здоровье';

  @override
  String get setBodyHint => 'Шаги, сон, замеры, фото, уход за кожей';

  @override
  String get setWorkouts => 'Тренировки';

  @override
  String get setWorkoutsHint => 'Программа под уровень, таймеры, голос';

  @override
  String get setWalks => 'Прогулки';

  @override
  String get setWalksHint => 'Круговой маршрут, отрезки, голос поверх музыки';

  @override
  String get shpNoticeLabel => 'Уведомление';

  @override
  String get shpWarningLabel => 'Предупреждение';

  @override
  String get shpTitle => 'Магазин наград';

  @override
  String get shpBalance => 'Баланс';

  @override
  String get shpClosedMessage => 'Магазин закрыт: баланс отрицательный';

  @override
  String get shpClosedHint =>
      'Выполняйте квесты, чтобы вернуть баланс в плюс. Режим дисциплины уже назначен.';

  @override
  String get shpRewards => 'Награды';

  @override
  String get shpAdd => 'Новая награда';

  @override
  String get shpEmptyTitle => 'Наград пока нет';

  @override
  String get shpEmptyText =>
      'Награды придумываете вы и покупаете их за ◆. Нажмите на пример, чтобы заполнить форму:';

  @override
  String get shpExampleChocolate => 'Шоколадка';

  @override
  String get shpExampleFastFood => 'Фастфуд';

  @override
  String get shpExampleGames => 'Час игр';

  @override
  String get shpExampleFreeEvening => 'Вечер без квестов';

  @override
  String get shpBuy => 'Купить';

  @override
  String get shpLimitNone => 'Без лимита';

  @override
  String shpLimitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза в день',
      many: '$count раз в день',
      few: '$count раза в день',
      one: '$count раз в день',
    );
    return '$_temp0';
  }

  @override
  String shpLimitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза в неделю',
      many: '$count раз в неделю',
      few: '$count раза в неделю',
      one: '$count раз в неделю',
    );
    return '$_temp0';
  }

  @override
  String shpLimitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count раза в месяц',
      many: '$count раз в месяц',
      few: '$count раза в месяц',
      one: '$count раз в месяц',
    );
    return '$_temp0';
  }

  @override
  String shpLimitLeft(int count) {
    return 'осталось $count';
  }

  @override
  String shpLimitReachedUntil(String date) {
    return 'лимит исчерпан до $date';
  }

  @override
  String shpNotEnough(int count) {
    return 'не хватает $count ◆';
  }

  @override
  String get shpConfirmTitle => 'Подтвердите покупку';

  @override
  String shpConfirmMessage(String title, int price, int after) {
    return '«$title» за $price ◆. Баланс после покупки: $after ◆.';
  }

  @override
  String shpBoughtMessage(String title) {
    return 'Награда «$title» получена. Система зафиксировала покупку.';
  }

  @override
  String get shpFailedMessage =>
      'Покупка отклонена: недостаточно ◆ или магазин закрыт.';

  @override
  String get shpLimitReachedMessage => 'Лимит этой награды на период исчерпан.';

  @override
  String get shpHistory => 'История покупок';

  @override
  String get shpHistoryEmpty => 'Покупок пока нет';

  @override
  String get shpArchive => 'Архив';

  @override
  String get shpRestore => 'Вернуть';

  @override
  String get shpReorder => 'Порядок';

  @override
  String get shpMoveUp => 'Выше';

  @override
  String get shpMoveDown => 'Ниже';

  @override
  String get shpEditorNew => 'Новая награда';

  @override
  String get shpEditorEdit => 'Награда';

  @override
  String get shpFieldTitle => 'Название';

  @override
  String get shpFieldTitleHint => 'Например: час игр';

  @override
  String get shpFieldPrice => 'Цена';

  @override
  String get shpFieldPriceHint => 'Сколько ◆ стоит награда';

  @override
  String get shpFieldLimit => 'Лимит частоты';

  @override
  String get shpPeriodNone => 'Нет';

  @override
  String get shpPeriodDay => 'День';

  @override
  String get shpPeriodWeek => 'Неделя';

  @override
  String get shpPeriodMonth => 'Месяц';

  @override
  String get shpFieldLimitCount => 'Сколько раз за период';

  @override
  String get shpToArchive => 'В архив';

  @override
  String get shpErrorPrice => 'От 1 до 100000';

  @override
  String get shpErrorCount => 'От 1 до 99';

  @override
  String get dscTitle => 'Режим дисциплины';

  @override
  String get dscStatus => 'Статус';

  @override
  String get dscOn => 'Включён';

  @override
  String get dscOff => 'Выключен';

  @override
  String get dscReasonLabel => 'Причина';

  @override
  String get dscReasonDebt => 'отрицательный баланс';

  @override
  String get dscReasonManual => 'включён вручную';

  @override
  String get dscReasonAi => 'решение Системы после срыва';

  @override
  String get dscExitLabel => 'Выключится';

  @override
  String get dscExitBalancePositive => 'когда баланс станет положительным';

  @override
  String get dscExitManual => 'вручную, когда баланс не отрицательный';

  @override
  String get dscSinceLabel => 'С';

  @override
  String get dscOffText =>
      'Режим включается сам, если баланс ◆ уходит в минус. Можно включить и вручную.';

  @override
  String get dscBalance => 'Баланс';

  @override
  String get dscToday => 'Правила на сегодня';

  @override
  String get dscRulesNote =>
      'Нагрузка — в пределах вашего уровня. Еда и сон не урезаются: отбой и подъём не сдвигаются позже обычных.';

  @override
  String get dscCannotRefuse => 'Квесты режима нельзя отменить.';

  @override
  String get dscPreviewNote => 'Так будет выглядеть день в режиме дисциплины.';

  @override
  String get dscBlockerTitle => 'Блокировка приложений';

  @override
  String get dscBlockerText =>
      'Блокировка развлекательных приложений после отбоя появится позже.';

  @override
  String get dscBlockerSoon => 'Позже';

  @override
  String get dscEnable => 'Включить режим';

  @override
  String get dscDisable => 'Выключить режим';

  @override
  String get dscEnableConfirmMessage =>
      'Подъём в 6:00, отбой в 22:00, доп. нагрузка. Квесты режима нельзя отменить.';

  @override
  String get dscDisableLocked => 'Выключить нельзя, пока баланс отрицательный.';

  @override
  String get dscChangedOnMessage =>
      'Режим дисциплины включён. Подъём в 6:00, отбой в 22:00, доп. нагрузка.';

  @override
  String get dscChangedOffMessage => 'Режим дисциплины выключен.';

  @override
  String dscQuestWake(String time) {
    return 'Подъём в $time';
  }

  @override
  String dscQuestBed(String time) {
    return 'Отбой в $time';
  }

  @override
  String dscQuestWorkout(int minutes) {
    return 'Доп. тренировка: $minutes мин';
  }

  @override
  String dscQuestWalk(int minutes) {
    return 'Спокойная прогулка: $minutes мин';
  }

  @override
  String get wrkTitle => 'Тренировки';

  @override
  String get wrkProgram => 'Программа';

  @override
  String get wrkToday => 'Сегодня';

  @override
  String wrkTodayDay(String key) {
    return 'По программе — день $key';
  }

  @override
  String get wrkRestDay =>
      'Сегодня по программе отдых. Можно провести любую тренировку из списка ниже.';

  @override
  String wrkDayTitle(String key) {
    return 'День $key';
  }

  @override
  String wrkMinutesShort(int minutes) {
    return '$minutes мин';
  }

  @override
  String wrkEstimate(int minutes) {
    return '≈$minutes мин';
  }

  @override
  String wrkExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count упражнения',
      many: '$count упражнений',
      few: '$count упражнения',
      one: '$count упражнение',
    );
    return '$_temp0';
  }

  @override
  String wrkSetsReps(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String wrkSetsSeconds(int sets, int seconds) {
    return '$sets × $seconds с';
  }

  @override
  String wrkRestShort(int seconds) {
    return 'отдых $seconds с';
  }

  @override
  String get wrkGentle =>
      'Щадящий вариант: без прыжков и осевой нагрузки — в анкете указаны травмы или ограничения.';

  @override
  String get wrkSafetyNote =>
      'Если упражнение вызывает боль или дискомфорт — пропустите его.';

  @override
  String get wrkLevelUnknown =>
      'Уровень в анкете не указан — программа для новичка.';

  @override
  String wrkProgressionWeeks(int weeks) {
    return 'Выполненных недель: $weeks';
  }

  @override
  String get wrkProgressionNote =>
      'Неделя засчитывается, если выполнены все тренировки недели (не больше 3). За каждую: +1 повтор или +5 с, до потолка вашего уровня.';

  @override
  String get wrkRegenerate => 'Пересоздать программу';

  @override
  String get wrkRegenerateTitle => 'Пересоздать программу?';

  @override
  String get wrkRegenerateText =>
      'Программа соберётся заново по анкете и плану. История тренировок сохранится, прогрессия начнётся сначала.';

  @override
  String get wrkAiProgram => 'Программа от ИИ';

  @override
  String get wrkSoon => 'скоро';

  @override
  String get wrkStart => 'Начать тренировку';

  @override
  String wrkStartDay(String key) {
    return 'Начать день $key';
  }

  @override
  String get wrkHistory => 'История';

  @override
  String get wrkHistoryEmpty => 'Тренировок пока нет.';

  @override
  String get wrkSessionDone => 'завершена';

  @override
  String get wrkSessionInterrupted => 'прервана';

  @override
  String wrkSessionStats(int minutes, int kcal) {
    return '$minutes мин · ≈$kcal ккал';
  }

  @override
  String get wrkPreparing => 'Программа собирается…';

  @override
  String get wrkPhasePrepare => 'Приготовьтесь';

  @override
  String get wrkPhaseWork => 'Работа';

  @override
  String get wrkPhaseRest => 'Отдых';

  @override
  String get wrkPaused => 'Пауза';

  @override
  String wrkSetOf(int set, int sets) {
    return 'Подход $set из $sets';
  }

  @override
  String wrkRepsTarget(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: '$reps повтора',
      many: '$reps повторов',
      few: '$reps повтора',
      one: '$reps повтор',
    );
    return '$_temp0';
  }

  @override
  String get wrkDoneSet => 'Подход выполнен';

  @override
  String get wrkPause => 'Пауза';

  @override
  String get wrkResume => 'Продолжить';

  @override
  String get wrkSkipRest => 'Пропустить отдых';

  @override
  String get wrkSkipExercise => 'Пропустить упражнение';

  @override
  String get wrkStop => 'Прервать';

  @override
  String wrkNext(String name) {
    return 'Далее: $name';
  }

  @override
  String get wrkLastExercise => 'Последнее упражнение';

  @override
  String get wrkTechnique => 'Техника';

  @override
  String get wrkVoice => 'Голосовые подсказки';

  @override
  String get wrkProgressLabel => 'Прогресс тренировки';

  @override
  String get wrkStopTitle => 'Прервать тренировку?';

  @override
  String get wrkStopText =>
      'Сделанное сохранится как незавершённая тренировка.';

  @override
  String get wrkFinishedTitle => 'Тренировка завершена';

  @override
  String wrkFinishedStats(int minutes, int kcal, int sets) {
    return 'Время: $minutes мин · ≈$kcal ккал · подходов: $sets';
  }

  @override
  String get wrkWeightAssumed =>
      'Расход — оценка по весу 70 кг: замеров веса нет.';

  @override
  String get wrkKcalNote => 'Расход — оценка по MET, не измерение.';

  @override
  String wrkSayPrepare(String name) {
    return 'Приготовьтесь. $name.';
  }

  @override
  String wrkSaySet(int set, int sets, String amount) {
    return 'Подход $set из $sets. $amount. Начали!';
  }

  @override
  String wrkSecondsAmount(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds секунды',
      many: '$seconds секунд',
      few: '$seconds секунды',
      one: '$seconds секунда',
    );
    return '$_temp0';
  }

  @override
  String wrkSayRest(String amount) {
    return 'Отдых: $amount.';
  }

  @override
  String wrkSayNext(String name) {
    return 'Далее: $name.';
  }

  @override
  String get wrkSayFinished => 'Тренировка завершена. Отличная работа!';

  @override
  String get wrkExMarchInPlace => 'Ходьба на месте';

  @override
  String get wrkExMarchInPlaceHint =>
      'Высоко поднимайте колени.\nРуки работают в такт.\nДышите ровно.';

  @override
  String get wrkExArmCircles => 'Круги руками';

  @override
  String get wrkExArmCirclesHint =>
      'Руки в стороны на уровне плеч.\nМаленькие круги вперёд, затем назад.\nПлечи опущены.';

  @override
  String get wrkExJumpingJacks => 'Джампинг-джек';

  @override
  String get wrkExJumpingJacksHint =>
      'Прыжок: ноги врозь, руки вверх.\nПрыжок обратно.\nПриземляйтесь мягко на носки.';

  @override
  String get wrkExChairSquat => 'Приседание на стул';

  @override
  String get wrkExChairSquatHint =>
      'Встаньте перед стулом, ноги на ширине плеч.\nСядьте, отводя таз назад.\nВстаньте без рывка.';

  @override
  String get wrkExGluteBridge => 'Ягодичный мост';

  @override
  String get wrkExGluteBridgeHint =>
      'Лёжа на спине, стопы на полу.\nПоднимите таз, сожмите ягодицы.\nМедленно опуститесь.';

  @override
  String get wrkExSquat => 'Приседания';

  @override
  String get wrkExSquatHint =>
      'Ноги на ширине плеч, носки чуть врозь.\nТаз назад, колени по направлению носков.\nСпина прямая, пятки на полу.';

  @override
  String get wrkExWallSit => 'Стульчик у стены';

  @override
  String get wrkExWallSitHint =>
      'Спина прижата к стене.\nОпуститесь, пока бёдра не станут почти параллельны полу.\nДержите позицию.';

  @override
  String get wrkExReverseLunge => 'Выпады назад';

  @override
  String get wrkExReverseLungeHint =>
      'Шаг назад, опустите заднее колено к полу.\nПереднее колено над стопой.\nВернитесь, смените ногу.';

  @override
  String get wrkExGobletSquat => 'Гоблет-присед';

  @override
  String get wrkExGobletSquatHint =>
      'Гантель вертикально у груди.\nПрисед, локти между коленями.\nСпина прямая.';

  @override
  String get wrkExKettlebellSwing => 'Махи гирей';

  @override
  String get wrkExKettlebellSwingHint =>
      'Гиря двумя руками, ноги шире плеч.\nТаз назад, затем резко вперёд.\nГиря поднимается до груди за счёт таза.';

  @override
  String get wrkExJumpSquat => 'Присед с выпрыгиванием';

  @override
  String get wrkExJumpSquatHint =>
      'Обычный присед.\nВыпрыгните вверх.\nПриземлитесь мягко сразу в присед.';

  @override
  String get wrkExWallPushUp => 'Отжимания от стены';

  @override
  String get wrkExWallPushUpHint =>
      'Ладони на стене на уровне плеч.\nСогните руки, корпус прямой.\nОттолкнитесь.';

  @override
  String get wrkExKneePushUp => 'Отжимания с колен';

  @override
  String get wrkExKneePushUpHint =>
      'Упор на колени и ладони.\nКорпус прямой от колен до головы.\nГрудь к полу и вверх.';

  @override
  String get wrkExPushUp => 'Отжимания';

  @override
  String get wrkExPushUpHint =>
      'Упор лёжа, ладони чуть шире плеч.\nКорпус — прямая линия.\nГрудь к полу, локти под 45°.';

  @override
  String get wrkExDumbbellPress => 'Жим гантелей лёжа';

  @override
  String get wrkExDumbbellPressHint =>
      'Лёжа на полу, гантели над грудью.\nОпустите до касания локтями пола.\nВыжмите вверх.';

  @override
  String get wrkExDiamondPushUp => 'Узкие отжимания';

  @override
  String get wrkExDiamondPushUpHint =>
      'Ладони рядом под грудью.\nЛокти вдоль корпуса.\nКорпус прямой.';

  @override
  String get wrkExSuperman => 'Супермен';

  @override
  String get wrkExSupermanHint =>
      'Лёжа на животе, руки вперёд.\nПоднимите руки и ноги на пару секунд.\nМедленно опустите.';

  @override
  String get wrkExReverseSnowAngel => 'Обратный снежный ангел';

  @override
  String get wrkExReverseSnowAngelHint =>
      'Лёжа на животе, руки вдоль тела.\nПриподнимите грудь и руки.\nДугой проведите руки над головой и обратно.';

  @override
  String get wrkExBandRow => 'Тяга резинки';

  @override
  String get wrkExBandRowHint =>
      'Закрепите резинку на уровне груди.\nТяните к поясу, сводя лопатки.\nПлавно отпустите.';

  @override
  String get wrkExDumbbellRow => 'Тяга гантели в наклоне';

  @override
  String get wrkExDumbbellRowHint =>
      'Опора рукой и коленом о стул.\nТяните гантель к поясу.\nСпина ровная.';

  @override
  String get wrkExPullUp => 'Подтягивания';

  @override
  String get wrkExPullUpHint =>
      'Хват чуть шире плеч.\nПодтянитесь подбородком к перекладине.\nОпуститесь подконтрольно.';

  @override
  String get wrkExDeadBug => 'Мёртвый жук';

  @override
  String get wrkExDeadBugHint =>
      'Лёжа на спине, руки вверх, колени над тазом.\nОпустите противоположные руку и ногу.\nПоясница прижата к полу.';

  @override
  String get wrkExBirdDog => 'Птица-собака';

  @override
  String get wrkExBirdDogHint =>
      'Упор на ладони и колени.\nВытяните противоположные руку и ногу.\nЗадержитесь, смените сторону.';

  @override
  String get wrkExPlank => 'Планка';

  @override
  String get wrkExPlankHint =>
      'Упор на предплечья и носки.\nКорпус — прямая линия, живот напряжён.\nНе прогибайтесь в пояснице.';

  @override
  String get wrkExCrunch => 'Скручивания';

  @override
  String get wrkExCrunchHint =>
      'Лёжа на спине, колени согнуты.\nПоднимите плечи к коленям.\nМедленно опуститесь.';

  @override
  String get wrkExSidePlank => 'Боковая планка';

  @override
  String get wrkExSidePlankHint =>
      'Упор на предплечье, ноги вместе.\nТаз поднят, корпус прямой.\nПоловину времени — на каждую сторону.';

  @override
  String get wrkExLegRaise => 'Подъём ног лёжа';

  @override
  String get wrkExLegRaiseHint =>
      'Лёжа на спине, руки вдоль тела.\nПоднимите прямые ноги вверх.\nОпускайте медленно, поясница прижата.';

  @override
  String get wrkExStepTouch => 'Приставные шаги';

  @override
  String get wrkExStepTouchHint =>
      'Шаг в сторону, приставьте ногу.\nВ другую сторону.\nРуки работают в такт.';

  @override
  String get wrkExShadowBoxing => 'Бой с тенью';

  @override
  String get wrkExShadowBoxingHint =>
      'Стойка, кулаки у подбородка.\nЛёгкие удары поочерёдно.\nДвигайтесь на носках без прыжков.';

  @override
  String get wrkExHighKnees => 'Бег с высоким подниманием колен';

  @override
  String get wrkExHighKneesHint =>
      'Бег на месте.\nКолени до уровня пояса.\nПриземление на носки.';

  @override
  String get wrkExMountainClimber => 'Скалолаз';

  @override
  String get wrkExMountainClimberHint =>
      'Упор лёжа на прямых руках.\nПоочерёдно подтягивайте колени к груди.\nТаз не поднимайте.';

  @override
  String get wrkExBurpee => 'Бёрпи';

  @override
  String get wrkExBurpeeHint =>
      'Присед, руки на пол.\nОтскок в упор лёжа и обратно.\nВыпрыгните вверх.';

  @override
  String get wrkExFullBodyStretch => 'Растяжка';

  @override
  String get wrkExFullBodyStretchHint =>
      'Потянитесь вверх, затем наклон к ногам.\nРастяните бёдра и грудь.\nДышите медленно, без рывков.';
}
