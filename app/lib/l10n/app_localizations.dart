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

  /// No description provided for @sumTitle.
  ///
  /// In ru, this message translates to:
  /// **'Итоги дня'**
  String get sumTitle;

  /// No description provided for @sumLine.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня выполнено {done} из {total}, баланс за день {diamonds} ◆.'**
  String sumLine(int done, int total, int diamonds);

  /// No description provided for @sumToneGood.
  ///
  /// In ru, this message translates to:
  /// **'Хороший день. Завтра — в том же темпе.'**
  String get sumToneGood;

  /// No description provided for @sumToneBad.
  ///
  /// In ru, this message translates to:
  /// **'Есть что подтянуть. Завтра — чище.'**
  String get sumToneBad;

  /// No description provided for @sumToneSoftGood.
  ///
  /// In ru, this message translates to:
  /// **'Ты молодец. Отдыхай, завтра продолжим.'**
  String get sumToneSoftGood;

  /// No description provided for @sumToneSoftBad.
  ///
  /// In ru, this message translates to:
  /// **'Ничего страшного. Высыпайся — завтра получится лучше.'**
  String get sumToneSoftBad;

  /// No description provided for @sumToneHarshGood.
  ///
  /// In ru, this message translates to:
  /// **'Принято. Не расслабляйся — завтра так же.'**
  String get sumToneHarshGood;

  /// No description provided for @sumToneHarshBad.
  ///
  /// In ru, this message translates to:
  /// **'Слабо. Завтра без оправданий.'**
  String get sumToneHarshBad;

  /// No description provided for @sumDone.
  ///
  /// In ru, this message translates to:
  /// **'выполнено'**
  String get sumDone;

  /// No description provided for @sumDiamonds.
  ///
  /// In ru, this message translates to:
  /// **'баллы'**
  String get sumDiamonds;

  /// No description provided for @sumXp.
  ///
  /// In ru, this message translates to:
  /// **'опыт'**
  String get sumXp;

  /// No description provided for @sumMistakes.
  ///
  /// In ru, this message translates to:
  /// **'Ошибки и незакрытое'**
  String get sumMistakes;

  /// No description provided for @sumDoneTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сделано'**
  String get sumDoneTitle;

  /// No description provided for @sumTomorrow.
  ///
  /// In ru, this message translates to:
  /// **'План на завтра'**
  String get sumTomorrow;

  /// No description provided for @sumTomorrowEmpty.
  ///
  /// In ru, this message translates to:
  /// **'На завтра квестов пока нет.'**
  String get sumTomorrowEmpty;

  /// No description provided for @sumMore.
  ///
  /// In ru, this message translates to:
  /// **'и ещё {n}'**
  String sumMore(int n);

  /// No description provided for @sumNotifTitle.
  ///
  /// In ru, this message translates to:
  /// **'Итоги дня'**
  String get sumNotifTitle;

  /// No description provided for @sumNotifBody.
  ///
  /// In ru, this message translates to:
  /// **'Подведём итоги перед отбоем — что сделано и что завтра.'**
  String get sumNotifBody;

  /// No description provided for @busyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Занятость'**
  String get busyTitle;

  /// No description provided for @busyHint.
  ///
  /// In ru, this message translates to:
  /// **'Квесты на это время сдвинутся на конец занятости без штрафа, напоминания будут тихими. Пары, работа и дорога из расписания учитываются сами.'**
  String get busyHint;

  /// No description provided for @busyActive.
  ///
  /// In ru, this message translates to:
  /// **'Занят до {time}'**
  String busyActive(String time);

  /// No description provided for @busyClear.
  ///
  /// In ru, this message translates to:
  /// **'Я освободился'**
  String get busyClear;

  /// No description provided for @busyHours.
  ///
  /// In ru, this message translates to:
  /// **'{h} ч'**
  String busyHours(int h);

  /// No description provided for @autoplanHidden.
  ///
  /// In ru, this message translates to:
  /// **'Автоплан: ещё заданий — {n}, откроются по очереди.'**
  String autoplanHidden(int n);

  /// No description provided for @habTitle.
  ///
  /// In ru, this message translates to:
  /// **'Привычки'**
  String get habTitle;

  /// No description provided for @habEmpty.
  ///
  /// In ru, this message translates to:
  /// **'От чего избавляемся? Добавьте привычку — Система посчитает дни без неё и сэкономленные деньги.'**
  String get habEmpty;

  /// No description provided for @habAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить привычку'**
  String get habAdd;

  /// No description provided for @habAddSave.
  ///
  /// In ru, this message translates to:
  /// **'Начать отсчёт'**
  String get habAddSave;

  /// No description provided for @habRulesHint.
  ///
  /// In ru, this message translates to:
  /// **'За серии — ◆ (1, 3, 7, 14, 30… дней). Честная отметка срыва — небольшой штраф, скрытый срыв обходится дороже.'**
  String get habRulesHint;

  /// No description provided for @habHelpHint.
  ///
  /// In ru, this message translates to:
  /// **'Если бросить тяжело — это нормально. Помогут врач или горячая линия (в России — 8-800-200-0-200, в Турции — ALO 171).'**
  String get habHelpHint;

  /// No description provided for @habRelapse.
  ///
  /// In ru, this message translates to:
  /// **'Был срыв'**
  String get habRelapse;

  /// No description provided for @habRelapseTitle.
  ///
  /// In ru, this message translates to:
  /// **'Срыв'**
  String get habRelapseTitle;

  /// No description provided for @habRelapseHint.
  ///
  /// In ru, this message translates to:
  /// **'Честно — значит мягко: −{n} ◆, серия начнётся заново, лучший результат сохранится. Что стало причиной?'**
  String habRelapseHint(int n);

  /// No description provided for @habNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get habNoticeLabel;

  /// No description provided for @habRemove.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get habRemove;

  /// No description provided for @habRemoveConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить привычку «{name}» и её историю?'**
  String habRemoveConfirm(String name);

  /// No description provided for @habDaysWithout.
  ///
  /// In ru, this message translates to:
  /// **'дн. без срыва'**
  String get habDaysWithout;

  /// No description provided for @habBest.
  ///
  /// In ru, this message translates to:
  /// **'рекорд {n}'**
  String habBest(int n);

  /// No description provided for @habNext.
  ///
  /// In ru, this message translates to:
  /// **'Следующая отметка — {days} дн.: +{diamonds} ◆'**
  String habNext(int days, int diamonds);

  /// No description provided for @habSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сэкономлено: {sum} ₽'**
  String habSaved(int sum);

  /// No description provided for @habLastTrigger.
  ///
  /// In ru, this message translates to:
  /// **'Последняя причина срыва: {trigger}'**
  String habLastTrigger(String trigger);

  /// No description provided for @habCustomTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get habCustomTitle;

  /// No description provided for @habDailyCost.
  ///
  /// In ru, this message translates to:
  /// **'Сколько уходило в день на привычку'**
  String get habDailyCost;

  /// No description provided for @habAlreadyDays.
  ///
  /// In ru, this message translates to:
  /// **'Уже не делаю, дней'**
  String get habAlreadyDays;

  /// No description provided for @habSmoking.
  ///
  /// In ru, this message translates to:
  /// **'Курение'**
  String get habSmoking;

  /// No description provided for @habVape.
  ///
  /// In ru, this message translates to:
  /// **'Вейп'**
  String get habVape;

  /// No description provided for @habAlcohol.
  ///
  /// In ru, this message translates to:
  /// **'Алкоголь'**
  String get habAlcohol;

  /// No description provided for @habSweets.
  ///
  /// In ru, this message translates to:
  /// **'Сладкое'**
  String get habSweets;

  /// No description provided for @habEnergy.
  ///
  /// In ru, this message translates to:
  /// **'Энергетики'**
  String get habEnergy;

  /// No description provided for @habPhone.
  ///
  /// In ru, this message translates to:
  /// **'Залипание в телефон'**
  String get habPhone;

  /// No description provided for @habLateSleep.
  ///
  /// In ru, this message translates to:
  /// **'Поздний отбой'**
  String get habLateSleep;

  /// No description provided for @habCustom.
  ///
  /// In ru, this message translates to:
  /// **'Своя привычка'**
  String get habCustom;

  /// No description provided for @habTrigStress.
  ///
  /// In ru, this message translates to:
  /// **'Стресс'**
  String get habTrigStress;

  /// No description provided for @habTrigBoredom.
  ///
  /// In ru, this message translates to:
  /// **'Скука'**
  String get habTrigBoredom;

  /// No description provided for @habTrigCompany.
  ///
  /// In ru, this message translates to:
  /// **'Компания'**
  String get habTrigCompany;

  /// No description provided for @habTrigTired.
  ///
  /// In ru, this message translates to:
  /// **'Усталость'**
  String get habTrigTired;

  /// No description provided for @habTrigHabitTime.
  ///
  /// In ru, this message translates to:
  /// **'Привычное время'**
  String get habTrigHabitTime;

  /// No description provided for @habTrigOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get habTrigOther;

  /// No description provided for @habReasonRelapse.
  ///
  /// In ru, this message translates to:
  /// **'Срыв привычки'**
  String get habReasonRelapse;

  /// No description provided for @dmTitle.
  ///
  /// In ru, this message translates to:
  /// **'Режимы дня'**
  String get dmTitle;

  /// No description provided for @dmAutoplan.
  ///
  /// In ru, this message translates to:
  /// **'Автоплан'**
  String get dmAutoplan;

  /// No description provided for @dmAutoplanHint.
  ///
  /// In ru, this message translates to:
  /// **'Видно только текущее задание; следующее откроется после него.'**
  String get dmAutoplanHint;

  /// No description provided for @dmAutoplanLocked.
  ///
  /// In ru, this message translates to:
  /// **'Откроется на {level} уровне.'**
  String dmAutoplanLocked(int level);

  /// No description provided for @dmAutoplanDiscipline.
  ///
  /// In ru, this message translates to:
  /// **'Автоплан в режиме дисциплины'**
  String get dmAutoplanDiscipline;

  /// No description provided for @dmBusySchedule.
  ///
  /// In ru, this message translates to:
  /// **'Занятость по расписанию'**
  String get dmBusySchedule;

  /// No description provided for @dmBusyScheduleHint.
  ///
  /// In ru, this message translates to:
  /// **'Пары, работа и дорога: квесты сдвигаются, напоминания тихие.'**
  String get dmBusyScheduleHint;

  /// No description provided for @dmAdaptive.
  ///
  /// In ru, this message translates to:
  /// **'Адаптивная сложность'**
  String get dmAdaptive;

  /// No description provided for @dmAdaptiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Нагрузка подстраивается под выполнение за 2 недели, не выше рамок плана.'**
  String get dmAdaptiveHint;

  /// No description provided for @dmAdaptiveCollecting.
  ///
  /// In ru, this message translates to:
  /// **'Собираю статистику (нужно 10+ закрытых квестов за 2 недели).'**
  String get dmAdaptiveCollecting;

  /// No description provided for @dmAdaptiveStatus.
  ///
  /// In ru, this message translates to:
  /// **'Нагрузка {pct}% к плану · выполнение {rate}% за 2 недели'**
  String dmAdaptiveStatus(String pct, int rate);

  /// No description provided for @dmSummary.
  ///
  /// In ru, this message translates to:
  /// **'Итоги дня перед отбоем'**
  String get dmSummary;

  /// No description provided for @dmSummaryHint.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление за 30 минут до отбоя: что сделано, баллы, план на завтра.'**
  String get dmSummaryHint;

  /// No description provided for @chrTapHoldHint.
  ///
  /// In ru, this message translates to:
  /// **'Подержи меня три секунды — поговорим.'**
  String get chrTapHoldHint;

  /// No description provided for @talkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разговор'**
  String get talkTitle;

  /// No description provided for @talkTextChat.
  ///
  /// In ru, this message translates to:
  /// **'Текст'**
  String get talkTextChat;

  /// No description provided for @talkStarting.
  ///
  /// In ru, this message translates to:
  /// **'Включаю микрофон…'**
  String get talkStarting;

  /// No description provided for @talkListening.
  ///
  /// In ru, this message translates to:
  /// **'Слушаю…'**
  String get talkListening;

  /// No description provided for @talkSpeaking.
  ///
  /// In ru, this message translates to:
  /// **'Отвечаю…'**
  String get talkSpeaking;

  /// No description provided for @talkPaused.
  ///
  /// In ru, this message translates to:
  /// **'Пауза. Коснитесь экрана, чтобы продолжить.'**
  String get talkPaused;

  /// No description provided for @talkOfflineHint.
  ///
  /// In ru, this message translates to:
  /// **'ИИ сейчас недоступен — отвечаю заготовкой.'**
  String get talkOfflineHint;

  /// No description provided for @talkExitHint.
  ///
  /// In ru, this message translates to:
  /// **'Смахните вниз, чтобы выйти. Коснитесь, чтобы перебить.'**
  String get talkExitHint;

  /// No description provided for @chrSemanticsTalk.
  ///
  /// In ru, this message translates to:
  /// **'{name}: нажмите — короткая реплика; удерживайте 3 секунды — живой разговор; смахните вниз, чтобы убрать'**
  String chrSemanticsTalk(String name);

  /// No description provided for @lvlPathTitle.
  ///
  /// In ru, this message translates to:
  /// **'Путь уровней'**
  String get lvlPathTitle;

  /// No description provided for @lvlPathOpenHint.
  ///
  /// In ru, this message translates to:
  /// **'Открыть путь уровней'**
  String get lvlPathOpenHint;

  /// No description provided for @lvlPathCurrent.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас'**
  String get lvlPathCurrent;

  /// No description provided for @lvlPathLevel.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}'**
  String lvlPathLevel(int level);

  /// No description provided for @lvlPathRank.
  ///
  /// In ru, this message translates to:
  /// **'Ранг {rank}'**
  String lvlPathRank(String rank);

  /// No description provided for @lvlPathXp.
  ///
  /// In ru, this message translates to:
  /// **'{into} / {need} опыта'**
  String lvlPathXp(int into, int need);

  /// No description provided for @lvlPathXpLeft.
  ///
  /// In ru, this message translates to:
  /// **'До следующего уровня: {xp} опыта'**
  String lvlPathXpLeft(int xp);

  /// No description provided for @lvlPathXpTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего опыта: {xp}'**
  String lvlPathXpTotal(int xp);

  /// No description provided for @lvlPathNextReward.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшая награда — уровень {level}'**
  String lvlPathNextReward(int level);

  /// No description provided for @lvlPathPassedSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}, пройден'**
  String lvlPathPassedSemantics(int level);

  /// No description provided for @lvlPathCurrentSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}, текущий'**
  String lvlPathCurrentSemantics(int level);

  /// No description provided for @lvlPathLockedSemantics.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}, впереди'**
  String lvlPathLockedSemantics(int level);

  /// No description provided for @lvlRewardDiamonds.
  ///
  /// In ru, this message translates to:
  /// **'+{n} ◆'**
  String lvlRewardDiamonds(int n);

  /// No description provided for @lvlRewardStatPoints.
  ///
  /// In ru, this message translates to:
  /// **'+{n} очка характеристик'**
  String lvlRewardStatPoints(int n);

  /// No description provided for @lvlRewardSkin.
  ///
  /// In ru, this message translates to:
  /// **'Форма: {name}'**
  String lvlRewardSkin(String name);

  /// No description provided for @lvlRewardFeature.
  ///
  /// In ru, this message translates to:
  /// **'Открывается: {name}'**
  String lvlRewardFeature(String name);

  /// No description provided for @lvlRewardBoss.
  ///
  /// In ru, this message translates to:
  /// **'Босс: {name}'**
  String lvlRewardBoss(String name);

  /// No description provided for @lvlSkinAura.
  ///
  /// In ru, this message translates to:
  /// **'Голубая аура'**
  String get lvlSkinAura;

  /// No description provided for @lvlSkinCloak.
  ///
  /// In ru, this message translates to:
  /// **'Плащ теней'**
  String get lvlSkinCloak;

  /// No description provided for @lvlSkinArmor.
  ///
  /// In ru, this message translates to:
  /// **'Доспех охотника'**
  String get lvlSkinArmor;

  /// No description provided for @lvlSkinWings.
  ///
  /// In ru, this message translates to:
  /// **'Крылья света'**
  String get lvlSkinWings;

  /// No description provided for @lvlSkinCrown.
  ///
  /// In ru, this message translates to:
  /// **'Корона ранга S'**
  String get lvlSkinCrown;

  /// No description provided for @lvlSkinMonarch.
  ///
  /// In ru, this message translates to:
  /// **'Облик Монарха'**
  String get lvlSkinMonarch;

  /// No description provided for @lvlFeatAutoplan.
  ///
  /// In ru, this message translates to:
  /// **'режим «Автоплан»'**
  String get lvlFeatAutoplan;

  /// No description provided for @lvlFeatHunt.
  ///
  /// In ru, this message translates to:
  /// **'охота на монстров'**
  String get lvlFeatHunt;

  /// No description provided for @lvlFeatFriends.
  ///
  /// In ru, this message translates to:
  /// **'совместные квесты с друзьями'**
  String get lvlFeatFriends;

  /// No description provided for @lvlFeatRareHunt.
  ///
  /// In ru, this message translates to:
  /// **'редкие монстры в охоте'**
  String get lvlFeatRareHunt;

  /// No description provided for @lvlFeatGlobalRating.
  ///
  /// In ru, this message translates to:
  /// **'глобальный рейтинг'**
  String get lvlFeatGlobalRating;

  /// No description provided for @lvlBossShadowWolf.
  ///
  /// In ru, this message translates to:
  /// **'Теневой волк'**
  String get lvlBossShadowWolf;

  /// No description provided for @lvlBossIronGolem.
  ///
  /// In ru, this message translates to:
  /// **'Железный голем'**
  String get lvlBossIronGolem;

  /// No description provided for @lvlBossStormDrake.
  ///
  /// In ru, this message translates to:
  /// **'Грозовой дракон'**
  String get lvlBossStormDrake;

  /// No description provided for @lvlBossFrostWarden.
  ///
  /// In ru, this message translates to:
  /// **'Ледяной страж'**
  String get lvlBossFrostWarden;

  /// No description provided for @lvlBossAbyssLord.
  ///
  /// In ru, this message translates to:
  /// **'Владыка бездны'**
  String get lvlBossAbyssLord;

  /// No description provided for @qeTitleLevel5.
  ///
  /// In ru, this message translates to:
  /// **'Пробуждённый'**
  String get qeTitleLevel5;

  /// No description provided for @qeTitleLevel20.
  ///
  /// In ru, this message translates to:
  /// **'Закалённый'**
  String get qeTitleLevel20;

  /// No description provided for @qeTitleLevel35.
  ///
  /// In ru, this message translates to:
  /// **'Неудержимый'**
  String get qeTitleLevel35;

  /// No description provided for @qeTitleLevel75.
  ///
  /// In ru, this message translates to:
  /// **'Легенда'**
  String get qeTitleLevel75;

  /// No description provided for @qeTitleLevel100.
  ///
  /// In ru, this message translates to:
  /// **'Монарх'**
  String get qeTitleLevel100;

  /// No description provided for @navHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье'**
  String get navHealth;

  /// No description provided for @navSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get navSettings;

  /// No description provided for @healthBody.
  ///
  /// In ru, this message translates to:
  /// **'Тело'**
  String get healthBody;

  /// No description provided for @shopTabPoints.
  ///
  /// In ru, this message translates to:
  /// **'За баллы'**
  String get shopTabPoints;

  /// No description provided for @shopTabPurchases.
  ///
  /// In ru, this message translates to:
  /// **'Покупки'**
  String get shopTabPurchases;

  /// No description provided for @moreAddExpense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get moreAddExpense;

  /// No description provided for @moreSections.
  ///
  /// In ru, this message translates to:
  /// **'Разделы'**
  String get moreSections;

  /// No description provided for @moreSettingsHint.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт, анкета, напоминания, голос, язык, данные'**
  String get moreSettingsHint;

  /// No description provided for @setSectionAi.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж и ИИ'**
  String get setSectionAi;

  /// No description provided for @mktSettingsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Покупки'**
  String get mktSettingsTitle;

  /// No description provided for @mktSettingsHint.
  ///
  /// In ru, this message translates to:
  /// **'Магазины и бюджет для подборки ИИ'**
  String get mktSettingsHint;

  /// No description provided for @mktSettingsStores.
  ///
  /// In ru, this message translates to:
  /// **'Магазины'**
  String get mktSettingsStores;

  /// No description provided for @mktSettingsBudget.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет на покупки в месяц'**
  String get mktSettingsBudget;

  /// No description provided for @mktSettingsBudgetHint.
  ///
  /// In ru, this message translates to:
  /// **'Товары дороже помечаются «не по бюджету». Пусто — без лимита.'**
  String get mktSettingsBudgetHint;

  /// No description provided for @homeQuickFood.
  ///
  /// In ru, this message translates to:
  /// **'Еда'**
  String get homeQuickFood;

  /// No description provided for @homeQuickWorkout.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка'**
  String get homeQuickWorkout;

  /// No description provided for @homeQuickWalk.
  ///
  /// In ru, this message translates to:
  /// **'Прогулка'**
  String get homeQuickWalk;

  /// No description provided for @homeQuickWaterAdded.
  ///
  /// In ru, this message translates to:
  /// **'Вода записана'**
  String get homeQuickWaterAdded;

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

  /// No description provided for @bdyEnergy.
  ///
  /// In ru, this message translates to:
  /// **'Энергия'**
  String get bdyEnergy;

  /// No description provided for @bdyHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get bdyHistory;

  /// No description provided for @bdyCharts.
  ///
  /// In ru, this message translates to:
  /// **'Графики'**
  String get bdyCharts;

  /// No description provided for @bdySleepTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сон'**
  String get bdySleepTitle;

  /// No description provided for @bdySleepLog.
  ///
  /// In ru, this message translates to:
  /// **'Записать сон'**
  String get bdySleepLog;

  /// No description provided for @bdySleepNotLogged.
  ///
  /// In ru, this message translates to:
  /// **'Сон за прошлую ночь не записан.'**
  String get bdySleepNotLogged;

  /// No description provided for @bdySleepLastNight.
  ///
  /// In ru, this message translates to:
  /// **'Прошлая ночь'**
  String get bdySleepLastNight;

  /// No description provided for @bdySleepDuration.
  ///
  /// In ru, this message translates to:
  /// **'Длительность'**
  String get bdySleepDuration;

  /// No description provided for @bdySleepTarget.
  ///
  /// In ru, this message translates to:
  /// **'Цель плана'**
  String get bdySleepTarget;

  /// No description provided for @bdySleepAverage.
  ///
  /// In ru, this message translates to:
  /// **'В среднем'**
  String get bdySleepAverage;

  /// No description provided for @bdySleepVsTarget.
  ///
  /// In ru, this message translates to:
  /// **'Против цели'**
  String get bdySleepVsTarget;

  /// No description provided for @bdySleepOnTarget.
  ///
  /// In ru, this message translates to:
  /// **'Ночей не меньше цели'**
  String get bdySleepOnTarget;

  /// No description provided for @bdySleepEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока нет записей сна.'**
  String get bdySleepEmpty;

  /// No description provided for @bdySleepChartLabel.
  ///
  /// In ru, this message translates to:
  /// **'График сна по дням, линия — цель плана'**
  String get bdySleepChartLabel;

  /// No description provided for @bdySleepHistory.
  ///
  /// In ru, this message translates to:
  /// **'Сон за {days} дн.'**
  String bdySleepHistory(int days);

  /// No description provided for @bdySleepWakeDay.
  ///
  /// In ru, this message translates to:
  /// **'Утро (день подъёма)'**
  String get bdySleepWakeDay;

  /// No description provided for @bdySleepBed.
  ///
  /// In ru, this message translates to:
  /// **'Лёг'**
  String get bdySleepBed;

  /// No description provided for @bdySleepWake.
  ///
  /// In ru, this message translates to:
  /// **'Встал'**
  String get bdySleepWake;

  /// No description provided for @bdySleepQuality.
  ///
  /// In ru, this message translates to:
  /// **'Качество сна'**
  String get bdySleepQuality;

  /// No description provided for @bdySleepQualityHint.
  ///
  /// In ru, this message translates to:
  /// **'1 — плохо, 5 — отлично'**
  String get bdySleepQualityHint;

  /// No description provided for @bdySleepQualityShort.
  ///
  /// In ru, this message translates to:
  /// **'кач. {quality}/5'**
  String bdySleepQualityShort(int quality);

  /// No description provided for @bdyMeasureTitle.
  ///
  /// In ru, this message translates to:
  /// **'Замеры'**
  String get bdyMeasureTitle;

  /// No description provided for @bdyMeasureAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить замер'**
  String get bdyMeasureAdd;

  /// No description provided for @bdyMeasureHint.
  ///
  /// In ru, this message translates to:
  /// **'Заполните то, что измерили. Обхваты — сантиметровой лентой, утром, до еды.'**
  String get bdyMeasureHint;

  /// No description provided for @bdyMeasureEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Замеров пока нет.'**
  String get bdyMeasureEmpty;

  /// No description provided for @bdyMeasureNeedTwo.
  ///
  /// In ru, this message translates to:
  /// **'Для графика нужно хотя бы два замера.'**
  String get bdyMeasureNeedTwo;

  /// No description provided for @bdyMeasureChangeNote.
  ///
  /// In ru, this message translates to:
  /// **'В скобках — изменение за 30 дней'**
  String get bdyMeasureChangeNote;

  /// No description provided for @bdyMeasureChartLabel.
  ///
  /// In ru, this message translates to:
  /// **'График: {name}'**
  String bdyMeasureChartLabel(String name);

  /// No description provided for @bdyMeasureWeight.
  ///
  /// In ru, this message translates to:
  /// **'Вес'**
  String get bdyMeasureWeight;

  /// No description provided for @bdyMeasureWaist.
  ///
  /// In ru, this message translates to:
  /// **'Талия'**
  String get bdyMeasureWaist;

  /// No description provided for @bdyMeasureHips.
  ///
  /// In ru, this message translates to:
  /// **'Бёдра'**
  String get bdyMeasureHips;

  /// No description provided for @bdyMeasureChest.
  ///
  /// In ru, this message translates to:
  /// **'Грудь'**
  String get bdyMeasureChest;

  /// No description provided for @bdyMeasureNeck.
  ///
  /// In ru, this message translates to:
  /// **'Шея'**
  String get bdyMeasureNeck;

  /// No description provided for @bdyMeasureArm.
  ///
  /// In ru, this message translates to:
  /// **'Рука'**
  String get bdyMeasureArm;

  /// No description provided for @bdyMeasureBodyFat.
  ///
  /// In ru, this message translates to:
  /// **'% жира'**
  String get bdyMeasureBodyFat;

  /// No description provided for @bdyUnitKg.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get bdyUnitKg;

  /// No description provided for @bdyUnitCm.
  ///
  /// In ru, this message translates to:
  /// **'см'**
  String get bdyUnitCm;

  /// No description provided for @bdyPeriodAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get bdyPeriodAll;

  /// No description provided for @bdyPeriodDays.
  ///
  /// In ru, this message translates to:
  /// **'{days} дн.'**
  String bdyPeriodDays(int days);

  /// No description provided for @bdyPhotoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото-дневник'**
  String get bdyPhotoTitle;

  /// No description provided for @bdyPhotoKindBody.
  ///
  /// In ru, this message translates to:
  /// **'Тело'**
  String get bdyPhotoKindBody;

  /// No description provided for @bdyPhotoKindSkin.
  ///
  /// In ru, this message translates to:
  /// **'Кожа'**
  String get bdyPhotoKindSkin;

  /// No description provided for @bdyPhotoLast.
  ///
  /// In ru, this message translates to:
  /// **'Последнее фото'**
  String get bdyPhotoLast;

  /// No description provided for @bdyPhotoAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новое фото'**
  String get bdyPhotoAdd;

  /// No description provided for @bdyPhotoPose.
  ///
  /// In ru, this message translates to:
  /// **'Ракурс'**
  String get bdyPhotoPose;

  /// No description provided for @bdyPhotoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Снять'**
  String get bdyPhotoCamera;

  /// No description provided for @bdyPhotoGallery.
  ///
  /// In ru, this message translates to:
  /// **'Из галереи'**
  String get bdyPhotoGallery;

  /// No description provided for @bdyPhotoEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Фото пока нет.'**
  String get bdyPhotoEmpty;

  /// No description provided for @bdyPhotoCompare.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить'**
  String get bdyPhotoCompare;

  /// No description provided for @bdyPhotoCompareHint.
  ///
  /// In ru, this message translates to:
  /// **'Выберите два фото, чтобы сравнить «до» и «после».'**
  String get bdyPhotoCompareHint;

  /// No description provided for @bdyPhotoCompareNeedTwo.
  ///
  /// In ru, this message translates to:
  /// **'Для сравнения нужно хотя бы два фото.'**
  String get bdyPhotoCompareNeedTwo;

  /// No description provided for @bdyPoseOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get bdyPoseOther;

  /// No description provided for @bdyCompareSlider.
  ///
  /// In ru, this message translates to:
  /// **'Шторка'**
  String get bdyCompareSlider;

  /// No description provided for @bdyCompareSideBySide.
  ///
  /// In ru, this message translates to:
  /// **'Рядом'**
  String get bdyCompareSideBySide;

  /// No description provided for @bdyCompareBefore.
  ///
  /// In ru, this message translates to:
  /// **'До'**
  String get bdyCompareBefore;

  /// No description provided for @bdyCompareAfter.
  ///
  /// In ru, this message translates to:
  /// **'После'**
  String get bdyCompareAfter;

  /// No description provided for @bdyCompareNote.
  ///
  /// In ru, this message translates to:
  /// **'Снимайте при одинаковом свете и с одного расстояния — так сравнение честнее.'**
  String get bdyCompareNote;

  /// No description provided for @bdyCareTitle.
  ///
  /// In ru, this message translates to:
  /// **'Уход за кожей'**
  String get bdyCareTitle;

  /// No description provided for @bdyCareOpen.
  ///
  /// In ru, this message translates to:
  /// **'Чек-лист'**
  String get bdyCareOpen;

  /// No description provided for @bdyCareMorning.
  ///
  /// In ru, this message translates to:
  /// **'Утро'**
  String get bdyCareMorning;

  /// No description provided for @bdyCareEvening.
  ///
  /// In ru, this message translates to:
  /// **'Вечер'**
  String get bdyCareEvening;

  /// No description provided for @bdyCareTemplateNote.
  ///
  /// In ru, this message translates to:
  /// **'Базовый шаблон по анкете. Подбор средств под вашу кожу появится позже.'**
  String get bdyCareTemplateNote;

  /// No description provided for @bdyCareSensitiveNote.
  ///
  /// In ru, this message translates to:
  /// **'Были реакции на средства: новое средство сначала пробуйте на небольшом участке кожи.'**
  String get bdyCareSensitiveNote;

  /// No description provided for @bdyCareCompleteNote.
  ///
  /// In ru, this message translates to:
  /// **'Рутина выполнена.'**
  String get bdyCareCompleteNote;

  /// No description provided for @bdyCareRoutineDone.
  ///
  /// In ru, this message translates to:
  /// **'{routine}: уход выполнен'**
  String bdyCareRoutineDone(String routine);

  /// No description provided for @bdyCareCleanse.
  ///
  /// In ru, this message translates to:
  /// **'Умыться мягким очищающим средством'**
  String get bdyCareCleanse;

  /// No description provided for @bdyCareCleanseGentle.
  ///
  /// In ru, this message translates to:
  /// **'без пересушивания'**
  String get bdyCareCleanseGentle;

  /// No description provided for @bdyCareColdRinse.
  ///
  /// In ru, this message translates to:
  /// **'Умыться прохладной водой'**
  String get bdyCareColdRinse;

  /// No description provided for @bdyCareMoisturize.
  ///
  /// In ru, this message translates to:
  /// **'Увлажняющий крем'**
  String get bdyCareMoisturize;

  /// No description provided for @bdyCareMoisturizeLight.
  ///
  /// In ru, this message translates to:
  /// **'лёгкая текстура'**
  String get bdyCareMoisturizeLight;

  /// No description provided for @bdyCareMoisturizeRich.
  ///
  /// In ru, this message translates to:
  /// **'плотнее, питательный'**
  String get bdyCareMoisturizeRich;

  /// No description provided for @bdyCareSunscreen.
  ///
  /// In ru, this message translates to:
  /// **'Солнцезащитный крем'**
  String get bdyCareSunscreen;

  /// No description provided for @bdyCareRemoveSunscreen.
  ///
  /// In ru, this message translates to:
  /// **'Смыть SPF и загрязнения'**
  String get bdyCareRemoveSunscreen;

  /// No description provided for @bdyCareAcne.
  ///
  /// In ru, this message translates to:
  /// **'Средство против воспалений (если есть)'**
  String get bdyCareAcne;

  /// No description provided for @bdyCareExfoliate.
  ///
  /// In ru, this message translates to:
  /// **'Мягкое отшелушивание'**
  String get bdyCareExfoliate;

  /// No description provided for @bdyCareHandsOff.
  ///
  /// In ru, this message translates to:
  /// **'Не трогать и не выдавливать'**
  String get bdyCareHandsOff;

  /// No description provided for @bdySkinType.
  ///
  /// In ru, this message translates to:
  /// **'Тип кожи (по анкете)'**
  String get bdySkinType;

  /// No description provided for @bdySkinNormal.
  ///
  /// In ru, this message translates to:
  /// **'Нормальная'**
  String get bdySkinNormal;

  /// No description provided for @bdySkinOily.
  ///
  /// In ru, this message translates to:
  /// **'Жирная'**
  String get bdySkinOily;

  /// No description provided for @bdySkinCombination.
  ///
  /// In ru, this message translates to:
  /// **'Комбинированная'**
  String get bdySkinCombination;

  /// No description provided for @bdySkinDry.
  ///
  /// In ru, this message translates to:
  /// **'Сухая'**
  String get bdySkinDry;

  /// No description provided for @bdySkinUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Не определён'**
  String get bdySkinUnknown;

  /// No description provided for @bdySwellTitle.
  ///
  /// In ru, this message translates to:
  /// **'Отёки'**
  String get bdySwellTitle;

  /// No description provided for @bdySwellOpen.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get bdySwellOpen;

  /// No description provided for @bdySwellMorningPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Утреннее фото лица'**
  String get bdySwellMorningPhoto;

  /// No description provided for @bdySwellPhotoHint.
  ///
  /// In ru, this message translates to:
  /// **'Сделайте фото анфас сразу после подъёма — по ленте снимков виден тренд.'**
  String get bdySwellPhotoHint;

  /// No description provided for @bdySwellTakenToday.
  ///
  /// In ru, this message translates to:
  /// **'Утреннее фото на сегодня есть.'**
  String get bdySwellTakenToday;

  /// No description provided for @bdySwellTipShort.
  ///
  /// In ru, this message translates to:
  /// **'Акценты: меньше соли вечером, вода днём, сон по плану.'**
  String get bdySwellTipShort;

  /// No description provided for @bdySwellTipsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подсказки'**
  String get bdySwellTipsTitle;

  /// No description provided for @bdySwellTipSalt.
  ///
  /// In ru, this message translates to:
  /// **'Солёное и фастфуд лучше не есть поздно вечером.'**
  String get bdySwellTipSalt;

  /// No description provided for @bdySwellTipWater.
  ///
  /// In ru, this message translates to:
  /// **'Пейте воду равномерно в течение дня, а не всё перед сном.'**
  String get bdySwellTipWater;

  /// No description provided for @bdySwellTipSleep.
  ///
  /// In ru, this message translates to:
  /// **'Высыпайтесь и ложитесь в одно время — недосып заметен на лице утром.'**
  String get bdySwellTipSleep;

  /// No description provided for @bdySwellNote.
  ///
  /// In ru, this message translates to:
  /// **'Если отёки сильные, появились внезапно или не проходят — покажитесь врачу.'**
  String get bdySwellNote;

  /// No description provided for @bdySwellTrend.
  ///
  /// In ru, this message translates to:
  /// **'Тренд по утрам'**
  String get bdySwellTrend;

  /// No description provided for @bdySwellEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Утренних фото пока нет.'**
  String get bdySwellEmpty;

  /// No description provided for @bdySwellCompareFirst.
  ///
  /// In ru, this message translates to:
  /// **'Сравнить первое и последнее'**
  String get bdySwellCompareFirst;

  /// No description provided for @blkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка приложений'**
  String get blkTitle;

  /// No description provided for @blkOverlayTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система: отбой'**
  String get blkOverlayTitle;

  /// No description provided for @blkOverlayBody.
  ///
  /// In ru, this message translates to:
  /// **'Время сна. Развлечения закрыты до {time}. Положите телефон — завтра нужен ясный ум.'**
  String blkOverlayBody(String time);

  /// No description provided for @blkOverlayButton.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get blkOverlayButton;

  /// No description provided for @blkNotifTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система: отбой'**
  String get blkNotifTitle;

  /// No description provided for @blkNotifBody.
  ///
  /// In ru, this message translates to:
  /// **'Отвлекающие приложения закрыты до {time}'**
  String blkNotifBody(String time);

  /// No description provided for @blkIntro.
  ///
  /// In ru, this message translates to:
  /// **'В режиме дисциплины после отбоя отвлекающие приложения закрываются экраном «Система: отбой». Попытки записываются; с третьей за ночь — штраф {diamonds} ◆.'**
  String blkIntro(String diamonds);

  /// No description provided for @blkStatusTitle.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get blkStatusTitle;

  /// No description provided for @blkDisciplineOn.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины включён. Блокировка: {from}–{until}.'**
  String blkDisciplineOn(String from, String until);

  /// No description provided for @blkDisciplineOff.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины выключен — блокировка не действует. Окно режима: {from}–{until}.'**
  String blkDisciplineOff(String from, String until);

  /// No description provided for @blkActiveNow.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка действует сейчас'**
  String get blkActiveNow;

  /// No description provided for @blkReady.
  ///
  /// In ru, this message translates to:
  /// **'Готово к работе'**
  String get blkReady;

  /// No description provided for @blkNotReady.
  ///
  /// In ru, this message translates to:
  /// **'Нужны разрешения'**
  String get blkNotReady;

  /// No description provided for @blkNoApps.
  ///
  /// In ru, this message translates to:
  /// **'Не выбрано ни одного приложения'**
  String get blkNoApps;

  /// No description provided for @blkPermsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения'**
  String get blkPermsTitle;

  /// No description provided for @blkUsageAccess.
  ///
  /// In ru, this message translates to:
  /// **'Доступ к истории использования'**
  String get blkUsageAccess;

  /// No description provided for @blkUsageAccessHint.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы видеть, какое приложение открыто сейчас.'**
  String get blkUsageAccessHint;

  /// No description provided for @blkOverlayPerm.
  ///
  /// In ru, this message translates to:
  /// **'Поверх других приложений'**
  String get blkOverlayPerm;

  /// No description provided for @blkOverlayPermHint.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы показать экран «Система: отбой».'**
  String get blkOverlayPermHint;

  /// No description provided for @blkGranted.
  ///
  /// In ru, this message translates to:
  /// **'Выдано'**
  String get blkGranted;

  /// No description provided for @blkNotGranted.
  ///
  /// In ru, this message translates to:
  /// **'Не выдано'**
  String get blkNotGranted;

  /// No description provided for @blkOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get blkOpenSettings;

  /// No description provided for @blkNotifHint.
  ///
  /// In ru, this message translates to:
  /// **'Во время блокировки в шторке висит уведомление Системы — так Android не остановит проверку.'**
  String get blkNotifHint;

  /// No description provided for @blkAppsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Приложения'**
  String get blkAppsTitle;

  /// No description provided for @blkAppsHint.
  ///
  /// In ru, this message translates to:
  /// **'Отмеченные закрываются после отбоя. Известные развлекательные отмечены по умолчанию.'**
  String get blkAppsHint;

  /// No description provided for @blkAppsSelected.
  ///
  /// In ru, this message translates to:
  /// **'Выбрано: {count}'**
  String blkAppsSelected(int count);

  /// No description provided for @blkAppsLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загружаю список приложений…'**
  String get blkAppsLoading;

  /// No description provided for @blkAppsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Приложения не найдены'**
  String get blkAppsEmpty;

  /// No description provided for @blkSearch.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get blkSearch;

  /// No description provided for @blkShowAll.
  ///
  /// In ru, this message translates to:
  /// **'Показать все'**
  String get blkShowAll;

  /// No description provided for @blkShowSelected.
  ///
  /// In ru, this message translates to:
  /// **'Только выбранные'**
  String get blkShowSelected;

  /// No description provided for @blkUnsupported.
  ///
  /// In ru, this message translates to:
  /// **'На этом устройстве блокировка недоступна.'**
  String get blkUnsupported;

  /// No description provided for @blkAttemptsTonight.
  ///
  /// In ru, this message translates to:
  /// **'Попыток за эту ночь: {count}'**
  String blkAttemptsTonight(int count);

  /// No description provided for @blkIosIntro.
  ///
  /// In ru, this message translates to:
  /// **'На iPhone прямой блокировки нет. Настройте личные автоматизации «Команд»: при открытии приложения сразу откроется Система. После отбоя она покажет «Система: отбой» и запишет попытку, днём — ответит «Сейчас можно».'**
  String get blkIosIntro;

  /// No description provided for @blkIosPickTitle.
  ///
  /// In ru, this message translates to:
  /// **'1. Какие приложения'**
  String get blkIosPickTitle;

  /// No description provided for @blkIosGames.
  ///
  /// In ru, this message translates to:
  /// **'Игры (любая игра)'**
  String get blkIosGames;

  /// No description provided for @blkIosStepsTitle.
  ///
  /// In ru, this message translates to:
  /// **'2. Автоматизация для каждого приложения'**
  String get blkIosStepsTitle;

  /// No description provided for @blkIosStep1.
  ///
  /// In ru, this message translates to:
  /// **'Откройте приложение «Команды» → вкладка «Автоматизация» → «+» («Новая автоматизация»).'**
  String get blkIosStep1;

  /// No description provided for @blkIosStep2.
  ///
  /// In ru, this message translates to:
  /// **'Выберите «Приложение», нажмите «Выбрать» и отметьте приложение (можно сразу несколько — тогда ссылка одна, например для игр).'**
  String get blkIosStep2;

  /// No description provided for @blkIosStep3.
  ///
  /// In ru, this message translates to:
  /// **'Отметьте «Открыто», выберите «Выполнять сразу» и нажмите «Далее».'**
  String get blkIosStep3;

  /// No description provided for @blkIosStep4.
  ///
  /// In ru, this message translates to:
  /// **'«Новая пустая автоматизация» → «Добавить действие» → найдите «Открыть URL».'**
  String get blkIosStep4;

  /// No description provided for @blkIosStep5.
  ///
  /// In ru, this message translates to:
  /// **'Вставьте ссылку этого приложения (кнопка «Скопировать» ниже) и нажмите «Готово».'**
  String get blkIosStep5;

  /// No description provided for @blkIosStep6.
  ///
  /// In ru, this message translates to:
  /// **'Повторите для остальных приложений. Проверьте: откройте приложение — должна открыться Система.'**
  String get blkIosStep6;

  /// No description provided for @blkIosLinksTitle.
  ///
  /// In ru, this message translates to:
  /// **'3. Ссылки'**
  String get blkIosLinksTitle;

  /// No description provided for @blkIosLinksEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Сначала выберите приложения выше.'**
  String get blkIosLinksEmpty;

  /// No description provided for @blkCopy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get blkCopy;

  /// No description provided for @blkCopied.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка скопирована: {app}'**
  String blkCopied(String app);

  /// No description provided for @blkIosFocusTitle.
  ///
  /// In ru, this message translates to:
  /// **'Совет: фокус-режим «Сон»'**
  String get blkIosFocusTitle;

  /// No description provided for @blkIosFocusBody.
  ///
  /// In ru, this message translates to:
  /// **'Настройки → Фокусирование → «Сон»: включайте по расписанию с отбоя до подъёма, скройте уведомления отвлекающих приложений и оставьте на главном экране только нужное.'**
  String get blkIosFocusBody;

  /// No description provided for @blkIosAlwaysNote.
  ///
  /// In ru, this message translates to:
  /// **'Автоматизация срабатывает в любое время — решает Система: блок действует только после отбоя в режиме дисциплины.'**
  String get blkIosAlwaysNote;

  /// No description provided for @blkBlockedLabel.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get blkBlockedLabel;

  /// No description provided for @blkBlockedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система: отбой'**
  String get blkBlockedTitle;

  /// No description provided for @blkBlockedMessageApp.
  ///
  /// In ru, this message translates to:
  /// **'{app} закрыт до {time}. Сон — тоже тренировка. Положите телефон.'**
  String blkBlockedMessageApp(String app, String time);

  /// No description provided for @blkBlockedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Развлечения закрыты до {time}. Сон — тоже тренировка. Положите телефон.'**
  String blkBlockedMessage(String time);

  /// No description provided for @blkPenaltyApplied.
  ///
  /// In ru, this message translates to:
  /// **'Повторная попытка: −{diamonds} ◆'**
  String blkPenaltyApplied(String diamonds);

  /// No description provided for @blkPenaltyWarning.
  ///
  /// In ru, this message translates to:
  /// **'С третьей попытки за ночь — штраф {diamonds} ◆ за каждую.'**
  String blkPenaltyWarning(String diamonds);

  /// No description provided for @blkClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get blkClose;

  /// No description provided for @blkAllowedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас можно'**
  String get blkAllowedTitle;

  /// No description provided for @blkAllowedMessage.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка сейчас не действует. Отдыхайте — в меру.'**
  String get blkAllowedMessage;

  /// No description provided for @blkChecking.
  ///
  /// In ru, this message translates to:
  /// **'Проверяю…'**
  String get blkChecking;

  /// No description provided for @blkReasonBlockedAttempt.
  ///
  /// In ru, this message translates to:
  /// **'Попытка открыть приложение после отбоя'**
  String get blkReasonBlockedAttempt;

  /// No description provided for @chrSemanticsChat.
  ///
  /// In ru, this message translates to:
  /// **'{name}: нажмите, чтобы открыть чат; удерживайте — меню; смахните вниз, чтобы убрать'**
  String chrSemanticsChat(String name);

  /// No description provided for @chrMenuChat.
  ///
  /// In ru, this message translates to:
  /// **'Чат'**
  String get chrMenuChat;

  /// No description provided for @chrMenuPocket.
  ///
  /// In ru, this message translates to:
  /// **'В карман'**
  String get chrMenuPocket;

  /// No description provided for @chrPlayerFallback.
  ///
  /// In ru, this message translates to:
  /// **'Игрок'**
  String get chrPlayerFallback;

  /// No description provided for @chrDoneSoft1.
  ///
  /// In ru, this message translates to:
  /// **'{name}, «{quest}» готово! Я тобой горжусь.'**
  String chrDoneSoft1(String name, String quest);

  /// No description provided for @chrDoneSoft2.
  ///
  /// In ru, this message translates to:
  /// **'Видишь, получилось! «{quest}» выполнено, {name}.'**
  String chrDoneSoft2(String name, String quest);

  /// No description provided for @chrDoneNormal1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» — выполнено. Отлично, {name}!'**
  String chrDoneNormal1(String name, String quest);

  /// No description provided for @chrDoneNormal2.
  ///
  /// In ru, this message translates to:
  /// **'Есть! «{quest}» закрыт. Идём дальше, {name}.'**
  String chrDoneNormal2(String name, String quest);

  /// No description provided for @chrDoneStrict1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» засчитано. Так и держать, {name}.'**
  String chrDoneStrict1(String name, String quest);

  /// No description provided for @chrDoneStrict2.
  ///
  /// In ru, this message translates to:
  /// **'Принято: «{quest}». Следующий квест ждёт.'**
  String chrDoneStrict2(String name, String quest);

  /// No description provided for @chrDoneHarsh1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» сделано. Наконец-то. Не сбавляй темп, {name}.'**
  String chrDoneHarsh1(String name, String quest);

  /// No description provided for @chrDoneHarsh2.
  ///
  /// In ru, this message translates to:
  /// **'Засчитано: «{quest}». Это минимум, {name}. Дальше.'**
  String chrDoneHarsh2(String name, String quest);

  /// No description provided for @chrFailSoft1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» не вышло — ничего, {name}. Завтра получится.'**
  String chrFailSoft1(String name, String quest);

  /// No description provided for @chrFailSoft2.
  ///
  /// In ru, this message translates to:
  /// **'Жаль, «{quest}» сорвался. Отдохни и попробуем снова.'**
  String chrFailSoft2(String name, String quest);

  /// No description provided for @chrFailNormal1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» провален. Обидно, {name}. Соберись.'**
  String chrFailNormal1(String name, String quest);

  /// No description provided for @chrFailNormal2.
  ///
  /// In ru, this message translates to:
  /// **'Эх, «{quest}» не засчитан. В следующий раз — не упускай.'**
  String chrFailNormal2(String name, String quest);

  /// No description provided for @chrFailStrict1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» провален, {name}. Так не пойдёт. Исправляй.'**
  String chrFailStrict1(String name, String quest);

  /// No description provided for @chrFailStrict2.
  ///
  /// In ru, this message translates to:
  /// **'Провал: «{quest}». Слово дал — слово держи.'**
  String chrFailStrict2(String name, String quest);

  /// No description provided for @chrFailHarsh1.
  ///
  /// In ru, this message translates to:
  /// **'«{quest}» — провал! {name}, где дисциплина? Хватит оправданий!'**
  String chrFailHarsh1(String name, String quest);

  /// No description provided for @chrFailHarsh2.
  ///
  /// In ru, this message translates to:
  /// **'Опять сорвал «{quest}»?! Позор лени. Завтра — без поблажек.'**
  String chrFailHarsh2(String name, String quest);

  /// No description provided for @chrPenaltySoft.
  ///
  /// In ru, this message translates to:
  /// **'Штраф… Ничего, отыграемся.'**
  String get chrPenaltySoft;

  /// No description provided for @chrPenaltyNormal.
  ///
  /// In ru, this message translates to:
  /// **'Штраф. Давай без повторов.'**
  String get chrPenaltyNormal;

  /// No description provided for @chrPenaltyStrict.
  ///
  /// In ru, this message translates to:
  /// **'Штраф заслужен. Выводы сделаны?'**
  String get chrPenaltyStrict;

  /// No description provided for @chrPenaltyHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Штраф! Расплата за лень. Отрабатывай!'**
  String get chrPenaltyHarsh;

  /// No description provided for @chrLevelUp.
  ///
  /// In ru, this message translates to:
  /// **'Уровень {level}! Так держать, {name}!'**
  String chrLevelUp(int level, String name);

  /// No description provided for @chrIdleSoft1.
  ///
  /// In ru, this message translates to:
  /// **'{name}, я тут. Может, сделаем что-нибудь маленькое?'**
  String chrIdleSoft1(String name);

  /// No description provided for @chrIdleSoft2.
  ///
  /// In ru, this message translates to:
  /// **'Давно не виделись, {name}. Загляни в квесты, когда будешь готов.'**
  String chrIdleSoft2(String name);

  /// No description provided for @chrIdleNormal1.
  ///
  /// In ru, this message translates to:
  /// **'{name}, ты здесь? Квесты сами себя не сделают.'**
  String chrIdleNormal1(String name);

  /// No description provided for @chrIdleNormal2.
  ///
  /// In ru, this message translates to:
  /// **'Эй, {name}! Посмотри, что осталось на сегодня.'**
  String chrIdleNormal2(String name);

  /// No description provided for @chrIdleStrict1.
  ///
  /// In ru, this message translates to:
  /// **'{name}, перерыв затянулся. За дело.'**
  String chrIdleStrict1(String name);

  /// No description provided for @chrIdleStrict2.
  ///
  /// In ru, this message translates to:
  /// **'Время идёт, {name}. Список квестов — вот он.'**
  String chrIdleStrict2(String name);

  /// No description provided for @chrIdleHarsh1.
  ///
  /// In ru, this message translates to:
  /// **'{name}! Сколько можно бездельничать? Встал и пошёл выполнять!'**
  String chrIdleHarsh1(String name);

  /// No description provided for @chrIdleHarsh2.
  ///
  /// In ru, this message translates to:
  /// **'Хватит прохлаждаться, {name}. Квесты ждут — живо!'**
  String chrIdleHarsh2(String name);

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

  /// No description provided for @chtTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чат'**
  String get chtTitle;

  /// No description provided for @chtHint.
  ///
  /// In ru, this message translates to:
  /// **'Напиши персонажу…'**
  String get chtHint;

  /// No description provided for @chtEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Начни разговор: спроси о плане, попроси помочь или просто расскажи, как дела.'**
  String get chtEmpty;

  /// No description provided for @chtSend.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get chtSend;

  /// No description provided for @chtMic.
  ///
  /// In ru, this message translates to:
  /// **'Голосовой ввод: нажми или удерживай'**
  String get chtMic;

  /// No description provided for @chtListening.
  ///
  /// In ru, this message translates to:
  /// **'Слушаю…'**
  String get chtListening;

  /// No description provided for @chtMicUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание речи недоступно — проверь разрешение на микрофон и речь'**
  String get chtMicUnavailable;

  /// No description provided for @chtThinking.
  ///
  /// In ru, this message translates to:
  /// **'Печатает…'**
  String get chtThinking;

  /// No description provided for @chtAction.
  ///
  /// In ru, this message translates to:
  /// **'Система изменила план: {summary}'**
  String chtAction(String summary);

  /// No description provided for @chtUndo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить'**
  String get chtUndo;

  /// No description provided for @chtUndone.
  ///
  /// In ru, this message translates to:
  /// **'Отменено'**
  String get chtUndone;

  /// No description provided for @chtUndoFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось отменить'**
  String get chtUndoFailed;

  /// No description provided for @chtRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get chtRetry;

  /// No description provided for @chtVoiceOn.
  ///
  /// In ru, this message translates to:
  /// **'Озвучка ответов включена'**
  String get chtVoiceOn;

  /// No description provided for @chtVoiceOff.
  ///
  /// In ru, this message translates to:
  /// **'Озвучка ответов выключена'**
  String get chtVoiceOff;

  /// No description provided for @chtErrNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Чтобы говорить с ИИ, войди в аккаунт: Ещё → Аккаунт.'**
  String get chtErrNotSignedIn;

  /// No description provided for @chtErrOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Сообщение сохранено — нажми «Повторить», когда появится сеть.'**
  String get chtErrOffline;

  /// No description provided for @chtErrBudget.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет ИИ на этот месяц исчерпан. До следующего месяца персонаж отвечает шаблонами.'**
  String get chtErrBudget;

  /// No description provided for @chtErrUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ИИ сейчас недоступен. Попробуй чуть позже.'**
  String get chtErrUnavailable;

  /// No description provided for @chtErrRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много запросов. Подожди немного.'**
  String get chtErrRateLimited;

  /// No description provided for @chtErrServer.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера ИИ. Попробуй ещё раз.'**
  String get chtErrServer;

  /// No description provided for @chtFallbackSoft.
  ///
  /// In ru, this message translates to:
  /// **'Я сейчас не могу толком ответить, но я рядом. Делай по плану, шаг за шагом — у тебя получается.'**
  String get chtFallbackSoft;

  /// No description provided for @chtFallbackNormal.
  ///
  /// In ru, this message translates to:
  /// **'Связи с Системой нет. План в силе — выполняй задания, поговорим позже.'**
  String get chtFallbackNormal;

  /// No description provided for @chtFallbackStrict.
  ///
  /// In ru, this message translates to:
  /// **'Связи нет — это не повод расслабляться. Открой квесты и делай.'**
  String get chtFallbackStrict;

  /// No description provided for @chtFallbackHarsh.
  ///
  /// In ru, this message translates to:
  /// **'Сервер молчит, а ты чего ждёшь? Задания сами себя не сделают. Вперёд.'**
  String get chtFallbackHarsh;

  /// No description provided for @chtJournal.
  ///
  /// In ru, this message translates to:
  /// **'Журнал ИИ'**
  String get chtJournal;

  /// No description provided for @chtUsageTitle.
  ///
  /// In ru, this message translates to:
  /// **'Расходы ИИ'**
  String get chtUsageTitle;

  /// No description provided for @chtUsageMonth.
  ///
  /// In ru, this message translates to:
  /// **'{spent} из {budget} за месяц'**
  String chtUsageMonth(String spent, String budget);

  /// No description provided for @chtUsageToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня: {usd}'**
  String chtUsageToday(String usd);

  /// No description provided for @chtUsageDegraded.
  ///
  /// In ru, this message translates to:
  /// **'Экономный режим: бюджет почти исчерпан, ИИ работает на более дешёвых моделях'**
  String get chtUsageDegraded;

  /// No description provided for @chtUsageByTask.
  ///
  /// In ru, this message translates to:
  /// **'По задачам'**
  String get chtUsageByTask;

  /// No description provided for @chtUsageCalls.
  ///
  /// In ru, this message translates to:
  /// **'{count} выз.'**
  String chtUsageCalls(int count);

  /// No description provided for @chtUsageEmpty.
  ///
  /// In ru, this message translates to:
  /// **'В этом месяце ИИ ещё не использовался.'**
  String get chtUsageEmpty;

  /// No description provided for @chtTaskChat.
  ///
  /// In ru, this message translates to:
  /// **'Разговор'**
  String get chtTaskChat;

  /// No description provided for @chtTaskAnalysis.
  ///
  /// In ru, this message translates to:
  /// **'Анализ дня и недели'**
  String get chtTaskAnalysis;

  /// No description provided for @chtTaskPlan.
  ///
  /// In ru, this message translates to:
  /// **'Построение плана'**
  String get chtTaskPlan;

  /// No description provided for @chtTaskPlanEdit.
  ///
  /// In ru, this message translates to:
  /// **'Изменение плана'**
  String get chtTaskPlanEdit;

  /// No description provided for @chtTaskShort.
  ///
  /// In ru, this message translates to:
  /// **'Короткие реплики'**
  String get chtTaskShort;

  /// No description provided for @chtTaskBankParse.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления банков'**
  String get chtTaskBankParse;

  /// No description provided for @chtTaskFoodVision.
  ///
  /// In ru, this message translates to:
  /// **'Еда и чеки по фото'**
  String get chtTaskFoodVision;

  /// No description provided for @chtTaskBodyVision.
  ///
  /// In ru, this message translates to:
  /// **'Фото тела и кожи'**
  String get chtTaskBodyVision;

  /// No description provided for @chtTaskLearning.
  ///
  /// In ru, this message translates to:
  /// **'Обучение'**
  String get chtTaskLearning;

  /// No description provided for @chtTaskTts.
  ///
  /// In ru, this message translates to:
  /// **'Голос'**
  String get chtTaskTts;

  /// No description provided for @chtActionsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Действия ИИ'**
  String get chtActionsTitle;

  /// No description provided for @chtActionsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'ИИ пока ничего не менял.'**
  String get chtActionsEmpty;

  /// No description provided for @chtLoadFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить'**
  String get chtLoadFailed;

  /// No description provided for @chtVoiceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Голос персонажа'**
  String get chtVoiceTitle;

  /// No description provided for @chtVoiceSystem.
  ///
  /// In ru, this message translates to:
  /// **'Системный голос телефона'**
  String get chtVoiceSystem;

  /// No description provided for @chtVoiceSystemDesc.
  ///
  /// In ru, this message translates to:
  /// **'Работает без интернета и бесплатно'**
  String get chtVoiceSystemDesc;

  /// No description provided for @chtVoiceListen.
  ///
  /// In ru, this message translates to:
  /// **'Прослушать'**
  String get chtVoiceListen;

  /// No description provided for @chtVoiceEmpty.
  ///
  /// In ru, this message translates to:
  /// **'На сервере нет голосов для этого языка.'**
  String get chtVoiceEmpty;

  /// No description provided for @chtVoiceListenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось воспроизвести голос'**
  String get chtVoiceListenFailed;

  /// No description provided for @chtVoiceFemale.
  ///
  /// In ru, this message translates to:
  /// **'женский'**
  String get chtVoiceFemale;

  /// No description provided for @chtVoiceMale.
  ///
  /// In ru, this message translates to:
  /// **'мужской'**
  String get chtVoiceMale;

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

  /// No description provided for @almTitle.
  ///
  /// In ru, this message translates to:
  /// **'Будильники'**
  String get almTitle;

  /// No description provided for @almRingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Подъём!'**
  String get almRingTitle;

  /// No description provided for @almRingBodySquats.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Сделайте {count} приседание, чтобы выключить} few{Сделайте {count} приседания, чтобы выключить} other{Сделайте {count} приседаний, чтобы выключить}}'**
  String almRingBodySquats(int count);

  /// No description provided for @almRingBodyQr.
  ///
  /// In ru, this message translates to:
  /// **'Отсканируйте QR-код в другой комнате, чтобы выключить'**
  String get almRingBodyQr;

  /// No description provided for @almDoTask.
  ///
  /// In ru, this message translates to:
  /// **'Выполнить задание'**
  String get almDoTask;

  /// No description provided for @almStop.
  ///
  /// In ru, this message translates to:
  /// **'Стоп'**
  String get almStop;

  /// No description provided for @almChannelName.
  ///
  /// In ru, this message translates to:
  /// **'Будильник'**
  String get almChannelName;

  /// No description provided for @almChannelDesc.
  ///
  /// In ru, this message translates to:
  /// **'Звонок будильника-квеста'**
  String get almChannelDesc;

  /// No description provided for @almFallbackBody.
  ///
  /// In ru, this message translates to:
  /// **'Будильник не выключен — откройте приложение и выполните задание.'**
  String get almFallbackBody;

  /// No description provided for @almReasonWake.
  ///
  /// In ru, this message translates to:
  /// **'Подъём по будильнику'**
  String get almReasonWake;

  /// No description provided for @almPermTitle.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения'**
  String get almPermTitle;

  /// No description provided for @almPermReady.
  ///
  /// In ru, this message translates to:
  /// **'Будильник готов: звонит поверх экрана блокировки и выключается только заданием.'**
  String get almPermReady;

  /// No description provided for @almPermExact.
  ///
  /// In ru, this message translates to:
  /// **'Точные будильники'**
  String get almPermExact;

  /// No description provided for @almPermFullScreen.
  ///
  /// In ru, this message translates to:
  /// **'Показ поверх экрана блокировки'**
  String get almPermFullScreen;

  /// No description provided for @almPermNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get almPermNotifications;

  /// No description provided for @almPermAlarmKit.
  ///
  /// In ru, this message translates to:
  /// **'Системный будильник (AlarmKit)'**
  String get almPermAlarmKit;

  /// No description provided for @almPermFallback.
  ///
  /// In ru, this message translates to:
  /// **'Системный будильник недоступен — прозвонит серия громких уведомлений. Не включайте беззвучный режим и «Фокус» на ночь.'**
  String get almPermFallback;

  /// No description provided for @almPermBackup.
  ///
  /// In ru, this message translates to:
  /// **'Если выключить звонок кнопкой «Стоп», через 3 минуты пойдут уведомления, пока не выполните задание.'**
  String get almPermBackup;

  /// No description provided for @almPermGrant.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить'**
  String get almPermGrant;

  /// No description provided for @almPermOn.
  ///
  /// In ru, this message translates to:
  /// **'есть'**
  String get almPermOn;

  /// No description provided for @almPermOff.
  ///
  /// In ru, this message translates to:
  /// **'нет'**
  String get almPermOff;

  /// No description provided for @almEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Будильников пока нет. Добавьте первый — выключить его можно будет только заданием.'**
  String get almEmpty;

  /// No description provided for @almAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить будильник'**
  String get almAdd;

  /// No description provided for @almNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый будильник'**
  String get almNew;

  /// No description provided for @almEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Будильник'**
  String get almEditTitle;

  /// No description provided for @almDaysEveryday.
  ///
  /// In ru, this message translates to:
  /// **'Каждый день'**
  String get almDaysEveryday;

  /// No description provided for @almDaysWeekdays.
  ///
  /// In ru, this message translates to:
  /// **'По будням'**
  String get almDaysWeekdays;

  /// No description provided for @almDaysWeekend.
  ///
  /// In ru, this message translates to:
  /// **'По выходным'**
  String get almDaysWeekend;

  /// No description provided for @almDaysOnce.
  ///
  /// In ru, this message translates to:
  /// **'Один раз'**
  String get almDaysOnce;

  /// No description provided for @almDayMon.
  ///
  /// In ru, this message translates to:
  /// **'Пн'**
  String get almDayMon;

  /// No description provided for @almDayTue.
  ///
  /// In ru, this message translates to:
  /// **'Вт'**
  String get almDayTue;

  /// No description provided for @almDayWed.
  ///
  /// In ru, this message translates to:
  /// **'Ср'**
  String get almDayWed;

  /// No description provided for @almDayThu.
  ///
  /// In ru, this message translates to:
  /// **'Чт'**
  String get almDayThu;

  /// No description provided for @almDayFri.
  ///
  /// In ru, this message translates to:
  /// **'Пт'**
  String get almDayFri;

  /// No description provided for @almDaySat.
  ///
  /// In ru, this message translates to:
  /// **'Сб'**
  String get almDaySat;

  /// No description provided for @almDaySun.
  ///
  /// In ru, this message translates to:
  /// **'Вс'**
  String get almDaySun;

  /// No description provided for @almDaysHint.
  ///
  /// In ru, this message translates to:
  /// **'Не выбрано ни одного дня — будильник прозвонит один раз.'**
  String get almDaysHint;

  /// No description provided for @almTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get almTime;

  /// No description provided for @almDays.
  ///
  /// In ru, this message translates to:
  /// **'Дни'**
  String get almDays;

  /// No description provided for @almLabel.
  ///
  /// In ru, this message translates to:
  /// **'Подпись'**
  String get almLabel;

  /// No description provided for @almTask.
  ///
  /// In ru, this message translates to:
  /// **'Задание'**
  String get almTask;

  /// No description provided for @almTaskSquats.
  ///
  /// In ru, this message translates to:
  /// **'Приседания'**
  String get almTaskSquats;

  /// No description provided for @almTaskQr.
  ///
  /// In ru, this message translates to:
  /// **'QR-код'**
  String get almTaskQr;

  /// No description provided for @almTaskSquatsShort.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} приседание} few{{count} приседания} other{{count} приседаний}}'**
  String almTaskSquatsShort(int count);

  /// No description provided for @almSquatsCount.
  ///
  /// In ru, this message translates to:
  /// **'Количество приседаний'**
  String get almSquatsCount;

  /// No description provided for @almQrHint.
  ///
  /// In ru, this message translates to:
  /// **'Распечатайте код и повесьте в другой комнате — например, на кухне или в ванной. Чтобы выключить будильник, придётся встать и дойти до него.'**
  String get almQrHint;

  /// No description provided for @almQrShare.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться для печати'**
  String get almQrShare;

  /// No description provided for @almQrShareText.
  ///
  /// In ru, this message translates to:
  /// **'QR-код будильника «Системы». Повесьте его в другой комнате.'**
  String get almQrShareText;

  /// No description provided for @almQrRegenerate.
  ///
  /// In ru, this message translates to:
  /// **'Новый код'**
  String get almQrRegenerate;

  /// No description provided for @almQrShareFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось поделиться кодом.'**
  String get almQrShareFailed;

  /// No description provided for @almDiscipline.
  ///
  /// In ru, this message translates to:
  /// **'Режим дисциплины'**
  String get almDiscipline;

  /// No description provided for @almDisciplineHint.
  ///
  /// In ru, this message translates to:
  /// **'Подъём режима дисциплины: время и дни задаёт режим, задание можно сменить.'**
  String get almDisciplineHint;

  /// No description provided for @almTest.
  ///
  /// In ru, this message translates to:
  /// **'Проверить через 1 мин'**
  String get almTest;

  /// No description provided for @almTestScheduled.
  ///
  /// In ru, this message translates to:
  /// **'Проверочный звонок через минуту. Можно заблокировать экран.'**
  String get almTestScheduled;

  /// No description provided for @almTestRing.
  ///
  /// In ru, this message translates to:
  /// **'Проверка'**
  String get almTestRing;

  /// No description provided for @almDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить будильник?'**
  String get almDeleteConfirm;

  /// No description provided for @almNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Будильник не найден.'**
  String get almNotFound;

  /// No description provided for @almSquatsHint.
  ///
  /// In ru, this message translates to:
  /// **'Держите телефон у груди и приседайте до конца — вниз и вверх.'**
  String get almSquatsHint;

  /// No description provided for @almSquatsProgress.
  ///
  /// In ru, this message translates to:
  /// **'{done} / {total}'**
  String almSquatsProgress(int done, int total);

  /// No description provided for @almSensorError.
  ///
  /// In ru, this message translates to:
  /// **'Датчик движения недоступен.'**
  String get almSensorError;

  /// No description provided for @almHoldFallback.
  ///
  /// In ru, this message translates to:
  /// **'Удерживать, чтобы выключить'**
  String get almHoldFallback;

  /// No description provided for @almScanQr.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать QR'**
  String get almScanQr;

  /// No description provided for @almScanTitle.
  ///
  /// In ru, this message translates to:
  /// **'QR будильника'**
  String get almScanTitle;

  /// No description provided for @almScanHint.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру на напечатанный код.'**
  String get almScanHint;

  /// No description provided for @almScanNoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна. Разрешите доступ к камере в настройках.'**
  String get almScanNoCamera;

  /// No description provided for @almQrWrong.
  ///
  /// In ru, this message translates to:
  /// **'Это не тот код.'**
  String get almQrWrong;

  /// No description provided for @almQrMissing.
  ///
  /// In ru, this message translates to:
  /// **'Код для этого будильника не создан — выполните приседания.'**
  String get almQrMissing;

  /// No description provided for @almSnooze.
  ///
  /// In ru, this message translates to:
  /// **'Отложить на 5 мин (осталось {left})'**
  String almSnooze(int left);

  /// No description provided for @almSnoozeNone.
  ///
  /// In ru, this message translates to:
  /// **'Откладывать больше нельзя.'**
  String get almSnoozeNone;

  /// No description provided for @almReward.
  ///
  /// In ru, this message translates to:
  /// **'+{count} ◆ за подъём вовремя'**
  String almReward(int count);

  /// No description provided for @almDone.
  ///
  /// In ru, this message translates to:
  /// **'Подъём засчитан'**
  String get almDone;

  /// No description provided for @almDoneBody.
  ///
  /// In ru, this message translates to:
  /// **'Будильник выключен. Доброе утро!'**
  String get almDoneBody;

  /// No description provided for @finTitle.
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get finTitle;

  /// No description provided for @finBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get finBalance;

  /// No description provided for @finCryptoValue.
  ///
  /// In ru, this message translates to:
  /// **'Крипта'**
  String get finCryptoValue;

  /// No description provided for @finFreeToMonthEnd.
  ///
  /// In ru, this message translates to:
  /// **'Свободно до конца месяца'**
  String get finFreeToMonthEnd;

  /// No description provided for @finNextIncome.
  ///
  /// In ru, this message translates to:
  /// **'Ближайшее поступление'**
  String get finNextIncome;

  /// No description provided for @finMonthExpenses.
  ///
  /// In ru, this message translates to:
  /// **'Расходы за месяц'**
  String get finMonthExpenses;

  /// No description provided for @finMonthIncome.
  ///
  /// In ru, this message translates to:
  /// **'Доходы за месяц'**
  String get finMonthIncome;

  /// No description provided for @finMissingRates.
  ///
  /// In ru, this message translates to:
  /// **'Часть сумм без курса — не вошла в итог. Обновите курсы.'**
  String get finMissingRates;

  /// No description provided for @finRatesNever.
  ///
  /// In ru, this message translates to:
  /// **'Курсы ещё не загружались'**
  String get finRatesNever;

  /// No description provided for @finRatesUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Курсы: {time}'**
  String finRatesUpdated(String time);

  /// No description provided for @finRefreshRates.
  ///
  /// In ru, this message translates to:
  /// **'Обновить курсы'**
  String get finRefreshRates;

  /// No description provided for @finRefreshing.
  ///
  /// In ru, this message translates to:
  /// **'Обновляю…'**
  String get finRefreshing;

  /// No description provided for @finInput.
  ///
  /// In ru, this message translates to:
  /// **'Ввод'**
  String get finInput;

  /// No description provided for @finExpense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get finExpense;

  /// No description provided for @finIncome.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get finIncome;

  /// No description provided for @finTransfer.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get finTransfer;

  /// No description provided for @finExpenses.
  ///
  /// In ru, this message translates to:
  /// **'Расходы'**
  String get finExpenses;

  /// No description provided for @finIncomes.
  ///
  /// In ru, this message translates to:
  /// **'Доходы'**
  String get finIncomes;

  /// No description provided for @finReceiptQr.
  ///
  /// In ru, this message translates to:
  /// **'QR чека'**
  String get finReceiptQr;

  /// No description provided for @finReceiptPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото чека'**
  String get finReceiptPhoto;

  /// No description provided for @finBanks.
  ///
  /// In ru, this message translates to:
  /// **'Банки'**
  String get finBanks;

  /// No description provided for @finStatement.
  ///
  /// In ru, this message translates to:
  /// **'Выписка'**
  String get finStatement;

  /// No description provided for @finMarket.
  ///
  /// In ru, this message translates to:
  /// **'Маркет'**
  String get finMarket;

  /// No description provided for @finAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Счета'**
  String get finAccounts;

  /// No description provided for @finNoAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Счетов пока нет. Добавьте наличные или карту — или просто запишите расход, счёт «Наличные» создастся сам.'**
  String get finNoAccounts;

  /// No description provided for @finManageAccounts.
  ///
  /// In ru, this message translates to:
  /// **'Счета и крипта'**
  String get finManageAccounts;

  /// No description provided for @finBudgets.
  ///
  /// In ru, this message translates to:
  /// **'Лимиты'**
  String get finBudgets;

  /// No description provided for @finBudgetsEmptyShort.
  ///
  /// In ru, this message translates to:
  /// **'Лимитов нет.'**
  String get finBudgetsEmptyShort;

  /// No description provided for @finBudgetsProposed.
  ///
  /// In ru, this message translates to:
  /// **'Предложено ИИ: {n} — ждут подтверждения'**
  String finBudgetsProposed(int n);

  /// No description provided for @finManageBudgets.
  ///
  /// In ru, this message translates to:
  /// **'Настроить лимиты'**
  String get finManageBudgets;

  /// No description provided for @finSoon.
  ///
  /// In ru, this message translates to:
  /// **'Скоро'**
  String get finSoon;

  /// No description provided for @finChargeSoon.
  ///
  /// In ru, this message translates to:
  /// **'скоро списание'**
  String get finChargeSoon;

  /// No description provided for @finRecent.
  ///
  /// In ru, this message translates to:
  /// **'Последние операции'**
  String get finRecent;

  /// No description provided for @finNoOperations.
  ///
  /// In ru, this message translates to:
  /// **'Операций нет.'**
  String get finNoOperations;

  /// No description provided for @finAllOperations.
  ///
  /// In ru, this message translates to:
  /// **'Все операции'**
  String get finAllOperations;

  /// No description provided for @finMore.
  ///
  /// In ru, this message translates to:
  /// **'Разделы'**
  String get finMore;

  /// No description provided for @finReports.
  ///
  /// In ru, this message translates to:
  /// **'Отчёты'**
  String get finReports;

  /// No description provided for @finGoals.
  ///
  /// In ru, this message translates to:
  /// **'Цели накопления'**
  String get finGoals;

  /// No description provided for @finSubscriptions.
  ///
  /// In ru, this message translates to:
  /// **'Подписки'**
  String get finSubscriptions;

  /// No description provided for @finDebts.
  ///
  /// In ru, this message translates to:
  /// **'Долги'**
  String get finDebts;

  /// No description provided for @finSettings.
  ///
  /// In ru, this message translates to:
  /// **'Настройки финансов'**
  String get finSettings;

  /// No description provided for @finWarning.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение'**
  String get finWarning;

  /// No description provided for @finSaveError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить'**
  String get finSaveError;

  /// No description provided for @finAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get finAll;

  /// No description provided for @finChoose.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать'**
  String get finChoose;

  /// No description provided for @finTxNew.
  ///
  /// In ru, this message translates to:
  /// **'Новая операция'**
  String get finTxNew;

  /// No description provided for @finTxEdit.
  ///
  /// In ru, this message translates to:
  /// **'Операция'**
  String get finTxEdit;

  /// No description provided for @finTxDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить операцию?'**
  String get finTxDeleteConfirm;

  /// No description provided for @finAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get finAmount;

  /// No description provided for @finAccount.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get finAccount;

  /// No description provided for @finFromAccount.
  ///
  /// In ru, this message translates to:
  /// **'Со счёта'**
  String get finFromAccount;

  /// No description provided for @finToAccount.
  ///
  /// In ru, this message translates to:
  /// **'На счёт'**
  String get finToAccount;

  /// No description provided for @finToAmount.
  ///
  /// In ru, this message translates to:
  /// **'Зачислено'**
  String get finToAmount;

  /// No description provided for @finToAmountHint.
  ///
  /// In ru, this message translates to:
  /// **'Счета в разных валютах: укажите сумму зачисления, иначе — по курсу.'**
  String get finToAmountHint;

  /// No description provided for @finTransferNeedsTwo.
  ///
  /// In ru, this message translates to:
  /// **'Выберите два разных счёта'**
  String get finTransferNeedsTwo;

  /// No description provided for @finNoAccountsAuto.
  ///
  /// In ru, this message translates to:
  /// **'Наличные (создастся)'**
  String get finNoAccountsAuto;

  /// No description provided for @finNoAccountsAutoHint.
  ///
  /// In ru, this message translates to:
  /// **'Счёт «Наличные · RUB» будет создан автоматически.'**
  String get finNoAccountsAutoHint;

  /// No description provided for @finCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get finCategory;

  /// No description provided for @finCategoryAutoHint.
  ///
  /// In ru, this message translates to:
  /// **'не выбрана — Система угадает по месту покупки'**
  String get finCategoryAutoHint;

  /// No description provided for @finMerchant.
  ///
  /// In ru, this message translates to:
  /// **'Где'**
  String get finMerchant;

  /// No description provided for @finPayer.
  ///
  /// In ru, this message translates to:
  /// **'От кого'**
  String get finPayer;

  /// No description provided for @finDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get finDate;

  /// No description provided for @finTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get finTime;

  /// No description provided for @finNote.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get finNote;

  /// No description provided for @finSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get finSource;

  /// No description provided for @finNoCategory.
  ///
  /// In ru, this message translates to:
  /// **'Без категории'**
  String get finNoCategory;

  /// No description provided for @finOperations.
  ///
  /// In ru, this message translates to:
  /// **'Операции'**
  String get finOperations;

  /// No description provided for @finAddOperation.
  ///
  /// In ru, this message translates to:
  /// **'Добавить операцию'**
  String get finAddOperation;

  /// No description provided for @finOperationsCount.
  ///
  /// In ru, this message translates to:
  /// **'Операций: {n}'**
  String finOperationsCount(int n);

  /// No description provided for @finShowMore.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё'**
  String get finShowMore;

  /// No description provided for @finPeriodWeek.
  ///
  /// In ru, this message translates to:
  /// **'Неделя'**
  String get finPeriodWeek;

  /// No description provided for @finPeriodMonth.
  ///
  /// In ru, this message translates to:
  /// **'Месяц'**
  String get finPeriodMonth;

  /// No description provided for @finPeriodYear.
  ///
  /// In ru, this message translates to:
  /// **'Год'**
  String get finPeriodYear;

  /// No description provided for @finPeriodAll.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get finPeriodAll;

  /// No description provided for @finAccountAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить счёт'**
  String get finAccountAdd;

  /// No description provided for @finAccountNew.
  ///
  /// In ru, this message translates to:
  /// **'Новый счёт'**
  String get finAccountNew;

  /// No description provided for @finAccountEdit.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get finAccountEdit;

  /// No description provided for @finAccountDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить счёт? Операции останутся, но без счёта.'**
  String get finAccountDeleteConfirm;

  /// No description provided for @finAccountKind.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get finAccountKind;

  /// No description provided for @finAccKindCash.
  ///
  /// In ru, this message translates to:
  /// **'Наличные'**
  String get finAccKindCash;

  /// No description provided for @finAccKindCard.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get finAccKindCard;

  /// No description provided for @finAccKindDeposit.
  ///
  /// In ru, this message translates to:
  /// **'Вклад'**
  String get finAccKindDeposit;

  /// No description provided for @finAccKindCrypto.
  ///
  /// In ru, this message translates to:
  /// **'Крипто-кошелёк'**
  String get finAccKindCrypto;

  /// No description provided for @finAccountName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get finAccountName;

  /// No description provided for @finCurrency.
  ///
  /// In ru, this message translates to:
  /// **'Валюта'**
  String get finCurrency;

  /// No description provided for @finOpeningBalance.
  ///
  /// In ru, this message translates to:
  /// **'Начальный остаток'**
  String get finOpeningBalance;

  /// No description provided for @finOpeningBalanceHint.
  ///
  /// In ru, this message translates to:
  /// **'Сколько было на счёте до начала учёта.'**
  String get finOpeningBalanceHint;

  /// No description provided for @finBank.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get finBank;

  /// No description provided for @finBankHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: Сбер, Т-Банк, Ziraat'**
  String get finBankHint;

  /// No description provided for @finCardLast4.
  ///
  /// In ru, this message translates to:
  /// **'Последние 4 цифры карты'**
  String get finCardLast4;

  /// No description provided for @finCardLast4Hint.
  ///
  /// In ru, this message translates to:
  /// **'Для сопоставления уведомлений банка'**
  String get finCardLast4Hint;

  /// No description provided for @finArchive.
  ///
  /// In ru, this message translates to:
  /// **'В архиве'**
  String get finArchive;

  /// No description provided for @finArchiveHint.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть из списков и итогов'**
  String get finArchiveHint;

  /// No description provided for @finArchived.
  ///
  /// In ru, this message translates to:
  /// **'Архив'**
  String get finArchived;

  /// No description provided for @finCrypto.
  ///
  /// In ru, this message translates to:
  /// **'Крипта'**
  String get finCrypto;

  /// No description provided for @finCryptoEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Монет нет.'**
  String get finCryptoEmpty;

  /// No description provided for @finCryptoRateNote.
  ///
  /// In ru, this message translates to:
  /// **'Количество — вручную, курс — автоматически (CoinGecko через сервер).'**
  String get finCryptoRateNote;

  /// No description provided for @finCryptoAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить монету'**
  String get finCryptoAdd;

  /// No description provided for @finCryptoEdit.
  ///
  /// In ru, this message translates to:
  /// **'Монета'**
  String get finCryptoEdit;

  /// No description provided for @finCryptoSymbol.
  ///
  /// In ru, this message translates to:
  /// **'Символ'**
  String get finCryptoSymbol;

  /// No description provided for @finCryptoCoinId.
  ///
  /// In ru, this message translates to:
  /// **'Id CoinGecko'**
  String get finCryptoCoinId;

  /// No description provided for @finCryptoCoinIdHint.
  ///
  /// In ru, this message translates to:
  /// **'bitcoin, ethereum, the-open-network…'**
  String get finCryptoCoinIdHint;

  /// No description provided for @finCryptoAmount.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get finCryptoAmount;

  /// No description provided for @finNoRate.
  ///
  /// In ru, this message translates to:
  /// **'нет курса'**
  String get finNoRate;

  /// No description provided for @finCategories.
  ///
  /// In ru, this message translates to:
  /// **'Категории'**
  String get finCategories;

  /// No description provided for @finCategoryAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новая категория'**
  String get finCategoryAdd;

  /// No description provided for @finCategoryName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get finCategoryName;

  /// No description provided for @finCategoryIcon.
  ///
  /// In ru, this message translates to:
  /// **'Иконка'**
  String get finCategoryIcon;

  /// No description provided for @finJunkFood.
  ///
  /// In ru, this message translates to:
  /// **'Вредная еда'**
  String get finJunkFood;

  /// No description provided for @finJunkFoodHint.
  ///
  /// In ru, this message translates to:
  /// **'Покупки здесь облагаются «налогом на фастфуд» (◆)'**
  String get finJunkFoodHint;

  /// No description provided for @finHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get finHide;

  /// No description provided for @finHidden.
  ///
  /// In ru, this message translates to:
  /// **'скрыта'**
  String get finHidden;

  /// No description provided for @finHideHint.
  ///
  /// In ru, this message translates to:
  /// **'Не показывать при вводе'**
  String get finHideHint;

  /// No description provided for @finCatGroceries.
  ///
  /// In ru, this message translates to:
  /// **'Продукты'**
  String get finCatGroceries;

  /// No description provided for @finCatCafe.
  ///
  /// In ru, this message translates to:
  /// **'Кафе и кофе'**
  String get finCatCafe;

  /// No description provided for @finCatFastfood.
  ///
  /// In ru, this message translates to:
  /// **'Фастфуд'**
  String get finCatFastfood;

  /// No description provided for @finCatTransport.
  ///
  /// In ru, this message translates to:
  /// **'Транспорт'**
  String get finCatTransport;

  /// No description provided for @finCatHousing.
  ///
  /// In ru, this message translates to:
  /// **'Жильё'**
  String get finCatHousing;

  /// No description provided for @finCatUtilities.
  ///
  /// In ru, this message translates to:
  /// **'Коммунальные'**
  String get finCatUtilities;

  /// No description provided for @finCatPhone.
  ///
  /// In ru, this message translates to:
  /// **'Связь и интернет'**
  String get finCatPhone;

  /// No description provided for @finCatHealth.
  ///
  /// In ru, this message translates to:
  /// **'Здоровье и аптека'**
  String get finCatHealth;

  /// No description provided for @finCatBeauty.
  ///
  /// In ru, this message translates to:
  /// **'Уход и красота'**
  String get finCatBeauty;

  /// No description provided for @finCatClothes.
  ///
  /// In ru, this message translates to:
  /// **'Одежда'**
  String get finCatClothes;

  /// No description provided for @finCatEducation.
  ///
  /// In ru, this message translates to:
  /// **'Учёба и книги'**
  String get finCatEducation;

  /// No description provided for @finCatSport.
  ///
  /// In ru, this message translates to:
  /// **'Спорт'**
  String get finCatSport;

  /// No description provided for @finCatFun.
  ///
  /// In ru, this message translates to:
  /// **'Развлечения'**
  String get finCatFun;

  /// No description provided for @finCatSubscriptions.
  ///
  /// In ru, this message translates to:
  /// **'Подписки'**
  String get finCatSubscriptions;

  /// No description provided for @finCatGifts.
  ///
  /// In ru, this message translates to:
  /// **'Подарки'**
  String get finCatGifts;

  /// No description provided for @finCatMarketplace.
  ///
  /// In ru, this message translates to:
  /// **'Маркетплейсы'**
  String get finCatMarketplace;

  /// No description provided for @finCatOther.
  ///
  /// In ru, this message translates to:
  /// **'Прочее'**
  String get finCatOther;

  /// No description provided for @finCatStipend.
  ///
  /// In ru, this message translates to:
  /// **'Стипендия'**
  String get finCatStipend;

  /// No description provided for @finCatSalary.
  ///
  /// In ru, this message translates to:
  /// **'Зарплата'**
  String get finCatSalary;

  /// No description provided for @finCatGiftIncome.
  ///
  /// In ru, this message translates to:
  /// **'Подарили'**
  String get finCatGiftIncome;

  /// No description provided for @finCatCashback.
  ///
  /// In ru, this message translates to:
  /// **'Кешбэк'**
  String get finCatCashback;

  /// No description provided for @finCatOtherIncome.
  ///
  /// In ru, this message translates to:
  /// **'Прочие доходы'**
  String get finCatOtherIncome;

  /// No description provided for @finBudgetsActive.
  ///
  /// In ru, this message translates to:
  /// **'Действующие лимиты'**
  String get finBudgetsActive;

  /// No description provided for @finBudgetsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Лимитов нет. Добавьте вручную или попросите ИИ предложить.'**
  String get finBudgetsEmpty;

  /// No description provided for @finBudgetsRule.
  ///
  /// In ru, this message translates to:
  /// **'Превысили лимит — штраф ◆, уложились за период — награда ◆.'**
  String get finBudgetsRule;

  /// No description provided for @finBudgetAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить лимит'**
  String get finBudgetAdd;

  /// No description provided for @finBudgetEdit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит'**
  String get finBudgetEdit;

  /// No description provided for @finLimit.
  ///
  /// In ru, this message translates to:
  /// **'Лимит'**
  String get finLimit;

  /// No description provided for @finRewardDiamonds.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get finRewardDiamonds;

  /// No description provided for @finPenaltyDiamonds.
  ///
  /// In ru, this message translates to:
  /// **'Штраф'**
  String get finPenaltyDiamonds;

  /// No description provided for @finBudgetsAi.
  ///
  /// In ru, this message translates to:
  /// **'План от ИИ'**
  String get finBudgetsAi;

  /// No description provided for @finBudgetsAiReady.
  ///
  /// In ru, this message translates to:
  /// **'Наблюдений: {days} дн. — можно попросить ИИ предложить лимиты.'**
  String finBudgetsAiReady(int days);

  /// No description provided for @finBudgetsAiNeedMore.
  ///
  /// In ru, this message translates to:
  /// **'Нужно 2–4 недели наблюдений (сейчас {days} дн.). Записывайте траты — ИИ предложит лимиты по вашим привычкам.'**
  String finBudgetsAiNeedMore(int days);

  /// No description provided for @finBudgetsAiAsk.
  ///
  /// In ru, this message translates to:
  /// **'Предложить лимиты (ИИ)'**
  String get finBudgetsAiAsk;

  /// No description provided for @finAiSuggested.
  ///
  /// In ru, this message translates to:
  /// **'Предложено лимитов: {n}. Подтвердите или отклоните.'**
  String finAiSuggested(int n);

  /// No description provided for @finAiNoSuggestions.
  ///
  /// In ru, this message translates to:
  /// **'ИИ не предложил лимитов — данных пока мало.'**
  String get finAiNoSuggestions;

  /// No description provided for @finAccept.
  ///
  /// In ru, this message translates to:
  /// **'Принять'**
  String get finAccept;

  /// No description provided for @finReject.
  ///
  /// In ru, this message translates to:
  /// **'Отклонить'**
  String get finReject;

  /// No description provided for @finAiThinking.
  ///
  /// In ru, this message translates to:
  /// **'Система думает…'**
  String get finAiThinking;

  /// No description provided for @finAiNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'ИИ доступен после входа в аккаунт. Остальное работает офлайн.'**
  String get finAiNotSignedIn;

  /// No description provided for @finAiOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет сети. Попробуйте позже — данные сохранены на устройстве.'**
  String get finAiOffline;

  /// No description provided for @finAiBudget.
  ///
  /// In ru, this message translates to:
  /// **'Лимит расходов на ИИ исчерпан.'**
  String get finAiBudget;

  /// No description provided for @finAiRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много запросов. Подождите немного.'**
  String get finAiRateLimited;

  /// No description provided for @finAiUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ИИ сейчас недоступен. Попробуйте позже.'**
  String get finAiUnavailable;

  /// No description provided for @finGoalsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Целей нет.'**
  String get finGoalsEmpty;

  /// No description provided for @finGoalsHint.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс — остаток выбранного счёта-копилки.'**
  String get finGoalsHint;

  /// No description provided for @finGoalAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новая цель'**
  String get finGoalAdd;

  /// No description provided for @finGoalEdit.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get finGoalEdit;

  /// No description provided for @finGoalTitle.
  ///
  /// In ru, this message translates to:
  /// **'На что копим'**
  String get finGoalTitle;

  /// No description provided for @finGoalTarget.
  ///
  /// In ru, this message translates to:
  /// **'Сколько нужно'**
  String get finGoalTarget;

  /// No description provided for @finGoalAccount.
  ///
  /// In ru, this message translates to:
  /// **'Счёт-копилка'**
  String get finGoalAccount;

  /// No description provided for @finGoalAccountHint.
  ///
  /// In ru, this message translates to:
  /// **'Остаток этого счёта — накоплено'**
  String get finGoalAccountHint;

  /// No description provided for @finGoalDeadline.
  ///
  /// In ru, this message translates to:
  /// **'К какой дате'**
  String get finGoalDeadline;

  /// No description provided for @finGoalNoAccount.
  ///
  /// In ru, this message translates to:
  /// **'Выберите счёт-копилку, чтобы видеть прогресс.'**
  String get finGoalNoAccount;

  /// No description provided for @finGoalReached.
  ///
  /// In ru, this message translates to:
  /// **'Цель достигнута!'**
  String get finGoalReached;

  /// No description provided for @finUntil.
  ///
  /// In ru, this message translates to:
  /// **'до {date}'**
  String finUntil(String date);

  /// No description provided for @finSubscriptionsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Подписок нет.'**
  String get finSubscriptionsEmpty;

  /// No description provided for @finSubscriptionsHint.
  ///
  /// In ru, this message translates to:
  /// **'В день списания Система сама запишет расход и сдвинет дату.'**
  String get finSubscriptionsHint;

  /// No description provided for @finSubscriptionsMonthly.
  ///
  /// In ru, this message translates to:
  /// **'В месяц'**
  String get finSubscriptionsMonthly;

  /// No description provided for @finSubscriptionAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новая подписка'**
  String get finSubscriptionAdd;

  /// No description provided for @finSubscriptionEdit.
  ///
  /// In ru, this message translates to:
  /// **'Подписка'**
  String get finSubscriptionEdit;

  /// No description provided for @finSubscriptionTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get finSubscriptionTitle;

  /// No description provided for @finNextCharge.
  ///
  /// In ru, this message translates to:
  /// **'списание {date}'**
  String finNextCharge(String date);

  /// No description provided for @finNextChargeDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата следующего списания'**
  String get finNextChargeDate;

  /// No description provided for @finPaused.
  ///
  /// In ru, this message translates to:
  /// **'приостановлена'**
  String get finPaused;

  /// No description provided for @finActive.
  ///
  /// In ru, this message translates to:
  /// **'Активна'**
  String get finActive;

  /// No description provided for @finDebtsOpen.
  ///
  /// In ru, this message translates to:
  /// **'Открытые долги'**
  String get finDebtsOpen;

  /// No description provided for @finDebtsClosed.
  ///
  /// In ru, this message translates to:
  /// **'Погашенные'**
  String get finDebtsClosed;

  /// No description provided for @finDebtsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Долгов нет.'**
  String get finDebtsEmpty;

  /// No description provided for @finDebtAdd.
  ///
  /// In ru, this message translates to:
  /// **'Новый долг'**
  String get finDebtAdd;

  /// No description provided for @finDebtEdit.
  ///
  /// In ru, this message translates to:
  /// **'Долг'**
  String get finDebtEdit;

  /// No description provided for @finDebtOwe.
  ///
  /// In ru, this message translates to:
  /// **'Я должен'**
  String get finDebtOwe;

  /// No description provided for @finDebtLent.
  ///
  /// In ru, this message translates to:
  /// **'Мне должны'**
  String get finDebtLent;

  /// No description provided for @finDebtPerson.
  ///
  /// In ru, this message translates to:
  /// **'Кто'**
  String get finDebtPerson;

  /// No description provided for @finDebtDue.
  ///
  /// In ru, this message translates to:
  /// **'Срок'**
  String get finDebtDue;

  /// No description provided for @finDebtSettle.
  ///
  /// In ru, this message translates to:
  /// **'Погашен'**
  String get finDebtSettle;

  /// No description provided for @finDebtSettleHint.
  ///
  /// In ru, this message translates to:
  /// **'Отметит долг закрытым и откроет запись операции.'**
  String get finDebtSettleHint;

  /// No description provided for @finOverdue.
  ///
  /// In ru, this message translates to:
  /// **'просрочен'**
  String get finOverdue;

  /// No description provided for @finSettled.
  ///
  /// In ru, this message translates to:
  /// **'погашен'**
  String get finSettled;

  /// No description provided for @finTotals.
  ///
  /// In ru, this message translates to:
  /// **'Итоги'**
  String get finTotals;

  /// No description provided for @finNet.
  ///
  /// In ru, this message translates to:
  /// **'Разница'**
  String get finNet;

  /// No description provided for @finByCategory.
  ///
  /// In ru, this message translates to:
  /// **'Расходы по категориям'**
  String get finByCategory;

  /// No description provided for @finNoExpensesPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Расходов за период нет.'**
  String get finNoExpensesPeriod;

  /// No description provided for @finDynamics.
  ///
  /// In ru, this message translates to:
  /// **'Доходы и расходы по периодам'**
  String get finDynamics;

  /// No description provided for @finPrevPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Предыдущий период'**
  String get finPrevPeriod;

  /// No description provided for @finNextPeriod.
  ///
  /// In ru, this message translates to:
  /// **'Следующий период'**
  String get finNextPeriod;

  /// No description provided for @finAiComment.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий ИИ'**
  String get finAiComment;

  /// No description provided for @finAiCommentHint.
  ///
  /// In ru, this message translates to:
  /// **'ИИ разберёт период: на что ушли деньги и где можно сэкономить.'**
  String get finAiCommentHint;

  /// No description provided for @finAiCommentAsk.
  ///
  /// In ru, this message translates to:
  /// **'Комментарий ИИ'**
  String get finAiCommentAsk;

  /// No description provided for @finSrcManual.
  ///
  /// In ru, this message translates to:
  /// **'вручную'**
  String get finSrcManual;

  /// No description provided for @finSrcReceiptQr.
  ///
  /// In ru, this message translates to:
  /// **'QR чека'**
  String get finSrcReceiptQr;

  /// No description provided for @finSrcReceiptPhoto.
  ///
  /// In ru, this message translates to:
  /// **'фото чека'**
  String get finSrcReceiptPhoto;

  /// No description provided for @finSrcFood.
  ///
  /// In ru, this message translates to:
  /// **'фото еды'**
  String get finSrcFood;

  /// No description provided for @finSrcBank.
  ///
  /// In ru, this message translates to:
  /// **'уведомление банка'**
  String get finSrcBank;

  /// No description provided for @finSrcSms.
  ///
  /// In ru, this message translates to:
  /// **'SMS банка'**
  String get finSrcSms;

  /// No description provided for @finSrcStatement.
  ///
  /// In ru, this message translates to:
  /// **'выписка'**
  String get finSrcStatement;

  /// No description provided for @finSrcSubscription.
  ///
  /// In ru, this message translates to:
  /// **'подписка'**
  String get finSrcSubscription;

  /// No description provided for @finSrcMarket.
  ///
  /// In ru, this message translates to:
  /// **'маркет'**
  String get finSrcMarket;

  /// No description provided for @finReasonJunkTax.
  ///
  /// In ru, this message translates to:
  /// **'налог на фастфуд'**
  String get finReasonJunkTax;

  /// No description provided for @finReasonBudgetOver.
  ///
  /// In ru, this message translates to:
  /// **'превышен лимит расходов'**
  String get finReasonBudgetOver;

  /// No description provided for @finReasonBudgetKept.
  ///
  /// In ru, this message translates to:
  /// **'уложились в лимит'**
  String get finReasonBudgetKept;

  /// No description provided for @finLockTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система заблокирована'**
  String get finLockTitle;

  /// No description provided for @finLockReason.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите вход в «Систему»'**
  String get finLockReason;

  /// No description provided for @finLockEnterPin.
  ///
  /// In ru, this message translates to:
  /// **'Введите PIN'**
  String get finLockEnterPin;

  /// No description provided for @finLockUseBiometric.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердите вход по Face ID или отпечатку'**
  String get finLockUseBiometric;

  /// No description provided for @finLockBiometricButton.
  ///
  /// In ru, this message translates to:
  /// **'Face ID / отпечаток'**
  String get finLockBiometricButton;

  /// No description provided for @finLockWrongPin.
  ///
  /// In ru, this message translates to:
  /// **'Неверный PIN'**
  String get finLockWrongPin;

  /// No description provided for @finLockCooldown.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток. Подождите {sec} с'**
  String finLockCooldown(int sec);

  /// No description provided for @finLockDigits.
  ///
  /// In ru, this message translates to:
  /// **'Введено цифр: {n}'**
  String finLockDigits(int n);

  /// No description provided for @finLockErase.
  ///
  /// In ru, this message translates to:
  /// **'Стереть'**
  String get finLockErase;

  /// No description provided for @finLockOk.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get finLockOk;

  /// No description provided for @finLockSection.
  ///
  /// In ru, this message translates to:
  /// **'Вход в приложение'**
  String get finLockSection;

  /// No description provided for @finLockIntro.
  ///
  /// In ru, this message translates to:
  /// **'Защитите приложение: при запуске и после возврата из фона Система спросит Face ID, отпечаток или PIN.'**
  String get finLockIntro;

  /// No description provided for @finLockModeOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключено'**
  String get finLockModeOff;

  /// No description provided for @finLockModeBiometric.
  ///
  /// In ru, this message translates to:
  /// **'Face ID / отпечаток'**
  String get finLockModeBiometric;

  /// No description provided for @finLockModePin.
  ///
  /// In ru, this message translates to:
  /// **'PIN'**
  String get finLockModePin;

  /// No description provided for @finLockModeBoth.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия + PIN'**
  String get finLockModeBoth;

  /// No description provided for @finLockNoBiometric.
  ///
  /// In ru, this message translates to:
  /// **'Биометрия на устройстве недоступна или не настроена.'**
  String get finLockNoBiometric;

  /// No description provided for @finLockTimeout.
  ///
  /// In ru, this message translates to:
  /// **'Спрашивать снова после фона'**
  String get finLockTimeout;

  /// No description provided for @finLockTimeoutNow.
  ///
  /// In ru, this message translates to:
  /// **'Сразу'**
  String get finLockTimeoutNow;

  /// No description provided for @finMinutes.
  ///
  /// In ru, this message translates to:
  /// **'{n} мин'**
  String finMinutes(int n);

  /// No description provided for @finLockChangePin.
  ///
  /// In ru, this message translates to:
  /// **'Сменить PIN'**
  String get finLockChangePin;

  /// No description provided for @finLockNewPin.
  ///
  /// In ru, this message translates to:
  /// **'Новый PIN'**
  String get finLockNewPin;

  /// No description provided for @finLockRepeatPin.
  ///
  /// In ru, this message translates to:
  /// **'Повторите PIN'**
  String get finLockRepeatPin;

  /// No description provided for @finLockPinMismatch.
  ///
  /// In ru, this message translates to:
  /// **'PIN не совпали'**
  String get finLockPinMismatch;

  /// No description provided for @finLockPinChanged.
  ///
  /// In ru, this message translates to:
  /// **'PIN изменён'**
  String get finLockPinChanged;

  /// No description provided for @finLockPinRule.
  ///
  /// In ru, this message translates to:
  /// **'От {min} до {max} цифр'**
  String finLockPinRule(int min, int max);

  /// No description provided for @finLockPinWarning.
  ///
  /// In ru, this message translates to:
  /// **'Забытый PIN не восстановить — включите и биометрию, если можно.'**
  String get finLockPinWarning;

  /// No description provided for @finJunkTaxSection.
  ///
  /// In ru, this message translates to:
  /// **'Налог на фастфуд'**
  String get finJunkTaxSection;

  /// No description provided for @finJunkTaxEnabled.
  ///
  /// In ru, this message translates to:
  /// **'Списывать ◆ за вредную еду'**
  String get finJunkTaxEnabled;

  /// No description provided for @finJunkTaxHint.
  ///
  /// In ru, this message translates to:
  /// **'За каждую покупку в категориях «вредная еда»'**
  String get finJunkTaxHint;

  /// No description provided for @finJunkTaxAmount.
  ///
  /// In ru, this message translates to:
  /// **'Налог за покупку'**
  String get finJunkTaxAmount;

  /// No description provided for @finSummaryFood.
  ///
  /// In ru, this message translates to:
  /// **'Еда за месяц'**
  String get finSummaryFood;

  /// No description provided for @finSummaryUntilIncome.
  ///
  /// In ru, this message translates to:
  /// **'До поступления'**
  String get finSummaryUntilIncome;

  /// No description provided for @finDays.
  ///
  /// In ru, this message translates to:
  /// **'{n} дн.'**
  String finDays(int n);

  /// No description provided for @finRemindSubTitle.
  ///
  /// In ru, this message translates to:
  /// **'Завтра списание: {title}'**
  String finRemindSubTitle(String title);

  /// No description provided for @finRemindSubBody.
  ///
  /// In ru, this message translates to:
  /// **'{amount} · {date}'**
  String finRemindSubBody(String amount, String date);

  /// No description provided for @finRemindDebtOweTitle.
  ///
  /// In ru, this message translates to:
  /// **'Срок долга'**
  String get finRemindDebtOweTitle;

  /// No description provided for @finRemindDebtLentTitle.
  ///
  /// In ru, this message translates to:
  /// **'Вам должны вернуть'**
  String get finRemindDebtLentTitle;

  /// No description provided for @finRemindDebtBody.
  ///
  /// In ru, this message translates to:
  /// **'{person}: {amount} до {date}'**
  String finRemindDebtBody(String person, String amount, String date);

  /// No description provided for @fniAccount.
  ///
  /// In ru, this message translates to:
  /// **'Счёт'**
  String get fniAccount;

  /// No description provided for @fniAuto.
  ///
  /// In ru, this message translates to:
  /// **'Автоматически'**
  String get fniAuto;

  /// No description provided for @fniCategory.
  ///
  /// In ru, this message translates to:
  /// **'Категория'**
  String get fniCategory;

  /// No description provided for @fniQrNotReceipt.
  ///
  /// In ru, this message translates to:
  /// **'Это не QR-код кассового чека.'**
  String get fniQrNotReceipt;

  /// No description provided for @fniDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Эта операция уже есть.'**
  String get fniDuplicate;

  /// No description provided for @fniAdded.
  ///
  /// In ru, this message translates to:
  /// **'Операция добавлена.'**
  String get fniAdded;

  /// No description provided for @fniSaveFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить операцию.'**
  String get fniSaveFailed;

  /// No description provided for @fniRetry.
  ///
  /// In ru, this message translates to:
  /// **'Ещё раз'**
  String get fniRetry;

  /// No description provided for @fniReceiptTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чек'**
  String get fniReceiptTitle;

  /// No description provided for @fniStore.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get fniStore;

  /// No description provided for @fniDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get fniDate;

  /// No description provided for @fniKind.
  ///
  /// In ru, this message translates to:
  /// **'Тип'**
  String get fniKind;

  /// No description provided for @fniRefund.
  ///
  /// In ru, this message translates to:
  /// **'Возврат'**
  String get fniRefund;

  /// No description provided for @fniTotal.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get fniTotal;

  /// No description provided for @fniQrNoItems.
  ///
  /// In ru, this message translates to:
  /// **'Позиции чека из ФНС пока недоступны — записана сумма из QR.'**
  String get fniQrNoItems;

  /// No description provided for @fniAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get fniAdd;

  /// No description provided for @fniReceiptQrTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чек по QR'**
  String get fniReceiptQrTitle;

  /// No description provided for @fniReceiptPhotoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чек по фото'**
  String get fniReceiptPhotoTitle;

  /// No description provided for @fniNoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна. Разрешите доступ в настройках.'**
  String get fniNoCamera;

  /// No description provided for @fniClose.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get fniClose;

  /// No description provided for @fniQrHint.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру на QR-код чека'**
  String get fniQrHint;

  /// No description provided for @fniFileFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть файл.'**
  String get fniFileFailed;

  /// No description provided for @fniFileTooLarge.
  ///
  /// In ru, this message translates to:
  /// **'Файл больше 3 МБ. Выгрузите выписку за меньший период.'**
  String get fniFileTooLarge;

  /// No description provided for @fniStatementTitle.
  ///
  /// In ru, this message translates to:
  /// **'Импорт выписки'**
  String get fniStatementTitle;

  /// No description provided for @fniStatementFile.
  ///
  /// In ru, this message translates to:
  /// **'Файл выписки'**
  String get fniStatementFile;

  /// No description provided for @fniStatementHint.
  ///
  /// In ru, this message translates to:
  /// **'Выгрузите выписку в банковском приложении (CSV или PDF) и выберите файл.'**
  String get fniStatementHint;

  /// No description provided for @fniPickFile.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать файл'**
  String get fniPickFile;

  /// No description provided for @fniStatementParsing.
  ///
  /// In ru, this message translates to:
  /// **'Разбираю выписку…'**
  String get fniStatementParsing;

  /// No description provided for @fniStatementEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Операций в файле не найдено.'**
  String get fniStatementEmpty;

  /// No description provided for @fniBank.
  ///
  /// In ru, this message translates to:
  /// **'Банк'**
  String get fniBank;

  /// No description provided for @fniSelectAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get fniSelectAll;

  /// No description provided for @fniAlreadyImported.
  ///
  /// In ru, this message translates to:
  /// **'уже есть'**
  String get fniAlreadyImported;

  /// No description provided for @fniBanksTitle.
  ///
  /// In ru, this message translates to:
  /// **'Банки'**
  String get fniBanksTitle;

  /// No description provided for @fniBanksAndroidOnly.
  ///
  /// In ru, this message translates to:
  /// **'Чтение уведомлений и SMS банков доступно только на Android. На iPhone используйте импорт выписки.'**
  String get fniBanksAndroidOnly;

  /// No description provided for @fniAccess.
  ///
  /// In ru, this message translates to:
  /// **'Доступ'**
  String get fniAccess;

  /// No description provided for @fniAccessNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления банков'**
  String get fniAccessNotifications;

  /// No description provided for @fniOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get fniOpenSettings;

  /// No description provided for @fniAccessSms.
  ///
  /// In ru, this message translates to:
  /// **'SMS банков'**
  String get fniAccessSms;

  /// No description provided for @fniAllow.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить'**
  String get fniAllow;

  /// No description provided for @fniAccessHint.
  ///
  /// In ru, this message translates to:
  /// **'Читаются только сообщения выбранных банков. Тексты хранятся в приложении и синхронизируются с вашим сервером.'**
  String get fniAccessHint;

  /// No description provided for @fniBanksList.
  ///
  /// In ru, this message translates to:
  /// **'Мои банки'**
  String get fniBanksList;

  /// No description provided for @fniProcessNow.
  ///
  /// In ru, this message translates to:
  /// **'Обработать'**
  String get fniProcessNow;

  /// No description provided for @fniSmsHistory.
  ///
  /// In ru, this message translates to:
  /// **'SMS за 30 дней'**
  String get fniSmsHistory;

  /// No description provided for @fniGranted.
  ///
  /// In ru, this message translates to:
  /// **'Есть'**
  String get fniGranted;

  /// No description provided for @fniOtherBank.
  ///
  /// In ru, this message translates to:
  /// **'Другой банк'**
  String get fniOtherBank;

  /// No description provided for @fniSourceNotifications.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления приложения'**
  String get fniSourceNotifications;

  /// No description provided for @fniSourceSms.
  ///
  /// In ru, this message translates to:
  /// **'SMS'**
  String get fniSourceSms;

  /// No description provided for @fniPackages.
  ///
  /// In ru, this message translates to:
  /// **'Пакеты приложений'**
  String get fniPackages;

  /// No description provided for @fniExtraSenders.
  ///
  /// In ru, this message translates to:
  /// **'Свои отправители SMS'**
  String get fniExtraSenders;

  /// No description provided for @fniExtraSendersHint.
  ///
  /// In ru, this message translates to:
  /// **'Имя или номер, через запятую'**
  String get fniExtraSendersHint;

  /// No description provided for @fniInbox.
  ///
  /// In ru, this message translates to:
  /// **'Входящие'**
  String get fniInbox;

  /// No description provided for @fniInboxEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Пока ничего. Новые уведомления и SMS банков появятся здесь.'**
  String get fniInboxEmpty;

  /// No description provided for @fniStatusReview.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте'**
  String get fniStatusReview;

  /// No description provided for @fniStatusAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено'**
  String get fniStatusAdded;

  /// No description provided for @fniStatusDuplicate.
  ///
  /// In ru, this message translates to:
  /// **'Дубль'**
  String get fniStatusDuplicate;

  /// No description provided for @fniStatusIgnored.
  ///
  /// In ru, this message translates to:
  /// **'Не операция'**
  String get fniStatusIgnored;

  /// No description provided for @fniStatusFailed.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка'**
  String get fniStatusFailed;

  /// No description provided for @fniStatusPending.
  ///
  /// In ru, this message translates to:
  /// **'Ожидает'**
  String get fniStatusPending;

  /// No description provided for @fniConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Верно'**
  String get fniConfirm;

  /// No description provided for @fniFix.
  ///
  /// In ru, this message translates to:
  /// **'Исправить'**
  String get fniFix;

  /// No description provided for @fniAddManually.
  ///
  /// In ru, this message translates to:
  /// **'Добавить вручную'**
  String get fniAddManually;

  /// No description provided for @fniFixInFinance.
  ///
  /// In ru, this message translates to:
  /// **'Измените или удалите эту операцию в разделе «Финансы».'**
  String get fniFixInFinance;

  /// No description provided for @fniIgnore.
  ///
  /// In ru, this message translates to:
  /// **'Игнор'**
  String get fniIgnore;

  /// No description provided for @fniEditTitle.
  ///
  /// In ru, this message translates to:
  /// **'Операция'**
  String get fniEditTitle;

  /// No description provided for @fniExpense.
  ///
  /// In ru, this message translates to:
  /// **'Расход'**
  String get fniExpense;

  /// No description provided for @fniIncome.
  ///
  /// In ru, this message translates to:
  /// **'Доход'**
  String get fniIncome;

  /// No description provided for @fniTransfer.
  ///
  /// In ru, this message translates to:
  /// **'Перевод'**
  String get fniTransfer;

  /// No description provided for @fniAmount.
  ///
  /// In ru, this message translates to:
  /// **'Сумма'**
  String get fniAmount;

  /// No description provided for @fniMerchant.
  ///
  /// In ru, this message translates to:
  /// **'Где / от кого'**
  String get fniMerchant;

  /// No description provided for @fniCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get fniCancel;

  /// No description provided for @fniSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get fniSave;

  /// No description provided for @fniImported.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено: {added}, уже было: {dup}'**
  String fniImported(int added, int dup);

  /// No description provided for @fniImporting.
  ///
  /// In ru, this message translates to:
  /// **'Импорт {done} / {total}'**
  String fniImporting(int done, int total);

  /// No description provided for @fniImportN.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать ({n})'**
  String fniImportN(int n);

  /// No description provided for @fniRows.
  ///
  /// In ru, this message translates to:
  /// **'Операции: {n}'**
  String fniRows(int n);

  /// No description provided for @fniSmsFound.
  ///
  /// In ru, this message translates to:
  /// **'Найдено SMS: {n}'**
  String fniSmsFound(int n);

  /// No description provided for @fniSenders.
  ///
  /// In ru, this message translates to:
  /// **'Отправители: {list}'**
  String fniSenders(String list);

  /// No description provided for @actStepsTitle.
  ///
  /// In ru, this message translates to:
  /// **'Шаги'**
  String get actStepsTitle;

  /// No description provided for @actGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель: {goal}'**
  String actGoal(String goal);

  /// No description provided for @actDistance.
  ///
  /// In ru, this message translates to:
  /// **'Дистанция'**
  String get actDistance;

  /// No description provided for @actDistanceKm.
  ///
  /// In ru, this message translates to:
  /// **'{km} км'**
  String actDistanceKm(String km);

  /// No description provided for @actFloors.
  ///
  /// In ru, this message translates to:
  /// **'Этажи'**
  String get actFloors;

  /// No description provided for @actNoValue.
  ///
  /// In ru, this message translates to:
  /// **'—'**
  String get actNoValue;

  /// No description provided for @actWeek.
  ///
  /// In ru, this message translates to:
  /// **'7 дней'**
  String get actWeek;

  /// No description provided for @actAllow.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить'**
  String get actAllow;

  /// No description provided for @actPermissionHint.
  ///
  /// In ru, this message translates to:
  /// **'Разрешите доступ к датчикам движения — шаги будут считаться сами.'**
  String get actPermissionHint;

  /// No description provided for @actUnavailableHint.
  ///
  /// In ru, this message translates to:
  /// **'Счётчика шагов на устройстве нет — введите шаги вручную.'**
  String get actUnavailableHint;

  /// No description provided for @actManual.
  ///
  /// In ru, this message translates to:
  /// **'Ввести вручную'**
  String get actManual;

  /// No description provided for @actManualLabel.
  ///
  /// In ru, this message translates to:
  /// **'Шаги за сегодня'**
  String get actManualLabel;

  /// No description provided for @actManualRange.
  ///
  /// In ru, this message translates to:
  /// **'От 0 до 100 000'**
  String get actManualRange;

  /// No description provided for @actSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get actSave;

  /// No description provided for @actCancel.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get actCancel;

  /// No description provided for @actStepsSemantic.
  ///
  /// In ru, this message translates to:
  /// **'Шаги за сегодня: {steps} из {goal}'**
  String actStepsSemantic(String steps, String goal);

  /// No description provided for @int6PlanAi.
  ///
  /// In ru, this message translates to:
  /// **'Построить план с ИИ'**
  String get int6PlanAi;

  /// No description provided for @int6PlanAiError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось построить план с ИИ. Проверьте вход в аккаунт и сеть.'**
  String get int6PlanAiError;

  /// No description provided for @int6Learning.
  ///
  /// In ru, this message translates to:
  /// **'Знания'**
  String get int6Learning;

  /// No description provided for @int6LearningHint.
  ///
  /// In ru, this message translates to:
  /// **'Курсы, уроки дня и повторения'**
  String get int6LearningHint;

  /// No description provided for @int6AiJournal.
  ///
  /// In ru, this message translates to:
  /// **'ИИ: расходы и действия'**
  String get int6AiJournal;

  /// No description provided for @int6AiJournalHint.
  ///
  /// In ru, this message translates to:
  /// **'Бюджет и что Система меняла (с отменой)'**
  String get int6AiJournalHint;

  /// No description provided for @int6Voice.
  ///
  /// In ru, this message translates to:
  /// **'Голос персонажа'**
  String get int6Voice;

  /// No description provided for @int6VoiceHint.
  ///
  /// In ru, this message translates to:
  /// **'Готовые голоса сервера, прослушать'**
  String get int6VoiceHint;

  /// No description provided for @int7Finance.
  ///
  /// In ru, this message translates to:
  /// **'Финансы'**
  String get int7Finance;

  /// No description provided for @int7FinanceHint.
  ///
  /// In ru, this message translates to:
  /// **'Счета, операции, лимиты, отчёты'**
  String get int7FinanceHint;

  /// No description provided for @int7Market.
  ///
  /// In ru, this message translates to:
  /// **'Маркет покупок'**
  String get int7Market;

  /// No description provided for @int7MarketHint.
  ///
  /// In ru, this message translates to:
  /// **'Подборка под план с ценами'**
  String get int7MarketHint;

  /// No description provided for @int7Blocker.
  ///
  /// In ru, this message translates to:
  /// **'Блокировка приложений'**
  String get int7Blocker;

  /// No description provided for @int7BlockerHint.
  ///
  /// In ru, this message translates to:
  /// **'После отбоя в режиме дисциплины'**
  String get int7BlockerHint;

  /// No description provided for @int7Alarms.
  ///
  /// In ru, this message translates to:
  /// **'Будильник-квест'**
  String get int7Alarms;

  /// No description provided for @int7AlarmsHint.
  ///
  /// In ru, this message translates to:
  /// **'Выключается только заданием'**
  String get int7AlarmsHint;

  /// No description provided for @int7Setup.
  ///
  /// In ru, this message translates to:
  /// **'Настроить'**
  String get int7Setup;

  /// No description provided for @livNextQuest.
  ///
  /// In ru, this message translates to:
  /// **'Следующий квест'**
  String get livNextQuest;

  /// No description provided for @livNoQuest.
  ///
  /// In ru, this message translates to:
  /// **'Квестов нет'**
  String get livNoQuest;

  /// No description provided for @livOverdue.
  ///
  /// In ru, this message translates to:
  /// **'Просрочен'**
  String get livOverdue;

  /// No description provided for @livSteps.
  ///
  /// In ru, this message translates to:
  /// **'Шаги'**
  String get livSteps;

  /// No description provided for @livWater.
  ///
  /// In ru, this message translates to:
  /// **'Вода'**
  String get livWater;

  /// No description provided for @livAddWater.
  ///
  /// In ru, this message translates to:
  /// **'+250 мл'**
  String get livAddWater;

  /// No description provided for @livMl.
  ///
  /// In ru, this message translates to:
  /// **'мл'**
  String get livMl;

  /// No description provided for @livKm.
  ///
  /// In ru, this message translates to:
  /// **'км'**
  String get livKm;

  /// No description provided for @livPerKm.
  ///
  /// In ru, this message translates to:
  /// **'/км'**
  String get livPerKm;

  /// No description provided for @livReward.
  ///
  /// In ru, this message translates to:
  /// **'Награда'**
  String get livReward;

  /// No description provided for @livWalk.
  ///
  /// In ru, this message translates to:
  /// **'Прогулка'**
  String get livWalk;

  /// No description provided for @livQuest.
  ///
  /// In ru, this message translates to:
  /// **'Квест'**
  String get livQuest;

  /// No description provided for @livWorkout.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка'**
  String get livWorkout;

  /// No description provided for @livChannelName.
  ///
  /// In ru, this message translates to:
  /// **'Активность'**
  String get livChannelName;

  /// No description provided for @livChannelDesc.
  ///
  /// In ru, this message translates to:
  /// **'Прогулка, активный квест и тренировка в шторке'**
  String get livChannelDesc;

  /// No description provided for @livWalkNextIn.
  ///
  /// In ru, this message translates to:
  /// **'Поворот через {m} м'**
  String livWalkNextIn(int m);

  /// No description provided for @locNotifTitle.
  ///
  /// In ru, this message translates to:
  /// **'Система · прогулка'**
  String get locNotifTitle;

  /// No description provided for @locNotifText.
  ///
  /// In ru, this message translates to:
  /// **'Идёт запись маршрута'**
  String get locNotifText;

  /// No description provided for @locNotifChannel.
  ///
  /// In ru, this message translates to:
  /// **'Прогулка'**
  String get locNotifChannel;

  /// No description provided for @lrnTitle.
  ///
  /// In ru, this message translates to:
  /// **'Знания'**
  String get lrnTitle;

  /// No description provided for @lrnToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get lrnToday;

  /// No description provided for @lrnCourses.
  ///
  /// In ru, this message translates to:
  /// **'Курсы'**
  String get lrnCourses;

  /// No description provided for @lrnNewCourse.
  ///
  /// In ru, this message translates to:
  /// **'Новый курс'**
  String get lrnNewCourse;

  /// No description provided for @lrnTopic.
  ///
  /// In ru, this message translates to:
  /// **'Что хотите выучить?'**
  String get lrnTopic;

  /// No description provided for @lrnTopicHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: нунчаки, C++, турецкий'**
  String get lrnTopicHint;

  /// No description provided for @lrnPerDay.
  ///
  /// In ru, this message translates to:
  /// **'Уроков в день'**
  String get lrnPerDay;

  /// No description provided for @lrnLength.
  ///
  /// In ru, this message translates to:
  /// **'Уроков в курсе'**
  String get lrnLength;

  /// No description provided for @lrnCreate.
  ///
  /// In ru, this message translates to:
  /// **'Построить курс'**
  String get lrnCreate;

  /// No description provided for @lrnCreating.
  ///
  /// In ru, this message translates to:
  /// **'Система строит курс…'**
  String get lrnCreating;

  /// No description provided for @lrnTodayEmpty.
  ///
  /// In ru, this message translates to:
  /// **'На сегодня всё: уроки и повторения выполнены.'**
  String get lrnTodayEmpty;

  /// No description provided for @lrnNoCourses.
  ///
  /// In ru, this message translates to:
  /// **'Курсов пока нет. Напишите, что хотите выучить, — Система построит курс.'**
  String get lrnNoCourses;

  /// No description provided for @lrnLessonOf.
  ///
  /// In ru, this message translates to:
  /// **'Урок {n} из {total}'**
  String lrnLessonOf(int n, int total);

  /// No description provided for @lrnReview.
  ///
  /// In ru, this message translates to:
  /// **'Повторение'**
  String get lrnReview;

  /// No description provided for @lrnLessonDay.
  ///
  /// In ru, this message translates to:
  /// **'Урок дня'**
  String get lrnLessonDay;

  /// No description provided for @lrnStatusPaused.
  ///
  /// In ru, this message translates to:
  /// **'На паузе'**
  String get lrnStatusPaused;

  /// No description provided for @lrnStatusDone.
  ///
  /// In ru, this message translates to:
  /// **'Курс пройден'**
  String get lrnStatusDone;

  /// No description provided for @lrnPause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get lrnPause;

  /// No description provided for @lrnResume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get lrnResume;

  /// No description provided for @lrnDelete.
  ///
  /// In ru, this message translates to:
  /// **'Удалить курс'**
  String get lrnDelete;

  /// No description provided for @lrnDeleteConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Удалить курс «{title}»? Прогресс будет потерян.'**
  String lrnDeleteConfirm(String title);

  /// No description provided for @lrnLoading.
  ///
  /// In ru, this message translates to:
  /// **'Загружаю урок…'**
  String get lrnLoading;

  /// No description provided for @lrnGoal.
  ///
  /// In ru, this message translates to:
  /// **'Цель'**
  String get lrnGoal;

  /// No description provided for @lrnExample.
  ///
  /// In ru, this message translates to:
  /// **'Пример'**
  String get lrnExample;

  /// No description provided for @lrnTip.
  ///
  /// In ru, this message translates to:
  /// **'Совет'**
  String get lrnTip;

  /// No description provided for @lrnStartQuiz.
  ///
  /// In ru, this message translates to:
  /// **'К проверке'**
  String get lrnStartQuiz;

  /// No description provided for @lrnFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить урок'**
  String get lrnFinish;

  /// No description provided for @lrnQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Вопрос {n} из {total}'**
  String lrnQuestion(int n, int total);

  /// No description provided for @lrnNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get lrnNext;

  /// No description provided for @lrnCorrect.
  ///
  /// In ru, this message translates to:
  /// **'Верно'**
  String get lrnCorrect;

  /// No description provided for @lrnWrong.
  ///
  /// In ru, this message translates to:
  /// **'Неверно'**
  String get lrnWrong;

  /// No description provided for @lrnResult.
  ///
  /// In ru, this message translates to:
  /// **'Результат'**
  String get lrnResult;

  /// No description provided for @lrnScore.
  ///
  /// In ru, this message translates to:
  /// **'Правильно: {p}%'**
  String lrnScore(int p);

  /// No description provided for @lrnNextReview.
  ///
  /// In ru, this message translates to:
  /// **'{days, plural, one{Повторение через {days} день} few{Повторение через {days} дня} many{Повторение через {days} дней} other{Повторение через {days} дня}}'**
  String lrnNextReview(int days);

  /// No description provided for @lrnMastered.
  ///
  /// In ru, this message translates to:
  /// **'Материал закреплён — повторений больше нет.'**
  String get lrnMastered;

  /// No description provided for @lrnPassed.
  ///
  /// In ru, this message translates to:
  /// **'Урок засчитан.'**
  String get lrnPassed;

  /// No description provided for @lrnFailed.
  ///
  /// In ru, this message translates to:
  /// **'Для зачёта нужно {p}% — попробуйте ещё раз.'**
  String lrnFailed(int p);

  /// No description provided for @lrnReviewPassed.
  ///
  /// In ru, this message translates to:
  /// **'Повторение засчитано.'**
  String get lrnReviewPassed;

  /// No description provided for @lrnReviewFailed.
  ///
  /// In ru, this message translates to:
  /// **'Повторение не засчитано — интервал сокращён.'**
  String get lrnReviewFailed;

  /// No description provided for @lrnRetry.
  ///
  /// In ru, this message translates to:
  /// **'Пройти снова'**
  String get lrnRetry;

  /// No description provided for @lrnLessonDone.
  ///
  /// In ru, this message translates to:
  /// **'Пройден'**
  String get lrnLessonDone;

  /// No description provided for @lrnErrOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Уже загруженные уроки доступны офлайн.'**
  String get lrnErrOffline;

  /// No description provided for @lrnErrNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт (Ещё → Аккаунт), чтобы Система строила курсы и уроки.'**
  String get lrnErrNotSignedIn;

  /// No description provided for @lrnErrBudget.
  ///
  /// In ru, this message translates to:
  /// **'Лимит ИИ исчерпан. Попробуйте позже.'**
  String get lrnErrBudget;

  /// No description provided for @lrnErrUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ИИ сейчас недоступен на сервере.'**
  String get lrnErrUnavailable;

  /// No description provided for @lrnErrServer.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить ответ. Попробуйте ещё раз.'**
  String get lrnErrServer;

  /// No description provided for @mktTitle.
  ///
  /// In ru, this message translates to:
  /// **'Маркет'**
  String get mktTitle;

  /// No description provided for @mktSuggest.
  ///
  /// In ru, this message translates to:
  /// **'Подобрать (ИИ)'**
  String get mktSuggest;

  /// No description provided for @mktSuggesting.
  ///
  /// In ru, this message translates to:
  /// **'Подбираю товары под план…'**
  String get mktSuggesting;

  /// No description provided for @mktCatAll.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get mktCatAll;

  /// No description provided for @mktCatSkin.
  ///
  /// In ru, this message translates to:
  /// **'Уход за кожей'**
  String get mktCatSkin;

  /// No description provided for @mktCatNutrition.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get mktCatNutrition;

  /// No description provided for @mktCatEquipment.
  ///
  /// In ru, this message translates to:
  /// **'Инвентарь'**
  String get mktCatEquipment;

  /// No description provided for @mktCatOther.
  ///
  /// In ru, this message translates to:
  /// **'Другое'**
  String get mktCatOther;

  /// No description provided for @mktTabNew.
  ///
  /// In ru, this message translates to:
  /// **'Подборка'**
  String get mktTabNew;

  /// No description provided for @mktTabSaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённые'**
  String get mktTabSaved;

  /// No description provided for @mktTabBought.
  ///
  /// In ru, this message translates to:
  /// **'Куплено'**
  String get mktTabBought;

  /// No description provided for @mktEmptyNew.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто. Нажмите «Подобрать (ИИ)» — Система подберёт товары под ваш план.'**
  String get mktEmptyNew;

  /// No description provided for @mktEmptySaved.
  ///
  /// In ru, this message translates to:
  /// **'Сохранённых товаров нет.'**
  String get mktEmptySaved;

  /// No description provided for @mktEmptyBought.
  ///
  /// In ru, this message translates to:
  /// **'Покупок пока нет.'**
  String get mktEmptyBought;

  /// No description provided for @mktEstimateNote.
  ///
  /// In ru, this message translates to:
  /// **'Цены примерные — по данным веб-поиска, на указанную дату.'**
  String get mktEstimateNote;

  /// No description provided for @mktPriceLine.
  ///
  /// In ru, this message translates to:
  /// **'≈ {price} · {source} · {date}'**
  String mktPriceLine(String price, String source, String date);

  /// No description provided for @mktPriceShort.
  ///
  /// In ru, this message translates to:
  /// **'≈ {price} · {date}'**
  String mktPriceShort(String price, String date);

  /// No description provided for @mktPriceUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Цена неизвестна'**
  String get mktPriceUnknown;

  /// No description provided for @mktPricePaid.
  ///
  /// In ru, this message translates to:
  /// **'Куплено за {price}'**
  String mktPricePaid(String price);

  /// No description provided for @mktBudgetOk.
  ///
  /// In ru, this message translates to:
  /// **'Можно купить'**
  String get mktBudgetOk;

  /// No description provided for @mktBudgetAfterIncome.
  ///
  /// In ru, this message translates to:
  /// **'После поступления денег'**
  String get mktBudgetAfterIncome;

  /// No description provided for @mktBudgetOver.
  ///
  /// In ru, this message translates to:
  /// **'Не по бюджету'**
  String get mktBudgetOver;

  /// No description provided for @mktSave.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get mktSave;

  /// No description provided for @mktHide.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get mktHide;

  /// No description provided for @mktBought.
  ///
  /// In ru, this message translates to:
  /// **'Купил'**
  String get mktBought;

  /// No description provided for @mktRefreshPrice.
  ///
  /// In ru, this message translates to:
  /// **'Обновить цену'**
  String get mktRefreshPrice;

  /// No description provided for @mktPriceUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Цена обновлена.'**
  String get mktPriceUpdated;

  /// No description provided for @mktPriceNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Свежую цену найти не удалось.'**
  String get mktPriceNotFound;

  /// No description provided for @mktSearchSuffix.
  ///
  /// In ru, this message translates to:
  /// **'поиск'**
  String get mktSearchSuffix;

  /// No description provided for @mktLinkCopied.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка скопирована.'**
  String get mktLinkCopied;

  /// No description provided for @mktOpenFailed.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть ссылку — она скопирована.'**
  String get mktOpenFailed;

  /// No description provided for @mktBoughtTitle.
  ///
  /// In ru, this message translates to:
  /// **'Покупка'**
  String get mktBoughtTitle;

  /// No description provided for @mktBoughtMessage.
  ///
  /// In ru, this message translates to:
  /// **'Сколько стоило «{title}»?'**
  String mktBoughtMessage(String title);

  /// No description provided for @mktBoughtPrice.
  ///
  /// In ru, this message translates to:
  /// **'Фактическая цена'**
  String get mktBoughtPrice;

  /// No description provided for @mktBoughtConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Записать'**
  String get mktBoughtConfirm;

  /// No description provided for @mktBoughtRecorded.
  ///
  /// In ru, this message translates to:
  /// **'Покупка записана в финансы.'**
  String get mktBoughtRecorded;

  /// No description provided for @mktBoughtNoFinance.
  ///
  /// In ru, this message translates to:
  /// **'Отмечено как купленное. В финансы не записано — раздел пока недоступен.'**
  String get mktBoughtNoFinance;

  /// No description provided for @mktNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get mktNoticeLabel;

  /// No description provided for @mktNothingFound.
  ///
  /// In ru, this message translates to:
  /// **'Система не нашла новых товаров. Попробуйте другую категорию.'**
  String get mktNothingFound;

  /// No description provided for @mktAdded.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено товаров: {count}'**
  String mktAdded(int count);

  /// No description provided for @mktErrOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Сохранённые товары доступны и офлайн.'**
  String get mktErrOffline;

  /// No description provided for @mktErrNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт («Ещё» → «Аккаунт»), чтобы Система подбирала товары.'**
  String get mktErrNotSignedIn;

  /// No description provided for @mktErrBudget.
  ///
  /// In ru, this message translates to:
  /// **'Лимит ИИ сейчас исчерпан. Попробуйте позже.'**
  String get mktErrBudget;

  /// No description provided for @mktErrUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ИИ на сервере сейчас недоступен.'**
  String get mktErrUnavailable;

  /// No description provided for @mktErrRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много запросов. Попробуйте через некоторое время.'**
  String get mktErrRateLimited;

  /// No description provided for @mktErrServer.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить ответ. Попробуйте ещё раз.'**
  String get mktErrServer;

  /// No description provided for @msgChannelName.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения Системы'**
  String get msgChannelName;

  /// No description provided for @msgChannelDesc.
  ///
  /// In ru, this message translates to:
  /// **'Брифинги, подбадривания и упрёки персонажа'**
  String get msgChannelDesc;

  /// No description provided for @msgTplBriefingTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Система ] Утренний брифинг'**
  String get msgTplBriefingTitle;

  /// No description provided for @msgTplBriefing1.
  ///
  /// In ru, this message translates to:
  /// **'Новый день — новые квесты. Открой список и начни с первого.'**
  String get msgTplBriefing1;

  /// No description provided for @msgTplBriefing2.
  ///
  /// In ru, this message translates to:
  /// **'Игрок, подъём. План на сегодня уже ждёт.'**
  String get msgTplBriefing2;

  /// No description provided for @msgTplBriefing3.
  ///
  /// In ru, this message translates to:
  /// **'Система на связи. Сегодняшние квесты сами себя не выполнят.'**
  String get msgTplBriefing3;

  /// No description provided for @msgTplCheerTitle.
  ///
  /// In ru, this message translates to:
  /// **'[ Система ]'**
  String get msgTplCheerTitle;

  /// No description provided for @msgTplCheer1.
  ///
  /// In ru, this message translates to:
  /// **'Ты держишь темп. Не сбавляй.'**
  String get msgTplCheer1;

  /// No description provided for @msgTplCheer2.
  ///
  /// In ru, this message translates to:
  /// **'Каждый выполненный квест — шаг к следующему рангу.'**
  String get msgTplCheer2;

  /// No description provided for @msgTplCheer3.
  ///
  /// In ru, this message translates to:
  /// **'Проверь квесты: что можно закрыть прямо сейчас?'**
  String get msgTplCheer3;

  /// No description provided for @msgTplCheer4.
  ///
  /// In ru, this message translates to:
  /// **'Глоток воды и вперёд. Система следит за прогрессом.'**
  String get msgTplCheer4;

  /// No description provided for @msgWaterQuestTitle.
  ///
  /// In ru, this message translates to:
  /// **'Дойти до магазина за водой'**
  String get msgWaterQuestTitle;

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

  /// No description provided for @nutYesterday.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get nutYesterday;

  /// No description provided for @nutToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get nutToday;

  /// No description provided for @nutNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление'**
  String get nutNoticeLabel;

  /// No description provided for @nutProtein.
  ///
  /// In ru, this message translates to:
  /// **'Белки'**
  String get nutProtein;

  /// No description provided for @nutFat.
  ///
  /// In ru, this message translates to:
  /// **'Жиры'**
  String get nutFat;

  /// No description provided for @nutCarbs.
  ///
  /// In ru, this message translates to:
  /// **'Углеводы'**
  String get nutCarbs;

  /// No description provided for @nutBalance.
  ///
  /// In ru, this message translates to:
  /// **'Баланс'**
  String get nutBalance;

  /// No description provided for @nutNoNorm.
  ///
  /// In ru, this message translates to:
  /// **'Нормы нет: примите план, чтобы видеть цель по калориям и БЖУ.'**
  String get nutNoNorm;

  /// No description provided for @nutNoWaterNorm.
  ///
  /// In ru, this message translates to:
  /// **'Норма воды появится после принятия плана.'**
  String get nutNoWaterNorm;

  /// No description provided for @nutGrams.
  ///
  /// In ru, this message translates to:
  /// **'{value} г'**
  String nutGrams(String value);

  /// No description provided for @nutGramsProgress.
  ///
  /// In ru, this message translates to:
  /// **'{current} / {total} г'**
  String nutGramsProgress(String current, String total);

  /// No description provided for @nutLiters.
  ///
  /// In ru, this message translates to:
  /// **'{value} л'**
  String nutLiters(String value);

  /// No description provided for @nutMacrosLine.
  ///
  /// In ru, this message translates to:
  /// **'Б {protein} · Ж {fat} · У {carbs}'**
  String nutMacrosLine(String protein, String fat, String carbs);

  /// No description provided for @nutTotalLine.
  ///
  /// In ru, this message translates to:
  /// **'Итого: {kcal} ккал · {macros}'**
  String nutTotalLine(String kcal, String macros);

  /// No description provided for @nutPerServing.
  ///
  /// In ru, this message translates to:
  /// **'Порция: {kcal} · {macros}'**
  String nutPerServing(String kcal, String macros);

  /// No description provided for @nutWaterAdd.
  ///
  /// In ru, this message translates to:
  /// **'+{ml} мл'**
  String nutWaterAdd(int ml);

  /// No description provided for @nutWaterUndo.
  ///
  /// In ru, this message translates to:
  /// **'Отменить последнюю запись воды'**
  String get nutWaterUndo;

  /// No description provided for @nutTrainingDay.
  ///
  /// In ru, this message translates to:
  /// **'День тренировки'**
  String get nutTrainingDay;

  /// No description provided for @nutAddTitle.
  ///
  /// In ru, this message translates to:
  /// **'Добавить еду'**
  String get nutAddTitle;

  /// No description provided for @nutAddBarcode.
  ///
  /// In ru, this message translates to:
  /// **'Штрихкод'**
  String get nutAddBarcode;

  /// No description provided for @nutAddManual.
  ///
  /// In ru, this message translates to:
  /// **'Вручную'**
  String get nutAddManual;

  /// No description provided for @nutAddPhoto.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get nutAddPhoto;

  /// No description provided for @nutRecipes.
  ///
  /// In ru, this message translates to:
  /// **'Мои рецепты'**
  String get nutRecipes;

  /// No description provided for @nutSearching.
  ///
  /// In ru, this message translates to:
  /// **'Поиск…'**
  String get nutSearching;

  /// No description provided for @nutDiaryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Записей за день нет. Добавьте еду — штрихкодом, вручную, фото или рецептом.'**
  String get nutDiaryEmpty;

  /// No description provided for @nutWithPhoto.
  ///
  /// In ru, this message translates to:
  /// **'с фото'**
  String get nutWithPhoto;

  /// No description provided for @nutMealBreakfast.
  ///
  /// In ru, this message translates to:
  /// **'Завтрак'**
  String get nutMealBreakfast;

  /// No description provided for @nutMealLunch.
  ///
  /// In ru, this message translates to:
  /// **'Обед'**
  String get nutMealLunch;

  /// No description provided for @nutMealDinner.
  ///
  /// In ru, this message translates to:
  /// **'Ужин'**
  String get nutMealDinner;

  /// No description provided for @nutMealSnack.
  ///
  /// In ru, this message translates to:
  /// **'Перекус'**
  String get nutMealSnack;

  /// No description provided for @nutNewEntry.
  ///
  /// In ru, this message translates to:
  /// **'Новая запись'**
  String get nutNewEntry;

  /// No description provided for @nutEditEntry.
  ///
  /// In ru, this message translates to:
  /// **'Запись дневника'**
  String get nutEditEntry;

  /// No description provided for @nutRecipeLineTitle.
  ///
  /// In ru, this message translates to:
  /// **'Строка рецепта'**
  String get nutRecipeLineTitle;

  /// No description provided for @nutPhotoSaved.
  ///
  /// In ru, this message translates to:
  /// **'Фото сохранено'**
  String get nutPhotoSaved;

  /// No description provided for @nutPhotoAiLater.
  ///
  /// In ru, this message translates to:
  /// **'Распознавание блюда по фото Система откроет позже. Пока введите название и КБЖУ сами.'**
  String get nutPhotoAiLater;

  /// No description provided for @nutFieldTitle.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get nutFieldTitle;

  /// No description provided for @nutFieldTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: овсянка с бананом'**
  String get nutFieldTitleHint;

  /// No description provided for @nutFieldMeal.
  ///
  /// In ru, this message translates to:
  /// **'Приём пищи'**
  String get nutFieldMeal;

  /// No description provided for @nutFieldMode.
  ///
  /// In ru, this message translates to:
  /// **'Как считать'**
  String get nutFieldMode;

  /// No description provided for @nutModePortion.
  ///
  /// In ru, this message translates to:
  /// **'На порцию'**
  String get nutModePortion;

  /// No description provided for @nutModePer100.
  ///
  /// In ru, this message translates to:
  /// **'На 100 г'**
  String get nutModePer100;

  /// No description provided for @nutFieldGrams.
  ///
  /// In ru, this message translates to:
  /// **'Вес порции'**
  String get nutFieldGrams;

  /// No description provided for @nutErrorGrams.
  ///
  /// In ru, this message translates to:
  /// **'Укажите вес в граммах'**
  String get nutErrorGrams;

  /// No description provided for @nutValuesPer100.
  ///
  /// In ru, this message translates to:
  /// **'Значения на 100 г'**
  String get nutValuesPer100;

  /// No description provided for @nutValuesPortion.
  ///
  /// In ru, this message translates to:
  /// **'Значения на всю порцию'**
  String get nutValuesPortion;

  /// No description provided for @nutFieldKcal.
  ///
  /// In ru, this message translates to:
  /// **'Калории'**
  String get nutFieldKcal;

  /// No description provided for @nutFieldProtein.
  ///
  /// In ru, this message translates to:
  /// **'Белки'**
  String get nutFieldProtein;

  /// No description provided for @nutFieldFat.
  ///
  /// In ru, this message translates to:
  /// **'Жиры'**
  String get nutFieldFat;

  /// No description provided for @nutFieldCarbs.
  ///
  /// In ru, this message translates to:
  /// **'Углеводы'**
  String get nutFieldCarbs;

  /// No description provided for @nutUnitKcal.
  ///
  /// In ru, this message translates to:
  /// **'ккал'**
  String get nutUnitKcal;

  /// No description provided for @nutUnitG.
  ///
  /// In ru, this message translates to:
  /// **'г'**
  String get nutUnitG;

  /// No description provided for @nutUnitKg.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get nutUnitKg;

  /// No description provided for @nutUnitPcs.
  ///
  /// In ru, this message translates to:
  /// **'шт.'**
  String get nutUnitPcs;

  /// No description provided for @nutUnitL.
  ///
  /// In ru, this message translates to:
  /// **'л'**
  String get nutUnitL;

  /// No description provided for @nutUnitMl.
  ///
  /// In ru, this message translates to:
  /// **'мл'**
  String get nutUnitMl;

  /// No description provided for @nutSaveToProducts.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить в мои продукты'**
  String get nutSaveToProducts;

  /// No description provided for @nutSaveToProductsHint.
  ///
  /// In ru, this message translates to:
  /// **'Потом найдётся поиском — без повторного ввода'**
  String get nutSaveToProductsHint;

  /// No description provided for @nutMyProducts.
  ///
  /// In ru, this message translates to:
  /// **'Мои продукты'**
  String get nutMyProducts;

  /// No description provided for @nutSearchHint.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по названию или штрихкоду'**
  String get nutSearchHint;

  /// No description provided for @nutWithoutProduct.
  ///
  /// In ru, this message translates to:
  /// **'Без продукта'**
  String get nutWithoutProduct;

  /// No description provided for @nutNewProduct.
  ///
  /// In ru, this message translates to:
  /// **'Новый продукт'**
  String get nutNewProduct;

  /// No description provided for @nutNoProducts.
  ///
  /// In ru, this message translates to:
  /// **'Продуктов пока нет. Отсканируйте штрихкод или добавьте продукт вручную.'**
  String get nutNoProducts;

  /// No description provided for @nutPer100Short.
  ///
  /// In ru, this message translates to:
  /// **'100 г'**
  String get nutPer100Short;

  /// No description provided for @nutProductNameHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: йогурт натуральный'**
  String get nutProductNameHint;

  /// No description provided for @nutFieldBrand.
  ///
  /// In ru, this message translates to:
  /// **'Бренд'**
  String get nutFieldBrand;

  /// No description provided for @nutFieldBarcode.
  ///
  /// In ru, this message translates to:
  /// **'Штрихкод'**
  String get nutFieldBarcode;

  /// No description provided for @nutFieldServing.
  ///
  /// In ru, this message translates to:
  /// **'Обычная порция'**
  String get nutFieldServing;

  /// No description provided for @nutBarcodeNotFound.
  ///
  /// In ru, this message translates to:
  /// **'Продукта нет в Open Food Facts. Введите данные с упаковки — Система запомнит его по штрихкоду.'**
  String get nutBarcodeNotFound;

  /// No description provided for @nutBarcodeOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с базой продуктов. Введите данные с упаковки — Система запомнит продукт по штрихкоду.'**
  String get nutBarcodeOffline;

  /// No description provided for @nutScanTitle.
  ///
  /// In ru, this message translates to:
  /// **'Штрихкод'**
  String get nutScanTitle;

  /// No description provided for @nutScanHint.
  ///
  /// In ru, this message translates to:
  /// **'Наведите камеру на штрихкод упаковки'**
  String get nutScanHint;

  /// No description provided for @nutScanNoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна. Разрешите доступ к камере в настройках или введите продукт вручную.'**
  String get nutScanNoCamera;

  /// No description provided for @nutPhotoTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото еды'**
  String get nutPhotoTitle;

  /// No description provided for @nutPhotoMessage.
  ///
  /// In ru, this message translates to:
  /// **'Снимите блюдо или выберите фото из галереи. Фото сохранится в записи дневника.'**
  String get nutPhotoMessage;

  /// No description provided for @nutPhotoCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get nutPhotoCamera;

  /// No description provided for @nutPhotoGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get nutPhotoGallery;

  /// No description provided for @nutPortions.
  ///
  /// In ru, this message translates to:
  /// **'Порций'**
  String get nutPortions;

  /// No description provided for @nutAddToDiary.
  ///
  /// In ru, this message translates to:
  /// **'Добавить в дневник'**
  String get nutAddToDiary;

  /// No description provided for @nutRecipesEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Рецептов пока нет. Соберите блюдо из продуктов один раз — потом добавляйте его в один тап.'**
  String get nutRecipesEmpty;

  /// No description provided for @nutNewRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Новый рецепт'**
  String get nutNewRecipe;

  /// No description provided for @nutEditRecipe.
  ///
  /// In ru, this message translates to:
  /// **'Рецепт'**
  String get nutEditRecipe;

  /// No description provided for @nutRecipeTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: омлет с овощами'**
  String get nutRecipeTitleHint;

  /// No description provided for @nutServings.
  ///
  /// In ru, this message translates to:
  /// **'Порций в блюде'**
  String get nutServings;

  /// No description provided for @nutIngredients.
  ///
  /// In ru, this message translates to:
  /// **'Состав'**
  String get nutIngredients;

  /// No description provided for @nutIngredientsEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Добавьте хотя бы один продукт или строку.'**
  String get nutIngredientsEmpty;

  /// No description provided for @nutFromProducts.
  ///
  /// In ru, this message translates to:
  /// **'Из продуктов'**
  String get nutFromProducts;

  /// No description provided for @nutManualLine.
  ///
  /// In ru, this message translates to:
  /// **'Вручную'**
  String get nutManualLine;

  /// No description provided for @nutShopping.
  ///
  /// In ru, this message translates to:
  /// **'Список покупок'**
  String get nutShopping;

  /// No description provided for @nutShopNothing.
  ///
  /// In ru, this message translates to:
  /// **'Список пуст — откройте, чтобы добавить покупки.'**
  String get nutShopNothing;

  /// No description provided for @nutShopRemainingCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{Осталось купить: {count} позиция · {sum}} few{Осталось купить: {count} позиции · {sum}} many{Осталось купить: {count} позиций · {sum}} other{Осталось купить: {count} позиции · {sum}}}'**
  String nutShopRemainingCount(int count, String sum);

  /// No description provided for @nutShopAdd.
  ///
  /// In ru, this message translates to:
  /// **'Добавить покупку'**
  String get nutShopAdd;

  /// No description provided for @nutShopEdit.
  ///
  /// In ru, this message translates to:
  /// **'Покупка'**
  String get nutShopEdit;

  /// No description provided for @nutShopTotal.
  ///
  /// In ru, this message translates to:
  /// **'Всего (примерно)'**
  String get nutShopTotal;

  /// No description provided for @nutShopRemaining.
  ///
  /// In ru, this message translates to:
  /// **'Ещё не куплено'**
  String get nutShopRemaining;

  /// No description provided for @nutShopPriceNote.
  ///
  /// In ru, this message translates to:
  /// **'Суммы — по ценам, которые вы указали.'**
  String get nutShopPriceNote;

  /// No description provided for @nutShopFromPlan.
  ///
  /// In ru, this message translates to:
  /// **'От плана питания'**
  String get nutShopFromPlan;

  /// No description provided for @nutShopFromPlanHint.
  ///
  /// In ru, this message translates to:
  /// **'Базовый список на неделю по нормам плана: белок, крупы, овощи, фрукты, вода. Цены укажите сами.'**
  String get nutShopFromPlanHint;

  /// No description provided for @nutShopNoPlan.
  ///
  /// In ru, this message translates to:
  /// **'Примите план — тогда Система составит базовый список на неделю.'**
  String get nutShopNoPlan;

  /// No description provided for @nutShopGenerate.
  ///
  /// In ru, this message translates to:
  /// **'Составить на неделю'**
  String get nutShopGenerate;

  /// No description provided for @nutShopEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Покупок пока нет.'**
  String get nutShopEmpty;

  /// No description provided for @nutShopClearDone.
  ///
  /// In ru, this message translates to:
  /// **'Убрать купленное'**
  String get nutShopClearDone;

  /// No description provided for @nutShopTitleHint.
  ///
  /// In ru, this message translates to:
  /// **'Например: гречка'**
  String get nutShopTitleHint;

  /// No description provided for @nutShopQuantity.
  ///
  /// In ru, this message translates to:
  /// **'Количество'**
  String get nutShopQuantity;

  /// No description provided for @nutShopPrice.
  ///
  /// In ru, this message translates to:
  /// **'Примерная цена'**
  String get nutShopPrice;

  /// No description provided for @nutGroceryChicken.
  ///
  /// In ru, this message translates to:
  /// **'Куриная грудка / индейка'**
  String get nutGroceryChicken;

  /// No description provided for @nutGroceryEggs.
  ///
  /// In ru, this message translates to:
  /// **'Яйца'**
  String get nutGroceryEggs;

  /// No description provided for @nutGroceryCottageCheese.
  ///
  /// In ru, this message translates to:
  /// **'Творог'**
  String get nutGroceryCottageCheese;

  /// No description provided for @nutGroceryGrains.
  ///
  /// In ru, this message translates to:
  /// **'Крупы (гречка, рис)'**
  String get nutGroceryGrains;

  /// No description provided for @nutGroceryOats.
  ///
  /// In ru, this message translates to:
  /// **'Овсяные хлопья'**
  String get nutGroceryOats;

  /// No description provided for @nutGroceryVegetables.
  ///
  /// In ru, this message translates to:
  /// **'Овощи'**
  String get nutGroceryVegetables;

  /// No description provided for @nutGroceryFruits.
  ///
  /// In ru, this message translates to:
  /// **'Фрукты'**
  String get nutGroceryFruits;

  /// No description provided for @nutGroceryOil.
  ///
  /// In ru, this message translates to:
  /// **'Растительное масло'**
  String get nutGroceryOil;

  /// No description provided for @nutGroceryWater.
  ///
  /// In ru, this message translates to:
  /// **'Питьевая вода'**
  String get nutGroceryWater;

  /// No description provided for @ovlSettingTitle.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж поверх приложений'**
  String get ovlSettingTitle;

  /// No description provided for @ovlSettingHint.
  ///
  /// In ru, this message translates to:
  /// **'Когда Система свёрнута, персонаж висит у края экрана и показывает сообщения. Тап — открыть Систему, удержание — скрыть.'**
  String get ovlSettingHint;

  /// No description provided for @ovlPermissionDenied.
  ///
  /// In ru, this message translates to:
  /// **'Нужно разрешение «Поверх других приложений».'**
  String get ovlPermissionDenied;

  /// No description provided for @ovlNotificationTitle.
  ///
  /// In ru, this message translates to:
  /// **'Персонаж на экране'**
  String get ovlNotificationTitle;

  /// No description provided for @ovlNotificationBody.
  ///
  /// In ru, this message translates to:
  /// **'Нажмите, чтобы открыть Систему'**
  String get ovlNotificationBody;

  /// No description provided for @ovlHideAction.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get ovlHideAction;

  /// No description provided for @ovlAvatarLabel.
  ///
  /// In ru, this message translates to:
  /// **'{name}: нажмите, чтобы открыть Систему; удерживайте, чтобы скрыть'**
  String ovlAvatarLabel(String name);

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

  /// No description provided for @wrkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тренировки'**
  String get wrkTitle;

  /// No description provided for @wrkProgram.
  ///
  /// In ru, this message translates to:
  /// **'Программа'**
  String get wrkProgram;

  /// No description provided for @wrkToday.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get wrkToday;

  /// No description provided for @wrkTodayDay.
  ///
  /// In ru, this message translates to:
  /// **'По программе — день {key}'**
  String wrkTodayDay(String key);

  /// No description provided for @wrkRestDay.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня по программе отдых. Можно провести любую тренировку из списка ниже.'**
  String get wrkRestDay;

  /// No description provided for @wrkDayTitle.
  ///
  /// In ru, this message translates to:
  /// **'День {key}'**
  String wrkDayTitle(String key);

  /// No description provided for @wrkMinutesShort.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин'**
  String wrkMinutesShort(int minutes);

  /// No description provided for @wrkEstimate.
  ///
  /// In ru, this message translates to:
  /// **'≈{minutes} мин'**
  String wrkEstimate(int minutes);

  /// No description provided for @wrkExerciseCount.
  ///
  /// In ru, this message translates to:
  /// **'{count, plural, one{{count} упражнение} few{{count} упражнения} many{{count} упражнений} other{{count} упражнения}}'**
  String wrkExerciseCount(int count);

  /// No description provided for @wrkSetsReps.
  ///
  /// In ru, this message translates to:
  /// **'{sets} × {reps}'**
  String wrkSetsReps(int sets, int reps);

  /// No description provided for @wrkSetsSeconds.
  ///
  /// In ru, this message translates to:
  /// **'{sets} × {seconds} с'**
  String wrkSetsSeconds(int sets, int seconds);

  /// No description provided for @wrkRestShort.
  ///
  /// In ru, this message translates to:
  /// **'отдых {seconds} с'**
  String wrkRestShort(int seconds);

  /// No description provided for @wrkGentle.
  ///
  /// In ru, this message translates to:
  /// **'Щадящий вариант: без прыжков и осевой нагрузки — в анкете указаны травмы или ограничения.'**
  String get wrkGentle;

  /// No description provided for @wrkSafetyNote.
  ///
  /// In ru, this message translates to:
  /// **'Если упражнение вызывает боль или дискомфорт — пропустите его.'**
  String get wrkSafetyNote;

  /// No description provided for @wrkLevelUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Уровень в анкете не указан — программа для новичка.'**
  String get wrkLevelUnknown;

  /// No description provided for @wrkProgressionWeeks.
  ///
  /// In ru, this message translates to:
  /// **'Выполненных недель: {weeks}'**
  String wrkProgressionWeeks(int weeks);

  /// No description provided for @wrkProgressionNote.
  ///
  /// In ru, this message translates to:
  /// **'Неделя засчитывается, если выполнены все тренировки недели (не больше 3). За каждую: +1 повтор или +5 с, до потолка вашего уровня.'**
  String get wrkProgressionNote;

  /// No description provided for @wrkRegenerate.
  ///
  /// In ru, this message translates to:
  /// **'Пересоздать программу'**
  String get wrkRegenerate;

  /// No description provided for @wrkRegenerateTitle.
  ///
  /// In ru, this message translates to:
  /// **'Пересоздать программу?'**
  String get wrkRegenerateTitle;

  /// No description provided for @wrkRegenerateText.
  ///
  /// In ru, this message translates to:
  /// **'Программа соберётся заново по анкете и плану. История тренировок сохранится, прогрессия начнётся сначала.'**
  String get wrkRegenerateText;

  /// No description provided for @wrkAiProgram.
  ///
  /// In ru, this message translates to:
  /// **'Программа от ИИ'**
  String get wrkAiProgram;

  /// No description provided for @wrkSoon.
  ///
  /// In ru, this message translates to:
  /// **'скоро'**
  String get wrkSoon;

  /// No description provided for @wrkStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать тренировку'**
  String get wrkStart;

  /// No description provided for @wrkStartDay.
  ///
  /// In ru, this message translates to:
  /// **'Начать день {key}'**
  String wrkStartDay(String key);

  /// No description provided for @wrkHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get wrkHistory;

  /// No description provided for @wrkHistoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Тренировок пока нет.'**
  String get wrkHistoryEmpty;

  /// No description provided for @wrkSessionDone.
  ///
  /// In ru, this message translates to:
  /// **'завершена'**
  String get wrkSessionDone;

  /// No description provided for @wrkSessionInterrupted.
  ///
  /// In ru, this message translates to:
  /// **'прервана'**
  String get wrkSessionInterrupted;

  /// No description provided for @wrkSessionStats.
  ///
  /// In ru, this message translates to:
  /// **'{minutes} мин · ≈{kcal} ккал'**
  String wrkSessionStats(int minutes, int kcal);

  /// No description provided for @wrkPreparing.
  ///
  /// In ru, this message translates to:
  /// **'Программа собирается…'**
  String get wrkPreparing;

  /// No description provided for @wrkPhasePrepare.
  ///
  /// In ru, this message translates to:
  /// **'Приготовьтесь'**
  String get wrkPhasePrepare;

  /// No description provided for @wrkPhaseWork.
  ///
  /// In ru, this message translates to:
  /// **'Работа'**
  String get wrkPhaseWork;

  /// No description provided for @wrkPhaseRest.
  ///
  /// In ru, this message translates to:
  /// **'Отдых'**
  String get wrkPhaseRest;

  /// No description provided for @wrkPaused.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get wrkPaused;

  /// No description provided for @wrkSetOf.
  ///
  /// In ru, this message translates to:
  /// **'Подход {set} из {sets}'**
  String wrkSetOf(int set, int sets);

  /// No description provided for @wrkRepsTarget.
  ///
  /// In ru, this message translates to:
  /// **'{reps, plural, one{{reps} повтор} few{{reps} повтора} many{{reps} повторов} other{{reps} повтора}}'**
  String wrkRepsTarget(int reps);

  /// No description provided for @wrkDoneSet.
  ///
  /// In ru, this message translates to:
  /// **'Подход выполнен'**
  String get wrkDoneSet;

  /// No description provided for @wrkPause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get wrkPause;

  /// No description provided for @wrkResume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get wrkResume;

  /// No description provided for @wrkSkipRest.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить отдых'**
  String get wrkSkipRest;

  /// No description provided for @wrkSkipExercise.
  ///
  /// In ru, this message translates to:
  /// **'Пропустить упражнение'**
  String get wrkSkipExercise;

  /// No description provided for @wrkStop.
  ///
  /// In ru, this message translates to:
  /// **'Прервать'**
  String get wrkStop;

  /// No description provided for @wrkNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее: {name}'**
  String wrkNext(String name);

  /// No description provided for @wrkLastExercise.
  ///
  /// In ru, this message translates to:
  /// **'Последнее упражнение'**
  String get wrkLastExercise;

  /// No description provided for @wrkTechnique.
  ///
  /// In ru, this message translates to:
  /// **'Техника'**
  String get wrkTechnique;

  /// No description provided for @wrkVoice.
  ///
  /// In ru, this message translates to:
  /// **'Голосовые подсказки'**
  String get wrkVoice;

  /// No description provided for @wrkProgressLabel.
  ///
  /// In ru, this message translates to:
  /// **'Прогресс тренировки'**
  String get wrkProgressLabel;

  /// No description provided for @wrkStopTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прервать тренировку?'**
  String get wrkStopTitle;

  /// No description provided for @wrkStopText.
  ///
  /// In ru, this message translates to:
  /// **'Сделанное сохранится как незавершённая тренировка.'**
  String get wrkStopText;

  /// No description provided for @wrkFinishedTitle.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка завершена'**
  String get wrkFinishedTitle;

  /// No description provided for @wrkFinishedStats.
  ///
  /// In ru, this message translates to:
  /// **'Время: {minutes} мин · ≈{kcal} ккал · подходов: {sets}'**
  String wrkFinishedStats(int minutes, int kcal, int sets);

  /// No description provided for @wrkWeightAssumed.
  ///
  /// In ru, this message translates to:
  /// **'Расход — оценка по весу 70 кг: замеров веса нет.'**
  String get wrkWeightAssumed;

  /// No description provided for @wrkKcalNote.
  ///
  /// In ru, this message translates to:
  /// **'Расход — оценка по MET, не измерение.'**
  String get wrkKcalNote;

  /// No description provided for @wrkSayPrepare.
  ///
  /// In ru, this message translates to:
  /// **'Приготовьтесь. {name}.'**
  String wrkSayPrepare(String name);

  /// No description provided for @wrkSaySet.
  ///
  /// In ru, this message translates to:
  /// **'Подход {set} из {sets}. {amount}. Начали!'**
  String wrkSaySet(int set, int sets, String amount);

  /// No description provided for @wrkSecondsAmount.
  ///
  /// In ru, this message translates to:
  /// **'{seconds, plural, one{{seconds} секунда} few{{seconds} секунды} many{{seconds} секунд} other{{seconds} секунды}}'**
  String wrkSecondsAmount(int seconds);

  /// No description provided for @wrkSayRest.
  ///
  /// In ru, this message translates to:
  /// **'Отдых: {amount}.'**
  String wrkSayRest(String amount);

  /// No description provided for @wrkSayNext.
  ///
  /// In ru, this message translates to:
  /// **'Далее: {name}.'**
  String wrkSayNext(String name);

  /// No description provided for @wrkSayFinished.
  ///
  /// In ru, this message translates to:
  /// **'Тренировка завершена. Отличная работа!'**
  String get wrkSayFinished;

  /// No description provided for @wrkExMarchInPlace.
  ///
  /// In ru, this message translates to:
  /// **'Ходьба на месте'**
  String get wrkExMarchInPlace;

  /// No description provided for @wrkExMarchInPlaceHint.
  ///
  /// In ru, this message translates to:
  /// **'Высоко поднимайте колени.\nРуки работают в такт.\nДышите ровно.'**
  String get wrkExMarchInPlaceHint;

  /// No description provided for @wrkExArmCircles.
  ///
  /// In ru, this message translates to:
  /// **'Круги руками'**
  String get wrkExArmCircles;

  /// No description provided for @wrkExArmCirclesHint.
  ///
  /// In ru, this message translates to:
  /// **'Руки в стороны на уровне плеч.\nМаленькие круги вперёд, затем назад.\nПлечи опущены.'**
  String get wrkExArmCirclesHint;

  /// No description provided for @wrkExJumpingJacks.
  ///
  /// In ru, this message translates to:
  /// **'Джампинг-джек'**
  String get wrkExJumpingJacks;

  /// No description provided for @wrkExJumpingJacksHint.
  ///
  /// In ru, this message translates to:
  /// **'Прыжок: ноги врозь, руки вверх.\nПрыжок обратно.\nПриземляйтесь мягко на носки.'**
  String get wrkExJumpingJacksHint;

  /// No description provided for @wrkExChairSquat.
  ///
  /// In ru, this message translates to:
  /// **'Приседание на стул'**
  String get wrkExChairSquat;

  /// No description provided for @wrkExChairSquatHint.
  ///
  /// In ru, this message translates to:
  /// **'Встаньте перед стулом, ноги на ширине плеч.\nСядьте, отводя таз назад.\nВстаньте без рывка.'**
  String get wrkExChairSquatHint;

  /// No description provided for @wrkExGluteBridge.
  ///
  /// In ru, this message translates to:
  /// **'Ягодичный мост'**
  String get wrkExGluteBridge;

  /// No description provided for @wrkExGluteBridgeHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на спине, стопы на полу.\nПоднимите таз, сожмите ягодицы.\nМедленно опуститесь.'**
  String get wrkExGluteBridgeHint;

  /// No description provided for @wrkExSquat.
  ///
  /// In ru, this message translates to:
  /// **'Приседания'**
  String get wrkExSquat;

  /// No description provided for @wrkExSquatHint.
  ///
  /// In ru, this message translates to:
  /// **'Ноги на ширине плеч, носки чуть врозь.\nТаз назад, колени по направлению носков.\nСпина прямая, пятки на полу.'**
  String get wrkExSquatHint;

  /// No description provided for @wrkExWallSit.
  ///
  /// In ru, this message translates to:
  /// **'Стульчик у стены'**
  String get wrkExWallSit;

  /// No description provided for @wrkExWallSitHint.
  ///
  /// In ru, this message translates to:
  /// **'Спина прижата к стене.\nОпуститесь, пока бёдра не станут почти параллельны полу.\nДержите позицию.'**
  String get wrkExWallSitHint;

  /// No description provided for @wrkExReverseLunge.
  ///
  /// In ru, this message translates to:
  /// **'Выпады назад'**
  String get wrkExReverseLunge;

  /// No description provided for @wrkExReverseLungeHint.
  ///
  /// In ru, this message translates to:
  /// **'Шаг назад, опустите заднее колено к полу.\nПереднее колено над стопой.\nВернитесь, смените ногу.'**
  String get wrkExReverseLungeHint;

  /// No description provided for @wrkExGobletSquat.
  ///
  /// In ru, this message translates to:
  /// **'Гоблет-присед'**
  String get wrkExGobletSquat;

  /// No description provided for @wrkExGobletSquatHint.
  ///
  /// In ru, this message translates to:
  /// **'Гантель вертикально у груди.\nПрисед, локти между коленями.\nСпина прямая.'**
  String get wrkExGobletSquatHint;

  /// No description provided for @wrkExKettlebellSwing.
  ///
  /// In ru, this message translates to:
  /// **'Махи гирей'**
  String get wrkExKettlebellSwing;

  /// No description provided for @wrkExKettlebellSwingHint.
  ///
  /// In ru, this message translates to:
  /// **'Гиря двумя руками, ноги шире плеч.\nТаз назад, затем резко вперёд.\nГиря поднимается до груди за счёт таза.'**
  String get wrkExKettlebellSwingHint;

  /// No description provided for @wrkExJumpSquat.
  ///
  /// In ru, this message translates to:
  /// **'Присед с выпрыгиванием'**
  String get wrkExJumpSquat;

  /// No description provided for @wrkExJumpSquatHint.
  ///
  /// In ru, this message translates to:
  /// **'Обычный присед.\nВыпрыгните вверх.\nПриземлитесь мягко сразу в присед.'**
  String get wrkExJumpSquatHint;

  /// No description provided for @wrkExWallPushUp.
  ///
  /// In ru, this message translates to:
  /// **'Отжимания от стены'**
  String get wrkExWallPushUp;

  /// No description provided for @wrkExWallPushUpHint.
  ///
  /// In ru, this message translates to:
  /// **'Ладони на стене на уровне плеч.\nСогните руки, корпус прямой.\nОттолкнитесь.'**
  String get wrkExWallPushUpHint;

  /// No description provided for @wrkExKneePushUp.
  ///
  /// In ru, this message translates to:
  /// **'Отжимания с колен'**
  String get wrkExKneePushUp;

  /// No description provided for @wrkExKneePushUpHint.
  ///
  /// In ru, this message translates to:
  /// **'Упор на колени и ладони.\nКорпус прямой от колен до головы.\nГрудь к полу и вверх.'**
  String get wrkExKneePushUpHint;

  /// No description provided for @wrkExPushUp.
  ///
  /// In ru, this message translates to:
  /// **'Отжимания'**
  String get wrkExPushUp;

  /// No description provided for @wrkExPushUpHint.
  ///
  /// In ru, this message translates to:
  /// **'Упор лёжа, ладони чуть шире плеч.\nКорпус — прямая линия.\nГрудь к полу, локти под 45°.'**
  String get wrkExPushUpHint;

  /// No description provided for @wrkExDumbbellPress.
  ///
  /// In ru, this message translates to:
  /// **'Жим гантелей лёжа'**
  String get wrkExDumbbellPress;

  /// No description provided for @wrkExDumbbellPressHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на полу, гантели над грудью.\nОпустите до касания локтями пола.\nВыжмите вверх.'**
  String get wrkExDumbbellPressHint;

  /// No description provided for @wrkExDiamondPushUp.
  ///
  /// In ru, this message translates to:
  /// **'Узкие отжимания'**
  String get wrkExDiamondPushUp;

  /// No description provided for @wrkExDiamondPushUpHint.
  ///
  /// In ru, this message translates to:
  /// **'Ладони рядом под грудью.\nЛокти вдоль корпуса.\nКорпус прямой.'**
  String get wrkExDiamondPushUpHint;

  /// No description provided for @wrkExSuperman.
  ///
  /// In ru, this message translates to:
  /// **'Супермен'**
  String get wrkExSuperman;

  /// No description provided for @wrkExSupermanHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на животе, руки вперёд.\nПоднимите руки и ноги на пару секунд.\nМедленно опустите.'**
  String get wrkExSupermanHint;

  /// No description provided for @wrkExReverseSnowAngel.
  ///
  /// In ru, this message translates to:
  /// **'Обратный снежный ангел'**
  String get wrkExReverseSnowAngel;

  /// No description provided for @wrkExReverseSnowAngelHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на животе, руки вдоль тела.\nПриподнимите грудь и руки.\nДугой проведите руки над головой и обратно.'**
  String get wrkExReverseSnowAngelHint;

  /// No description provided for @wrkExBandRow.
  ///
  /// In ru, this message translates to:
  /// **'Тяга резинки'**
  String get wrkExBandRow;

  /// No description provided for @wrkExBandRowHint.
  ///
  /// In ru, this message translates to:
  /// **'Закрепите резинку на уровне груди.\nТяните к поясу, сводя лопатки.\nПлавно отпустите.'**
  String get wrkExBandRowHint;

  /// No description provided for @wrkExDumbbellRow.
  ///
  /// In ru, this message translates to:
  /// **'Тяга гантели в наклоне'**
  String get wrkExDumbbellRow;

  /// No description provided for @wrkExDumbbellRowHint.
  ///
  /// In ru, this message translates to:
  /// **'Опора рукой и коленом о стул.\nТяните гантель к поясу.\nСпина ровная.'**
  String get wrkExDumbbellRowHint;

  /// No description provided for @wrkExPullUp.
  ///
  /// In ru, this message translates to:
  /// **'Подтягивания'**
  String get wrkExPullUp;

  /// No description provided for @wrkExPullUpHint.
  ///
  /// In ru, this message translates to:
  /// **'Хват чуть шире плеч.\nПодтянитесь подбородком к перекладине.\nОпуститесь подконтрольно.'**
  String get wrkExPullUpHint;

  /// No description provided for @wrkExDeadBug.
  ///
  /// In ru, this message translates to:
  /// **'Мёртвый жук'**
  String get wrkExDeadBug;

  /// No description provided for @wrkExDeadBugHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на спине, руки вверх, колени над тазом.\nОпустите противоположные руку и ногу.\nПоясница прижата к полу.'**
  String get wrkExDeadBugHint;

  /// No description provided for @wrkExBirdDog.
  ///
  /// In ru, this message translates to:
  /// **'Птица-собака'**
  String get wrkExBirdDog;

  /// No description provided for @wrkExBirdDogHint.
  ///
  /// In ru, this message translates to:
  /// **'Упор на ладони и колени.\nВытяните противоположные руку и ногу.\nЗадержитесь, смените сторону.'**
  String get wrkExBirdDogHint;

  /// No description provided for @wrkExPlank.
  ///
  /// In ru, this message translates to:
  /// **'Планка'**
  String get wrkExPlank;

  /// No description provided for @wrkExPlankHint.
  ///
  /// In ru, this message translates to:
  /// **'Упор на предплечья и носки.\nКорпус — прямая линия, живот напряжён.\nНе прогибайтесь в пояснице.'**
  String get wrkExPlankHint;

  /// No description provided for @wrkExCrunch.
  ///
  /// In ru, this message translates to:
  /// **'Скручивания'**
  String get wrkExCrunch;

  /// No description provided for @wrkExCrunchHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на спине, колени согнуты.\nПоднимите плечи к коленям.\nМедленно опуститесь.'**
  String get wrkExCrunchHint;

  /// No description provided for @wrkExSidePlank.
  ///
  /// In ru, this message translates to:
  /// **'Боковая планка'**
  String get wrkExSidePlank;

  /// No description provided for @wrkExSidePlankHint.
  ///
  /// In ru, this message translates to:
  /// **'Упор на предплечье, ноги вместе.\nТаз поднят, корпус прямой.\nПоловину времени — на каждую сторону.'**
  String get wrkExSidePlankHint;

  /// No description provided for @wrkExLegRaise.
  ///
  /// In ru, this message translates to:
  /// **'Подъём ног лёжа'**
  String get wrkExLegRaise;

  /// No description provided for @wrkExLegRaiseHint.
  ///
  /// In ru, this message translates to:
  /// **'Лёжа на спине, руки вдоль тела.\nПоднимите прямые ноги вверх.\nОпускайте медленно, поясница прижата.'**
  String get wrkExLegRaiseHint;

  /// No description provided for @wrkExStepTouch.
  ///
  /// In ru, this message translates to:
  /// **'Приставные шаги'**
  String get wrkExStepTouch;

  /// No description provided for @wrkExStepTouchHint.
  ///
  /// In ru, this message translates to:
  /// **'Шаг в сторону, приставьте ногу.\nВ другую сторону.\nРуки работают в такт.'**
  String get wrkExStepTouchHint;

  /// No description provided for @wrkExShadowBoxing.
  ///
  /// In ru, this message translates to:
  /// **'Бой с тенью'**
  String get wrkExShadowBoxing;

  /// No description provided for @wrkExShadowBoxingHint.
  ///
  /// In ru, this message translates to:
  /// **'Стойка, кулаки у подбородка.\nЛёгкие удары поочерёдно.\nДвигайтесь на носках без прыжков.'**
  String get wrkExShadowBoxingHint;

  /// No description provided for @wrkExHighKnees.
  ///
  /// In ru, this message translates to:
  /// **'Бег с высоким подниманием колен'**
  String get wrkExHighKnees;

  /// No description provided for @wrkExHighKneesHint.
  ///
  /// In ru, this message translates to:
  /// **'Бег на месте.\nКолени до уровня пояса.\nПриземление на носки.'**
  String get wrkExHighKneesHint;

  /// No description provided for @wrkExMountainClimber.
  ///
  /// In ru, this message translates to:
  /// **'Скалолаз'**
  String get wrkExMountainClimber;

  /// No description provided for @wrkExMountainClimberHint.
  ///
  /// In ru, this message translates to:
  /// **'Упор лёжа на прямых руках.\nПоочерёдно подтягивайте колени к груди.\nТаз не поднимайте.'**
  String get wrkExMountainClimberHint;

  /// No description provided for @wrkExBurpee.
  ///
  /// In ru, this message translates to:
  /// **'Бёрпи'**
  String get wrkExBurpee;

  /// No description provided for @wrkExBurpeeHint.
  ///
  /// In ru, this message translates to:
  /// **'Присед, руки на пол.\nОтскок в упор лёжа и обратно.\nВыпрыгните вверх.'**
  String get wrkExBurpeeHint;

  /// No description provided for @wrkExFullBodyStretch.
  ///
  /// In ru, this message translates to:
  /// **'Растяжка'**
  String get wrkExFullBodyStretch;

  /// No description provided for @wrkExFullBodyStretchHint.
  ///
  /// In ru, this message translates to:
  /// **'Потянитесь вверх, затем наклон к ногам.\nРастяните бёдра и грудь.\nДышите медленно, без рывков.'**
  String get wrkExFullBodyStretchHint;

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

  /// No description provided for @setWalks.
  ///
  /// In ru, this message translates to:
  /// **'Прогулки'**
  String get setWalks;

  /// No description provided for @setWalksHint.
  ///
  /// In ru, this message translates to:
  /// **'Круговой маршрут, отрезки, голос поверх музыки'**
  String get setWalksHint;

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
  /// **'В режиме дисциплины после отбоя развлекательные приложения блокируются: на Android — экраном «Система: отбой», на iPhone — через автоматизацию «Команд».'**
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

  /// No description provided for @synTitle.
  ///
  /// In ru, this message translates to:
  /// **'Аккаунт'**
  String get synTitle;

  /// No description provided for @synServer.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера'**
  String get synServer;

  /// No description provided for @synName.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get synName;

  /// No description provided for @synPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get synPassword;

  /// No description provided for @synNewPassword.
  ///
  /// In ru, this message translates to:
  /// **'Новый пароль'**
  String get synNewPassword;

  /// No description provided for @synTotpCode.
  ///
  /// In ru, this message translates to:
  /// **'Код из приложения-аутентификатора'**
  String get synTotpCode;

  /// No description provided for @synLogin.
  ///
  /// In ru, this message translates to:
  /// **'Войти'**
  String get synLogin;

  /// No description provided for @synRegister.
  ///
  /// In ru, this message translates to:
  /// **'Создать аккаунт'**
  String get synRegister;

  /// No description provided for @synForgot.
  ///
  /// In ru, this message translates to:
  /// **'Забыли пароль?'**
  String get synForgot;

  /// No description provided for @synReset.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить пароль'**
  String get synReset;

  /// No description provided for @synResetHint.
  ///
  /// In ru, this message translates to:
  /// **'Сброс возможен, только если включена двухфакторная защита (TOTP)'**
  String get synResetHint;

  /// No description provided for @synResetDone.
  ///
  /// In ru, this message translates to:
  /// **'Пароль изменён — войдите с новым'**
  String get synResetDone;

  /// No description provided for @synBackToLogin.
  ///
  /// In ru, this message translates to:
  /// **'Назад ко входу'**
  String get synBackToLogin;

  /// No description provided for @synSignedInAs.
  ///
  /// In ru, this message translates to:
  /// **'Вы вошли как {name}'**
  String synSignedInAs(String name);

  /// No description provided for @synLogout.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get synLogout;

  /// No description provided for @synSectionLogin.
  ///
  /// In ru, this message translates to:
  /// **'Вход'**
  String get synSectionLogin;

  /// No description provided for @synSectionTotp.
  ///
  /// In ru, this message translates to:
  /// **'Двухфакторная защита'**
  String get synSectionTotp;

  /// No description provided for @synTotpOn.
  ///
  /// In ru, this message translates to:
  /// **'Включена'**
  String get synTotpOn;

  /// No description provided for @synTotpOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключена — без неё пароль не восстановить'**
  String get synTotpOff;

  /// No description provided for @synTotpSetup.
  ///
  /// In ru, this message translates to:
  /// **'Включить TOTP'**
  String get synTotpSetup;

  /// No description provided for @synTotpScan.
  ///
  /// In ru, this message translates to:
  /// **'Отсканируйте QR в приложении-аутентификаторе или введите секрет вручную'**
  String get synTotpScan;

  /// No description provided for @synCopy.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get synCopy;

  /// No description provided for @synCopied.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get synCopied;

  /// No description provided for @synTotpConfirm.
  ///
  /// In ru, this message translates to:
  /// **'Подтвердить'**
  String get synTotpConfirm;

  /// No description provided for @synTotpEnabled.
  ///
  /// In ru, this message translates to:
  /// **'TOTP включена'**
  String get synTotpEnabled;

  /// No description provided for @synTotpNeeded.
  ///
  /// In ru, this message translates to:
  /// **'Введите код из приложения-аутентификатора'**
  String get synTotpNeeded;

  /// No description provided for @synSectionSync.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация'**
  String get synSectionSync;

  /// No description provided for @synSyncNow.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировать сейчас'**
  String get synSyncNow;

  /// No description provided for @synStatusOff.
  ///
  /// In ru, this message translates to:
  /// **'Выключена — войдите в аккаунт'**
  String get synStatusOff;

  /// No description provided for @synStatusIdle.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизировано'**
  String get synStatusIdle;

  /// No description provided for @synStatusSyncing.
  ///
  /// In ru, this message translates to:
  /// **'Синхронизация…'**
  String get synStatusSyncing;

  /// No description provided for @synStatusOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером'**
  String get synStatusOffline;

  /// No description provided for @synStatusError.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка синхронизации'**
  String get synStatusError;

  /// No description provided for @synLastSync.
  ///
  /// In ru, this message translates to:
  /// **'Последняя: {time}'**
  String synLastSync(String time);

  /// No description provided for @synPending.
  ///
  /// In ru, this message translates to:
  /// **'Не отправлено: {count}'**
  String synPending(int count);

  /// No description provided for @synErrNetwork.
  ///
  /// In ru, this message translates to:
  /// **'Сервер недоступен — проверьте адрес и интернет'**
  String get synErrNetwork;

  /// No description provided for @synErrCredentials.
  ///
  /// In ru, this message translates to:
  /// **'Неверное имя или пароль'**
  String get synErrCredentials;

  /// No description provided for @synErrTotp.
  ///
  /// In ru, this message translates to:
  /// **'Неверный код'**
  String get synErrTotp;

  /// No description provided for @synErrNameTaken.
  ///
  /// In ru, this message translates to:
  /// **'Имя уже занято'**
  String get synErrNameTaken;

  /// No description provided for @synErrWeakPassword.
  ///
  /// In ru, this message translates to:
  /// **'Пароль — не короче 8 символов'**
  String get synErrWeakPassword;

  /// No description provided for @synErrRateLimited.
  ///
  /// In ru, this message translates to:
  /// **'Слишком много попыток — подождите'**
  String get synErrRateLimited;

  /// No description provided for @synErrServer.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка сервера — попробуйте позже'**
  String get synErrServer;

  /// No description provided for @synErrInvalidName.
  ///
  /// In ru, this message translates to:
  /// **'Имя: 3–32 символа — буквы, цифры, _ - . без пробелов'**
  String get synErrInvalidName;

  /// No description provided for @synErrFill.
  ///
  /// In ru, this message translates to:
  /// **'Заполните адрес сервера, имя и пароль'**
  String get synErrFill;

  /// No description provided for @visEstimate.
  ///
  /// In ru, this message translates to:
  /// **'Оценка'**
  String get visEstimate;

  /// No description provided for @visNoticeLabel.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get visNoticeLabel;

  /// No description provided for @visSourceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото'**
  String get visSourceTitle;

  /// No description provided for @visSourceMessage.
  ///
  /// In ru, this message translates to:
  /// **'Сделать снимок или выбрать из галереи?'**
  String get visSourceMessage;

  /// No description provided for @visCamera.
  ///
  /// In ru, this message translates to:
  /// **'Камера'**
  String get visCamera;

  /// No description provided for @visGallery.
  ///
  /// In ru, this message translates to:
  /// **'Галерея'**
  String get visGallery;

  /// No description provided for @visAnalyzing.
  ///
  /// In ru, this message translates to:
  /// **'Анализирую фото…'**
  String get visAnalyzing;

  /// No description provided for @visErrOffline.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи с сервером. Попробуйте позже.'**
  String get visErrOffline;

  /// No description provided for @visErrNotSignedIn.
  ///
  /// In ru, this message translates to:
  /// **'Войдите в аккаунт («Ещё» → «Аккаунт»), чтобы анализировать фото.'**
  String get visErrNotSignedIn;

  /// No description provided for @visErrBudget.
  ///
  /// In ru, this message translates to:
  /// **'Лимит ИИ сейчас исчерпан. Попробуйте позже.'**
  String get visErrBudget;

  /// No description provided for @visErrUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'ИИ на сервере сейчас недоступен.'**
  String get visErrUnavailable;

  /// No description provided for @visErrServer.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось разобрать фото. Попробуйте ещё раз.'**
  String get visErrServer;

  /// No description provided for @visRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get visRetry;

  /// No description provided for @visRemove.
  ///
  /// In ru, this message translates to:
  /// **'Убрать'**
  String get visRemove;

  /// No description provided for @visBack.
  ///
  /// In ru, this message translates to:
  /// **'Назад'**
  String get visBack;

  /// No description provided for @visDone.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get visDone;

  /// No description provided for @visFoodTitle.
  ///
  /// In ru, this message translates to:
  /// **'Фото еды'**
  String get visFoodTitle;

  /// No description provided for @visFoodSeen.
  ///
  /// In ru, this message translates to:
  /// **'Что на фото'**
  String get visFoodSeen;

  /// No description provided for @visFoodNothing.
  ///
  /// In ru, this message translates to:
  /// **'Еда не распознана — добавьте позиции вручную.'**
  String get visFoodNothing;

  /// No description provided for @visFoodItemName.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get visFoodItemName;

  /// No description provided for @visFoodGrams.
  ///
  /// In ru, this message translates to:
  /// **'Граммы'**
  String get visFoodGrams;

  /// No description provided for @visFoodItemLine.
  ///
  /// In ru, this message translates to:
  /// **'{name} — {grams} г'**
  String visFoodItemLine(String name, String grams);

  /// No description provided for @visFoodAddItem.
  ///
  /// In ru, this message translates to:
  /// **'Добавить позицию'**
  String get visFoodAddItem;

  /// No description provided for @visFoodQuestion.
  ///
  /// In ru, this message translates to:
  /// **'Купил или приготовил?'**
  String get visFoodQuestion;

  /// No description provided for @visFoodBought.
  ///
  /// In ru, this message translates to:
  /// **'Купил'**
  String get visFoodBought;

  /// No description provided for @visFoodCooked.
  ///
  /// In ru, this message translates to:
  /// **'Приготовил'**
  String get visFoodCooked;

  /// No description provided for @visFoodWhere.
  ///
  /// In ru, this message translates to:
  /// **'Где купил?'**
  String get visFoodWhere;

  /// No description provided for @visFoodWhereHint.
  ///
  /// In ru, this message translates to:
  /// **'Кафе, магазин, сеть — можно оставить пустым'**
  String get visFoodWhereHint;

  /// No description provided for @visFoodFind.
  ///
  /// In ru, this message translates to:
  /// **'Найти КБЖУ'**
  String get visFoodFind;

  /// No description provided for @visFoodScanHint.
  ///
  /// In ru, this message translates to:
  /// **'Есть упаковка? Штрихкод точнее.'**
  String get visFoodScanHint;

  /// No description provided for @visFoodScan.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать штрихкод'**
  String get visFoodScan;

  /// No description provided for @visFoodPer100.
  ///
  /// In ru, this message translates to:
  /// **'На 100 г: {kcal} · {macros}'**
  String visFoodPer100(String kcal, String macros);

  /// No description provided for @visFoodSource.
  ///
  /// In ru, this message translates to:
  /// **'Источник: {title}'**
  String visFoodSource(String title);

  /// No description provided for @visFoodCached.
  ///
  /// In ru, this message translates to:
  /// **'из сохранённого'**
  String get visFoodCached;

  /// No description provided for @visFoodSaveDiary.
  ///
  /// In ru, this message translates to:
  /// **'Записать в дневник'**
  String get visFoodSaveDiary;

  /// No description provided for @visFoodRecipeName.
  ///
  /// In ru, this message translates to:
  /// **'Название блюда'**
  String get visFoodRecipeName;

  /// No description provided for @visFoodSaveRecipe.
  ///
  /// In ru, this message translates to:
  /// **'В мои рецепты и дневник'**
  String get visFoodSaveRecipe;

  /// No description provided for @visFoodTotal.
  ///
  /// In ru, this message translates to:
  /// **'Итого'**
  String get visFoodTotal;

  /// No description provided for @visBodyTitle.
  ///
  /// In ru, this message translates to:
  /// **'Анализ тела'**
  String get visBodyTitle;

  /// No description provided for @visSkinTitle.
  ///
  /// In ru, this message translates to:
  /// **'Анализ кожи'**
  String get visSkinTitle;

  /// No description provided for @visBodyFat.
  ///
  /// In ru, this message translates to:
  /// **'Доля жира'**
  String get visBodyFat;

  /// No description provided for @visFatRange.
  ///
  /// In ru, this message translates to:
  /// **'{min}–{max}%'**
  String visFatRange(String min, String max);

  /// No description provided for @visMuscle.
  ///
  /// In ru, this message translates to:
  /// **'Мышцы'**
  String get visMuscle;

  /// No description provided for @visLevelLow.
  ///
  /// In ru, this message translates to:
  /// **'ниже среднего'**
  String get visLevelLow;

  /// No description provided for @visLevelMedium.
  ///
  /// In ru, this message translates to:
  /// **'средне'**
  String get visLevelMedium;

  /// No description provided for @visLevelHigh.
  ///
  /// In ru, this message translates to:
  /// **'выше среднего'**
  String get visLevelHigh;

  /// No description provided for @visSwelling.
  ///
  /// In ru, this message translates to:
  /// **'Отёки'**
  String get visSwelling;

  /// No description provided for @visSwellingNone.
  ///
  /// In ru, this message translates to:
  /// **'не видны'**
  String get visSwellingNone;

  /// No description provided for @visSwellingMild.
  ///
  /// In ru, this message translates to:
  /// **'лёгкие'**
  String get visSwellingMild;

  /// No description provided for @visSwellingNoticeable.
  ///
  /// In ru, this message translates to:
  /// **'заметные'**
  String get visSwellingNoticeable;

  /// No description provided for @visPosture.
  ///
  /// In ru, this message translates to:
  /// **'Осанка'**
  String get visPosture;

  /// No description provided for @visComparison.
  ///
  /// In ru, this message translates to:
  /// **'Сравнение с прошлым'**
  String get visComparison;

  /// No description provided for @visPreviousAt.
  ///
  /// In ru, this message translates to:
  /// **'Прошлое фото: {date}'**
  String visPreviousAt(String date);

  /// No description provided for @visSkinType.
  ///
  /// In ru, this message translates to:
  /// **'Тип кожи'**
  String get visSkinType;

  /// No description provided for @visSkinDry.
  ///
  /// In ru, this message translates to:
  /// **'сухая'**
  String get visSkinDry;

  /// No description provided for @visSkinNormal.
  ///
  /// In ru, this message translates to:
  /// **'нормальная'**
  String get visSkinNormal;

  /// No description provided for @visSkinOily.
  ///
  /// In ru, this message translates to:
  /// **'жирная'**
  String get visSkinOily;

  /// No description provided for @visSkinCombination.
  ///
  /// In ru, this message translates to:
  /// **'комбинированная'**
  String get visSkinCombination;

  /// No description provided for @visSkinSensitive.
  ///
  /// In ru, this message translates to:
  /// **'чувствительная'**
  String get visSkinSensitive;

  /// No description provided for @visAcne.
  ///
  /// In ru, this message translates to:
  /// **'Высыпания'**
  String get visAcne;

  /// No description provided for @visAcneScore.
  ///
  /// In ru, this message translates to:
  /// **'{score} из 10'**
  String visAcneScore(String score);

  /// No description provided for @visDisclaimer.
  ///
  /// In ru, this message translates to:
  /// **'Оценка по фото: свет, ракурс и камера влияют на результат. Это не медицинское заключение.'**
  String get visDisclaimer;

  /// No description provided for @visReceiptTitle.
  ///
  /// In ru, this message translates to:
  /// **'Чек'**
  String get visReceiptTitle;

  /// No description provided for @visReceiptStore.
  ///
  /// In ru, this message translates to:
  /// **'Магазин'**
  String get visReceiptStore;

  /// No description provided for @visReceiptDate.
  ///
  /// In ru, this message translates to:
  /// **'Дата'**
  String get visReceiptDate;

  /// No description provided for @visReceiptFinanceLater.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте позиции — дальше чек можно записать в финансы.'**
  String get visReceiptFinanceLater;

  /// No description provided for @wlkTitle.
  ///
  /// In ru, this message translates to:
  /// **'Прогулка'**
  String get wlkTitle;

  /// No description provided for @wlkPlan.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут'**
  String get wlkPlan;

  /// No description provided for @wlkByDistance.
  ///
  /// In ru, this message translates to:
  /// **'Километры'**
  String get wlkByDistance;

  /// No description provided for @wlkByTime.
  ///
  /// In ru, this message translates to:
  /// **'Минуты'**
  String get wlkByTime;

  /// No description provided for @wlkKm.
  ///
  /// In ru, this message translates to:
  /// **'{value} км'**
  String wlkKm(String value);

  /// No description provided for @wlkMin.
  ///
  /// In ru, this message translates to:
  /// **'{n} мин'**
  String wlkMin(int n);

  /// No description provided for @wlkIntervals.
  ///
  /// In ru, this message translates to:
  /// **'Интервалы: шаг, ускорение, кардио'**
  String get wlkIntervals;

  /// No description provided for @wlkIntervalsHint.
  ///
  /// In ru, this message translates to:
  /// **'Выключено — весь круг спокойным шагом'**
  String get wlkIntervalsHint;

  /// No description provided for @wlkBuild.
  ///
  /// In ru, this message translates to:
  /// **'Построить круг'**
  String get wlkBuild;

  /// No description provided for @wlkBuilding.
  ///
  /// In ru, this message translates to:
  /// **'Строю маршрут…'**
  String get wlkBuilding;

  /// No description provided for @wlkNoLocation.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к геопозиции. Разрешите его в настройках.'**
  String get wlkNoLocation;

  /// No description provided for @wlkNoRoute.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось построить маршрут. Проверьте сеть и попробуйте ещё раз.'**
  String get wlkNoRoute;

  /// No description provided for @wlkRouteInfo.
  ///
  /// In ru, this message translates to:
  /// **'{km} км · ~{min} мин'**
  String wlkRouteInfo(String km, int min);

  /// No description provided for @wlkStart.
  ///
  /// In ru, this message translates to:
  /// **'Начать прогулку'**
  String get wlkStart;

  /// No description provided for @wlkStartFree.
  ///
  /// In ru, this message translates to:
  /// **'Без маршрута'**
  String get wlkStartFree;

  /// No description provided for @wlkPause.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get wlkPause;

  /// No description provided for @wlkResume.
  ///
  /// In ru, this message translates to:
  /// **'Продолжить'**
  String get wlkResume;

  /// No description provided for @wlkFinish.
  ///
  /// In ru, this message translates to:
  /// **'Завершить'**
  String get wlkFinish;

  /// No description provided for @wlkActive.
  ///
  /// In ru, this message translates to:
  /// **'Идёт прогулка'**
  String get wlkActive;

  /// No description provided for @wlkPaused.
  ///
  /// In ru, this message translates to:
  /// **'Пауза'**
  String get wlkPaused;

  /// No description provided for @wlkDistance.
  ///
  /// In ru, this message translates to:
  /// **'Дистанция'**
  String get wlkDistance;

  /// No description provided for @wlkTime.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get wlkTime;

  /// No description provided for @wlkPace.
  ///
  /// In ru, this message translates to:
  /// **'Темп'**
  String get wlkPace;

  /// No description provided for @wlkPaceValue.
  ///
  /// In ru, this message translates to:
  /// **'{value} /км'**
  String wlkPaceValue(String value);

  /// No description provided for @wlkNext.
  ///
  /// In ru, this message translates to:
  /// **'Дальше'**
  String get wlkNext;

  /// No description provided for @wlkInMeters.
  ///
  /// In ru, this message translates to:
  /// **'через {m} м'**
  String wlkInMeters(int m);

  /// No description provided for @wlkOffRoute.
  ///
  /// In ru, this message translates to:
  /// **'Вы сошли с маршрута'**
  String get wlkOffRoute;

  /// No description provided for @wlkModeWalk.
  ///
  /// In ru, this message translates to:
  /// **'Шаг'**
  String get wlkModeWalk;

  /// No description provided for @wlkModeBrisk.
  ///
  /// In ru, this message translates to:
  /// **'Ускорение'**
  String get wlkModeBrisk;

  /// No description provided for @wlkModeCardio.
  ///
  /// In ru, this message translates to:
  /// **'Кардио'**
  String get wlkModeCardio;

  /// No description provided for @wlkModeRest.
  ///
  /// In ru, this message translates to:
  /// **'Отдых'**
  String get wlkModeRest;

  /// No description provided for @wlkTurnStart.
  ///
  /// In ru, this message translates to:
  /// **'Старт'**
  String get wlkTurnStart;

  /// No description provided for @wlkTurnStraight.
  ///
  /// In ru, this message translates to:
  /// **'Прямо'**
  String get wlkTurnStraight;

  /// No description provided for @wlkTurnLeft.
  ///
  /// In ru, this message translates to:
  /// **'Налево'**
  String get wlkTurnLeft;

  /// No description provided for @wlkTurnRight.
  ///
  /// In ru, this message translates to:
  /// **'Направо'**
  String get wlkTurnRight;

  /// No description provided for @wlkTurnSlightLeft.
  ///
  /// In ru, this message translates to:
  /// **'Левее'**
  String get wlkTurnSlightLeft;

  /// No description provided for @wlkTurnSlightRight.
  ///
  /// In ru, this message translates to:
  /// **'Правее'**
  String get wlkTurnSlightRight;

  /// No description provided for @wlkTurnUTurn.
  ///
  /// In ru, this message translates to:
  /// **'Разворот'**
  String get wlkTurnUTurn;

  /// No description provided for @wlkTurnArrive.
  ///
  /// In ru, this message translates to:
  /// **'Финиш'**
  String get wlkTurnArrive;

  /// No description provided for @wlkSayTurnLeft.
  ///
  /// In ru, this message translates to:
  /// **'поверни налево'**
  String get wlkSayTurnLeft;

  /// No description provided for @wlkSayTurnRight.
  ///
  /// In ru, this message translates to:
  /// **'поверни направо'**
  String get wlkSayTurnRight;

  /// No description provided for @wlkSayTurnSlightLeft.
  ///
  /// In ru, this message translates to:
  /// **'держись левее'**
  String get wlkSayTurnSlightLeft;

  /// No description provided for @wlkSayTurnSlightRight.
  ///
  /// In ru, this message translates to:
  /// **'держись правее'**
  String get wlkSayTurnSlightRight;

  /// No description provided for @wlkSayTurnUTurn.
  ///
  /// In ru, this message translates to:
  /// **'развернись'**
  String get wlkSayTurnUTurn;

  /// No description provided for @wlkSayModeWalk.
  ///
  /// In ru, this message translates to:
  /// **'иди спокойным шагом'**
  String get wlkSayModeWalk;

  /// No description provided for @wlkSayModeBrisk.
  ///
  /// In ru, this message translates to:
  /// **'ускорься'**
  String get wlkSayModeBrisk;

  /// No description provided for @wlkSayModeCardio.
  ///
  /// In ru, this message translates to:
  /// **'кардио-интервал, максимальный темп'**
  String get wlkSayModeCardio;

  /// No description provided for @wlkSayModeRest.
  ///
  /// In ru, this message translates to:
  /// **'отдых, сбавь темп'**
  String get wlkSayModeRest;

  /// No description provided for @wlkSayAnd.
  ///
  /// In ru, this message translates to:
  /// **'{first} и {second}'**
  String wlkSayAnd(String first, String second);

  /// No description provided for @wlkSayStart.
  ///
  /// In ru, this message translates to:
  /// **'Начинаем прогулку'**
  String get wlkSayStart;

  /// No description provided for @wlkSayArrive.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут пройден. Отличная работа'**
  String get wlkSayArrive;

  /// No description provided for @wlkSayOffRoute.
  ///
  /// In ru, this message translates to:
  /// **'Ты сошёл с маршрута, вернись на линию'**
  String get wlkSayOffRoute;

  /// No description provided for @wlkSummary.
  ///
  /// In ru, this message translates to:
  /// **'Итог прогулки'**
  String get wlkSummary;

  /// No description provided for @wlkKcal.
  ///
  /// In ru, this message translates to:
  /// **'{n} ккал'**
  String wlkKcal(int n);

  /// No description provided for @wlkHistory.
  ///
  /// In ru, this message translates to:
  /// **'История'**
  String get wlkHistory;

  /// No description provided for @wlkHistoryEmpty.
  ///
  /// In ru, this message translates to:
  /// **'Прогулок пока нет.'**
  String get wlkHistoryEmpty;

  /// No description provided for @wlkShop.
  ///
  /// In ru, this message translates to:
  /// **'Магазин рядом'**
  String get wlkShop;

  /// No description provided for @wlkGrocery.
  ///
  /// In ru, this message translates to:
  /// **'Продукты'**
  String get wlkGrocery;

  /// No description provided for @wlkWater.
  ///
  /// In ru, this message translates to:
  /// **'Вода'**
  String get wlkWater;

  /// No description provided for @wlkSearching.
  ///
  /// In ru, this message translates to:
  /// **'Ищу рядом…'**
  String get wlkSearching;

  /// No description provided for @wlkNothingNearby.
  ///
  /// In ru, this message translates to:
  /// **'Рядом ничего не нашлось.'**
  String get wlkNothingNearby;

  /// No description provided for @wlkUnnamed.
  ///
  /// In ru, this message translates to:
  /// **'Без названия'**
  String get wlkUnnamed;

  /// No description provided for @wlkToPlace.
  ///
  /// In ru, this message translates to:
  /// **'До места: {name}'**
  String wlkToPlace(String name);

  /// No description provided for @wlkTrackerUnavailable.
  ///
  /// In ru, this message translates to:
  /// **'Трекинг прогулки недоступен.'**
  String get wlkTrackerUnavailable;

  /// No description provided for @wlkMapAttribution.
  ///
  /// In ru, this message translates to:
  /// **'© участники OpenStreetMap'**
  String get wlkMapAttribution;

  /// No description provided for @polShowPassword.
  ///
  /// In ru, this message translates to:
  /// **'Показать пароль'**
  String get polShowPassword;

  /// No description provided for @polHidePassword.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть пароль'**
  String get polHidePassword;
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
