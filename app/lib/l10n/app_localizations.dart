import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get appTitle;

  /// No description provided for @navStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get navStatus;

  /// No description provided for @navQuests.
  ///
  /// In ru, this message translates to:
  /// **'Квесты'**
  String get navQuests;

  /// No description provided for @navNutrition.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get navNutrition;

  /// No description provided for @navShop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get navShop;

  /// No description provided for @navMore.
  ///
  /// In ru, this message translates to:
  /// **'Ещё'**
  String get navMore;

  /// No description provided for @sectionEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Раздел в разработке'**
  String get sectionEmptyTitle;

  /// No description provided for @sectionEmptyBody.
  ///
  /// In ru, this message translates to:
  /// **'Система откроет этот раздел на следующих этапах.'**
  String get sectionEmptyBody;

  /// No description provided for @certExpiresInDays.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, =0{Сертификат истекает сегодня} one{Сертификат истекает через {days} день} few{Сертификат истекает через {days} дня} other{Сертификат истекает через {days} дней}}'**
  String certExpiresInDays(int days);

  /// No description provided for @certExpired.
  ///
  /// In ru, this message translates to:
  /// **'Сертификат истёк — переустановите приложение'**
  String get certExpired;

  /// No description provided for @certReinstallHint.
  ///
  /// In ru, this message translates to:
  /// **'Переустановите приложение через Sideloadly, данные сохранятся после синхронизации.'**
  String get certReinstallHint;

  /// No description provided for @homeSystemOnline.
  ///
  /// In ru, this message translates to:
  /// **'Система · онлайн'**
  String get homeSystemOnline;

  /// No description provided for @homeNotificationsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления: {count}'**
  String homeNotificationsLabel(int count);

  /// No description provided for @homeSettingsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get homeSettingsLabel;

  /// No description provided for @homeWeekDay.
  ///
  /// In ru, this message translates to:
  /// **'Неделя {week} · день {day}'**
  String homeWeekDay(int week, int day);

  /// No description provided for @homeStatusTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get homeStatusTitle;

  /// No description provided for @homeLevelShort.
  ///
  /// In ru, this message translates to:
  /// **'LV'**
  String get homeLevelShort;

  /// No description provided for @homeLevelSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String homeLevelSemantics(int level);

  /// No description provided for @homeRank.
  ///
  /// In ru, this message translates to:
  /// **'Ранг {rank}'**
  String homeRank(String rank);

  /// No description provided for @homeStreakDays.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день подряд} few{{count} дня подряд} many{{count} дней подряд} other{{count} дня подряд}}'**
  String homeStreakDays(int count);

  /// No description provided for @homeXpLabel.
  ///
  /// In ru, this message translates to:
  /// **'Опыт · до LV {level}'**
  String homeXpLabel(int level);

  /// No description provided for @homeXpValue.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total} XP'**
  String homeXpValue(String current, String total);

  /// No description provided for @homeEnergy.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get homeEnergy;

  /// No description provided for @homeWater.
  ///
  /// In ru, this message translates to:
  /// **'Вода'**
  String get homeWater;

  /// No description provided for @homeCalories.
  ///
  /// In ru, this message translates to:
  /// **'Калории'**
  String get homeCalories;

  /// No description provided for @homePercentValue.
  ///
  /// In ru, this message translates to:
  /// **'{value}%'**
  String homePercentValue(String value);

  /// No description provided for @homeLitersProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total} л'**
  String homeLitersProgress(String current, String total);

  /// No description provided for @homeKcalProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total} ккал'**
  String homeKcalProgress(String current, String total);

  /// No description provided for @homeKcalValue.
  ///
  /// In ru, this message translates to:
  /// **'{value} ккал'**
  String homeKcalValue(String value);

  /// No description provided for @homeStatStrength.
  ///
  /// In ru, this message translates to:
  /// **'Сила'**
  String get homeStatStrength;

  /// No description provided for @homeStatEndurance.
  ///
  /// In ru, this message translates to:
  /// **'Выносливость'**
  String get homeStatEndurance;

  /// No description provided for @homeStatDiscipline.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплина'**
  String get homeStatDiscipline;

  /// No description provided for @homeStatIntellect.
  ///
  /// In ru, this message translates to:
  /// **'Интеллект'**
  String get homeStatIntellect;

  /// No description provided for @homeStatHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get homeStatHealth;

  /// No description provided for @homeStatLooks.
  ///
  /// In ru, this message translates to:
  /// **'Внешность'**
  String get homeStatLooks;

  /// No description provided for @homeStatDeltaSemantics.
  ///
  /// In ru, this message translates to:
  /// **'{stat}: {value}, за сегодня {delta}'**
  String homeStatDeltaSemantics(String stat, String value, String delta);

  /// No description provided for @homePointsLabel.
  ///
  /// In ru, this message translates to:
  /// **'Баллы'**
  String get homePointsLabel;

  /// No description provided for @homePointsValue.
  ///
  /// In ru, this message translates to:
  /// **'{points} ◆'**
  String homePointsValue(String points);

  /// No description provided for @homeStatPointsButton.
  ///
  /// In ru, this message translates to:
  /// **'Очки характ.: {count}'**
  String homeStatPointsButton(int count);

  /// No description provided for @homeEffectsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Эффекты'**
  String get homeEffectsTitle;

  /// No description provided for @homeEffectsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Активных эффектов нет'**
  String get homeEffectsEmpty;

  /// No description provided for @homeNextQuestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Следующий квест'**
  String get homeNextQuestTitle;

  /// No description provided for @homeQuestDeadline.
  ///
  /// In ru, this message translates to:
  /// **'до {time}'**
  String homeQuestDeadline(String time);

  /// No description provided for @homeTimeLeftSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Осталось {time}'**
  String homeTimeLeftSemantics(String time);

  /// No description provided for @homeRewardLabel.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get homeRewardLabel;

  /// No description provided for @homePenaltyLabel.
  ///
  /// In ru, this message translates to:
  /// **'Штраф'**
  String get homePenaltyLabel;

  /// No description provided for @homeRewardPoints.
  ///
  /// In ru, this message translates to:
  /// **'+{points} ◆'**
  String homeRewardPoints(String points);

  /// No description provided for @homePenaltyPoints.
  ///
  /// In ru, this message translates to:
  /// **'−{points} ◆'**
  String homePenaltyPoints(String points);

  /// No description provided for @homeRewardXp.
  ///
  /// In ru, this message translates to:
  /// **'+{xp} XP'**
  String homeRewardXp(String xp);

  /// No description provided for @homeActionDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get homeActionDone;

  /// No description provided for @homeActionSnooze.
  ///
  /// In ru, this message translates to:
  /// **'+10 мин'**
  String get homeActionSnooze;

  /// No description provided for @homeActionNoWater.
  ///
  /// In ru, this message translates to:
  /// **'Нет воды'**
  String get homeActionNoWater;

  /// No description provided for @homeActionRefuse.
  ///
  /// In ru, this message translates to:
  /// **'Отказ'**
  String get homeActionRefuse;

  /// No description provided for @homeRefuseHint.
  ///
  /// In ru, this message translates to:
  /// **'Отказ: удерживать 5 сек'**
  String get homeRefuseHint;

  /// No description provided for @homeNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get homeNoticeLabel;

  /// No description provided for @homeWarningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get homeWarningLabel;

  /// No description provided for @homeQuestCompletedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Квест выполнен'**
  String get homeQuestCompletedTitle;

  /// No description provided for @homeQuestCompletedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Награда: +{points} ◆, +{xp} XP.'**
  String homeQuestCompletedMessage(String points, String xp);

  /// No description provided for @homeQuestFailedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Квест провален'**
  String get homeQuestFailedTitle;

  /// No description provided for @homeQuestRefusedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Отказ от квеста «{quest}». Штраф: −{points} ◆.'**
  String homeQuestRefusedMessage(String quest, String points);

  /// No description provided for @homeNoWaterMessage.
  ///
  /// In ru, this message translates to:
  /// **'Квест отложен: Система напомнит, когда вода будет рядом.'**
  String get homeNoWaterMessage;

  /// No description provided for @homeOk.
  ///
  /// In ru, this message translates to:
  /// **'Понятно'**
  String get homeOk;

  /// No description provided for @homeDayTitle.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get homeDayTitle;

  /// No description provided for @homeSegSleep.
  ///
  /// In ru, this message translates to:
  /// **'Сон'**
  String get homeSegSleep;

  /// No description provided for @homeSegClasses.
  ///
  /// In ru, this message translates to:
  /// **'Пары'**
  String get homeSegClasses;

  /// No description provided for @homeSegWorkout.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка'**
  String get homeSegWorkout;

  /// No description provided for @homeSegFree.
  ///
  /// In ru, this message translates to:
  /// **'Свободно'**
  String get homeSegFree;

  /// No description provided for @homeSegCommute.
  ///
  /// In ru, this message translates to:
  /// **'Дорога'**
  String get homeSegCommute;

  /// No description provided for @homeNow.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас {time}'**
  String homeNow(String time);

  /// No description provided for @homeLeaveHome.
  ///
  /// In ru, this message translates to:
  /// **'Выход из дома: {time}'**
  String homeLeaveHome(String time);

  /// No description provided for @homeSegmentSemantics.
  ///
  /// In ru, this message translates to:
  /// **'{type}: {start}–{end}'**
  String homeSegmentSemantics(String type, String start, String end);

  /// No description provided for @homeDailyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневные квесты'**
  String get homeDailyTitle;

  /// No description provided for @homeDailyCounter.
  ///
  /// In ru, this message translates to:
  /// **'{done} / {total}'**
  String homeDailyCounter(int done, int total);

  /// No description provided for @homeDailyPenaltyTotal.
  ///
  /// In ru, this message translates to:
  /// **'Штраф при провале: −{points} ◆'**
  String homeDailyPenaltyTotal(String points);

  /// No description provided for @homeMinutesProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total} мин'**
  String homeMinutesProgress(String current, String total);

  /// No description provided for @homeStepsProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total} шагов'**
  String homeStepsProgress(String current, String total);

  /// No description provided for @homeBossTitle.
  ///
  /// In ru, this message translates to:
  /// **'Босс недели'**
  String get homeBossTitle;

  /// No description provided for @homeBossTimeLeft.
  ///
  /// In ru, this message translates to:
  /// **'{days} д {time}'**
  String homeBossTimeLeft(String days, String time);

  /// No description provided for @homeBossProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total}'**
  String homeBossProgress(int current, int total);

  /// No description provided for @homeBossReward.
  ///
  /// In ru, this message translates to:
  /// **'Награда: +{points} ◆ и титул «{title}»'**
  String homeBossReward(String points, String title);

  /// No description provided for @homeEaten.
  ///
  /// In ru, this message translates to:
  /// **'Съедено'**
  String get homeEaten;

  /// No description provided for @homeBurned.
  ///
  /// In ru, this message translates to:
  /// **'Сожжено'**
  String get homeBurned;

  /// No description provided for @homeDeficit.
  ///
  /// In ru, this message translates to:
  /// **'Дефицит'**
  String get homeDeficit;

  /// No description provided for @homeFinanceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get homeFinanceTitle;

  /// No description provided for @homeFoodSpent.
  ///
  /// In ru, this message translates to:
  /// **'Траты на еду'**
  String get homeFoodSpent;

  /// No description provided for @homeLimit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит'**
  String get homeLimit;

  /// No description provided for @homeUntilStipend.
  ///
  /// In ru, this message translates to:
  /// **'До стипендии'**
  String get homeUntilStipend;

  /// No description provided for @homeDaysCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} день} few{{count} дня} many{{count} дней} other{{count} дня}}'**
  String homeDaysCount(int count);

  /// No description provided for @homeAssistantTitle.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент'**
  String get homeAssistantTitle;

  /// No description provided for @homeAssistantAvatar.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж-ассистент'**
  String get homeAssistantAvatar;

  /// No description provided for @homeAssistantSpeaking.
  ///
  /// In ru, this message translates to:
  /// **'Ассистент говорит'**
  String get homeAssistantSpeaking;

  /// No description provided for @homeMicLabel.
  ///
  /// In ru, this message translates to:
  /// **'Голосовой ввод'**
  String get homeMicLabel;

  /// No description provided for @homeReplyHint.
  ///
  /// In ru, this message translates to:
  /// **'Ответить…'**
  String get homeReplyHint;

  /// No description provided for @homeSendLabel.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get homeSendLabel;

  /// No description provided for @homeDemoPlayerName.
  ///
  /// In ru, this message translates to:
  /// **'Мурат'**
  String get homeDemoPlayerName;

  /// No description provided for @homeDemoPlayerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пробуждённый'**
  String get homeDemoPlayerTitle;

  /// No description provided for @homeDemoEffectVigor.
  ///
  /// In ru, this message translates to:
  /// **'Бодрость +5% опыта'**
  String get homeDemoEffectVigor;

  /// No description provided for @homeDemoEffectDehydration.
  ///
  /// In ru, this message translates to:
  /// **'Обезвоживание −10% выносливости'**
  String get homeDemoEffectDehydration;

  /// No description provided for @homeDemoNextQuest.
  ///
  /// In ru, this message translates to:
  /// **'Выпить 500 мл воды'**
  String get homeDemoNextQuest;

  /// No description provided for @homeDemoQuestWakeUp.
  ///
  /// In ru, this message translates to:
  /// **'Подъём до 07:00'**
  String get homeDemoQuestWakeUp;

  /// No description provided for @homeDemoQuestBreakfast.
  ///
  /// In ru, this message translates to:
  /// **'Завтрак с белком'**
  String get homeDemoQuestBreakfast;

  /// No description provided for @homeDemoQuestWater.
  ///
  /// In ru, this message translates to:
  /// **'Выпить 2,5 л воды'**
  String get homeDemoQuestWater;

  /// No description provided for @homeDemoQuestWorkout.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка дома'**
  String get homeDemoQuestWorkout;

  /// No description provided for @homeDemoSubWarmup.
  ///
  /// In ru, this message translates to:
  /// **'Разминка 5 мин'**
  String get homeDemoSubWarmup;

  /// No description provided for @homeDemoSubPushups.
  ///
  /// In ru, this message translates to:
  /// **'Отжимания 3×15'**
  String get homeDemoSubPushups;

  /// No description provided for @homeDemoSubPlank.
  ///
  /// In ru, this message translates to:
  /// **'Планка 3×45 с'**
  String get homeDemoSubPlank;

  /// No description provided for @homeDemoQuestReading.
  ///
  /// In ru, this message translates to:
  /// **'Читать 20 минут'**
  String get homeDemoQuestReading;

  /// No description provided for @homeDemoQuestSteps.
  ///
  /// In ru, this message translates to:
  /// **'Пройти 8 000 шагов'**
  String get homeDemoQuestSteps;

  /// No description provided for @homeDemoQuestSleep.
  ///
  /// In ru, this message translates to:
  /// **'Отбой до 23:00'**
  String get homeDemoQuestSleep;

  /// No description provided for @homeDemoBossGoal.
  ///
  /// In ru, this message translates to:
  /// **'Провести 5 тренировок за неделю'**
  String get homeDemoBossGoal;

  /// No description provided for @homeDemoBossRewardTitle.
  ///
  /// In ru, this message translates to:
  /// **'Несгибаемый'**
  String get homeDemoBossRewardTitle;

  /// No description provided for @homeDemoAssistantLine.
  ///
  /// In ru, this message translates to:
  /// **'Вода — 48% нормы. Выпей стакан до 11:30, и «Бодрость» продлится ещё час.'**
  String get homeDemoAssistantLine;

  /// No description provided for @chrIntro.
  ///
  /// In ru, this message translates to:
  /// **'Выберите спутника. Он проведёт вас через фото-сессии своим голосом, а потом будет жить внизу экрана: напоминать, хвалить и ругать — в выбранном режиме.'**
  String get chrIntro;

  /// No description provided for @chrArchetype.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж'**
  String get chrArchetype;

  /// No description provided for @chrArchetypeRequired.
  ///
  /// In ru, this message translates to:
  /// **'Выберите персонажа, чтобы продолжить'**
  String get chrArchetypeRequired;

  /// No description provided for @chrNameAnimeGirl.
  ///
  /// In ru, this message translates to:
  /// **'Аниме-девушка'**
  String get chrNameAnimeGirl;

  /// No description provided for @chrDescAnimeGirl.
  ///
  /// In ru, this message translates to:
  /// **'Жизнерадостная и упрямая. Радуется каждой победе и не даёт сдаться.'**
  String get chrDescAnimeGirl;

  /// No description provided for @chrSpeechAnimeGirl.
  ///
  /// In ru, this message translates to:
  /// **'живая, с восклицаниями и подбадриваниями'**
  String get chrSpeechAnimeGirl;

  /// No description provided for @chrSampleAnimeGirl1.
  ///
  /// In ru, this message translates to:
  /// **'Привет! Сегодня мы точно всё успеем!'**
  String get chrSampleAnimeGirl1;

  /// No description provided for @chrSampleAnimeGirl2.
  ///
  /// In ru, this message translates to:
  /// **'Ещё один квест — и я буду тобой гордиться!'**
  String get chrSampleAnimeGirl2;

  /// No description provided for @chrSampleAnimeGirl3.
  ///
  /// In ru, this message translates to:
  /// **'Не сдавайся, у тебя получается лучше, чем вчера!'**
  String get chrSampleAnimeGirl3;

  /// No description provided for @chrLineAnimeGirlSoft.
  ///
  /// In ru, this message translates to:
  /// **'Ничего страшного, отдохни немного — и попробуем ещё раз, ладно?'**
  String get chrLineAnimeGirlSoft;

  /// No description provided for @chrLineAnimeGirlNormal.
  ///
  /// In ru, this message translates to:
  /// **'Хорошая работа! Осталось совсем чуть-чуть, давай закончим!'**
  String get chrLineAnimeGirlNormal;

  /// No description provided for @chrLineAnimeGirlStrict.
  ///
  /// In ru, this message translates to:
  /// **'Эй! Квест сам себя не выполнит. Встаём и делаем!'**
  String get chrLineAnimeGirlStrict;

  /// No description provided for @chrLineAnimeGirlHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Опять откладываешь?! Хватит оправданий — марш выполнять, сейчас же!'**
  String get chrLineAnimeGirlHarsh;

  /// No description provided for @chrNameAnimeGuy.
  ///
  /// In ru, this message translates to:
  /// **'Аниме-парень'**
  String get chrNameAnimeGuy;

  /// No description provided for @chrDescAnimeGuy.
  ///
  /// In ru, this message translates to:
  /// **'Соперник и напарник. Вызывает на спор и тянет вперёд.'**
  String get chrDescAnimeGuy;

  /// No description provided for @chrSpeechAnimeGuy.
  ///
  /// In ru, this message translates to:
  /// **'дерзкая, с вызовом и азартом'**
  String get chrSpeechAnimeGuy;

  /// No description provided for @chrSampleAnimeGuy1.
  ///
  /// In ru, this message translates to:
  /// **'Спорим, сегодня ты меня не обгонишь?'**
  String get chrSampleAnimeGuy1;

  /// No description provided for @chrSampleAnimeGuy2.
  ///
  /// In ru, this message translates to:
  /// **'Ха, неплохо! Но я знаю, что ты можешь больше.'**
  String get chrSampleAnimeGuy2;

  /// No description provided for @chrSampleAnimeGuy3.
  ///
  /// In ru, this message translates to:
  /// **'Вперёд, напарник, уровень сам себя не поднимет!'**
  String get chrSampleAnimeGuy3;

  /// No description provided for @chrLineAnimeGuySoft.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня тяжело? Бывает. Сделаем хотя бы маленький шаг вместе.'**
  String get chrLineAnimeGuySoft;

  /// No description provided for @chrLineAnimeGuyNormal.
  ///
  /// In ru, this message translates to:
  /// **'Неплохо идёшь! Ещё рывок — и этот день наш.'**
  String get chrLineAnimeGuyNormal;

  /// No description provided for @chrLineAnimeGuyStrict.
  ///
  /// In ru, this message translates to:
  /// **'Ты же не собираешься проиграть лени? Докажи, что сильнее.'**
  String get chrLineAnimeGuyStrict;

  /// No description provided for @chrLineAnimeGuyHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Серьёзно? Это всё, на что ты способен? Встал и сделал, без нытья!'**
  String get chrLineAnimeGuyHarsh;

  /// No description provided for @chrNameStoicStrongman.
  ///
  /// In ru, this message translates to:
  /// **'Невозмутимый силач'**
  String get chrNameStoicStrongman;

  /// No description provided for @chrDescStoicStrongman.
  ///
  /// In ru, this message translates to:
  /// **'Спокоен как скала. Верит в дисциплину и повторения.'**
  String get chrDescStoicStrongman;

  /// No description provided for @chrSpeechStoicStrongman.
  ///
  /// In ru, this message translates to:
  /// **'короткие фразы, без лишних слов'**
  String get chrSpeechStoicStrongman;

  /// No description provided for @chrSampleStoicStrongman1.
  ///
  /// In ru, this message translates to:
  /// **'Новый день. Делаем.'**
  String get chrSampleStoicStrongman1;

  /// No description provided for @chrSampleStoicStrongman2.
  ///
  /// In ru, this message translates to:
  /// **'Сила — это повторения.'**
  String get chrSampleStoicStrongman2;

  /// No description provided for @chrSampleStoicStrongman3.
  ///
  /// In ru, this message translates to:
  /// **'Медленно, но каждый день.'**
  String get chrSampleStoicStrongman3;

  /// No description provided for @chrLineStoicStrongmanSoft.
  ///
  /// In ru, this message translates to:
  /// **'Отдохни. Потом продолжим.'**
  String get chrLineStoicStrongmanSoft;

  /// No description provided for @chrLineStoicStrongmanNormal.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо. Следующий подход.'**
  String get chrLineStoicStrongmanNormal;

  /// No description provided for @chrLineStoicStrongmanStrict.
  ///
  /// In ru, this message translates to:
  /// **'Пропуск. Так не пойдёт. Делай.'**
  String get chrLineStoicStrongmanStrict;

  /// No description provided for @chrLineStoicStrongmanHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Хватит болтать. Встал. Сделал. Сейчас.'**
  String get chrLineStoicStrongmanHarsh;

  /// No description provided for @chrNameGrimSwordsman.
  ///
  /// In ru, this message translates to:
  /// **'Мрачный мечник'**
  String get chrNameGrimSwordsman;

  /// No description provided for @chrDescGrimSwordsman.
  ///
  /// In ru, this message translates to:
  /// **'Суровый наставник. Каждый день — тренировка воли.'**
  String get chrDescGrimSwordsman;

  /// No description provided for @chrSpeechGrimSwordsman.
  ///
  /// In ru, this message translates to:
  /// **'сдержанная, с мрачной иронией'**
  String get chrSpeechGrimSwordsman;

  /// No description provided for @chrSampleGrimSwordsman1.
  ///
  /// In ru, this message translates to:
  /// **'Клинок тупится без дела. Как и воля.'**
  String get chrSampleGrimSwordsman1;

  /// No description provided for @chrSampleGrimSwordsman2.
  ///
  /// In ru, this message translates to:
  /// **'Ты снова здесь. Значит, ещё не сдался.'**
  String get chrSampleGrimSwordsman2;

  /// No description provided for @chrSampleGrimSwordsman3.
  ///
  /// In ru, this message translates to:
  /// **'Тьма не страшна тому, кто держит слово.'**
  String get chrSampleGrimSwordsman3;

  /// No description provided for @chrLineGrimSwordsmanSoft.
  ///
  /// In ru, this message translates to:
  /// **'Даже клинку нужен отдых. Переведи дух и возвращайся.'**
  String get chrLineGrimSwordsmanSoft;

  /// No description provided for @chrLineGrimSwordsmanNormal.
  ///
  /// In ru, this message translates to:
  /// **'Удар засчитан. Держи ритм до конца дня.'**
  String get chrLineGrimSwordsmanNormal;

  /// No description provided for @chrLineGrimSwordsmanStrict.
  ///
  /// In ru, this message translates to:
  /// **'Слабость ищет оправдания. Сила ищет путь. Выбирай.'**
  String get chrLineGrimSwordsmanStrict;

  /// No description provided for @chrLineGrimSwordsmanHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Позорно. Воин, который бросает клятву, — уже не воин. Исправь это.'**
  String get chrLineGrimSwordsmanHarsh;

  /// No description provided for @chrSpeechLabel.
  ///
  /// In ru, this message translates to:
  /// **'Манера речи: {speech}'**
  String chrSpeechLabel(String speech);

  /// No description provided for @chrPreviewStates.
  ///
  /// In ru, this message translates to:
  /// **'Анимации'**
  String get chrPreviewStates;

  /// No description provided for @chrStateIdle.
  ///
  /// In ru, this message translates to:
  /// **'Покой'**
  String get chrStateIdle;

  /// No description provided for @chrStateWalk.
  ///
  /// In ru, this message translates to:
  /// **'Идти'**
  String get chrStateWalk;

  /// No description provided for @chrStateTalk.
  ///
  /// In ru, this message translates to:
  /// **'Говорить'**
  String get chrStateTalk;

  /// No description provided for @chrStateHappy.
  ///
  /// In ru, this message translates to:
  /// **'Радость'**
  String get chrStateHappy;

  /// No description provided for @chrStateAngry.
  ///
  /// In ru, this message translates to:
  /// **'Злость'**
  String get chrStateAngry;

  /// No description provided for @chrStateSit.
  ///
  /// In ru, this message translates to:
  /// **'Сесть'**
  String get chrStateSit;

  /// No description provided for @chrStateSleep.
  ///
  /// In ru, this message translates to:
  /// **'Сон'**
  String get chrStateSleep;

  /// No description provided for @chrStatePoint.
  ///
  /// In ru, this message translates to:
  /// **'Указать'**
  String get chrStatePoint;

  /// No description provided for @chrVoice.
  ///
  /// In ru, this message translates to:
  /// **'Голос'**
  String get chrVoice;

  /// No description provided for @chrVoiceNote.
  ///
  /// In ru, this message translates to:
  /// **'Пока звучит системный синтез речи телефона; позже появятся голоса персонажей.'**
  String get chrVoiceNote;

  /// No description provided for @chrVoiceBright.
  ///
  /// In ru, this message translates to:
  /// **'Звонкий'**
  String get chrVoiceBright;

  /// No description provided for @chrVoiceSoft.
  ///
  /// In ru, this message translates to:
  /// **'Мягкий'**
  String get chrVoiceSoft;

  /// No description provided for @chrVoiceCalm.
  ///
  /// In ru, this message translates to:
  /// **'Спокойный'**
  String get chrVoiceCalm;

  /// No description provided for @chrVoiceEnergetic.
  ///
  /// In ru, this message translates to:
  /// **'Энергичный'**
  String get chrVoiceEnergetic;

  /// No description provided for @chrVoiceDeep.
  ///
  /// In ru, this message translates to:
  /// **'Глубокий'**
  String get chrVoiceDeep;

  /// No description provided for @chrVoiceLow.
  ///
  /// In ru, this message translates to:
  /// **'Низкий'**
  String get chrVoiceLow;

  /// No description provided for @chrVoiceHoarse.
  ///
  /// In ru, this message translates to:
  /// **'Хриплый'**
  String get chrVoiceHoarse;

  /// No description provided for @chrListen.
  ///
  /// In ru, this message translates to:
  /// **'Прослушать'**
  String get chrListen;

  /// No description provided for @chrStop.
  ///
  /// In ru, this message translates to:
  /// **'Остановить'**
  String get chrStop;

  /// No description provided for @chrTtsUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Синтез речи недоступен на этом устройстве для языка интерфейса — голос можно будет прослушать позже.'**
  String get chrTtsUnavailable;

  /// No description provided for @chrMotivation.
  ///
  /// In ru, this message translates to:
  /// **'Режим мотивации'**
  String get chrMotivation;

  /// No description provided for @chrModeSoft.
  ///
  /// In ru, this message translates to:
  /// **'Мягкий'**
  String get chrModeSoft;

  /// No description provided for @chrModeSoftDesc.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка и мягкие напоминания, без давления.'**
  String get chrModeSoftDesc;

  /// No description provided for @chrModeNormal.
  ///
  /// In ru, this message translates to:
  /// **'Обычный'**
  String get chrModeNormal;

  /// No description provided for @chrModeNormalDesc.
  ///
  /// In ru, this message translates to:
  /// **'Похвала за успехи, спокойные замечания за пропуски.'**
  String get chrModeNormalDesc;

  /// No description provided for @chrModeStrict.
  ///
  /// In ru, this message translates to:
  /// **'Строгий'**
  String get chrModeStrict;

  /// No description provided for @chrModeStrictDesc.
  ///
  /// In ru, this message translates to:
  /// **'Чёткие требования и прямая критика за провалы.'**
  String get chrModeStrictDesc;

  /// No description provided for @chrModeHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Жёсткий'**
  String get chrModeHarsh;

  /// No description provided for @chrModeHarshDesc.
  ///
  /// In ru, this message translates to:
  /// **'Ругает по всей строгости, но без унижений внешности и здоровья.'**
  String get chrModeHarshDesc;

  /// No description provided for @chrModeExample.
  ///
  /// In ru, this message translates to:
  /// **'Пример реплики'**
  String get chrModeExample;

  /// No description provided for @chrModeTry.
  ///
  /// In ru, this message translates to:
  /// **'Услышать в этом режиме'**
  String get chrModeTry;

  /// No description provided for @chrProfanity.
  ///
  /// In ru, this message translates to:
  /// **'Допускать мат'**
  String get chrProfanity;

  /// No description provided for @chrProfanityHint.
  ///
  /// In ru, this message translates to:
  /// **'Редко и только в жёстком режиме'**
  String get chrProfanityHint;

  /// No description provided for @chrTapSoft1.
  ///
  /// In ru, this message translates to:
  /// **'Я рядом. Сделаем немного — уже хорошо.'**
  String get chrTapSoft1;

  /// No description provided for @chrTapSoft2.
  ///
  /// In ru, this message translates to:
  /// **'Не торопись, всё получится.'**
  String get chrTapSoft2;

  /// No description provided for @chrTapSoft3.
  ///
  /// In ru, this message translates to:
  /// **'Ты молодец, что заглянул.'**
  String get chrTapSoft3;

  /// No description provided for @chrTapNormal1.
  ///
  /// In ru, this message translates to:
  /// **'Как продвигаются квесты?'**
  String get chrTapNormal1;

  /// No description provided for @chrTapNormal2.
  ///
  /// In ru, this message translates to:
  /// **'Хороший темп. Продолжаем.'**
  String get chrTapNormal2;

  /// No description provided for @chrTapNormal3.
  ///
  /// In ru, this message translates to:
  /// **'Не забудь про воду.'**
  String get chrTapNormal3;

  /// No description provided for @chrTapStrict1.
  ///
  /// In ru, this message translates to:
  /// **'Квесты ждут. Не расслабляйся.'**
  String get chrTapStrict1;

  /// No description provided for @chrTapStrict2.
  ///
  /// In ru, this message translates to:
  /// **'Сначала дело, потом отдых.'**
  String get chrTapStrict2;

  /// No description provided for @chrTapStrict3.
  ///
  /// In ru, this message translates to:
  /// **'Проверь список. Что ещё не сделано?'**
  String get chrTapStrict3;

  /// No description provided for @chrTapHarsh1.
  ///
  /// In ru, this message translates to:
  /// **'Хватит листать. Иди выполнять.'**
  String get chrTapHarsh1;

  /// No description provided for @chrTapHarsh2.
  ///
  /// In ru, this message translates to:
  /// **'Оправдания не засчитываются.'**
  String get chrTapHarsh2;

  /// No description provided for @chrTapHarsh3.
  ///
  /// In ru, this message translates to:
  /// **'День не резиновый. Действуй.'**
  String get chrTapHarsh3;

  /// No description provided for @chrPocketTab.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть персонажа'**
  String get chrPocketTab;

  /// No description provided for @chrSemantics.
  ///
  /// In ru, this message translates to:
  /// **'{name}: нажмите, чтобы услышать реплику; смахните вниз, чтобы убрать'**
  String chrSemantics(String name);

  /// No description provided for @commonNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get commonNext;

  /// No description provided for @commonBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get commonBack;

  /// No description provided for @commonDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get commonDone;

  /// No description provided for @commonClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get commonClose;

  /// No description provided for @commonSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get commonDelete;

  /// No description provided for @commonAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get commonAdd;

  /// No description provided for @commonEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменить'**
  String get commonEdit;

  /// No description provided for @commonSkip.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить'**
  String get commonSkip;

  /// No description provided for @commonOptional.
  ///
  /// In ru, this message translates to:
  /// **'необязательно'**
  String get commonOptional;

  /// No description provided for @commonOutOfRange.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте значение'**
  String get commonOutOfRange;

  /// No description provided for @commonRequired.
  ///
  /// In ru, this message translates to:
  /// **'Обязательное поле'**
  String get commonRequired;

  /// No description provided for @commonEstimateNote.
  ///
  /// In ru, this message translates to:
  /// **'оценка по фото, не медицинское измерение'**
  String get commonEstimateNote;

  /// No description provided for @commonCalculatedBySystem.
  ///
  /// In ru, this message translates to:
  /// **'Будет рассчитано Системой'**
  String get commonCalculatedBySystem;

  /// No description provided for @onbIntroLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get onbIntroLabel;

  /// No description provided for @onbIntroTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вы получили право стать Игроком'**
  String get onbIntroTitle;

  /// No description provided for @onbIntroMessage.
  ///
  /// In ru, this message translates to:
  /// **'Система соберёт сведения о вас, чтобы составить план. Ответы сохраняются сразу — можно прерваться и продолжить позже. Любой раздел можно изменить в настройках.'**
  String get onbIntroMessage;

  /// No description provided for @onbIntroAccept.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get onbIntroAccept;

  /// No description provided for @onbStepCounter.
  ///
  /// In ru, this message translates to:
  /// **'Этап {current}/{total}'**
  String onbStepCounter(int current, int total);

  /// No description provided for @onbFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить'**
  String get onbFinish;

  /// No description provided for @onbStepProfile.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get onbStepProfile;

  /// No description provided for @onbStepBody.
  ///
  /// In ru, this message translates to:
  /// **'Тело'**
  String get onbStepBody;

  /// No description provided for @onbStepBodyPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото тела'**
  String get onbStepBodyPhotos;

  /// No description provided for @onbStepSkin.
  ///
  /// In ru, this message translates to:
  /// **'Кожа'**
  String get onbStepSkin;

  /// No description provided for @onbStepHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get onbStepHealth;

  /// No description provided for @onbStepGoals.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get onbStepGoals;

  /// No description provided for @onbStepSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get onbStepSchedule;

  /// No description provided for @onbStepNutrition.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get onbStepNutrition;

  /// No description provided for @onbStepTraining.
  ///
  /// In ru, this message translates to:
  /// **'Тренировки'**
  String get onbStepTraining;

  /// No description provided for @onbStepFinance.
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get onbStepFinance;

  /// No description provided for @onbStepCharacter.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж и голос'**
  String get onbStepCharacter;

  /// No description provided for @onbStepPermissions.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения'**
  String get onbStepPermissions;

  /// No description provided for @hqStatStrengthShort.
  ///
  /// In ru, this message translates to:
  /// **'СИЛ'**
  String get hqStatStrengthShort;

  /// No description provided for @hqStatEnduranceShort.
  ///
  /// In ru, this message translates to:
  /// **'ВЫН'**
  String get hqStatEnduranceShort;

  /// No description provided for @hqStatDisciplineShort.
  ///
  /// In ru, this message translates to:
  /// **'ДИС'**
  String get hqStatDisciplineShort;

  /// No description provided for @hqStatIntellectShort.
  ///
  /// In ru, this message translates to:
  /// **'ИНТ'**
  String get hqStatIntellectShort;

  /// No description provided for @hqStatHealthShort.
  ///
  /// In ru, this message translates to:
  /// **'ЗДР'**
  String get hqStatHealthShort;

  /// No description provided for @hqStatLooksShort.
  ///
  /// In ru, this message translates to:
  /// **'ВНШ'**
  String get hqStatLooksShort;

  /// No description provided for @hqCaloriesTodayTitle.
  ///
  /// In ru, this message translates to:
  /// **'Калории за день'**
  String get hqCaloriesTodayTitle;

  /// No description provided for @hqNutritionDiaryTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дневник питания'**
  String get hqNutritionDiaryTitle;

  /// No description provided for @hqNutritionDiarySoon.
  ///
  /// In ru, this message translates to:
  /// **'Дневник питания, фото еды и подсчёт БЖУ Система откроет на следующем этапе.'**
  String get hqNutritionDiarySoon;

  /// No description provided for @hqFinanceFoodTitle.
  ///
  /// In ru, this message translates to:
  /// **'Финансы на еду'**
  String get hqFinanceFoodTitle;

  /// No description provided for @ntfQuestTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Квест ] {title}'**
  String ntfQuestTitle(String title);

  /// No description provided for @ntfPenaltyQuestTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Штрафной квест ] {title}'**
  String ntfPenaltyQuestTitle(String title);

  /// No description provided for @ntfBossTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Босс недели ] {title}'**
  String ntfBossTitle(String title);

  /// No description provided for @ntfQuestBody.
  ///
  /// In ru, this message translates to:
  /// **'Срок — до {time}. Награда: +{diamonds} ◆'**
  String ntfQuestBody(String time, int diamonds);

  /// No description provided for @ntfQuestBodyNoReward.
  ///
  /// In ru, this message translates to:
  /// **'Срок — до {time}.'**
  String ntfQuestBodyNoReward(String time);

  /// No description provided for @ntfPenaltyQuestBody.
  ///
  /// In ru, this message translates to:
  /// **'Срок — до {time}. Отказ невозможен.'**
  String ntfPenaltyQuestBody(String time);

  /// No description provided for @ntfReproachTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Система ] Квест не выполнен'**
  String get ntfReproachTitle;

  /// No description provided for @ntfReproachBody.
  ///
  /// In ru, this message translates to:
  /// **'«{title}» просрочен. Система фиксирует бездействие. Выполни сейчас.'**
  String ntfReproachBody(String title);

  /// No description provided for @ntfActionDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get ntfActionDone;

  /// No description provided for @ntfActionSnooze.
  ///
  /// In ru, this message translates to:
  /// **'+10 мин'**
  String get ntfActionSnooze;

  /// No description provided for @ntfChannelQuests.
  ///
  /// In ru, this message translates to:
  /// **'Квесты'**
  String get ntfChannelQuests;

  /// No description provided for @ntfChannelQuestsDesc.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о квестах, упрёки и сообщения Системы'**
  String get ntfChannelQuestsDesc;

  /// No description provided for @ntfChannelNag.
  ///
  /// In ru, this message translates to:
  /// **'Надоедать'**
  String get ntfChannelNag;

  /// No description provided for @ntfChannelNagDesc.
  ///
  /// In ru, this message translates to:
  /// **'Повтор каждую минуту, пока квест не выполнен'**
  String get ntfChannelNagDesc;

  /// No description provided for @ntfFailedTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Система ] Квест провален'**
  String get ntfFailedTitle;

  /// No description provided for @ntfFailedBody.
  ///
  /// In ru, this message translates to:
  /// **'«{title}»: −{diamonds} ◆'**
  String ntfFailedBody(String title, int diamonds);

  /// No description provided for @ntfPenaltyTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Штраф ] −{diamonds} ◆'**
  String ntfPenaltyTitle(int diamonds);

  /// No description provided for @ntfLevelUpTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Система ] Уровень повышен'**
  String get ntfLevelUpTitle;

  /// No description provided for @ntfLevelUpBody.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}. Свободных очков: {points}'**
  String ntfLevelUpBody(int level, int points);

  /// No description provided for @ntfTestTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Система ] Проверка связи'**
  String get ntfTestTitle;

  /// No description provided for @ntfTestBody.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления работают. Игрок, жди приказов.'**
  String get ntfTestBody;

  /// No description provided for @ntfTestSent.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление отправлено'**
  String get ntfTestSent;

  /// No description provided for @ntfSectionGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Основное'**
  String get ntfSectionGeneral;

  /// No description provided for @ntfEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get ntfEnabled;

  /// No description provided for @ntfEnabledHint.
  ///
  /// In ru, this message translates to:
  /// **'Локальные уведомления о квестах'**
  String get ntfEnabledHint;

  /// No description provided for @ntfNag.
  ///
  /// In ru, this message translates to:
  /// **'Надоедать каждую минуту'**
  String get ntfNag;

  /// No description provided for @ntfNagHint.
  ///
  /// In ru, this message translates to:
  /// **'Повтор, пока не нажмёте «Выполнено»'**
  String get ntfNagHint;

  /// No description provided for @ntfReproach.
  ///
  /// In ru, this message translates to:
  /// **'Упрёки'**
  String get ntfReproach;

  /// No description provided for @ntfReproachHint.
  ///
  /// In ru, this message translates to:
  /// **'Через 15 мин после срока, если квест не выполнен'**
  String get ntfReproachHint;

  /// No description provided for @ntfVoice.
  ///
  /// In ru, this message translates to:
  /// **'Голос персонажа как звук'**
  String get ntfVoice;

  /// No description provided for @ntfVoiceHint.
  ///
  /// In ru, this message translates to:
  /// **'Будет на этапе 6 — пока стандартный звук'**
  String get ntfVoiceHint;

  /// No description provided for @ntfSectionQuiet.
  ///
  /// In ru, this message translates to:
  /// **'Тихие часы'**
  String get ntfSectionQuiet;

  /// No description provided for @ntfQuietEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Не беспокоить'**
  String get ntfQuietEnabled;

  /// No description provided for @ntfQuietHint.
  ///
  /// In ru, this message translates to:
  /// **'В это время ничего не звенит, упрёк придёт после окончания'**
  String get ntfQuietHint;

  /// No description provided for @ntfQuietFrom.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get ntfQuietFrom;

  /// No description provided for @ntfQuietTo.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get ntfQuietTo;

  /// No description provided for @ntfSectionPermission.
  ///
  /// In ru, this message translates to:
  /// **'Разрешение'**
  String get ntfSectionPermission;

  /// No description provided for @ntfPermGranted.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления разрешены'**
  String get ntfPermGranted;

  /// No description provided for @ntfPermDenied.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления запрещены — квесты не смогут напомнить о себе'**
  String get ntfPermDenied;

  /// No description provided for @ntfPermUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Статус разрешения неизвестен'**
  String get ntfPermUnknown;

  /// No description provided for @ntfPermExactOff.
  ///
  /// In ru, this message translates to:
  /// **'Точные будильники выключены — напоминания могут опаздывать'**
  String get ntfPermExactOff;

  /// No description provided for @ntfPermRequest.
  ///
  /// In ru, this message translates to:
  /// **'Запросить разрешение'**
  String get ntfPermRequest;

  /// No description provided for @ntfTest.
  ///
  /// In ru, this message translates to:
  /// **'Проверить уведомление'**
  String get ntfTest;

  /// No description provided for @ntfUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления недоступны на этой платформе'**
  String get ntfUnavailable;

  /// No description provided for @planNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get planNoticeLabel;

  /// No description provided for @planTitle.
  ///
  /// In ru, this message translates to:
  /// **'План составлен'**
  String get planTitle;

  /// No description provided for @planDraftNote.
  ///
  /// In ru, this message translates to:
  /// **'Черновой план — Система уточнит его после подключения ИИ.'**
  String get planDraftNote;

  /// No description provided for @planAcceptedAt.
  ///
  /// In ru, this message translates to:
  /// **'План принят {date}'**
  String planAcceptedAt(String date);

  /// No description provided for @planAccept.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get planAccept;

  /// No description provided for @planEditData.
  ///
  /// In ru, this message translates to:
  /// **'Изменить данные'**
  String get planEditData;

  /// No description provided for @planRecalculate.
  ///
  /// In ru, this message translates to:
  /// **'Пересчитать'**
  String get planRecalculate;

  /// No description provided for @planChooseSection.
  ///
  /// In ru, this message translates to:
  /// **'Какой раздел изменить?'**
  String get planChooseSection;

  /// No description provided for @planLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось составить план'**
  String get planLoadError;

  /// No description provided for @planRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get planRetry;

  /// No description provided for @planNormsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Нормы'**
  String get planNormsTitle;

  /// No description provided for @planCalories.
  ///
  /// In ru, this message translates to:
  /// **'Калории'**
  String get planCalories;

  /// No description provided for @planKcal.
  ///
  /// In ru, this message translates to:
  /// **'{value} ккал'**
  String planKcal(String value);

  /// No description provided for @planModeDeficit.
  ///
  /// In ru, this message translates to:
  /// **'Дефицит'**
  String get planModeDeficit;

  /// No description provided for @planModeSurplus.
  ///
  /// In ru, this message translates to:
  /// **'Профицит'**
  String get planModeSurplus;

  /// No description provided for @planModeMaintenance.
  ///
  /// In ru, this message translates to:
  /// **'Поддержание'**
  String get planModeMaintenance;

  /// No description provided for @planBmrTdee.
  ///
  /// In ru, this message translates to:
  /// **'Базовый обмен {bmr} · расход {tdee} ккал'**
  String planBmrTdee(String bmr, String tdee);

  /// No description provided for @planProtein.
  ///
  /// In ru, this message translates to:
  /// **'Белки'**
  String get planProtein;

  /// No description provided for @planFat.
  ///
  /// In ru, this message translates to:
  /// **'Жиры'**
  String get planFat;

  /// No description provided for @planCarbs.
  ///
  /// In ru, this message translates to:
  /// **'Углеводы'**
  String get planCarbs;

  /// No description provided for @planGrams.
  ///
  /// In ru, this message translates to:
  /// **'{value} г'**
  String planGrams(String value);

  /// No description provided for @planWater.
  ///
  /// In ru, this message translates to:
  /// **'Вода'**
  String get planWater;

  /// No description provided for @planMl.
  ///
  /// In ru, this message translates to:
  /// **'{value} мл'**
  String planMl(String value);

  /// No description provided for @planWaterTrainingDay.
  ///
  /// In ru, this message translates to:
  /// **'В день тренировки — {value} мл'**
  String planWaterTrainingDay(String value);

  /// No description provided for @planSleep.
  ///
  /// In ru, this message translates to:
  /// **'Сон'**
  String get planSleep;

  /// No description provided for @planHours.
  ///
  /// In ru, this message translates to:
  /// **'{value} ч'**
  String planHours(String value);

  /// No description provided for @planHoursMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{h} ч {m} мин'**
  String planHoursMinutes(String h, String m);

  /// No description provided for @planWakeBed.
  ///
  /// In ru, this message translates to:
  /// **'Подъём {wake} · отбой {bed}'**
  String planWakeBed(String wake, String bed);

  /// No description provided for @planRoutineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Распорядок дня'**
  String get planRoutineTitle;

  /// No description provided for @planWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя {n}'**
  String planWeek(String n);

  /// No description provided for @planWdMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get planWdMon;

  /// No description provided for @planWdTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get planWdTue;

  /// No description provided for @planWdWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get planWdWed;

  /// No description provided for @planWdThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get planWdThu;

  /// No description provided for @planWdFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get planWdFri;

  /// No description provided for @planWdSat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get planWdSat;

  /// No description provided for @planWdSun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get planWdSun;

  /// No description provided for @planRoutineWake.
  ///
  /// In ru, this message translates to:
  /// **'Подъём'**
  String get planRoutineWake;

  /// No description provided for @planRoutineSkincareAm.
  ///
  /// In ru, this message translates to:
  /// **'Уход за кожей (утро)'**
  String get planRoutineSkincareAm;

  /// No description provided for @planRoutineMeal.
  ///
  /// In ru, this message translates to:
  /// **'Приём пищи {n}'**
  String planRoutineMeal(String n);

  /// No description provided for @planRoutineLeaveHome.
  ///
  /// In ru, this message translates to:
  /// **'Выход из дома'**
  String get planRoutineLeaveHome;

  /// No description provided for @planRoutineLesson.
  ///
  /// In ru, this message translates to:
  /// **'Пара'**
  String get planRoutineLesson;

  /// No description provided for @planRoutineWork.
  ///
  /// In ru, this message translates to:
  /// **'Работа'**
  String get planRoutineWork;

  /// No description provided for @planRoutineOther.
  ///
  /// In ru, this message translates to:
  /// **'Дело'**
  String get planRoutineOther;

  /// No description provided for @planRoutineReturnHome.
  ///
  /// In ru, this message translates to:
  /// **'Дома'**
  String get planRoutineReturnHome;

  /// No description provided for @planRoutineTraining.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка'**
  String get planRoutineTraining;

  /// No description provided for @planRoutineSkincarePm.
  ///
  /// In ru, this message translates to:
  /// **'Уход за кожей (вечер)'**
  String get planRoutineSkincarePm;

  /// No description provided for @planRoutineBed.
  ///
  /// In ru, this message translates to:
  /// **'Отбой'**
  String get planRoutineBed;

  /// No description provided for @planQuestsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Квесты'**
  String get planQuestsTitle;

  /// No description provided for @planQuestsNote.
  ///
  /// In ru, this message translates to:
  /// **'Выполнение квестов появится в следующем обновлении.'**
  String get planQuestsNote;

  /// No description provided for @planQuestLeaveHome.
  ///
  /// In ru, this message translates to:
  /// **'Выйти из дома к {time}'**
  String planQuestLeaveHome(String time);

  /// No description provided for @planQuestAttendLesson.
  ///
  /// In ru, this message translates to:
  /// **'Пара: {title}'**
  String planQuestAttendLesson(String title);

  /// No description provided for @planQuestAttendWork.
  ///
  /// In ru, this message translates to:
  /// **'Работа: {title}'**
  String planQuestAttendWork(String title);

  /// No description provided for @planQuestWater.
  ///
  /// In ru, this message translates to:
  /// **'Выпить {ml} мл воды'**
  String planQuestWater(String ml);

  /// No description provided for @planQuestSleep.
  ///
  /// In ru, this message translates to:
  /// **'Лечь спать в {time} (сон {hours} ч)'**
  String planQuestSleep(String time, String hours);

  /// No description provided for @planQuestMeals.
  ///
  /// In ru, this message translates to:
  /// **'Приёмы пищи по плану: {count}'**
  String planQuestMeals(String count);

  /// No description provided for @planQuestTraining.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка {minutes} мин'**
  String planQuestTraining(String minutes);

  /// No description provided for @planQuestSkincareMorning.
  ///
  /// In ru, this message translates to:
  /// **'Утренний уход за кожей'**
  String get planQuestSkincareMorning;

  /// No description provided for @planQuestSkincareEvening.
  ///
  /// In ru, this message translates to:
  /// **'Вечерний уход за кожей'**
  String get planQuestSkincareEvening;

  /// No description provided for @planQuestWakeOnTime.
  ///
  /// In ru, this message translates to:
  /// **'Подъём в {time} без отсрочек'**
  String planQuestWakeOnTime(String time);

  /// No description provided for @planQuestStudy.
  ///
  /// In ru, this message translates to:
  /// **'Учёба {minutes} мин'**
  String planQuestStudy(String minutes);

  /// No description provided for @planQuestTrackExpenses.
  ///
  /// In ru, this message translates to:
  /// **'Записать траты за день'**
  String get planQuestTrackExpenses;

  /// No description provided for @planQuestEveryDay.
  ///
  /// In ru, this message translates to:
  /// **'каждый день'**
  String get planQuestEveryDay;

  /// No description provided for @planQuestWeekOnly.
  ///
  /// In ru, this message translates to:
  /// **'неделя {n}'**
  String planQuestWeekOnly(String n);

  /// No description provided for @planQuestReward.
  ///
  /// In ru, this message translates to:
  /// **'+{diamonds} ◆ · +{xp} опыта'**
  String planQuestReward(String diamonds, String xp);

  /// No description provided for @planWarningsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждения'**
  String get planWarningsTitle;

  /// No description provided for @planWarnSleepShort.
  ///
  /// In ru, this message translates to:
  /// **'По расписанию сна {scheduled} — меньше нормы {target}. Рекомендуемый отбой — {bed}.'**
  String planWarnSleepShort(String scheduled, String target, String bed);

  /// No description provided for @planWarnDeficitFloor.
  ///
  /// In ru, this message translates to:
  /// **'Дефицит калорий ограничен безопасным минимумом — ниже Система не урезает.'**
  String get planWarnDeficitFloor;

  /// No description provided for @planWarnActivityDefaulted.
  ///
  /// In ru, this message translates to:
  /// **'Уровень активности не указан — взят «сидячий».'**
  String get planWarnActivityDefaulted;

  /// No description provided for @planWarnNoTrainingWindow.
  ///
  /// In ru, this message translates to:
  /// **'{day}: нет свободного окна для тренировки.'**
  String planWarnNoTrainingWindow(String day);

  /// No description provided for @planWarnInjuries.
  ///
  /// In ru, this message translates to:
  /// **'Указаны травмы или ограничения — нагрузку подбирайте осторожно, при сомнениях посоветуйтесь с врачом.'**
  String get planWarnInjuries;

  /// No description provided for @planMissingMessage.
  ///
  /// In ru, this message translates to:
  /// **'Для расчёта калорий и БЖУ заполните: {fields}.'**
  String planMissingMessage(String fields);

  /// No description provided for @planMissingSex.
  ///
  /// In ru, this message translates to:
  /// **'пол'**
  String get planMissingSex;

  /// No description provided for @planMissingBirthDate.
  ///
  /// In ru, this message translates to:
  /// **'дата рождения'**
  String get planMissingBirthDate;

  /// No description provided for @planMissingHeight.
  ///
  /// In ru, this message translates to:
  /// **'рост'**
  String get planMissingHeight;

  /// No description provided for @planMissingWeight.
  ///
  /// In ru, this message translates to:
  /// **'вес'**
  String get planMissingWeight;

  /// No description provided for @planFillSection.
  ///
  /// In ru, this message translates to:
  /// **'Заполнить: {section}'**
  String planFillSection(String section);

  /// No description provided for @qaUnitCm.
  ///
  /// In ru, this message translates to:
  /// **'см'**
  String get qaUnitCm;

  /// No description provided for @qaUnitKg.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get qaUnitKg;

  /// No description provided for @qaRangeHint.
  ///
  /// In ru, this message translates to:
  /// **'Допустимо от {min} до {max}'**
  String qaRangeHint(int min, int max);

  /// No description provided for @qaProfileIntro.
  ///
  /// In ru, this message translates to:
  /// **'Система должна знать, как к вам обращаться и где вы находитесь.'**
  String get qaProfileIntro;

  /// No description provided for @qaProfileName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get qaProfileName;

  /// No description provided for @qaProfileNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Как к вам обращаться'**
  String get qaProfileNameHint;

  /// No description provided for @qaProfileLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get qaProfileLanguage;

  /// No description provided for @qaLangRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get qaLangRu;

  /// No description provided for @qaLangTr.
  ///
  /// In ru, this message translates to:
  /// **'Türkçe'**
  String get qaLangTr;

  /// No description provided for @qaLangSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get qaLangSystem;

  /// No description provided for @qaProfileSex.
  ///
  /// In ru, this message translates to:
  /// **'Пол'**
  String get qaProfileSex;

  /// No description provided for @qaSexMale.
  ///
  /// In ru, this message translates to:
  /// **'Мужской'**
  String get qaSexMale;

  /// No description provided for @qaSexFemale.
  ///
  /// In ru, this message translates to:
  /// **'Женский'**
  String get qaSexFemale;

  /// No description provided for @qaProfileBirthDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата рождения'**
  String get qaProfileBirthDate;

  /// No description provided for @qaProfileTimezone.
  ///
  /// In ru, this message translates to:
  /// **'Часовой пояс'**
  String get qaProfileTimezone;

  /// No description provided for @qaProfileTimezoneHint.
  ///
  /// In ru, this message translates to:
  /// **'Определён по устройству — проверьте'**
  String get qaProfileTimezoneHint;

  /// No description provided for @qaProfileCity.
  ///
  /// In ru, this message translates to:
  /// **'Город'**
  String get qaProfileCity;

  /// No description provided for @qaProfileCityHint.
  ///
  /// In ru, this message translates to:
  /// **'Для погоды и магазинов рядом'**
  String get qaProfileCityHint;

  /// No description provided for @qaBodyIntro.
  ///
  /// In ru, this message translates to:
  /// **'Исходные параметры тела. По ним Система рассчитает нормы калорий и воды.'**
  String get qaBodyIntro;

  /// No description provided for @qaBodyHeight.
  ///
  /// In ru, this message translates to:
  /// **'Рост'**
  String get qaBodyHeight;

  /// No description provided for @qaBodyWeight.
  ///
  /// In ru, this message translates to:
  /// **'Вес'**
  String get qaBodyWeight;

  /// No description provided for @qaBodyGirths.
  ///
  /// In ru, this message translates to:
  /// **'Обхваты'**
  String get qaBodyGirths;

  /// No description provided for @qaBodyGirthsHint.
  ///
  /// In ru, this message translates to:
  /// **'Измерьте сантиметровой лентой утром, без одежды. Можно пропустить.'**
  String get qaBodyGirthsHint;

  /// No description provided for @qaBodyWaist.
  ///
  /// In ru, this message translates to:
  /// **'Талия'**
  String get qaBodyWaist;

  /// No description provided for @qaBodyHips.
  ///
  /// In ru, this message translates to:
  /// **'Бёдра'**
  String get qaBodyHips;

  /// No description provided for @qaBodyChest.
  ///
  /// In ru, this message translates to:
  /// **'Грудь'**
  String get qaBodyChest;

  /// No description provided for @qaBodyNeck.
  ///
  /// In ru, this message translates to:
  /// **'Шея'**
  String get qaBodyNeck;

  /// No description provided for @qaBodyArm.
  ///
  /// In ru, this message translates to:
  /// **'Рука (бицепс)'**
  String get qaBodyArm;

  /// No description provided for @qaBodyActivity.
  ///
  /// In ru, this message translates to:
  /// **'Уровень активности'**
  String get qaBodyActivity;

  /// No description provided for @qaActivitySedentary.
  ///
  /// In ru, this message translates to:
  /// **'Минимальный'**
  String get qaActivitySedentary;

  /// No description provided for @qaActivitySedentaryHint.
  ///
  /// In ru, this message translates to:
  /// **'Почти весь день сидя, тренировок нет'**
  String get qaActivitySedentaryHint;

  /// No description provided for @qaActivityLight.
  ///
  /// In ru, this message translates to:
  /// **'Низкий'**
  String get qaActivityLight;

  /// No description provided for @qaActivityLightHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёгкие тренировки или прогулки 1–3 раза в неделю'**
  String get qaActivityLightHint;

  /// No description provided for @qaActivityModerate.
  ///
  /// In ru, this message translates to:
  /// **'Средний'**
  String get qaActivityModerate;

  /// No description provided for @qaActivityModerateHint.
  ///
  /// In ru, this message translates to:
  /// **'Тренировки 3–5 раз в неделю'**
  String get qaActivityModerateHint;

  /// No description provided for @qaActivityActive.
  ///
  /// In ru, this message translates to:
  /// **'Высокий'**
  String get qaActivityActive;

  /// No description provided for @qaActivityActiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Интенсивные тренировки 6–7 раз в неделю'**
  String get qaActivityActiveHint;

  /// No description provided for @qaActivityVeryActive.
  ///
  /// In ru, this message translates to:
  /// **'Очень высокий'**
  String get qaActivityVeryActive;

  /// No description provided for @qaActivityVeryActiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Тяжёлый физический труд или по две тренировки в день'**
  String get qaActivityVeryActiveHint;

  /// No description provided for @qaBodyWorkload.
  ///
  /// In ru, this message translates to:
  /// **'Нагрузка на учёбе / работе'**
  String get qaBodyWorkload;

  /// No description provided for @qaBodyWorkloadHint.
  ///
  /// In ru, this message translates to:
  /// **'Как вы проводите основную часть дня'**
  String get qaBodyWorkloadHint;

  /// No description provided for @qaWorkloadSitting.
  ///
  /// In ru, this message translates to:
  /// **'Сидячая'**
  String get qaWorkloadSitting;

  /// No description provided for @qaWorkloadMixed.
  ///
  /// In ru, this message translates to:
  /// **'Смешанная'**
  String get qaWorkloadMixed;

  /// No description provided for @qaWorkloadStanding.
  ///
  /// In ru, this message translates to:
  /// **'На ногах'**
  String get qaWorkloadStanding;

  /// No description provided for @qaWorkloadPhysical.
  ///
  /// In ru, this message translates to:
  /// **'Физический труд'**
  String get qaWorkloadPhysical;

  /// No description provided for @qaBodyPhotosIntro.
  ///
  /// In ru, this message translates to:
  /// **'Фото помогут Системе оценить состав тела и осанку и отслеживать прогресс. Этап можно пропустить. Снимки хранятся на устройстве.'**
  String get qaBodyPhotosIntro;

  /// No description provided for @qaPhotoTipsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как снимать'**
  String get qaPhotoTipsTitle;

  /// No description provided for @qaBodyTipLight.
  ///
  /// In ru, this message translates to:
  /// **'Ровный свет спереди, без яркого окна за спиной.'**
  String get qaBodyTipLight;

  /// No description provided for @qaBodyTipClothes.
  ///
  /// In ru, this message translates to:
  /// **'Облегающая одежда или бельё, волосы убраны.'**
  String get qaBodyTipClothes;

  /// No description provided for @qaBodyTipPose.
  ///
  /// In ru, this message translates to:
  /// **'Стойте прямо, руки чуть в стороны, смотрите вперёд. Тело — внутри контура.'**
  String get qaBodyTipPose;

  /// No description provided for @qaBodyTipCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера на уровне пояса, примерно в 2 метрах. Удобнее со штативом или с помощником.'**
  String get qaBodyTipCamera;

  /// No description provided for @qaPoseBodyFront.
  ///
  /// In ru, this message translates to:
  /// **'Спереди'**
  String get qaPoseBodyFront;

  /// No description provided for @qaPoseBodyFrontHint.
  ///
  /// In ru, this message translates to:
  /// **'Встаньте лицом к камере, руки немного в стороны, ноги на ширине плеч.'**
  String get qaPoseBodyFrontHint;

  /// No description provided for @qaPoseBodySide.
  ///
  /// In ru, this message translates to:
  /// **'Сбоку'**
  String get qaPoseBodySide;

  /// No description provided for @qaPoseBodySideHint.
  ///
  /// In ru, this message translates to:
  /// **'Повернитесь к камере правым боком, руки вдоль тела, смотрите прямо.'**
  String get qaPoseBodySideHint;

  /// No description provided for @qaPoseBodyBack.
  ///
  /// In ru, this message translates to:
  /// **'Сзади'**
  String get qaPoseBodyBack;

  /// No description provided for @qaPoseBodyBackHint.
  ///
  /// In ru, this message translates to:
  /// **'Встаньте спиной к камере, руки немного в стороны.'**
  String get qaPoseBodyBackHint;

  /// No description provided for @qaPhotoTap.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите, чтобы снять'**
  String get qaPhotoTap;

  /// No description provided for @qaPhotoTaken.
  ///
  /// In ru, this message translates to:
  /// **'Снято'**
  String get qaPhotoTaken;

  /// No description provided for @qaPhotoNotTaken.
  ///
  /// In ru, this message translates to:
  /// **'Нет фото'**
  String get qaPhotoNotTaken;

  /// No description provided for @qaPhotoRetakeHint.
  ///
  /// In ru, this message translates to:
  /// **'Снято · нажмите, чтобы переснять'**
  String get qaPhotoRetakeHint;

  /// No description provided for @qaEstimateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Оценка'**
  String get qaEstimateTitle;

  /// No description provided for @qaEstBodyFat.
  ///
  /// In ru, this message translates to:
  /// **'% жира'**
  String get qaEstBodyFat;

  /// No description provided for @qaEstMuscle.
  ///
  /// In ru, this message translates to:
  /// **'Мышечная масса'**
  String get qaEstMuscle;

  /// No description provided for @qaEstPosture.
  ///
  /// In ru, this message translates to:
  /// **'Осанка'**
  String get qaEstPosture;

  /// No description provided for @qaEstFigure.
  ///
  /// In ru, this message translates to:
  /// **'Тип фигуры'**
  String get qaEstFigure;

  /// No description provided for @qaEstFaceSwelling.
  ///
  /// In ru, this message translates to:
  /// **'Отёчность лица'**
  String get qaEstFaceSwelling;

  /// No description provided for @qaExactTitle.
  ///
  /// In ru, this message translates to:
  /// **'Знаю точные цифры'**
  String get qaExactTitle;

  /// No description provided for @qaExactHint.
  ///
  /// In ru, this message translates to:
  /// **'Если есть данные с умных весов или от врача — укажите их, Система будет опираться на них.'**
  String get qaExactHint;

  /// No description provided for @qaExactFat.
  ///
  /// In ru, this message translates to:
  /// **'% жира'**
  String get qaExactFat;

  /// No description provided for @qaExactMuscle.
  ///
  /// In ru, this message translates to:
  /// **'Мышечная масса'**
  String get qaExactMuscle;

  /// No description provided for @qaCameraWarningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get qaCameraWarningLabel;

  /// No description provided for @qaCameraUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна на этом устройстве. Этап можно пропустить и вернуться к нему позже в настройках.'**
  String get qaCameraUnavailable;

  /// No description provided for @qaCameraUnavailableInline.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна — фото можно сделать позже в настройках. Остальные поля работают.'**
  String get qaCameraUnavailableInline;

  /// No description provided for @qaCameraDenied.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к камере. Разрешите доступ в настройках, затем вернитесь сюда.'**
  String get qaCameraDenied;

  /// No description provided for @qaCameraOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get qaCameraOpenSettings;

  /// No description provided for @qaCameraRetake.
  ///
  /// In ru, this message translates to:
  /// **'Переснять'**
  String get qaCameraRetake;

  /// No description provided for @qaCameraShutter.
  ///
  /// In ru, this message translates to:
  /// **'Сделать снимок'**
  String get qaCameraShutter;

  /// No description provided for @qaCameraSwitch.
  ///
  /// In ru, this message translates to:
  /// **'Сменить камеру'**
  String get qaCameraSwitch;

  /// No description provided for @qaSkinIntro.
  ///
  /// In ru, this message translates to:
  /// **'Фото лица и несколько вопросов помогут Системе подобрать уход. Фото необязательны.'**
  String get qaSkinIntro;

  /// No description provided for @qaSkinTipLight.
  ///
  /// In ru, this message translates to:
  /// **'Дневной свет у окна, без фильтров и вспышки.'**
  String get qaSkinTipLight;

  /// No description provided for @qaSkinTipClean.
  ///
  /// In ru, this message translates to:
  /// **'Чистое лицо без макияжа и крема.'**
  String get qaSkinTipClean;

  /// No description provided for @qaSkinTipHair.
  ///
  /// In ru, this message translates to:
  /// **'Уберите волосы со лба и щёк.'**
  String get qaSkinTipHair;

  /// No description provided for @qaSkinFacePhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото лица'**
  String get qaSkinFacePhotos;

  /// No description provided for @qaPoseFaceFront.
  ///
  /// In ru, this message translates to:
  /// **'Анфас'**
  String get qaPoseFaceFront;

  /// No description provided for @qaPoseFaceFrontHint.
  ///
  /// In ru, this message translates to:
  /// **'Смотрите прямо в камеру, лицо — внутри овала.'**
  String get qaPoseFaceFrontHint;

  /// No description provided for @qaPoseFaceLeft.
  ///
  /// In ru, this message translates to:
  /// **'Профиль слева'**
  String get qaPoseFaceLeft;

  /// No description provided for @qaPoseFaceLeftHint.
  ///
  /// In ru, this message translates to:
  /// **'Повернитесь так, чтобы к камере была ЛЕВАЯ щека.'**
  String get qaPoseFaceLeftHint;

  /// No description provided for @qaPoseFaceRight.
  ///
  /// In ru, this message translates to:
  /// **'Профиль справа'**
  String get qaPoseFaceRight;

  /// No description provided for @qaPoseFaceRightHint.
  ///
  /// In ru, this message translates to:
  /// **'Повернитесь так, чтобы к камере была ПРАВАЯ щека.'**
  String get qaPoseFaceRightHint;

  /// No description provided for @qaSkinCloseups.
  ///
  /// In ru, this message translates to:
  /// **'Проблемные зоны крупно'**
  String get qaSkinCloseups;

  /// No description provided for @qaSkinCloseupsHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно несколько снимков'**
  String get qaSkinCloseupsHint;

  /// No description provided for @qaPoseCloseup.
  ///
  /// In ru, this message translates to:
  /// **'Крупный план'**
  String get qaPoseCloseup;

  /// No description provided for @qaPoseCloseupHint.
  ///
  /// In ru, this message translates to:
  /// **'Поднесите камеру близко к зоне, дождитесь фокуса.'**
  String get qaPoseCloseupHint;

  /// No description provided for @qaSkinAddCloseup.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get qaSkinAddCloseup;

  /// No description provided for @qaShootTitleBody.
  ///
  /// In ru, this message translates to:
  /// **'Фото-сессия: тело'**
  String get qaShootTitleBody;

  /// No description provided for @qaShootTitleFace.
  ///
  /// In ru, this message translates to:
  /// **'Фото-сессия: лицо'**
  String get qaShootTitleFace;

  /// No description provided for @qaShootCardBody.
  ///
  /// In ru, this message translates to:
  /// **'Фото-сессия: тело (3 ракурса)'**
  String get qaShootCardBody;

  /// No description provided for @qaShootCardFace.
  ///
  /// In ru, this message translates to:
  /// **'Фото-сессия: лицо (3 ракурса)'**
  String get qaShootCardFace;

  /// No description provided for @qaShootCardHint.
  ///
  /// In ru, this message translates to:
  /// **'Поставьте телефон и нажмите «Начать» — дальше Система всё скажет голосом и сама сделает снимки.'**
  String get qaShootCardHint;

  /// No description provided for @qaShootStartSession.
  ///
  /// In ru, this message translates to:
  /// **'Начать сессию'**
  String get qaShootStartSession;

  /// No description provided for @qaShootRestartSession.
  ///
  /// In ru, this message translates to:
  /// **'Пройти сессию заново'**
  String get qaShootRestartSession;

  /// No description provided for @qaShootCloseupButton.
  ///
  /// In ru, this message translates to:
  /// **'Крупный план проблемной зоны'**
  String get qaShootCloseupButton;

  /// No description provided for @qaShootAiNoteBody.
  ///
  /// In ru, this message translates to:
  /// **'После съёмки ИИ оценит габариты и состав тела с учётом роста и напишет вам.'**
  String get qaShootAiNoteBody;

  /// No description provided for @qaShootAiNoteSkin.
  ///
  /// In ru, this message translates to:
  /// **'После съёмки ИИ оценит тип кожи и выраженность высыпаний и напишет вам.'**
  String get qaShootAiNoteSkin;

  /// No description provided for @qaShootPrepTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подготовка'**
  String get qaShootPrepTitle;

  /// No description provided for @qaShootPrepPhoneBody.
  ///
  /// In ru, this message translates to:
  /// **'Поставьте телефон вертикально на уровне пояса: обоприте о стену, стопку книг или поставьте на штатив. Экран — к себе.'**
  String get qaShootPrepPhoneBody;

  /// No description provided for @qaShootPrepDistanceBody.
  ///
  /// In ru, this message translates to:
  /// **'Вы встанете примерно в 2 метрах. Подойдите или отойдите, чтобы тело совпало с контуром.'**
  String get qaShootPrepDistanceBody;

  /// No description provided for @qaShootPrepPhoneFace.
  ///
  /// In ru, this message translates to:
  /// **'Поставьте телефон вертикально на уровне глаз, примерно в 50 см от лица.'**
  String get qaShootPrepPhoneFace;

  /// No description provided for @qaShootPrepLight.
  ///
  /// In ru, this message translates to:
  /// **'Свет: встаньте лицом к окну или лампе. Яркого окна за спиной быть не должно.'**
  String get qaShootPrepLight;

  /// No description provided for @qaShootPrepSound.
  ///
  /// In ru, this message translates to:
  /// **'Включите звук: Система скажет, куда встать, и сосчитает до снимка. Нажимать ничего не нужно.'**
  String get qaShootPrepSound;

  /// No description provided for @qaShootDelay.
  ///
  /// In ru, this message translates to:
  /// **'Задержка отсчёта'**
  String get qaShootDelay;

  /// No description provided for @qaShootDelaySec.
  ///
  /// In ru, this message translates to:
  /// **'{n} с'**
  String qaShootDelaySec(int n);

  /// No description provided for @qaShootDelayManual.
  ///
  /// In ru, this message translates to:
  /// **'Кнопкой'**
  String get qaShootDelayManual;

  /// No description provided for @qaShootOperator.
  ///
  /// In ru, this message translates to:
  /// **'Снимает другой человек'**
  String get qaShootOperator;

  /// No description provided for @qaShootOperatorHint.
  ///
  /// In ru, this message translates to:
  /// **'Основная камера. Отсчёт можно выключить и снимать кнопкой.'**
  String get qaShootOperatorHint;

  /// No description provided for @qaShootStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать'**
  String get qaShootStart;

  /// No description provided for @qaShootPause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get qaShootPause;

  /// No description provided for @qaShootResume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get qaShootResume;

  /// No description provided for @qaShootPausedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сессия на паузе'**
  String get qaShootPausedTitle;

  /// No description provided for @qaShootPausedHint.
  ///
  /// In ru, this message translates to:
  /// **'Текущий ракурс начнётся заново.'**
  String get qaShootPausedHint;

  /// No description provided for @qaShootStop.
  ///
  /// In ru, this message translates to:
  /// **'Прервать'**
  String get qaShootStop;

  /// No description provided for @qaShootShotOf.
  ///
  /// In ru, this message translates to:
  /// **'Ракурс {n} из {total}'**
  String qaShootShotOf(int n, int total);

  /// No description provided for @qaShootWaitShutter.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите кнопку, когда человек встанет в контур.'**
  String get qaShootWaitShutter;

  /// No description provided for @qaShootRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get qaShootRetry;

  /// No description provided for @qaShootReviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте снимки'**
  String get qaShootReviewTitle;

  /// No description provided for @qaShootReviewHint.
  ///
  /// In ru, this message translates to:
  /// **'Если ракурс не получился — переснимите только его.'**
  String get qaShootReviewHint;

  /// No description provided for @qaShootSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить снимки. Попробуйте ещё раз.'**
  String get qaShootSaveFailed;

  /// No description provided for @qaShootSayBodyFront.
  ///
  /// In ru, this message translates to:
  /// **'Отойди примерно на 2 метра, лицом к камере. Подойди или отступи, чтобы совпасть с контуром. Руки немного в стороны.'**
  String get qaShootSayBodyFront;

  /// No description provided for @qaShootSayBodySide.
  ///
  /// In ru, this message translates to:
  /// **'Повернись к камере правым боком. Руки вдоль тела, смотри прямо.'**
  String get qaShootSayBodySide;

  /// No description provided for @qaShootSayBodyBack.
  ///
  /// In ru, this message translates to:
  /// **'Повернись к камере спиной. Руки немного в стороны.'**
  String get qaShootSayBodyBack;

  /// No description provided for @qaShootSayFaceFront.
  ///
  /// In ru, this message translates to:
  /// **'Сядь примерно в 50 сантиметрах от телефона. Смотри прямо в камеру, лицо — в овале.'**
  String get qaShootSayFaceFront;

  /// No description provided for @qaShootSayFaceLeft.
  ///
  /// In ru, this message translates to:
  /// **'Повернись так, чтобы к камере была левая щека. Голова — в овале, держи её ровно.'**
  String get qaShootSayFaceLeft;

  /// No description provided for @qaShootSayFaceRight.
  ///
  /// In ru, this message translates to:
  /// **'Теперь повернись так, чтобы к камере была правая щека. Голова — в овале.'**
  String get qaShootSayFaceRight;

  /// No description provided for @qaShootTaken.
  ///
  /// In ru, this message translates to:
  /// **'Снимок сделан. Следующий: {next}.'**
  String qaShootTaken(String next);

  /// No description provided for @qaShootTakenLast.
  ///
  /// In ru, this message translates to:
  /// **'Снимок сделан. Съёмка завершена.'**
  String get qaShootTakenLast;

  /// No description provided for @qaShootFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сделать снимок. Попробуй ещё раз.'**
  String get qaShootFailed;

  /// No description provided for @qaBodyGirthsOptionalTitle.
  ///
  /// In ru, this message translates to:
  /// **'Обхваты — если знаете'**
  String get qaBodyGirthsOptionalTitle;

  /// No description provided for @qaBodyGirthsOptionalHint.
  ///
  /// In ru, this message translates to:
  /// **'Необязательно. Если не знаете — Система примерно оценит их по фото с учётом роста и сообщит вам.'**
  String get qaBodyGirthsOptionalHint;

  /// No description provided for @qaBodyGirthsHowTitle.
  ///
  /// In ru, this message translates to:
  /// **'Как мерить'**
  String get qaBodyGirthsHowTitle;

  /// No description provided for @qaBodyGirthsHowGeneral.
  ///
  /// In ru, this message translates to:
  /// **'Сантиметровая лента горизонтально, прилегает, но не сдавливает. Утром, на спокойном выдохе.'**
  String get qaBodyGirthsHowGeneral;

  /// No description provided for @qaBodyWaistHow.
  ///
  /// In ru, this message translates to:
  /// **'Талия — по самому узкому месту, обычно чуть выше пупка.'**
  String get qaBodyWaistHow;

  /// No description provided for @qaBodyHipsHow.
  ///
  /// In ru, this message translates to:
  /// **'Бёдра — по самым выступающим точкам ягодиц, ноги вместе.'**
  String get qaBodyHipsHow;

  /// No description provided for @qaBodyChestHow.
  ///
  /// In ru, this message translates to:
  /// **'Грудь — по самым выступающим точкам, лента проходит под мышками.'**
  String get qaBodyChestHow;

  /// No description provided for @qaBodyNeckHow.
  ///
  /// In ru, this message translates to:
  /// **'Шея — сразу под кадыком.'**
  String get qaBodyNeckHow;

  /// No description provided for @qaBodyArmHow.
  ///
  /// In ru, this message translates to:
  /// **'Рука — по самому широкому месту плеча, рука расслаблена.'**
  String get qaBodyArmHow;

  /// No description provided for @qaSkinOily.
  ///
  /// In ru, this message translates to:
  /// **'Жирность к обеду'**
  String get qaSkinOily;

  /// No description provided for @qaSkinOilyNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get qaSkinOilyNo;

  /// No description provided for @qaSkinOilyTzone.
  ///
  /// In ru, this message translates to:
  /// **'Т-зона'**
  String get qaSkinOilyTzone;

  /// No description provided for @qaSkinOilyAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё лицо'**
  String get qaSkinOilyAll;

  /// No description provided for @qaSkinTightness.
  ///
  /// In ru, this message translates to:
  /// **'Стянутость после умывания'**
  String get qaSkinTightness;

  /// No description provided for @qaSkinTightNever.
  ///
  /// In ru, this message translates to:
  /// **'Никогда'**
  String get qaSkinTightNever;

  /// No description provided for @qaSkinTightSometimes.
  ///
  /// In ru, this message translates to:
  /// **'Иногда'**
  String get qaSkinTightSometimes;

  /// No description provided for @qaSkinTightOften.
  ///
  /// In ru, this message translates to:
  /// **'Часто'**
  String get qaSkinTightOften;

  /// No description provided for @qaSkinReactions.
  ///
  /// In ru, this message translates to:
  /// **'Реакции на средства'**
  String get qaSkinReactions;

  /// No description provided for @qaSkinReactionsHint.
  ///
  /// In ru, this message translates to:
  /// **'Что вызывало покраснение, зуд, высыпания'**
  String get qaSkinReactionsHint;

  /// No description provided for @qaSkinRoutine.
  ///
  /// In ru, this message translates to:
  /// **'Текущий уход'**
  String get qaSkinRoutine;

  /// No description provided for @qaSkinRoutineHint.
  ///
  /// In ru, this message translates to:
  /// **'Чем умываетесь, какие средства используете'**
  String get qaSkinRoutineHint;

  /// No description provided for @qaEstSkinType.
  ///
  /// In ru, this message translates to:
  /// **'Тип кожи'**
  String get qaEstSkinType;

  /// No description provided for @qaEstAcne.
  ///
  /// In ru, this message translates to:
  /// **'Акне'**
  String get qaEstAcne;

  /// No description provided for @qaEstBlackheads.
  ///
  /// In ru, this message translates to:
  /// **'Чёрные точки'**
  String get qaEstBlackheads;

  /// No description provided for @qaEstPostAcne.
  ///
  /// In ru, this message translates to:
  /// **'Постакне'**
  String get qaEstPostAcne;

  /// No description provided for @qaSkinDermTitle.
  ///
  /// In ru, this message translates to:
  /// **'Рекомендация'**
  String get qaSkinDermTitle;

  /// No description provided for @qaSkinDermAdvice.
  ///
  /// In ru, this message translates to:
  /// **'При выраженных воспалениях, болезненных высыпаниях или рубцах покажитесь дерматологу. Система подберёт уход, но не заменяет врача.'**
  String get qaSkinDermAdvice;

  /// No description provided for @qaHealthIntro.
  ///
  /// In ru, this message translates to:
  /// **'Всё необязательно. Ответы нужны, чтобы план был безопасным.'**
  String get qaHealthIntro;

  /// No description provided for @qaHealthChronic.
  ///
  /// In ru, this message translates to:
  /// **'Хронические состояния'**
  String get qaHealthChronic;

  /// No description provided for @qaHealthChronicHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: гастрит, астма'**
  String get qaHealthChronicHint;

  /// No description provided for @qaHealthMedications.
  ///
  /// In ru, this message translates to:
  /// **'Лекарства'**
  String get qaHealthMedications;

  /// No description provided for @qaHealthMedicationsHint.
  ///
  /// In ru, this message translates to:
  /// **'Что принимаете постоянно'**
  String get qaHealthMedicationsHint;

  /// No description provided for @qaHealthAllergies.
  ///
  /// In ru, this message translates to:
  /// **'Аллергии'**
  String get qaHealthAllergies;

  /// No description provided for @qaHealthAllergiesHint.
  ///
  /// In ru, this message translates to:
  /// **'Продукты, лекарства, средства'**
  String get qaHealthAllergiesHint;

  /// No description provided for @qaHealthIntolerances.
  ///
  /// In ru, this message translates to:
  /// **'Непереносимости'**
  String get qaHealthIntolerances;

  /// No description provided for @qaHealthIntolerancesHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: лактоза, глютен'**
  String get qaHealthIntolerancesHint;

  /// No description provided for @qaHealthInjuries.
  ///
  /// In ru, this message translates to:
  /// **'Травмы и ограничения'**
  String get qaHealthInjuries;

  /// No description provided for @qaHealthInjuriesHint.
  ///
  /// In ru, this message translates to:
  /// **'Что нельзя или трудно делать на тренировках'**
  String get qaHealthInjuriesHint;

  /// No description provided for @qaHealthSleep.
  ///
  /// In ru, this message translates to:
  /// **'Качество сна'**
  String get qaHealthSleep;

  /// No description provided for @qaHealthSleepHint.
  ///
  /// In ru, this message translates to:
  /// **'1 — очень плохо, 5 — отлично'**
  String get qaHealthSleepHint;

  /// No description provided for @qaHealthStress.
  ///
  /// In ru, this message translates to:
  /// **'Уровень стресса'**
  String get qaHealthStress;

  /// No description provided for @qaHealthStressHint.
  ///
  /// In ru, this message translates to:
  /// **'1 — почти нет, 5 — очень высокий'**
  String get qaHealthStressHint;

  /// No description provided for @qaGoalsIntro.
  ///
  /// In ru, this message translates to:
  /// **'Чего вы хотите добиться? Система построит квесты вокруг этих целей.'**
  String get qaGoalsIntro;

  /// No description provided for @qaGoalsPick.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get qaGoalsPick;

  /// No description provided for @qaGoalsPickHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать несколько'**
  String get qaGoalsPickHint;

  /// No description provided for @qaGoalAcne.
  ///
  /// In ru, this message translates to:
  /// **'Избавиться от прыщей'**
  String get qaGoalAcne;

  /// No description provided for @qaGoalBlackheads.
  ///
  /// In ru, this message translates to:
  /// **'Убрать чёрные точки'**
  String get qaGoalBlackheads;

  /// No description provided for @qaGoalSwelling.
  ///
  /// In ru, this message translates to:
  /// **'Убрать отёки'**
  String get qaGoalSwelling;

  /// No description provided for @qaGoalWeightLoss.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить лишний вес'**
  String get qaGoalWeightLoss;

  /// No description provided for @qaGoalMuscle.
  ///
  /// In ru, this message translates to:
  /// **'Набрать мышцы'**
  String get qaGoalMuscle;

  /// No description provided for @qaGoalDiscipline.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплина'**
  String get qaGoalDiscipline;

  /// No description provided for @qaGoalStudy.
  ///
  /// In ru, this message translates to:
  /// **'Учёба'**
  String get qaGoalStudy;

  /// No description provided for @qaGoalMoney.
  ///
  /// In ru, this message translates to:
  /// **'Деньги'**
  String get qaGoalMoney;

  /// No description provided for @qaGoalCustom.
  ///
  /// In ru, this message translates to:
  /// **'Своя цель'**
  String get qaGoalCustom;

  /// No description provided for @qaGoalsOwn.
  ///
  /// In ru, this message translates to:
  /// **'Свои цели'**
  String get qaGoalsOwn;

  /// No description provided for @qaGoalsOwnHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: выучить турецкий'**
  String get qaGoalsOwnHint;

  /// No description provided for @qaGoalsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Выберите хотя бы одну цель'**
  String get qaGoalsEmpty;

  /// No description provided for @qaGoalPriority.
  ///
  /// In ru, this message translates to:
  /// **'Приоритет'**
  String get qaGoalPriority;

  /// No description provided for @qaGoalPriorityHigh.
  ///
  /// In ru, this message translates to:
  /// **'Высокий'**
  String get qaGoalPriorityHigh;

  /// No description provided for @qaGoalPriorityMedium.
  ///
  /// In ru, this message translates to:
  /// **'Средний'**
  String get qaGoalPriorityMedium;

  /// No description provided for @qaGoalPriorityLow.
  ///
  /// In ru, this message translates to:
  /// **'Низкий'**
  String get qaGoalPriorityLow;

  /// No description provided for @qaGoalDeadline.
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get qaGoalDeadline;

  /// No description provided for @qaGoalDeadlineClear.
  ///
  /// In ru, this message translates to:
  /// **'Убрать срок'**
  String get qaGoalDeadlineClear;

  /// No description provided for @qaTzCityHint.
  ///
  /// In ru, this message translates to:
  /// **'Часовой пояс подставится по городу'**
  String get qaTzCityHint;

  /// No description provided for @qaTzFromCity.
  ///
  /// In ru, this message translates to:
  /// **'Определён по городу: {city}'**
  String qaTzFromCity(String city);

  /// No description provided for @qaTzFromDevice.
  ///
  /// In ru, this message translates to:
  /// **'Текущий пояс телефона'**
  String get qaTzFromDevice;

  /// No description provided for @qaTzDeviceBadge.
  ///
  /// In ru, this message translates to:
  /// **'сейчас на телефоне'**
  String get qaTzDeviceBadge;

  /// No description provided for @qbScheduleIntro.
  ///
  /// In ru, this message translates to:
  /// **'Система построит день вокруг учёбы, работы и сна. Укажите пары, дорогу, подъём и отбой.'**
  String get qbScheduleIntro;

  /// No description provided for @qbNutritionIntro.
  ///
  /// In ru, this message translates to:
  /// **'Эти данные нужны для норм калорий, меню и списка покупок.'**
  String get qbNutritionIntro;

  /// No description provided for @qbMealsPerDay.
  ///
  /// In ru, this message translates to:
  /// **'Приёмов пищи в день'**
  String get qbMealsPerDay;

  /// No description provided for @qbPreferences.
  ///
  /// In ru, this message translates to:
  /// **'Предпочтения'**
  String get qbPreferences;

  /// No description provided for @qbPreferencesHint.
  ///
  /// In ru, this message translates to:
  /// **'Что любите, какую кухню, режим питания'**
  String get qbPreferencesHint;

  /// No description provided for @qbExcluded.
  ///
  /// In ru, this message translates to:
  /// **'Что не едите'**
  String get qbExcluded;

  /// No description provided for @qbExcludedHint.
  ///
  /// In ru, this message translates to:
  /// **'Продукты, которые исключить из меню'**
  String get qbExcludedHint;

  /// No description provided for @qbFoodBudget.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет на еду'**
  String get qbFoodBudget;

  /// No description provided for @qbRubPerWeek.
  ///
  /// In ru, this message translates to:
  /// **'₽/нед'**
  String get qbRubPerWeek;

  /// No description provided for @qbCanCook.
  ///
  /// In ru, this message translates to:
  /// **'Умеете готовить?'**
  String get qbCanCook;

  /// No description provided for @qbCookNo.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get qbCookNo;

  /// No description provided for @qbCookBasic.
  ///
  /// In ru, this message translates to:
  /// **'Простое'**
  String get qbCookBasic;

  /// No description provided for @qbCookGood.
  ///
  /// In ru, this message translates to:
  /// **'Хорошо'**
  String get qbCookGood;

  /// No description provided for @qbStores.
  ///
  /// In ru, this message translates to:
  /// **'Где покупаете продукты'**
  String get qbStores;

  /// No description provided for @qbStoresHint.
  ///
  /// In ru, this message translates to:
  /// **'Можно выбрать несколько'**
  String get qbStoresHint;

  /// No description provided for @qbStorePyaterochka.
  ///
  /// In ru, this message translates to:
  /// **'Пятёрочка'**
  String get qbStorePyaterochka;

  /// No description provided for @qbStoreMagnit.
  ///
  /// In ru, this message translates to:
  /// **'Магнит'**
  String get qbStoreMagnit;

  /// No description provided for @qbStorePerekrestok.
  ///
  /// In ru, this message translates to:
  /// **'Перекрёсток'**
  String get qbStorePerekrestok;

  /// No description provided for @qbStoreVkusvill.
  ///
  /// In ru, this message translates to:
  /// **'ВкусВилл'**
  String get qbStoreVkusvill;

  /// No description provided for @qbStoreLenta.
  ///
  /// In ru, this message translates to:
  /// **'Лента'**
  String get qbStoreLenta;

  /// No description provided for @qbStoreAuchan.
  ///
  /// In ru, this message translates to:
  /// **'Ашан'**
  String get qbStoreAuchan;

  /// No description provided for @qbStoreMarket.
  ///
  /// In ru, this message translates to:
  /// **'Рынок'**
  String get qbStoreMarket;

  /// No description provided for @qbStoreDelivery.
  ///
  /// In ru, this message translates to:
  /// **'Доставка'**
  String get qbStoreDelivery;

  /// No description provided for @qbStoreOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое (через запятую)'**
  String get qbStoreOther;

  /// No description provided for @qbWaterNow.
  ///
  /// In ru, this message translates to:
  /// **'Сколько воды пьёте сейчас'**
  String get qbWaterNow;

  /// No description provided for @qbWaterNowHint.
  ///
  /// In ru, this message translates to:
  /// **'Примерно, в миллилитрах в день'**
  String get qbWaterNowHint;

  /// No description provided for @qbWaterExact.
  ///
  /// In ru, this message translates to:
  /// **'Точное значение'**
  String get qbWaterExact;

  /// No description provided for @qbMlPerDay.
  ///
  /// In ru, this message translates to:
  /// **'мл/день'**
  String get qbMlPerDay;

  /// No description provided for @qbTrainingIntro.
  ///
  /// In ru, this message translates to:
  /// **'Тренировки — дома. Система подберёт программу под ваш инвентарь и время.'**
  String get qbTrainingIntro;

  /// No description provided for @qbPlace.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get qbPlace;

  /// No description provided for @qbPlaceHome.
  ///
  /// In ru, this message translates to:
  /// **'Дом'**
  String get qbPlaceHome;

  /// No description provided for @qbPlaceHomeNote.
  ///
  /// In ru, this message translates to:
  /// **'Программа рассчитана на домашние тренировки'**
  String get qbPlaceHomeNote;

  /// No description provided for @qbEquipment.
  ///
  /// In ru, this message translates to:
  /// **'Инвентарь'**
  String get qbEquipment;

  /// No description provided for @qbEquipNone.
  ///
  /// In ru, this message translates to:
  /// **'Нет инвентаря'**
  String get qbEquipNone;

  /// No description provided for @qbEquipDumbbells.
  ///
  /// In ru, this message translates to:
  /// **'Гантели'**
  String get qbEquipDumbbells;

  /// No description provided for @qbEquipPullupBar.
  ///
  /// In ru, this message translates to:
  /// **'Турник'**
  String get qbEquipPullupBar;

  /// No description provided for @qbEquipBands.
  ///
  /// In ru, this message translates to:
  /// **'Резинки'**
  String get qbEquipBands;

  /// No description provided for @qbEquipMat.
  ///
  /// In ru, this message translates to:
  /// **'Коврик'**
  String get qbEquipMat;

  /// No description provided for @qbEquipKettlebell.
  ///
  /// In ru, this message translates to:
  /// **'Гиря'**
  String get qbEquipKettlebell;

  /// No description provided for @qbEquipOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get qbEquipOther;

  /// No description provided for @qbLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень подготовки'**
  String get qbLevel;

  /// No description provided for @qbLevelBeginner.
  ///
  /// In ru, this message translates to:
  /// **'Новичок'**
  String get qbLevelBeginner;

  /// No description provided for @qbLevelIntermediate.
  ///
  /// In ru, this message translates to:
  /// **'Средний'**
  String get qbLevelIntermediate;

  /// No description provided for @qbLevelAdvanced.
  ///
  /// In ru, this message translates to:
  /// **'Опытный'**
  String get qbLevelAdvanced;

  /// No description provided for @qbMinutesPerDay.
  ///
  /// In ru, this message translates to:
  /// **'Минут в день'**
  String get qbMinutesPerDay;

  /// No description provided for @qbMinutesExact.
  ///
  /// In ru, this message translates to:
  /// **'Своё значение'**
  String get qbMinutesExact;

  /// No description provided for @qbMinutesUnit.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get qbMinutesUnit;

  /// No description provided for @qbTrainingDays.
  ///
  /// In ru, this message translates to:
  /// **'Дни тренировок'**
  String get qbTrainingDays;

  /// No description provided for @qbDayMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get qbDayMon;

  /// No description provided for @qbDayTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get qbDayTue;

  /// No description provided for @qbDayWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get qbDayWed;

  /// No description provided for @qbDayThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get qbDayThu;

  /// No description provided for @qbDayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get qbDayFri;

  /// No description provided for @qbDaySat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get qbDaySat;

  /// No description provided for @qbDaySun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get qbDaySun;

  /// No description provided for @qbFinanceIntro.
  ///
  /// In ru, this message translates to:
  /// **'Всё необязательно. Доходы и счета помогут Системе следить за бюджетом и лимитами.'**
  String get qbFinanceIntro;

  /// No description provided for @qbFinIncomes.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get qbFinIncomes;

  /// No description provided for @qbFinIncomesHint.
  ///
  /// In ru, this message translates to:
  /// **'Стипендия, зарплата, переводы — и когда приходят'**
  String get qbFinIncomesHint;

  /// No description provided for @qbFinAddIncome.
  ///
  /// In ru, this message translates to:
  /// **'Добавить доход'**
  String get qbFinAddIncome;

  /// No description provided for @qbFinAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Счета'**
  String get qbFinAccounts;

  /// No description provided for @qbFinAddAccount.
  ///
  /// In ru, this message translates to:
  /// **'Добавить счёт'**
  String get qbFinAddAccount;

  /// No description provided for @qbFinCurrencies.
  ///
  /// In ru, this message translates to:
  /// **'Валюты'**
  String get qbFinCurrencies;

  /// No description provided for @qbFinCurrenciesHint.
  ///
  /// In ru, this message translates to:
  /// **'RUB — основная, отчёты в рублях'**
  String get qbFinCurrenciesHint;

  /// No description provided for @qbFinCrypto.
  ///
  /// In ru, this message translates to:
  /// **'Криптовалюта'**
  String get qbFinCrypto;

  /// No description provided for @qbFinAddCrypto.
  ///
  /// In ru, this message translates to:
  /// **'Добавить монету'**
  String get qbFinAddCrypto;

  /// No description provided for @qbFinDebts.
  ///
  /// In ru, this message translates to:
  /// **'Долги'**
  String get qbFinDebts;

  /// No description provided for @qbFinAddDebt.
  ///
  /// In ru, this message translates to:
  /// **'Добавить долг'**
  String get qbFinAddDebt;

  /// No description provided for @qbFinIncome.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get qbFinIncome;

  /// No description provided for @qbFinAccount.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get qbFinAccount;

  /// No description provided for @qbFinCryptoItem.
  ///
  /// In ru, this message translates to:
  /// **'Монета'**
  String get qbFinCryptoItem;

  /// No description provided for @qbFinDebt.
  ///
  /// In ru, this message translates to:
  /// **'Долг'**
  String get qbFinDebt;

  /// No description provided for @qbIncomeStipend.
  ///
  /// In ru, this message translates to:
  /// **'Стипендия'**
  String get qbIncomeStipend;

  /// No description provided for @qbIncomeSalary.
  ///
  /// In ru, this message translates to:
  /// **'Зарплата'**
  String get qbIncomeSalary;

  /// No description provided for @qbIncomeTransfer.
  ///
  /// In ru, this message translates to:
  /// **'Переводы'**
  String get qbIncomeTransfer;

  /// No description provided for @qbIncomeOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get qbIncomeOther;

  /// No description provided for @qbFinIncomeKind.
  ///
  /// In ru, this message translates to:
  /// **'Вид дохода'**
  String get qbFinIncomeKind;

  /// No description provided for @qbFinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get qbFinTitle;

  /// No description provided for @qbFinAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get qbFinAmount;

  /// No description provided for @qbFinDayOfMonth.
  ///
  /// In ru, this message translates to:
  /// **'Число месяца поступления'**
  String get qbFinDayOfMonth;

  /// No description provided for @qbFinDayOfMonthShort.
  ///
  /// In ru, this message translates to:
  /// **'{day}-го числа'**
  String qbFinDayOfMonthShort(int day);

  /// No description provided for @qbFinCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get qbFinCash;

  /// No description provided for @qbFinCard.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get qbFinCard;

  /// No description provided for @qbFinBank.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get qbFinBank;

  /// No description provided for @qbFinCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get qbFinCurrency;

  /// No description provided for @qbFinBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get qbFinBalance;

  /// No description provided for @qbFinCryptoSymbol.
  ///
  /// In ru, this message translates to:
  /// **'Тикер'**
  String get qbFinCryptoSymbol;

  /// No description provided for @qbFinCryptoAmount.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get qbFinCryptoAmount;

  /// No description provided for @qbFinCryptoRateNote.
  ///
  /// In ru, this message translates to:
  /// **'Количество — вручную, курс будет подтягиваться автоматически'**
  String get qbFinCryptoRateNote;

  /// No description provided for @qbFinIOwe.
  ///
  /// In ru, this message translates to:
  /// **'Я должен'**
  String get qbFinIOwe;

  /// No description provided for @qbFinOweMe.
  ///
  /// In ru, this message translates to:
  /// **'Мне должны'**
  String get qbFinOweMe;

  /// No description provided for @qbFinDebtToWhom.
  ///
  /// In ru, this message translates to:
  /// **'Кому'**
  String get qbFinDebtToWhom;

  /// No description provided for @qbFinDebtWho.
  ///
  /// In ru, this message translates to:
  /// **'Кто'**
  String get qbFinDebtWho;

  /// No description provided for @qbFinDueDate.
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get qbFinDueDate;

  /// No description provided for @qbFinClearDate.
  ///
  /// In ru, this message translates to:
  /// **'Убрать срок'**
  String get qbFinClearDate;

  /// No description provided for @qbFinDueShort.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String qbFinDueShort(String date);

  /// No description provided for @qbPermissionsIntro.
  ///
  /// In ru, this message translates to:
  /// **'Система запросит разрешения по одному. Любое можно выдать позже в настройках.'**
  String get qbPermissionsIntro;

  /// No description provided for @qbPermProgress.
  ///
  /// In ru, this message translates to:
  /// **'Обработано {done} из {total}'**
  String qbPermProgress(int done, int total);

  /// No description provided for @qbPermAllow.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить'**
  String get qbPermAllow;

  /// No description provided for @qbPermLater.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get qbPermLater;

  /// No description provided for @qbPermOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get qbPermOpenSettings;

  /// No description provided for @qbPermGranted.
  ///
  /// In ru, this message translates to:
  /// **'Выдано'**
  String get qbPermGranted;

  /// No description provided for @qbPermDenied.
  ///
  /// In ru, this message translates to:
  /// **'Отказано'**
  String get qbPermDenied;

  /// No description provided for @qbPermSkipped.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get qbPermSkipped;

  /// No description provided for @qbPermUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Недоступно'**
  String get qbPermUnavailable;

  /// No description provided for @qbPermAllDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово. Изменить разрешения можно в любой момент.'**
  String get qbPermAllDone;

  /// No description provided for @qbPermNoneAvailable.
  ///
  /// In ru, this message translates to:
  /// **'На этом устройстве разрешения не требуются.'**
  String get qbPermNoneAvailable;

  /// No description provided for @qbPermNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get qbPermNotifications;

  /// No description provided for @qbPermNotificationsWhy.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания о квестах, воде, сне и сообщения персонажа.'**
  String get qbPermNotificationsWhy;

  /// No description provided for @qbPermMotion.
  ///
  /// In ru, this message translates to:
  /// **'Движение и фитнес'**
  String get qbPermMotion;

  /// No description provided for @qbPermMotionWhy.
  ///
  /// In ru, this message translates to:
  /// **'Подсчёт шагов и активности для квестов и калорий.'**
  String get qbPermMotionWhy;

  /// No description provided for @qbPermLocationAlways.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация «Всегда»'**
  String get qbPermLocationAlways;

  /// No description provided for @qbPermLocationAlwaysWhy.
  ///
  /// In ru, this message translates to:
  /// **'Запись прогулок в фоне и подсказки маршрута. Сначала система спросит доступ «При использовании», затем «Всегда».'**
  String get qbPermLocationAlwaysWhy;

  /// No description provided for @qbPermCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get qbPermCamera;

  /// No description provided for @qbPermCameraWhy.
  ///
  /// In ru, this message translates to:
  /// **'Фото тела, кожи, еды и чеков для оценки прогресса.'**
  String get qbPermCameraWhy;

  /// No description provided for @qbPermMicrophone.
  ///
  /// In ru, this message translates to:
  /// **'Микрофон'**
  String get qbPermMicrophone;

  /// No description provided for @qbPermMicrophoneWhy.
  ///
  /// In ru, this message translates to:
  /// **'Голосовое общение с персонажем.'**
  String get qbPermMicrophoneWhy;

  /// No description provided for @qbPermMediaLibrary.
  ///
  /// In ru, this message translates to:
  /// **'Медиатека'**
  String get qbPermMediaLibrary;

  /// No description provided for @qbPermMediaLibraryWhy.
  ///
  /// In ru, this message translates to:
  /// **'Показ текущего трека Apple Music на прогулке и тренировке.'**
  String get qbPermMediaLibraryWhy;

  /// No description provided for @qbPermAlarms.
  ///
  /// In ru, this message translates to:
  /// **'Будильники'**
  String get qbPermAlarms;

  /// No description provided for @qbPermAlarmsWhy.
  ///
  /// In ru, this message translates to:
  /// **'Точные будильники для подъёма и важных квестов.'**
  String get qbPermAlarmsWhy;

  /// No description provided for @qbPermAlarmsLater.
  ///
  /// In ru, this message translates to:
  /// **'Настроим на этапе будильника.'**
  String get qbPermAlarmsLater;

  /// No description provided for @qeQuestPenaltyCleaning.
  ///
  /// In ru, this message translates to:
  /// **'Штраф: уборка {minutes} мин'**
  String qeQuestPenaltyCleaning(String minutes);

  /// No description provided for @qeQuestPenaltyReading.
  ///
  /// In ru, this message translates to:
  /// **'Штраф: чтение {minutes} мин'**
  String qeQuestPenaltyReading(String minutes);

  /// No description provided for @qeQuestPenaltyPlank.
  ///
  /// In ru, this message translates to:
  /// **'Штраф: планка {seconds} с'**
  String qeQuestPenaltyPlank(String seconds);

  /// No description provided for @qeQuestPenaltyWalk.
  ///
  /// In ru, this message translates to:
  /// **'Штраф: прогулка {minutes} мин'**
  String qeQuestPenaltyWalk(String minutes);

  /// No description provided for @qeQuestPenaltyNoGames.
  ///
  /// In ru, this message translates to:
  /// **'Штраф: вечер без игр и соцсетей'**
  String get qeQuestPenaltyNoGames;

  /// No description provided for @qeQuestBoostWalk.
  ///
  /// In ru, this message translates to:
  /// **'Усиление: прогулка {minutes} мин'**
  String qeQuestBoostWalk(String minutes);

  /// No description provided for @qeQuestBoostWater.
  ///
  /// In ru, this message translates to:
  /// **'Усиление: ещё {ml} мл воды'**
  String qeQuestBoostWater(String ml);

  /// No description provided for @qeQuestBoostBedOnTime.
  ///
  /// In ru, this message translates to:
  /// **'Усиление: отбой не позже {time}'**
  String qeQuestBoostBedOnTime(String time);

  /// No description provided for @qeQuestBoostPlanTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'Усиление: распиши завтрашний день'**
  String get qeQuestBoostPlanTomorrow;

  /// No description provided for @qeQuestBossAll.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов за неделю'**
  String qeQuestBossAll(String count);

  /// No description provided for @qeQuestBossStrength.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов силы'**
  String qeQuestBossStrength(String count);

  /// No description provided for @qeQuestBossEndurance.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов выносливости'**
  String qeQuestBossEndurance(String count);

  /// No description provided for @qeQuestBossDiscipline.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов дисциплины'**
  String qeQuestBossDiscipline(String count);

  /// No description provided for @qeQuestBossIntellect.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов интеллекта'**
  String qeQuestBossIntellect(String count);

  /// No description provided for @qeQuestBossHealth.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов здоровья'**
  String qeQuestBossHealth(String count);

  /// No description provided for @qeQuestBossLooks.
  ///
  /// In ru, this message translates to:
  /// **'Закрой {count} квестов внешности'**
  String qeQuestBossLooks(String count);

  /// No description provided for @qeEffectVigor.
  ///
  /// In ru, this message translates to:
  /// **'Бодрость +{pct}% опыта'**
  String qeEffectVigor(String pct);

  /// No description provided for @qeEffectDehydration.
  ///
  /// In ru, this message translates to:
  /// **'Обезвоживание −{pct}% выносливости'**
  String qeEffectDehydration(String pct);

  /// No description provided for @qeEffectBossAura.
  ///
  /// In ru, this message translates to:
  /// **'Аура победителя +{pct}% ◆'**
  String qeEffectBossAura(String pct);

  /// No description provided for @qeTitleStreak7.
  ///
  /// In ru, this message translates to:
  /// **'Несгибаемый'**
  String get qeTitleStreak7;

  /// No description provided for @qeTitleStreak30.
  ///
  /// In ru, this message translates to:
  /// **'Железная воля'**
  String get qeTitleStreak30;

  /// No description provided for @qeTitleBossSlayer.
  ///
  /// In ru, this message translates to:
  /// **'Победитель босса'**
  String get qeTitleBossSlayer;

  /// No description provided for @qeTitleBossHunter.
  ///
  /// In ru, this message translates to:
  /// **'Охотник на боссов'**
  String get qeTitleBossHunter;

  /// No description provided for @qeTitleLevel10.
  ///
  /// In ru, this message translates to:
  /// **'Пробуждённый'**
  String get qeTitleLevel10;

  /// No description provided for @qeTitleLevel25.
  ///
  /// In ru, this message translates to:
  /// **'Закалённый'**
  String get qeTitleLevel25;

  /// No description provided for @qeTitleLevel50.
  ///
  /// In ru, this message translates to:
  /// **'Легенда Системы'**
  String get qeTitleLevel50;

  /// No description provided for @qeReasonFailedQuests.
  ///
  /// In ru, this message translates to:
  /// **'Провалы за день. Назначен штрафной квест'**
  String get qeReasonFailedQuests;

  /// No description provided for @qeReasonMarkWalked.
  ///
  /// In ru, this message translates to:
  /// **'Отметка: гулял с друзьями. За честность штраф мягче'**
  String get qeReasonMarkWalked;

  /// No description provided for @qeReasonMarkAlcohol.
  ///
  /// In ru, this message translates to:
  /// **'Отметка: алкоголь. Завтра — усиленный план'**
  String get qeReasonMarkAlcohol;

  /// No description provided for @qeReasonMarkRelapse.
  ///
  /// In ru, this message translates to:
  /// **'Отметка: срыв. Завтра — усиленный план'**
  String get qeReasonMarkRelapse;

  /// No description provided for @qeReasonBossFailed.
  ///
  /// In ru, this message translates to:
  /// **'Босс недели не побеждён'**
  String get qeReasonBossFailed;

  /// No description provided for @qeReasonReproach.
  ///
  /// In ru, this message translates to:
  /// **'Квест не выполнен. Система недовольна'**
  String get qeReasonReproach;

  /// No description provided for @qeReasonOther.
  ///
  /// In ru, this message translates to:
  /// **'Штраф Системы'**
  String get qeReasonOther;

  /// No description provided for @qstViewToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get qstViewToday;

  /// No description provided for @qstViewWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get qstViewWeek;

  /// No description provided for @qstViewHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get qstViewHistory;

  /// No description provided for @qstFilterTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр'**
  String get qstFilterTitle;

  /// No description provided for @qstFilterActive.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр: {count}'**
  String qstFilterActive(int count);

  /// No description provided for @qstFilterReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить'**
  String get qstFilterReset;

  /// No description provided for @qstFilterKind.
  ///
  /// In ru, this message translates to:
  /// **'Вид'**
  String get qstFilterKind;

  /// No description provided for @qstFilterStat.
  ///
  /// In ru, this message translates to:
  /// **'Характеристика'**
  String get qstFilterStat;

  /// No description provided for @qstKindDaily.
  ///
  /// In ru, this message translates to:
  /// **'Ежедневные'**
  String get qstKindDaily;

  /// No description provided for @qstKindSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Из расписания'**
  String get qstKindSchedule;

  /// No description provided for @qstKindGoal.
  ///
  /// In ru, this message translates to:
  /// **'По цели'**
  String get qstKindGoal;

  /// No description provided for @qstKindPenalty.
  ///
  /// In ru, this message translates to:
  /// **'Штрафные'**
  String get qstKindPenalty;

  /// No description provided for @qstKindBoss.
  ///
  /// In ru, this message translates to:
  /// **'Босс'**
  String get qstKindBoss;

  /// No description provided for @qstStatusPending.
  ///
  /// In ru, this message translates to:
  /// **'Активен'**
  String get qstStatusPending;

  /// No description provided for @qstStatusDone.
  ///
  /// In ru, this message translates to:
  /// **'Выполнен'**
  String get qstStatusDone;

  /// No description provided for @qstStatusFailed.
  ///
  /// In ru, this message translates to:
  /// **'Провален'**
  String get qstStatusFailed;

  /// No description provided for @qstStatusRefused.
  ///
  /// In ru, this message translates to:
  /// **'Отказ'**
  String get qstStatusRefused;

  /// No description provided for @qstStatusExcused.
  ///
  /// In ru, this message translates to:
  /// **'Пауза: без штрафа'**
  String get qstStatusExcused;

  /// No description provided for @qstEmptyDay.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня квестов нет'**
  String get qstEmptyDay;

  /// No description provided for @qstEmptyWeek.
  ///
  /// In ru, this message translates to:
  /// **'На эту неделю квестов нет'**
  String get qstEmptyWeek;

  /// No description provided for @qstEmptyFiltered.
  ///
  /// In ru, this message translates to:
  /// **'Нет квестов под фильтр'**
  String get qstEmptyFiltered;

  /// No description provided for @qstEmptyHistory.
  ///
  /// In ru, this message translates to:
  /// **'Журнал пуст'**
  String get qstEmptyHistory;

  /// No description provided for @qstLoadError.
  ///
  /// In ru, this message translates to:
  /// **'Система не отвечает. Повторите позже.'**
  String get qstLoadError;

  /// No description provided for @qstActionRejected.
  ///
  /// In ru, this message translates to:
  /// **'Система отклонила действие.'**
  String get qstActionRejected;

  /// No description provided for @qstNoValue.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get qstNoValue;

  /// No description provided for @qstAllDay.
  ///
  /// In ru, this message translates to:
  /// **'В течение дня'**
  String get qstAllDay;

  /// No description provided for @qstOpenQuest.
  ///
  /// In ru, this message translates to:
  /// **'Открыть квест'**
  String get qstOpenQuest;

  /// No description provided for @qstSubtasks.
  ///
  /// In ru, this message translates to:
  /// **'Подзадачи'**
  String get qstSubtasks;

  /// No description provided for @qstProgress.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс'**
  String get qstProgress;

  /// No description provided for @qstProgressAddLabel.
  ///
  /// In ru, this message translates to:
  /// **'Добавить прогресс: {step}'**
  String qstProgressAddLabel(String step);

  /// No description provided for @qstRefusePenalty.
  ///
  /// In ru, this message translates to:
  /// **'Отказ: −{points} ◆'**
  String qstRefusePenalty(String points);

  /// No description provided for @qstNoRefuse.
  ///
  /// In ru, this message translates to:
  /// **'Штрафной квест: отказ невозможен'**
  String get qstNoRefuse;

  /// No description provided for @qstArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get qstArchive;

  /// No description provided for @qstArchiveConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Квест уйдёт в архив и больше не будет появляться.'**
  String get qstArchiveConfirm;

  /// No description provided for @qstNewQuest.
  ///
  /// In ru, this message translates to:
  /// **'Новый квест'**
  String get qstNewQuest;

  /// No description provided for @qstEditQuest.
  ///
  /// In ru, this message translates to:
  /// **'Изменить квест'**
  String get qstEditQuest;

  /// No description provided for @qstBossReward.
  ///
  /// In ru, this message translates to:
  /// **'Награда: +{points} ◆, +{xp} XP'**
  String qstBossReward(String points, String xp);

  /// No description provided for @qstDiamondsDelta.
  ///
  /// In ru, this message translates to:
  /// **'{value} ◆'**
  String qstDiamondsDelta(String value);

  /// No description provided for @qstXpDelta.
  ///
  /// In ru, this message translates to:
  /// **'{value} XP'**
  String qstXpDelta(String value);

  /// No description provided for @qstHistCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Выполнено'**
  String get qstHistCompleted;

  /// No description provided for @qstHistFailed.
  ///
  /// In ru, this message translates to:
  /// **'Провал'**
  String get qstHistFailed;

  /// No description provided for @qstHistRefused.
  ///
  /// In ru, this message translates to:
  /// **'Отказ'**
  String get qstHistRefused;

  /// No description provided for @qstHistPenalty.
  ///
  /// In ru, this message translates to:
  /// **'Штраф'**
  String get qstHistPenalty;

  /// No description provided for @qstHistBonus.
  ///
  /// In ru, this message translates to:
  /// **'Бонус'**
  String get qstHistBonus;

  /// No description provided for @qstHistPurchase.
  ///
  /// In ru, this message translates to:
  /// **'Покупка'**
  String get qstHistPurchase;

  /// No description provided for @qstHistMark.
  ///
  /// In ru, this message translates to:
  /// **'Отметка дня'**
  String get qstHistMark;

  /// No description provided for @qstHistPauseStarted.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get qstHistPauseStarted;

  /// No description provided for @qstHistPauseEnded.
  ///
  /// In ru, this message translates to:
  /// **'Пауза снята'**
  String get qstHistPauseEnded;

  /// No description provided for @qstHistStatPoint.
  ///
  /// In ru, this message translates to:
  /// **'Очко характеристики'**
  String get qstHistStatPoint;

  /// No description provided for @qstHistBossCompleted.
  ///
  /// In ru, this message translates to:
  /// **'Босс повержен'**
  String get qstHistBossCompleted;

  /// No description provided for @qstHistBossFailed.
  ///
  /// In ru, this message translates to:
  /// **'Босс не повержен'**
  String get qstHistBossFailed;

  /// No description provided for @qstHistDisciplineOn.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплина включена'**
  String get qstHistDisciplineOn;

  /// No description provided for @qstHistDisciplineOff.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплина снята'**
  String get qstHistDisciplineOff;

  /// No description provided for @qstHistAdjustment.
  ///
  /// In ru, this message translates to:
  /// **'Корректировка'**
  String get qstHistAdjustment;

  /// No description provided for @qstMarksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Честные отметки'**
  String get qstMarksTitle;

  /// No description provided for @qstMarksHint.
  ///
  /// In ru, this message translates to:
  /// **'Честная отметка мягче скрытого срыва. Завтра — усиленный план.'**
  String get qstMarksHint;

  /// No description provided for @qstMarkWalked.
  ///
  /// In ru, this message translates to:
  /// **'Гулял с друзьями'**
  String get qstMarkWalked;

  /// No description provided for @qstMarkAlcohol.
  ///
  /// In ru, this message translates to:
  /// **'Алкоголь'**
  String get qstMarkAlcohol;

  /// No description provided for @qstMarkRelapse.
  ///
  /// In ru, this message translates to:
  /// **'Сорвался'**
  String get qstMarkRelapse;

  /// No description provided for @qstMarkConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отметить: {mark}?'**
  String qstMarkConfirmTitle(String mark);

  /// No description provided for @qstMarkConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Честная отметка мягче скрытого срыва: небольшой штраф сейчас, завтра — усиленный план.'**
  String get qstMarkConfirmMessage;

  /// No description provided for @qstMarkConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Отметить'**
  String get qstMarkConfirm;

  /// No description provided for @qstPauseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get qstPauseTitle;

  /// No description provided for @qstPauseHint.
  ///
  /// In ru, this message translates to:
  /// **'Болезнь, каникулы, отпуск: штрафы не начисляются, серия не сгорает.'**
  String get qstPauseHint;

  /// No description provided for @qstPauseStart.
  ///
  /// In ru, this message translates to:
  /// **'Поставить паузу'**
  String get qstPauseStart;

  /// No description provided for @qstPauseEnd.
  ///
  /// In ru, this message translates to:
  /// **'Снять паузу'**
  String get qstPauseEnd;

  /// No description provided for @qstPauseConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Начать паузу'**
  String get qstPauseConfirm;

  /// No description provided for @qstPauseReason.
  ///
  /// In ru, this message translates to:
  /// **'Причина'**
  String get qstPauseReason;

  /// No description provided for @qstPauseReasonIllness.
  ///
  /// In ru, this message translates to:
  /// **'Болезнь'**
  String get qstPauseReasonIllness;

  /// No description provided for @qstPauseReasonVacation.
  ///
  /// In ru, this message translates to:
  /// **'Отпуск'**
  String get qstPauseReasonVacation;

  /// No description provided for @qstPauseReasonHolidays.
  ///
  /// In ru, this message translates to:
  /// **'Каникулы'**
  String get qstPauseReasonHolidays;

  /// No description provided for @qstPauseReasonOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get qstPauseReasonOther;

  /// No description provided for @qstPauseActive.
  ///
  /// In ru, this message translates to:
  /// **'Пауза: {reason}'**
  String qstPauseActive(String reason);

  /// No description provided for @qstPauseUntil.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String qstPauseUntil(String date);

  /// No description provided for @qstPauseUntilRemoved.
  ///
  /// In ru, this message translates to:
  /// **'До снятия'**
  String get qstPauseUntilRemoved;

  /// No description provided for @qstPauseUntilDate.
  ///
  /// In ru, this message translates to:
  /// **'До даты'**
  String get qstPauseUntilDate;

  /// No description provided for @qstPauseEndDate.
  ///
  /// In ru, this message translates to:
  /// **'Последний день паузы'**
  String get qstPauseEndDate;

  /// No description provided for @qstPausedPill.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get qstPausedPill;

  /// No description provided for @qstDisciplinePill.
  ///
  /// In ru, this message translates to:
  /// **'Дисциплина'**
  String get qstDisciplinePill;

  /// No description provided for @qstPlayerNoName.
  ///
  /// In ru, this message translates to:
  /// **'Игрок'**
  String get qstPlayerNoName;

  /// No description provided for @qstStatPointsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Очки характеристик'**
  String get qstStatPointsTitle;

  /// No description provided for @qstStatPointsLeft.
  ///
  /// In ru, this message translates to:
  /// **'Свободно: {count}'**
  String qstStatPointsLeft(int count);

  /// No description provided for @qstStatPointAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить очко: {stat}'**
  String qstStatPointAdd(String stat);

  /// No description provided for @qstWindowFailedMessage.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}». Штраф: −{points} ◆.'**
  String qstWindowFailedMessage(String quest, String points);

  /// No description provided for @qstWindowFailedMany.
  ///
  /// In ru, this message translates to:
  /// **'Провалено квестов: {count}. Штраф: −{points} ◆.'**
  String qstWindowFailedMany(int count, String points);

  /// No description provided for @qstWindowRefusedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отказ от квеста'**
  String get qstWindowRefusedTitle;

  /// No description provided for @qstWindowPenaltyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Штраф'**
  String get qstWindowPenaltyTitle;

  /// No description provided for @qstWindowPenaltyMessage.
  ///
  /// In ru, this message translates to:
  /// **'{reason}. Штраф: −{points} ◆.'**
  String qstWindowPenaltyMessage(String reason, String points);

  /// No description provided for @qstWindowPenaltyQuest.
  ///
  /// In ru, this message translates to:
  /// **'Назначен штрафной квест: «{quest}».'**
  String qstWindowPenaltyQuest(String quest);

  /// No description provided for @qstLevelUpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уровень повышен'**
  String get qstLevelUpTitle;

  /// No description provided for @qstLevelUpLevel.
  ///
  /// In ru, this message translates to:
  /// **'LV {level}'**
  String qstLevelUpLevel(int level);

  /// No description provided for @qstLevelUpRank.
  ///
  /// In ru, this message translates to:
  /// **'Новый ранг: {rank}'**
  String qstLevelUpRank(String rank);

  /// No description provided for @qstLevelUpPoints.
  ///
  /// In ru, this message translates to:
  /// **'Свободные очки характеристик: {count}'**
  String qstLevelUpPoints(int count);

  /// No description provided for @qstTitleGot.
  ///
  /// In ru, this message translates to:
  /// **'Титул: «{title}»'**
  String qstTitleGot(String title);

  /// No description provided for @qstBossWonTitle.
  ///
  /// In ru, this message translates to:
  /// **'Босс повержен'**
  String get qstBossWonTitle;

  /// No description provided for @qstBossLostTitle.
  ///
  /// In ru, this message translates to:
  /// **'Босс не повержен'**
  String get qstBossLostTitle;

  /// No description provided for @qstBossLostMessage.
  ///
  /// In ru, this message translates to:
  /// **'Неделя закрыта без победы. Новый босс — с понедельника.'**
  String get qstBossLostMessage;

  /// No description provided for @qstDisciplineOnTitle.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины включён'**
  String get qstDisciplineOnTitle;

  /// No description provided for @qstDisciplineOnMessage.
  ///
  /// In ru, this message translates to:
  /// **'Подъём 6:00, отбой 22:00, дополнительная нагрузка в пределах плана. Режим снимется, когда баланс ◆ станет положительным.'**
  String get qstDisciplineOnMessage;

  /// No description provided for @qstDisciplineOffTitle.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины снят'**
  String get qstDisciplineOffTitle;

  /// No description provided for @qstDisciplineOffMessage.
  ///
  /// In ru, this message translates to:
  /// **'Баланс восстановлен. Обычный режим.'**
  String get qstDisciplineOffMessage;

  /// No description provided for @qstDisciplineMore.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get qstDisciplineMore;

  /// No description provided for @qstFormTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get qstFormTitle;

  /// No description provided for @qstFormTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: растяжка 10 минут'**
  String get qstFormTitleHint;

  /// No description provided for @qstFormStat.
  ///
  /// In ru, this message translates to:
  /// **'Характеристика'**
  String get qstFormStat;

  /// No description provided for @qstFormTimed.
  ///
  /// In ru, this message translates to:
  /// **'Ко времени'**
  String get qstFormTimed;

  /// No description provided for @qstFormTimedHint.
  ///
  /// In ru, this message translates to:
  /// **'Иначе — в течение дня'**
  String get qstFormTimedHint;

  /// No description provided for @qstFormTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get qstFormTime;

  /// No description provided for @qstFormWindow.
  ///
  /// In ru, this message translates to:
  /// **'Окно выполнения'**
  String get qstFormWindow;

  /// No description provided for @qstMinutesUnit.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get qstMinutesUnit;

  /// No description provided for @qstFormWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'Дни недели'**
  String get qstFormWeekdays;

  /// No description provided for @qstFormWeekdaysHint.
  ///
  /// In ru, this message translates to:
  /// **'Не выбраны — каждый день'**
  String get qstFormWeekdaysHint;

  /// No description provided for @qstFormWeekParity.
  ///
  /// In ru, this message translates to:
  /// **'Чередование недель'**
  String get qstFormWeekParity;

  /// No description provided for @qstWeekEvery.
  ///
  /// In ru, this message translates to:
  /// **'Каждую'**
  String get qstWeekEvery;

  /// No description provided for @qstWeek1.
  ///
  /// In ru, this message translates to:
  /// **'Неделя 1'**
  String get qstWeek1;

  /// No description provided for @qstWeek2.
  ///
  /// In ru, this message translates to:
  /// **'Неделя 2'**
  String get qstWeek2;

  /// No description provided for @qstFormSubtasks.
  ///
  /// In ru, this message translates to:
  /// **'Подзадачи'**
  String get qstFormSubtasks;

  /// No description provided for @qstFormSubtaskHint.
  ///
  /// In ru, this message translates to:
  /// **'Подзадача {n}'**
  String qstFormSubtaskHint(int n);

  /// No description provided for @qstFormAddSubtask.
  ///
  /// In ru, this message translates to:
  /// **'Добавить подзадачу'**
  String get qstFormAddSubtask;

  /// No description provided for @qstFormRemoveSubtask.
  ///
  /// In ru, this message translates to:
  /// **'Убрать подзадачу'**
  String get qstFormRemoveSubtask;

  /// No description provided for @qstFormDefaultReward.
  ///
  /// In ru, this message translates to:
  /// **'Награда и штраф — по правилам Системы'**
  String get qstFormDefaultReward;

  /// No description provided for @qstFormDefaultRewardHint.
  ///
  /// In ru, this message translates to:
  /// **'Система рассчитает ◆ и опыт по виду квеста'**
  String get qstFormDefaultRewardHint;

  /// No description provided for @qstFormRewardDiamonds.
  ///
  /// In ru, this message translates to:
  /// **'Награда, ◆'**
  String get qstFormRewardDiamonds;

  /// No description provided for @qstFormRewardXp.
  ///
  /// In ru, this message translates to:
  /// **'Опыт, XP'**
  String get qstFormRewardXp;

  /// No description provided for @qstFormPenalty.
  ///
  /// In ru, this message translates to:
  /// **'Штраф за провал, ◆'**
  String get qstFormPenalty;

  /// No description provided for @qstFormNag.
  ///
  /// In ru, this message translates to:
  /// **'Надоедать'**
  String get qstFormNag;

  /// No description provided for @qstFormNagHint.
  ///
  /// In ru, this message translates to:
  /// **'Напоминать каждую минуту до выполнения'**
  String get qstFormNagHint;

  /// No description provided for @schTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get schTitle;

  /// No description provided for @schInstitution.
  ///
  /// In ru, this message translates to:
  /// **'Учебное заведение'**
  String get schInstitution;

  /// No description provided for @schInstSchool.
  ///
  /// In ru, this message translates to:
  /// **'Школа'**
  String get schInstSchool;

  /// No description provided for @schInstCollege.
  ///
  /// In ru, this message translates to:
  /// **'Колледж'**
  String get schInstCollege;

  /// No description provided for @schInstUniversity.
  ///
  /// In ru, this message translates to:
  /// **'Вуз'**
  String get schInstUniversity;

  /// No description provided for @schInstNone.
  ///
  /// In ru, this message translates to:
  /// **'Не учусь'**
  String get schInstNone;

  /// No description provided for @schInstitutionName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get schInstitutionName;

  /// No description provided for @schInstitutionNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: МГУ, школа № 5'**
  String get schInstitutionNameHint;

  /// No description provided for @schWake.
  ///
  /// In ru, this message translates to:
  /// **'Подъём'**
  String get schWake;

  /// No description provided for @schBed.
  ///
  /// In ru, this message translates to:
  /// **'Отбой'**
  String get schBed;

  /// No description provided for @schCommute.
  ///
  /// In ru, this message translates to:
  /// **'Дорога до учёбы'**
  String get schCommute;

  /// No description provided for @schCommuteHint.
  ///
  /// In ru, this message translates to:
  /// **'В одну сторону, в минутах'**
  String get schCommuteHint;

  /// No description provided for @schMinutesUnit.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get schMinutesUnit;

  /// No description provided for @schWeekends.
  ///
  /// In ru, this message translates to:
  /// **'Выходные дни'**
  String get schWeekends;

  /// No description provided for @schAlternation.
  ///
  /// In ru, this message translates to:
  /// **'Чередование недель (неделя 1/2)'**
  String get schAlternation;

  /// No description provided for @schAlternationHint.
  ///
  /// In ru, this message translates to:
  /// **'Разные пары по чётным и нечётным неделям'**
  String get schAlternationHint;

  /// No description provided for @schCurrentWeek.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас: неделя {week}'**
  String schCurrentWeek(int week);

  /// No description provided for @schSwitchWeek.
  ///
  /// In ru, this message translates to:
  /// **'Переключить неделю'**
  String get schSwitchWeek;

  /// No description provided for @schWeekN.
  ///
  /// In ru, this message translates to:
  /// **'Неделя {week}'**
  String schWeekN(int week);

  /// No description provided for @schItemsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пункты расписания'**
  String get schItemsTitle;

  /// No description provided for @schDayEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Нет пунктов'**
  String get schDayEmpty;

  /// No description provided for @schAddItem.
  ///
  /// In ru, this message translates to:
  /// **'Добавить пункт'**
  String get schAddItem;

  /// No description provided for @schAddItemTo.
  ///
  /// In ru, this message translates to:
  /// **'Добавить пункт: {day}'**
  String schAddItemTo(String day);

  /// No description provided for @schCopyDay.
  ///
  /// In ru, this message translates to:
  /// **'Копировать день'**
  String get schCopyDay;

  /// No description provided for @schCopyDayFrom.
  ///
  /// In ru, this message translates to:
  /// **'Копировать день: {day}'**
  String schCopyDayFrom(String day);

  /// No description provided for @schCopyDayTo.
  ///
  /// In ru, this message translates to:
  /// **'На какой день скопировать?'**
  String get schCopyDayTo;

  /// No description provided for @schCopied.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Скопирован {count} пункт} few{Скопировано {count} пункта} many{Скопировано {count} пунктов} other{Скопировано {count} пункта}}'**
  String schCopied(int count);

  /// No description provided for @schItemNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый пункт'**
  String get schItemNew;

  /// No description provided for @schItemEdit.
  ///
  /// In ru, this message translates to:
  /// **'Пункт расписания'**
  String get schItemEdit;

  /// No description provided for @schItemTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get schItemTitle;

  /// No description provided for @schItemTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Матанализ'**
  String get schItemTitleHint;

  /// No description provided for @schKind.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get schKind;

  /// No description provided for @schKindLesson.
  ///
  /// In ru, this message translates to:
  /// **'Пара / урок'**
  String get schKindLesson;

  /// No description provided for @schKindWork.
  ///
  /// In ru, this message translates to:
  /// **'Работа'**
  String get schKindWork;

  /// No description provided for @schKindOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get schKindOther;

  /// No description provided for @schDay.
  ///
  /// In ru, this message translates to:
  /// **'День недели'**
  String get schDay;

  /// No description provided for @schStart.
  ///
  /// In ru, this message translates to:
  /// **'Начало'**
  String get schStart;

  /// No description provided for @schDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность, мин'**
  String get schDuration;

  /// No description provided for @schEndsAt.
  ///
  /// In ru, this message translates to:
  /// **'Окончание: {time}'**
  String schEndsAt(String time);

  /// No description provided for @schParity.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get schParity;

  /// No description provided for @schParityEvery.
  ///
  /// In ru, this message translates to:
  /// **'Каждую'**
  String get schParityEvery;

  /// No description provided for @schLocation.
  ///
  /// In ru, this message translates to:
  /// **'Место'**
  String get schLocation;

  /// No description provided for @schLocationHint.
  ///
  /// In ru, this message translates to:
  /// **'Аудитория, адрес'**
  String get schLocationHint;

  /// No description provided for @schRequiresCommute.
  ///
  /// In ru, this message translates to:
  /// **'Нужна дорога'**
  String get schRequiresCommute;

  /// No description provided for @schRequiresCommuteHint.
  ///
  /// In ru, this message translates to:
  /// **'Учитывать во времени выхода из дома'**
  String get schRequiresCommuteHint;

  /// No description provided for @schDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить пункт?'**
  String get schDeleteConfirm;

  /// No description provided for @schWd1.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get schWd1;

  /// No description provided for @schWd2.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get schWd2;

  /// No description provided for @schWd3.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get schWd3;

  /// No description provided for @schWd4.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get schWd4;

  /// No description provided for @schWd5.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get schWd5;

  /// No description provided for @schWd6.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get schWd6;

  /// No description provided for @schWd7.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get schWd7;

  /// No description provided for @schWdFull1.
  ///
  /// In ru, this message translates to:
  /// **'Понедельник'**
  String get schWdFull1;

  /// No description provided for @schWdFull2.
  ///
  /// In ru, this message translates to:
  /// **'Вторник'**
  String get schWdFull2;

  /// No description provided for @schWdFull3.
  ///
  /// In ru, this message translates to:
  /// **'Среда'**
  String get schWdFull3;

  /// No description provided for @schWdFull4.
  ///
  /// In ru, this message translates to:
  /// **'Четверг'**
  String get schWdFull4;

  /// No description provided for @schWdFull5.
  ///
  /// In ru, this message translates to:
  /// **'Пятница'**
  String get schWdFull5;

  /// No description provided for @schWdFull6.
  ///
  /// In ru, this message translates to:
  /// **'Суббота'**
  String get schWdFull6;

  /// No description provided for @schWdFull7.
  ///
  /// In ru, this message translates to:
  /// **'Воскресенье'**
  String get schWdFull7;

  /// No description provided for @schWeekend.
  ///
  /// In ru, this message translates to:
  /// **'Выходной'**
  String get schWeekend;

  /// No description provided for @schHeader.
  ///
  /// In ru, this message translates to:
  /// **'Неделя {week} · {day}'**
  String schHeader(int week, String day);

  /// No description provided for @schHeaderNoAlt.
  ///
  /// In ru, this message translates to:
  /// **'Без чередования · {day}'**
  String schHeaderNoAlt(String day);

  /// No description provided for @schPrevWeek.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущая неделя'**
  String get schPrevWeek;

  /// No description provided for @schNextWeek.
  ///
  /// In ru, this message translates to:
  /// **'Следующая неделя'**
  String get schNextWeek;

  /// No description provided for @schToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get schToday;

  /// No description provided for @schDayFeed.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get schDayFeed;

  /// No description provided for @schSlotSleep.
  ///
  /// In ru, this message translates to:
  /// **'Сон'**
  String get schSlotSleep;

  /// No description provided for @schSlotCommute.
  ///
  /// In ru, this message translates to:
  /// **'Дорога'**
  String get schSlotCommute;

  /// No description provided for @schSlotFree.
  ///
  /// In ru, this message translates to:
  /// **'Свободно'**
  String get schSlotFree;

  /// No description provided for @schLeaveHome.
  ///
  /// In ru, this message translates to:
  /// **'Выход из дома в {time}'**
  String schLeaveHome(String time);

  /// No description provided for @schNoLeave.
  ///
  /// In ru, this message translates to:
  /// **'В этот день выходить не нужно'**
  String get schNoLeave;

  /// No description provided for @schFreeTotal.
  ///
  /// In ru, this message translates to:
  /// **'Свободно: {duration}'**
  String schFreeTotal(String duration);

  /// No description provided for @schHoursMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{hours} ч {minutes} мин'**
  String schHoursMinutes(int hours, int minutes);

  /// No description provided for @schMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String schMinutes(int minutes);

  /// No description provided for @schTimeRange.
  ///
  /// In ru, this message translates to:
  /// **'{start}–{end}'**
  String schTimeRange(String start, String end);

  /// No description provided for @schEditSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Редактировать расписание'**
  String get schEditSchedule;

  /// No description provided for @schBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get schBack;

  /// No description provided for @schWarningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get schWarningLabel;

  /// No description provided for @setSectionQuestionnaire.
  ///
  /// In ru, this message translates to:
  /// **'Анкета'**
  String get setSectionQuestionnaire;

  /// No description provided for @setSectionPlan.
  ///
  /// In ru, this message translates to:
  /// **'План'**
  String get setSectionPlan;

  /// No description provided for @setPlan.
  ///
  /// In ru, this message translates to:
  /// **'План'**
  String get setPlan;

  /// No description provided for @setPlanHint.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр и принятие плана'**
  String get setPlanHint;

  /// No description provided for @setSchedule.
  ///
  /// In ru, this message translates to:
  /// **'Расписание'**
  String get setSchedule;

  /// No description provided for @setScheduleHint.
  ///
  /// In ru, this message translates to:
  /// **'Пары, работа, сон'**
  String get setScheduleHint;

  /// No description provided for @setSectionLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get setSectionLanguage;

  /// No description provided for @setLangRu.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get setLangRu;

  /// No description provided for @setLangTr.
  ///
  /// In ru, this message translates to:
  /// **'Türkçe'**
  String get setLangTr;

  /// No description provided for @setLangSystem.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get setLangSystem;

  /// No description provided for @setSectionData.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get setSectionData;

  /// No description provided for @setExport.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт в JSON'**
  String get setExport;

  /// No description provided for @setExportHint.
  ///
  /// In ru, this message translates to:
  /// **'Все данные одним файлом — сохраните его в «Файлы» или отправьте себе'**
  String get setExportHint;

  /// No description provided for @setIncludePhotos.
  ///
  /// In ru, this message translates to:
  /// **'Включить фото'**
  String get setIncludePhotos;

  /// No description provided for @setIncludePhotosHint.
  ///
  /// In ru, this message translates to:
  /// **'Файл станет больше'**
  String get setIncludePhotosHint;

  /// No description provided for @setPhotosWebNote.
  ///
  /// In ru, this message translates to:
  /// **'В браузере фото не переносятся'**
  String get setPhotosWebNote;

  /// No description provided for @setImport.
  ///
  /// In ru, this message translates to:
  /// **'Импорт из JSON'**
  String get setImport;

  /// No description provided for @setImportHint.
  ///
  /// In ru, this message translates to:
  /// **'Заменит все данные на этом устройстве'**
  String get setImportHint;

  /// No description provided for @setRestart.
  ///
  /// In ru, this message translates to:
  /// **'Пройти анкету заново'**
  String get setRestart;

  /// No description provided for @setRestartHint.
  ///
  /// In ru, this message translates to:
  /// **'Ответы сохранятся, их можно будет изменить'**
  String get setRestartHint;

  /// No description provided for @setRestartMessage.
  ///
  /// In ru, this message translates to:
  /// **'Анкета начнётся с первого этапа. Введённые данные не удаляются.'**
  String get setRestartMessage;

  /// No description provided for @setRestartConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Начать заново'**
  String get setRestartConfirm;

  /// No description provided for @setSectionAbout.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get setSectionAbout;

  /// No description provided for @setVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get setVersion;

  /// No description provided for @setPlatform.
  ///
  /// In ru, this message translates to:
  /// **'Платформа'**
  String get setPlatform;

  /// No description provided for @setPlatformOther.
  ///
  /// In ru, this message translates to:
  /// **'Другая'**
  String get setPlatformOther;

  /// No description provided for @setCertExpires.
  ///
  /// In ru, this message translates to:
  /// **'Сертификат действует до'**
  String get setCertExpires;

  /// No description provided for @setGoalsCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} цель} few{{count} цели} many{{count} целей} other{{count} цели}}'**
  String setGoalsCount(int count);

  /// No description provided for @setHeightValue.
  ///
  /// In ru, this message translates to:
  /// **'{value} см'**
  String setHeightValue(String value);

  /// No description provided for @setWeightValue.
  ///
  /// In ru, this message translates to:
  /// **'{value} кг'**
  String setWeightValue(String value);

  /// No description provided for @setNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get setNoticeLabel;

  /// No description provided for @setWarningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get setWarningLabel;

  /// No description provided for @setErrorLabel.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get setErrorLabel;

  /// No description provided for @setExportReady.
  ///
  /// In ru, this message translates to:
  /// **'Файл резервной копии готов'**
  String get setExportReady;

  /// No description provided for @setExportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось подготовить файл. Попробуйте ещё раз.'**
  String get setExportFailed;

  /// No description provided for @setShareUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Отправка файлов недоступна на этом устройстве.'**
  String get setShareUnavailable;

  /// No description provided for @setPickUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Выбор файла недоступен на этом устройстве.'**
  String get setPickUnavailable;

  /// No description provided for @setImportPreviewTitle.
  ///
  /// In ru, this message translates to:
  /// **'Что будет импортировано'**
  String get setImportPreviewTitle;

  /// No description provided for @setImportExportedAt.
  ///
  /// In ru, this message translates to:
  /// **'Создан: {date}'**
  String setImportExportedAt(String date);

  /// No description provided for @setImportRows.
  ///
  /// In ru, this message translates to:
  /// **'{table}: {count}'**
  String setImportRows(String table, int count);

  /// No description provided for @setImportPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Файлов фото: {count}'**
  String setImportPhotos(int count);

  /// No description provided for @setImportNoPhotos.
  ///
  /// In ru, this message translates to:
  /// **'Фото в файле нет'**
  String get setImportNoPhotos;

  /// No description provided for @setImportWarning.
  ///
  /// In ru, this message translates to:
  /// **'Все текущие данные на этом устройстве будут заменены.'**
  String get setImportWarning;

  /// No description provided for @setImportReplace.
  ///
  /// In ru, this message translates to:
  /// **'Заменить все данные'**
  String get setImportReplace;

  /// No description provided for @setImportHoldHint.
  ///
  /// In ru, this message translates to:
  /// **'Удерживайте, чтобы подтвердить'**
  String get setImportHoldHint;

  /// No description provided for @setImportDone.
  ///
  /// In ru, this message translates to:
  /// **'Данные импортированы'**
  String get setImportDone;

  /// No description provided for @setImportFailed.
  ///
  /// In ru, this message translates to:
  /// **'Импорт не удался. Данные не изменены.'**
  String get setImportFailed;

  /// No description provided for @setErrNotJson.
  ///
  /// In ru, this message translates to:
  /// **'Файл не читается как JSON.'**
  String get setErrNotJson;

  /// No description provided for @setErrWrongFormat.
  ///
  /// In ru, this message translates to:
  /// **'Это не резервная копия Системы.'**
  String get setErrWrongFormat;

  /// No description provided for @setErrFormatVersion.
  ///
  /// In ru, this message translates to:
  /// **'Версия формата файла не поддерживается.'**
  String get setErrFormatVersion;

  /// No description provided for @setErrNewerSchema.
  ///
  /// In ru, this message translates to:
  /// **'Файл создан более новой версией приложения. Обновите приложение и повторите.'**
  String get setErrNewerSchema;

  /// No description provided for @setErrInvalid.
  ///
  /// In ru, this message translates to:
  /// **'Файл повреждён.'**
  String get setErrInvalid;

  /// No description provided for @setTableAppSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get setTableAppSettings;

  /// No description provided for @setTableProfiles.
  ///
  /// In ru, this message translates to:
  /// **'Профиль'**
  String get setTableProfiles;

  /// No description provided for @setTableBodyMeasurements.
  ///
  /// In ru, this message translates to:
  /// **'Замеры тела'**
  String get setTableBodyMeasurements;

  /// No description provided for @setTablePhotos.
  ///
  /// In ru, this message translates to:
  /// **'Записи фото'**
  String get setTablePhotos;

  /// No description provided for @setTableGoals.
  ///
  /// In ru, this message translates to:
  /// **'Цели'**
  String get setTableGoals;

  /// No description provided for @setTableScheduleSettings.
  ///
  /// In ru, this message translates to:
  /// **'Параметры расписания'**
  String get setTableScheduleSettings;

  /// No description provided for @setTableScheduleItems.
  ///
  /// In ru, this message translates to:
  /// **'Пункты расписания'**
  String get setTableScheduleItems;

  /// No description provided for @setTablePlans.
  ///
  /// In ru, this message translates to:
  /// **'Планы'**
  String get setTablePlans;

  /// No description provided for @setTableQuestionnaireSections.
  ///
  /// In ru, this message translates to:
  /// **'Разделы анкеты'**
  String get setTableQuestionnaireSections;

  /// No description provided for @setSectionQuests.
  ///
  /// In ru, this message translates to:
  /// **'Квесты'**
  String get setSectionQuests;

  /// No description provided for @setReminders.
  ///
  /// In ru, this message translates to:
  /// **'Напоминания'**
  String get setReminders;

  /// No description provided for @setRemindersHint.
  ///
  /// In ru, this message translates to:
  /// **'Тихие часы, повтор, упрёки'**
  String get setRemindersHint;

  /// No description provided for @setDiscipline.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины'**
  String get setDiscipline;

  /// No description provided for @setDisciplineHint.
  ///
  /// In ru, this message translates to:
  /// **'Подъём 6:00, отбой 22:00, доп. нагрузка'**
  String get setDisciplineHint;

  /// No description provided for @setBody.
  ///
  /// In ru, this message translates to:
  /// **'Тело и здоровье'**
  String get setBody;

  /// No description provided for @setBodyHint.
  ///
  /// In ru, this message translates to:
  /// **'Шаги, сон, замеры, фото, уход за кожей'**
  String get setBodyHint;

  /// No description provided for @setWorkouts.
  ///
  /// In ru, this message translates to:
  /// **'Тренировки'**
  String get setWorkouts;

  /// No description provided for @setWorkoutsHint.
  ///
  /// In ru, this message translates to:
  /// **'Программа под уровень, таймеры, голос'**
  String get setWorkoutsHint;

  /// No description provided for @shpNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get shpNoticeLabel;

  /// No description provided for @shpWarningLabel.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get shpWarningLabel;

  /// No description provided for @shpTitle.
  ///
  /// In ru, this message translates to:
  /// **'Магазин наград'**
  String get shpTitle;

  /// No description provided for @shpBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get shpBalance;

  /// No description provided for @shpClosedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Магазин закрыт: баланс отрицательный'**
  String get shpClosedMessage;

  /// No description provided for @shpClosedHint.
  ///
  /// In ru, this message translates to:
  /// **'Выполняйте квесты, чтобы вернуть баланс в плюс. Режим дисциплины уже назначен.'**
  String get shpClosedHint;

  /// No description provided for @shpRewards.
  ///
  /// In ru, this message translates to:
  /// **'Награды'**
  String get shpRewards;

  /// No description provided for @shpAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новая награда'**
  String get shpAdd;

  /// No description provided for @shpEmptyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Наград пока нет'**
  String get shpEmptyTitle;

  /// No description provided for @shpEmptyText.
  ///
  /// In ru, this message translates to:
  /// **'Награды придумываете вы и покупаете их за ◆. Нажмите на пример, чтобы заполнить форму:'**
  String get shpEmptyText;

  /// No description provided for @shpExampleChocolate.
  ///
  /// In ru, this message translates to:
  /// **'Шоколадка'**
  String get shpExampleChocolate;

  /// No description provided for @shpExampleFastFood.
  ///
  /// In ru, this message translates to:
  /// **'Фастфуд'**
  String get shpExampleFastFood;

  /// No description provided for @shpExampleGames.
  ///
  /// In ru, this message translates to:
  /// **'Час игр'**
  String get shpExampleGames;

  /// No description provided for @shpExampleFreeEvening.
  ///
  /// In ru, this message translates to:
  /// **'Вечер без квестов'**
  String get shpExampleFreeEvening;

  /// No description provided for @shpBuy.
  ///
  /// In ru, this message translates to:
  /// **'Купить'**
  String get shpBuy;

  /// No description provided for @shpLimitNone.
  ///
  /// In ru, this message translates to:
  /// **'Без лимита'**
  String get shpLimitNone;

  /// No description provided for @shpLimitDay.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} раз в день} few{{count} раза в день} many{{count} раз в день} other{{count} раза в день}}'**
  String shpLimitDay(int count);

  /// No description provided for @shpLimitWeek.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} раз в неделю} few{{count} раза в неделю} many{{count} раз в неделю} other{{count} раза в неделю}}'**
  String shpLimitWeek(int count);

  /// No description provided for @shpLimitMonth.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} раз в месяц} few{{count} раза в месяц} many{{count} раз в месяц} other{{count} раза в месяц}}'**
  String shpLimitMonth(int count);

  /// No description provided for @shpLimitLeft.
  ///
  /// In ru, this message translates to:
  /// **'осталось {count}'**
  String shpLimitLeft(int count);

  /// No description provided for @shpLimitReachedUntil.
  ///
  /// In ru, this message translates to:
  /// **'лимит исчерпан до {date}'**
  String shpLimitReachedUntil(String date);

  /// No description provided for @shpNotEnough.
  ///
  /// In ru, this message translates to:
  /// **'не хватает {count} ◆'**
  String shpNotEnough(int count);

  /// No description provided for @shpConfirmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите покупку'**
  String get shpConfirmTitle;

  /// No description provided for @shpConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'«{title}» за {price} ◆. Баланс после покупки: {after} ◆.'**
  String shpConfirmMessage(String title, int price, int after);

  /// No description provided for @shpBoughtMessage.
  ///
  /// In ru, this message translates to:
  /// **'Награда «{title}» получена. Система зафиксировала покупку.'**
  String shpBoughtMessage(String title);

  /// No description provided for @shpFailedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Покупка отклонена: недостаточно ◆ или магазин закрыт.'**
  String get shpFailedMessage;

  /// No description provided for @shpLimitReachedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Лимит этой награды на период исчерпан.'**
  String get shpLimitReachedMessage;

  /// No description provided for @shpHistory.
  ///
  /// In ru, this message translates to:
  /// **'История покупок'**
  String get shpHistory;

  /// No description provided for @shpHistoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Покупок пока нет'**
  String get shpHistoryEmpty;

  /// No description provided for @shpArchive.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get shpArchive;

  /// No description provided for @shpRestore.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть'**
  String get shpRestore;

  /// No description provided for @shpReorder.
  ///
  /// In ru, this message translates to:
  /// **'Порядок'**
  String get shpReorder;

  /// No description provided for @shpMoveUp.
  ///
  /// In ru, this message translates to:
  /// **'Выше'**
  String get shpMoveUp;

  /// No description provided for @shpMoveDown.
  ///
  /// In ru, this message translates to:
  /// **'Ниже'**
  String get shpMoveDown;

  /// No description provided for @shpEditorNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая награда'**
  String get shpEditorNew;

  /// No description provided for @shpEditorEdit.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get shpEditorEdit;

  /// No description provided for @shpFieldTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get shpFieldTitle;

  /// No description provided for @shpFieldTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: час игр'**
  String get shpFieldTitleHint;

  /// No description provided for @shpFieldPrice.
  ///
  /// In ru, this message translates to:
  /// **'Цена'**
  String get shpFieldPrice;

  /// No description provided for @shpFieldPriceHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько ◆ стоит награда'**
  String get shpFieldPriceHint;

  /// No description provided for @shpFieldLimit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит частоты'**
  String get shpFieldLimit;

  /// No description provided for @shpPeriodNone.
  ///
  /// In ru, this message translates to:
  /// **'Нет'**
  String get shpPeriodNone;

  /// No description provided for @shpPeriodDay.
  ///
  /// In ru, this message translates to:
  /// **'День'**
  String get shpPeriodDay;

  /// No description provided for @shpPeriodWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get shpPeriodWeek;

  /// No description provided for @shpPeriodMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get shpPeriodMonth;

  /// No description provided for @shpFieldLimitCount.
  ///
  /// In ru, this message translates to:
  /// **'Сколько раз за период'**
  String get shpFieldLimitCount;

  /// No description provided for @shpToArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архив'**
  String get shpToArchive;

  /// No description provided for @shpErrorPrice.
  ///
  /// In ru, this message translates to:
  /// **'От 1 до 100000'**
  String get shpErrorPrice;

  /// No description provided for @shpErrorCount.
  ///
  /// In ru, this message translates to:
  /// **'От 1 до 99'**
  String get shpErrorCount;

  /// No description provided for @dscTitle.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины'**
  String get dscTitle;

  /// No description provided for @dscStatus.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get dscStatus;

  /// No description provided for @dscOn.
  ///
  /// In ru, this message translates to:
  /// **'Включён'**
  String get dscOn;

  /// No description provided for @dscOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключен'**
  String get dscOff;

  /// No description provided for @dscReasonLabel.
  ///
  /// In ru, this message translates to:
  /// **'Причина'**
  String get dscReasonLabel;

  /// No description provided for @dscReasonDebt.
  ///
  /// In ru, this message translates to:
  /// **'отрицательный баланс'**
  String get dscReasonDebt;

  /// No description provided for @dscReasonManual.
  ///
  /// In ru, this message translates to:
  /// **'включён вручную'**
  String get dscReasonManual;

  /// No description provided for @dscReasonAi.
  ///
  /// In ru, this message translates to:
  /// **'решение Системы после срыва'**
  String get dscReasonAi;

  /// No description provided for @dscExitLabel.
  ///
  /// In ru, this message translates to:
  /// **'Выключится'**
  String get dscExitLabel;

  /// No description provided for @dscExitBalancePositive.
  ///
  /// In ru, this message translates to:
  /// **'когда баланс станет положительным'**
  String get dscExitBalancePositive;

  /// No description provided for @dscExitManual.
  ///
  /// In ru, this message translates to:
  /// **'вручную, когда баланс не отрицательный'**
  String get dscExitManual;

  /// No description provided for @dscSinceLabel.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get dscSinceLabel;

  /// No description provided for @dscOffText.
  ///
  /// In ru, this message translates to:
  /// **'Режим включается сам, если баланс ◆ уходит в минус. Можно включить и вручную.'**
  String get dscOffText;

  /// No description provided for @dscBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get dscBalance;

  /// No description provided for @dscToday.
  ///
  /// In ru, this message translates to:
  /// **'Правила на сегодня'**
  String get dscToday;

  /// No description provided for @dscRulesNote.
  ///
  /// In ru, this message translates to:
  /// **'Нагрузка — в пределах вашего уровня. Еда и сон не урезаются: отбой и подъём не сдвигаются позже обычных.'**
  String get dscRulesNote;

  /// No description provided for @dscCannotRefuse.
  ///
  /// In ru, this message translates to:
  /// **'Квесты режима нельзя отменить.'**
  String get dscCannotRefuse;

  /// No description provided for @dscPreviewNote.
  ///
  /// In ru, this message translates to:
  /// **'Так будет выглядеть день в режиме дисциплины.'**
  String get dscPreviewNote;

  /// No description provided for @dscBlockerTitle.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка приложений'**
  String get dscBlockerTitle;

  /// No description provided for @dscBlockerText.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка развлекательных приложений после отбоя появится позже.'**
  String get dscBlockerText;

  /// No description provided for @dscBlockerSoon.
  ///
  /// In ru, this message translates to:
  /// **'Позже'**
  String get dscBlockerSoon;

  /// No description provided for @dscEnable.
  ///
  /// In ru, this message translates to:
  /// **'Включить режим'**
  String get dscEnable;

  /// No description provided for @dscDisable.
  ///
  /// In ru, this message translates to:
  /// **'Выключить режим'**
  String get dscDisable;

  /// No description provided for @dscEnableConfirmMessage.
  ///
  /// In ru, this message translates to:
  /// **'Подъём в 6:00, отбой в 22:00, доп. нагрузка. Квесты режима нельзя отменить.'**
  String get dscEnableConfirmMessage;

  /// No description provided for @dscDisableLocked.
  ///
  /// In ru, this message translates to:
  /// **'Выключить нельзя, пока баланс отрицательный.'**
  String get dscDisableLocked;

  /// No description provided for @dscChangedOnMessage.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины включён. Подъём в 6:00, отбой в 22:00, доп. нагрузка.'**
  String get dscChangedOnMessage;

  /// No description provided for @dscChangedOffMessage.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины выключен.'**
  String get dscChangedOffMessage;

  /// No description provided for @dscQuestWake.
  ///
  /// In ru, this message translates to:
  /// **'Подъём в {time}'**
  String dscQuestWake(String time);

  /// No description provided for @dscQuestBed.
  ///
  /// In ru, this message translates to:
  /// **'Отбой в {time}'**
  String dscQuestBed(String time);

  /// No description provided for @dscQuestWorkout.
  ///
  /// In ru, this message translates to:
  /// **'Доп. тренировка: {minutes} мин'**
  String dscQuestWorkout(int minutes);

  /// No description provided for @dscQuestWalk.
  ///
  /// In ru, this message translates to:
  /// **'Спокойная прогулка: {minutes} мин'**
  String dscQuestWalk(int minutes);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ru', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ru':
      return AppLocalizationsRu();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
