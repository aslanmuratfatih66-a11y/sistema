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
