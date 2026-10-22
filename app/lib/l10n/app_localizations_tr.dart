// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Sistem';

  @override
  String get navStatus => 'Durum';

  @override
  String get navQuests => 'Görevler';

  @override
  String get navNutrition => 'Beslenme';

  @override
  String get navShop => 'Mağaza';

  @override
  String get navMore => 'Diğer';

  @override
  String get sectionEmptyTitle => 'Bölüm geliştiriliyor';

  @override
  String get sectionEmptyBody => 'Sistem bu bölümü sonraki aşamalarda açacak.';

  @override
  String certExpiresInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Sertifikanın süresi $days gün içinde doluyor',
      zero: 'Sertifikanın süresi bugün doluyor',
    );
    return '$_temp0';
  }

  @override
  String get certExpired =>
      'Sertifikanın süresi doldu — uygulamayı yeniden yükleyin';

  @override
  String get certReinstallHint =>
      'Uygulamayı Sideloadly ile yeniden yükleyin, veriler senkronizasyondan sonra korunur.';

  @override
  String get homeSystemOnline => 'Sistem · çevrimiçi';

  @override
  String homeNotificationsLabel(int count) {
    return 'Bildirimler: $count';
  }

  @override
  String get homeSettingsLabel => 'Ayarlar';

  @override
  String homeWeekDay(int week, int day) {
    return 'Hafta $week · gün $day';
  }

  @override
  String get homeStatusTitle => 'Durum';

  @override
  String get homeLevelShort => 'LV';

  @override
  String homeLevelSemantics(int level) {
    return 'Seviye $level';
  }

  @override
  String homeRank(String rank) {
    return 'Rütbe $rank';
  }

  @override
  String homeStreakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count günlük seri',
    );
    return '$_temp0';
  }

  @override
  String homeXpLabel(int level) {
    return 'Deneyim · sonraki: LV $level';
  }

  @override
  String homeXpValue(String current, String total) {
    return '$current / $total XP';
  }

  @override
  String get homeEnergy => 'Enerji';

  @override
  String get homeWater => 'Su';

  @override
  String get homeCalories => 'Kalori';

  @override
  String homePercentValue(String value) {
    return '%$value';
  }

  @override
  String homeLitersProgress(String current, String total) {
    return '$current / $total L';
  }

  @override
  String homeKcalProgress(String current, String total) {
    return '$current / $total kcal';
  }

  @override
  String homeKcalValue(String value) {
    return '$value kcal';
  }

  @override
  String get homeStatStrength => 'Güç';

  @override
  String get homeStatEndurance => 'Dayanıklılık';

  @override
  String get homeStatDiscipline => 'Disiplin';

  @override
  String get homeStatIntellect => 'Zekâ';

  @override
  String get homeStatHealth => 'Sağlık';

  @override
  String get homeStatLooks => 'Görünüm';

  @override
  String homeStatDeltaSemantics(String stat, String value, String delta) {
    return '$stat: $value, bugün $delta';
  }

  @override
  String get homePointsLabel => 'Puan';

  @override
  String homePointsValue(String points) {
    return '$points ◆';
  }

  @override
  String homeStatPointsButton(int count) {
    return 'Özellik puanı: $count';
  }

  @override
  String get homeEffectsTitle => 'Etkiler';

  @override
  String get homeEffectsEmpty => 'Aktif etki yok';

  @override
  String get homeNextQuestTitle => 'Sıradaki görev';

  @override
  String homeQuestDeadline(String time) {
    return 'son: $time';
  }

  @override
  String homeTimeLeftSemantics(String time) {
    return 'Kalan süre: $time';
  }

  @override
  String get homeRewardLabel => 'Ödül';

  @override
  String get homePenaltyLabel => 'Ceza';

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
  String get homeActionDone => 'Tamamlandı';

  @override
  String get homeActionSnooze => '+10 dk';

  @override
  String get homeActionNoWater => 'Su yok';

  @override
  String get homeActionRefuse => 'Reddet';

  @override
  String get homeRefuseHint => 'Reddetmek için 5 sn basılı tutun';

  @override
  String get homeNoticeLabel => 'Bildirim';

  @override
  String get homeWarningLabel => 'Uyarı';

  @override
  String get homeQuestCompletedTitle => 'Görev tamamlandı';

  @override
  String homeQuestCompletedMessage(String points, String xp) {
    return 'Ödül: +$points ◆, +$xp XP.';
  }

  @override
  String get homeQuestFailedTitle => 'Görev başarısız';

  @override
  String homeQuestRefusedMessage(String quest, String points) {
    return '“$quest” görevi reddedildi. Ceza: −$points ◆.';
  }

  @override
  String get homeNoWaterMessage =>
      'Görev ertelendi: su yakında olduğunda Sistem hatırlatacak.';

  @override
  String get homeOk => 'Anladım';

  @override
  String get homeDayTitle => 'Gün';

  @override
  String get homeSegSleep => 'Uyku';

  @override
  String get homeSegClasses => 'Dersler';

  @override
  String get homeSegWorkout => 'Antrenman';

  @override
  String get homeSegFree => 'Serbest';

  @override
  String get homeSegCommute => 'Yol';

  @override
  String homeNow(String time) {
    return 'Şimdi $time';
  }

  @override
  String homeLeaveHome(String time) {
    return 'Evden çıkış: $time';
  }

  @override
  String homeSegmentSemantics(String type, String start, String end) {
    return '$type: $start–$end';
  }

  @override
  String get homeDailyTitle => 'Günlük görevler';

  @override
  String homeDailyCounter(int done, int total) {
    return '$done / $total';
  }

  @override
  String homeDailyPenaltyTotal(String points) {
    return 'Başarısızlık cezası: −$points ◆';
  }

  @override
  String homeMinutesProgress(String current, String total) {
    return '$current / $total dk';
  }

  @override
  String homeStepsProgress(String current, String total) {
    return '$current / $total adım';
  }

  @override
  String get homeBossTitle => 'Haftanın bossu';

  @override
  String homeBossTimeLeft(String days, String time) {
    return '$days g $time';
  }

  @override
  String homeBossProgress(int current, int total) {
    return '$current / $total';
  }

  @override
  String homeBossReward(String points, String title) {
    return 'Ödül: +$points ◆ ve “$title” unvanı';
  }

  @override
  String get homeEaten => 'Alınan';

  @override
  String get homeBurned => 'Yakılan';

  @override
  String get homeDeficit => 'Kalori açığı';

  @override
  String get homeFinanceTitle => 'Finans';

  @override
  String get homeFoodSpent => 'Yemek harcaması';

  @override
  String get homeLimit => 'Limit';

  @override
  String get homeUntilStipend => 'Burs gününe';

  @override
  String homeDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
    );
    return '$_temp0';
  }

  @override
  String get homeAssistantTitle => 'Asistan';

  @override
  String get homeAssistantAvatar => 'Asistan karakteri';

  @override
  String get homeAssistantSpeaking => 'Asistan konuşuyor';

  @override
  String get homeMicLabel => 'Sesli giriş';

  @override
  String get homeReplyHint => 'Yanıtla…';

  @override
  String get homeSendLabel => 'Gönder';

  @override
  String get homeDemoPlayerName => 'Murat';

  @override
  String get homeDemoPlayerTitle => 'Uyanmış';

  @override
  String get homeDemoEffectVigor => 'Zindelik: +%5 deneyim';

  @override
  String get homeDemoEffectDehydration => 'Susuzluk: −%10 dayanıklılık';

  @override
  String get homeDemoNextQuest => '500 ml su iç';

  @override
  String get homeDemoQuestWakeUp => '07:00\'den önce kalk';

  @override
  String get homeDemoQuestBreakfast => 'Proteinli kahvaltı';

  @override
  String get homeDemoQuestWater => '2,5 L su iç';

  @override
  String get homeDemoQuestWorkout => 'Evde antrenman';

  @override
  String get homeDemoSubWarmup => '5 dk ısınma';

  @override
  String get homeDemoSubPushups => 'Şınav 3×15';

  @override
  String get homeDemoSubPlank => 'Plank 3×45 sn';

  @override
  String get homeDemoQuestReading => '20 dakika kitap oku';

  @override
  String get homeDemoQuestSteps => '8.000 adım yürü';

  @override
  String get homeDemoQuestSleep => '23:00\'ten önce yat';

  @override
  String get homeDemoBossGoal => 'Bu hafta 5 antrenman tamamla';

  @override
  String get homeDemoBossRewardTitle => 'Yılmaz';

  @override
  String get homeDemoAssistantLine =>
      'Su hedefinin %48\'i tamam. 11:30\'a kadar bir bardak iç, “Zindelik” bir saat daha sürsün.';

  @override
  String get hqStatStrengthShort => 'GÜÇ';

  @override
  String get hqStatEnduranceShort => 'DAY';

  @override
  String get hqStatDisciplineShort => 'DİS';

  @override
  String get hqStatIntellectShort => 'ZEK';

  @override
  String get hqStatHealthShort => 'SAĞ';

  @override
  String get hqStatLooksShort => 'GÖR';

  @override
  String get hqCaloriesTodayTitle => 'Günlük kalori';

  @override
  String get hqNutritionDiaryTitle => 'Beslenme günlüğü';

  @override
  String get hqNutritionDiarySoon =>
      'Beslenme günlüğünü, yemek fotoğraflarını ve makro takibini Sistem bir sonraki aşamada açacak.';

  @override
  String get hqFinanceFoodTitle => 'Yemek bütçesi';

  @override
  String get bdyEnergy => 'Enerji';

  @override
  String get bdyHistory => 'Geçmiş';

  @override
  String get bdyCharts => 'Grafikler';

  @override
  String get bdySleepTitle => 'Uyku';

  @override
  String get bdySleepLog => 'Uykuyu kaydet';

  @override
  String get bdySleepNotLogged => 'Dün geceki uyku kaydedilmedi.';

  @override
  String get bdySleepLastNight => 'Dün gece';

  @override
  String get bdySleepDuration => 'Süre';

  @override
  String get bdySleepTarget => 'Plan hedefi';

  @override
  String get bdySleepAverage => 'Ortalama';

  @override
  String get bdySleepVsTarget => 'Hedefe göre';

  @override
  String get bdySleepOnTarget => 'Hedefe ulaşan geceler';

  @override
  String get bdySleepEmpty => 'Henüz uyku kaydı yok.';

  @override
  String get bdySleepChartLabel =>
      'Günlere göre uyku grafiği, çizgi plan hedefidir';

  @override
  String bdySleepHistory(int days) {
    return 'Son $days gün uyku';
  }

  @override
  String get bdySleepWakeDay => 'Sabah (kalkış günü)';

  @override
  String get bdySleepBed => 'Yatış';

  @override
  String get bdySleepWake => 'Kalkış';

  @override
  String get bdySleepQuality => 'Uyku kalitesi';

  @override
  String get bdySleepQualityHint => '1 — kötü, 5 — mükemmel';

  @override
  String bdySleepQualityShort(int quality) {
    return 'kal. $quality/5';
  }

  @override
  String get bdyMeasureTitle => 'Ölçüler';

  @override
  String get bdyMeasureAdd => 'Ölçü ekle';

  @override
  String get bdyMeasureHint =>
      'Ölçtüklerinizi doldurun. Çevre ölçüleri — mezura ile, sabah, yemekten önce.';

  @override
  String get bdyMeasureEmpty => 'Henüz ölçü yok.';

  @override
  String get bdyMeasureNeedTwo => 'Grafik için en az iki ölçü gerekir.';

  @override
  String get bdyMeasureChangeNote => 'Parantez içinde — 30 günlük değişim';

  @override
  String bdyMeasureChartLabel(String name) {
    return 'Grafik: $name';
  }

  @override
  String get bdyMeasureWeight => 'Kilo';

  @override
  String get bdyMeasureWaist => 'Bel';

  @override
  String get bdyMeasureHips => 'Kalça';

  @override
  String get bdyMeasureChest => 'Göğüs';

  @override
  String get bdyMeasureNeck => 'Boyun';

  @override
  String get bdyMeasureArm => 'Kol';

  @override
  String get bdyMeasureBodyFat => 'Yağ %';

  @override
  String get bdyUnitKg => 'kg';

  @override
  String get bdyUnitCm => 'cm';

  @override
  String get bdyPeriodAll => 'Tümü';

  @override
  String bdyPeriodDays(int days) {
    return '$days gün';
  }

  @override
  String get bdyPhotoTitle => 'Fotoğraf günlüğü';

  @override
  String get bdyPhotoKindBody => 'Vücut';

  @override
  String get bdyPhotoKindSkin => 'Cilt';

  @override
  String get bdyPhotoLast => 'Son fotoğraf';

  @override
  String get bdyPhotoAdd => 'Yeni fotoğraf';

  @override
  String get bdyPhotoPose => 'Açı';

  @override
  String get bdyPhotoCamera => 'Çek';

  @override
  String get bdyPhotoGallery => 'Galeriden';

  @override
  String get bdyPhotoEmpty => 'Henüz fotoğraf yok.';

  @override
  String get bdyPhotoCompare => 'Karşılaştır';

  @override
  String get bdyPhotoCompareHint =>
      '“Önce” ve “sonra”yı karşılaştırmak için iki fotoğraf seçin.';

  @override
  String get bdyPhotoCompareNeedTwo =>
      'Karşılaştırma için en az iki fotoğraf gerekir.';

  @override
  String get bdyPoseOther => 'Diğer';

  @override
  String get bdyCompareSlider => 'Kaydırıcı';

  @override
  String get bdyCompareSideBySide => 'Yan yana';

  @override
  String get bdyCompareBefore => 'Önce';

  @override
  String get bdyCompareAfter => 'Sonra';

  @override
  String get bdyCompareNote =>
      'Aynı ışıkta ve aynı mesafeden çekin — karşılaştırma daha doğru olur.';

  @override
  String get bdyCareTitle => 'Cilt bakımı';

  @override
  String get bdyCareOpen => 'Kontrol listesi';

  @override
  String get bdyCareMorning => 'Sabah';

  @override
  String get bdyCareEvening => 'Akşam';

  @override
  String get bdyCareTemplateNote =>
      'Ankete göre temel şablon. Cildinize uygun ürün seçimi daha sonra eklenecek.';

  @override
  String get bdyCareSensitiveNote =>
      'Ürünlere tepki olmuş: yeni bir ürünü önce cildin küçük bir bölgesinde deneyin.';

  @override
  String get bdyCareCompleteNote => 'Rutin tamamlandı.';

  @override
  String bdyCareRoutineDone(String routine) {
    return '$routine: bakım tamamlandı';
  }

  @override
  String get bdyCareCleanse => 'Yumuşak bir temizleyiciyle yüzünü yıka';

  @override
  String get bdyCareCleanseGentle => 'kurutmadan';

  @override
  String get bdyCareColdRinse => 'Yüzünü serin suyla yıka';

  @override
  String get bdyCareMoisturize => 'Nemlendirici krem';

  @override
  String get bdyCareMoisturizeLight => 'hafif doku';

  @override
  String get bdyCareMoisturizeRich => 'daha yoğun, besleyici';

  @override
  String get bdyCareSunscreen => 'Güneş kremi';

  @override
  String get bdyCareRemoveSunscreen => 'SPF\'yi ve kiri temizle';

  @override
  String get bdyCareAcne => 'Sivilce karşıtı ürün (varsa)';

  @override
  String get bdyCareExfoliate => 'Nazik peeling';

  @override
  String get bdyCareHandsOff => 'Dokunma ve sıkma';

  @override
  String get bdySkinType => 'Cilt tipi (ankete göre)';

  @override
  String get bdySkinNormal => 'Normal';

  @override
  String get bdySkinOily => 'Yağlı';

  @override
  String get bdySkinCombination => 'Karma';

  @override
  String get bdySkinDry => 'Kuru';

  @override
  String get bdySkinUnknown => 'Belirlenmedi';

  @override
  String get bdySwellTitle => 'Ödem';

  @override
  String get bdySwellOpen => 'Ayrıntılar';

  @override
  String get bdySwellMorningPhoto => 'Sabah yüz fotoğrafı';

  @override
  String get bdySwellPhotoHint =>
      'Kalkar kalkmaz önden bir fotoğraf çekin — fotoğraf akışında eğilim görünür.';

  @override
  String get bdySwellTakenToday => 'Bugünün sabah fotoğrafı var.';

  @override
  String get bdySwellTipShort =>
      'Odak: akşam daha az tuz, gün içinde su, plana göre uyku.';

  @override
  String get bdySwellTipsTitle => 'İpuçları';

  @override
  String get bdySwellTipSalt =>
      'Tuzlu yiyecekleri ve fast food\'u gece geç saatte yememek daha iyi.';

  @override
  String get bdySwellTipWater =>
      'Suyu gün boyunca eşit için, hepsini yatmadan önce değil.';

  @override
  String get bdySwellTipSleep =>
      'Yeterince uyuyun ve aynı saatte yatın — uykusuzluk sabah yüzde belli olur.';

  @override
  String get bdySwellNote =>
      'Ödem şiddetliyse, aniden ortaya çıktıysa veya geçmiyorsa doktora görünün.';

  @override
  String get bdySwellTrend => 'Sabahlara göre eğilim';

  @override
  String get bdySwellEmpty => 'Henüz sabah fotoğrafı yok.';

  @override
  String get bdySwellCompareFirst => 'İlk ve sonuncuyu karşılaştır';

  @override
  String get blkTitle => 'Uygulama engelleme';

  @override
  String get blkOverlayTitle => 'Sistem: yatma vakti';

  @override
  String blkOverlayBody(String time) {
    return 'Uyku zamanı. Eğlence $time saatine kadar kapalı. Telefonu bırakın — yarın berrak bir zihin gerek.';
  }

  @override
  String get blkOverlayButton => 'Kapat';

  @override
  String get blkNotifTitle => 'Sistem: yatma vakti';

  @override
  String blkNotifBody(String time) {
    return 'Dikkat dağıtan uygulamalar $time saatine kadar kapalı';
  }

  @override
  String blkIntro(String diamonds) {
    return 'Disiplin modunda yatma saatinden sonra dikkat dağıtan uygulamalar “Sistem: yatma vakti” ekranıyla kapatılır. Denemeler kaydedilir; gecenin üçüncüsünden itibaren ceza $diamonds ◆.';
  }

  @override
  String get blkStatusTitle => 'Durum';

  @override
  String blkDisciplineOn(String from, String until) {
    return 'Disiplin modu açık. Engelleme: $from–$until.';
  }

  @override
  String blkDisciplineOff(String from, String until) {
    return 'Disiplin modu kapalı — engelleme çalışmıyor. Mod aralığı: $from–$until.';
  }

  @override
  String get blkActiveNow => 'Engelleme şu an etkin';

  @override
  String get blkReady => 'Çalışmaya hazır';

  @override
  String get blkNotReady => 'İzinler gerekli';

  @override
  String get blkNoApps => 'Hiç uygulama seçilmedi';

  @override
  String get blkPermsTitle => 'İzinler';

  @override
  String get blkUsageAccess => 'Kullanım erişimi';

  @override
  String get blkUsageAccessHint =>
      'Şu an hangi uygulamanın açık olduğunu görmek için.';

  @override
  String get blkOverlayPerm => 'Diğer uygulamaların üzerinde göster';

  @override
  String get blkOverlayPermHint =>
      '“Sistem: yatma vakti” ekranını göstermek için.';

  @override
  String get blkGranted => 'Verildi';

  @override
  String get blkNotGranted => 'Verilmedi';

  @override
  String get blkOpenSettings => 'Ayarları aç';

  @override
  String get blkNotifHint =>
      'Engelleme sırasında bildirim panelinde Sistem bildirimi durur — böylece Android denetimi durdurmaz.';

  @override
  String get blkAppsTitle => 'Uygulamalar';

  @override
  String get blkAppsHint =>
      'İşaretlenenler yatma saatinden sonra kapatılır. Bilinen eğlence uygulamaları varsayılan olarak işaretli.';

  @override
  String blkAppsSelected(int count) {
    return 'Seçili: $count';
  }

  @override
  String get blkAppsLoading => 'Uygulama listesi yükleniyor…';

  @override
  String get blkAppsEmpty => 'Uygulama bulunamadı';

  @override
  String get blkSearch => 'Ara';

  @override
  String get blkShowAll => 'Tümünü göster';

  @override
  String get blkShowSelected => 'Yalnızca seçilenler';

  @override
  String get blkUnsupported => 'Bu cihazda engelleme kullanılamıyor.';

  @override
  String blkAttemptsTonight(int count) {
    return 'Bu gece deneme sayısı: $count';
  }

  @override
  String get blkIosIntro =>
      'iPhone\'da doğrudan engelleme yok. “Kestirmeler” uygulamasında kişisel otomasyonlar kurun: uygulama açılınca hemen Sistem açılır. Yatma saatinden sonra “Sistem: yatma vakti” gösterir ve denemeyi kaydeder, gündüz “Şimdi serbest” der.';

  @override
  String get blkIosPickTitle => '1. Hangi uygulamalar';

  @override
  String get blkIosGames => 'Oyunlar (herhangi bir oyun)';

  @override
  String get blkIosStepsTitle => '2. Her uygulama için otomasyon';

  @override
  String get blkIosStep1 =>
      '“Kestirmeler” uygulamasını açın → “Otomasyon” sekmesi → “+” (“Yeni Otomasyon”).';

  @override
  String get blkIosStep2 =>
      '“Uygulama”yı seçin, “Seç”e dokunun ve uygulamayı işaretleyin (birkaçını birden seçebilirsiniz — o zaman tek bağlantı, örneğin oyunlar için).';

  @override
  String get blkIosStep3 =>
      '“Açıldığında”yı işaretleyin, “Hemen Çalıştır”ı seçin ve “Sonraki”ye dokunun.';

  @override
  String get blkIosStep4 =>
      '“Yeni Boş Otomasyon” → “Eylem Ekle” → “URL\'yi Aç” eylemini bulun.';

  @override
  String get blkIosStep5 =>
      'Bu uygulamanın bağlantısını yapıştırın (aşağıdaki “Kopyala” düğmesi) ve “Bitti”ye dokunun.';

  @override
  String get blkIosStep6 =>
      'Diğer uygulamalar için tekrarlayın. Kontrol edin: uygulamayı açın — Sistem açılmalı.';

  @override
  String get blkIosLinksTitle => '3. Bağlantılar';

  @override
  String get blkIosLinksEmpty => 'Önce yukarıdan uygulamaları seçin.';

  @override
  String get blkCopy => 'Kopyala';

  @override
  String blkCopied(String app) {
    return 'Bağlantı kopyalandı: $app';
  }

  @override
  String get blkIosFocusTitle => 'İpucu: “Uyku” odak modu';

  @override
  String get blkIosFocusBody =>
      'Ayarlar → Odak → “Uyku”: yatma saatinden kalkışa kadar zamanlayın, dikkat dağıtan uygulamaların bildirimlerini gizleyin ve ana ekranda yalnızca gerekenleri bırakın.';

  @override
  String get blkIosAlwaysNote =>
      'Otomasyon her zaman çalışır — kararı Sistem verir: engelleme yalnızca disiplin modunda yatma saatinden sonra geçerli.';

  @override
  String get blkBlockedLabel => 'Sistem';

  @override
  String get blkBlockedTitle => 'Sistem: yatma vakti';

  @override
  String blkBlockedMessageApp(String app, String time) {
    return '$app $time saatine kadar kapalı. Uyku da bir antrenmandır. Telefonu bırakın.';
  }

  @override
  String blkBlockedMessage(String time) {
    return 'Eğlence $time saatine kadar kapalı. Uyku da bir antrenmandır. Telefonu bırakın.';
  }

  @override
  String blkPenaltyApplied(String diamonds) {
    return 'Tekrarlanan deneme: −$diamonds ◆';
  }

  @override
  String blkPenaltyWarning(String diamonds) {
    return 'Gecenin üçüncü denemesinden itibaren her biri için ceza $diamonds ◆.';
  }

  @override
  String get blkClose => 'Kapat';

  @override
  String get blkAllowedTitle => 'Şimdi serbest';

  @override
  String get blkAllowedMessage =>
      'Engelleme şu an geçerli değil. Dinlenin — ama ölçülü.';

  @override
  String get blkChecking => 'Kontrol ediliyor…';

  @override
  String get blkReasonBlockedAttempt =>
      'Yatma saatinden sonra uygulama açma denemesi';

  @override
  String chrSemanticsChat(String name) {
    return '$name: sohbeti açmak için dokunun; menü için basılı tutun; kaldırmak için aşağı kaydırın';
  }

  @override
  String get chrMenuChat => 'Sohbet';

  @override
  String get chrMenuPocket => 'Cebe koy';

  @override
  String get chrPlayerFallback => 'Oyuncu';

  @override
  String chrDoneSoft1(String name, String quest) {
    return '$name, “$quest” tamam! Seninle gurur duyuyorum.';
  }

  @override
  String chrDoneSoft2(String name, String quest) {
    return 'Gördün mü, oldu! “$quest” tamamlandı, $name.';
  }

  @override
  String chrDoneNormal1(String name, String quest) {
    return '“$quest” tamamlandı. Harika, $name!';
  }

  @override
  String chrDoneNormal2(String name, String quest) {
    return 'İşte bu! “$quest” kapandı. Devam, $name.';
  }

  @override
  String chrDoneStrict1(String name, String quest) {
    return '“$quest” sayıldı. Böyle devam, $name.';
  }

  @override
  String chrDoneStrict2(String name, String quest) {
    return 'Kabul: “$quest”. Sıradaki görev bekliyor.';
  }

  @override
  String chrDoneHarsh1(String name, String quest) {
    return '“$quest” bitti. Nihayet. Tempoyu düşürme, $name.';
  }

  @override
  String chrDoneHarsh2(String name, String quest) {
    return 'Sayıldı: “$quest”. Bu asgari, $name. Devam.';
  }

  @override
  String chrFailSoft1(String name, String quest) {
    return '“$quest” olmadı — sorun değil, $name. Yarın olur.';
  }

  @override
  String chrFailSoft2(String name, String quest) {
    return 'Yazık, “$quest” kaçtı. Dinlen, sonra tekrar deneriz.';
  }

  @override
  String chrFailNormal1(String name, String quest) {
    return '“$quest” başarısız. Üzücü, $name. Toparlan.';
  }

  @override
  String chrFailNormal2(String name, String quest) {
    return 'Eh, “$quest” sayılmadı. Bir dahakine kaçırma.';
  }

  @override
  String chrFailStrict1(String name, String quest) {
    return '“$quest” başarısız, $name. Böyle olmaz. Düzelt.';
  }

  @override
  String chrFailStrict2(String name, String quest) {
    return 'Başarısız: “$quest”. Söz verdiysen tut.';
  }

  @override
  String chrFailHarsh1(String name, String quest) {
    return '“$quest” — başarısız! $name, disiplin nerede? Bahane yok!';
  }

  @override
  String chrFailHarsh2(String name, String quest) {
    return '“$quest” yine mi yapılmadı?! Tembelliğe yer yok. Yarın taviz yok.';
  }

  @override
  String get chrPenaltySoft => 'Ceza… Önemli değil, telafi ederiz.';

  @override
  String get chrPenaltyNormal => 'Ceza. Tekrarlanmasın.';

  @override
  String get chrPenaltyStrict => 'Ceza hak edildi. Ders çıkarıldı mı?';

  @override
  String get chrPenaltyHarsh => 'Ceza! Tembelliğin bedeli. Çalış!';

  @override
  String chrLevelUp(int level, String name) {
    return 'Seviye $level! Böyle devam, $name!';
  }

  @override
  String chrIdleSoft1(String name) {
    return '$name, buradayım. Küçük bir şey yapalım mı?';
  }

  @override
  String chrIdleSoft2(String name) {
    return 'Uzun zamandır görüşmedik, $name. Hazır olunca görevlere bak.';
  }

  @override
  String chrIdleNormal1(String name) {
    return '$name, orada mısın? Görevler kendi kendine yapılmaz.';
  }

  @override
  String chrIdleNormal2(String name) {
    return 'Hey, $name! Bugün için ne kaldı, bir bak.';
  }

  @override
  String chrIdleStrict1(String name) {
    return '$name, mola uzadı. İşe dön.';
  }

  @override
  String chrIdleStrict2(String name) {
    return 'Zaman geçiyor, $name. Görev listesi burada.';
  }

  @override
  String chrIdleHarsh1(String name) {
    return '$name! Daha ne kadar boş duracaksın? Kalk ve yap!';
  }

  @override
  String chrIdleHarsh2(String name) {
    return 'Oyalanmayı bırak, $name. Görevler bekliyor — hemen!';
  }

  @override
  String get chrIntro =>
      'Bir yol arkadaşı seçin. Fotoğraf çekimlerinde sesiyle size rehberlik edecek, sonra ekranın altında yaşayacak: hatırlatacak, övecek ve azarlayacak — seçtiğiniz modda.';

  @override
  String get chrArchetype => 'Karakter';

  @override
  String get chrArchetypeRequired => 'Devam etmek için bir karakter seçin';

  @override
  String get chrNameAnimeGirl => 'Anime kız';

  @override
  String get chrDescAnimeGirl =>
      'Neşeli ve inatçı. Her zafere sevinir, pes etmene izin vermez.';

  @override
  String get chrSpeechAnimeGirl => 'canlı, ünlemlerle ve cesaretlendirmelerle';

  @override
  String get chrSampleAnimeGirl1 =>
      'Merhaba! Bugün kesinlikle her şeye yetişeceğiz!';

  @override
  String get chrSampleAnimeGirl2 =>
      'Bir görev daha ve seninle gurur duyacağım!';

  @override
  String get chrSampleAnimeGirl3 => 'Pes etme, dünden daha iyi gidiyorsun!';

  @override
  String get chrLineAnimeGirlSoft =>
      'Sorun değil, biraz dinlen, sonra tekrar deneriz, olur mu?';

  @override
  String get chrLineAnimeGirlNormal => 'Harika iş! Az kaldı, hadi bitirelim!';

  @override
  String get chrLineAnimeGirlStrict =>
      'Hey! Görev kendi kendini yapmaz. Kalk ve yap!';

  @override
  String get chrLineAnimeGirlHarsh =>
      'Yine mi erteliyorsun?! Bahane yok — hemen git ve yap!';

  @override
  String get chrNameAnimeGuy => 'Anime genç';

  @override
  String get chrDescAnimeGuy =>
      'Hem rakip hem ortak. Meydan okur ve seni ileri çeker.';

  @override
  String get chrSpeechAnimeGuy => 'cüretkâr, meydan okuyan ve hırslı';

  @override
  String get chrSampleAnimeGuy1 => 'İddiaya var mısın, bugün beni geçemezsin?';

  @override
  String get chrSampleAnimeGuy2 =>
      'Ha, fena değil! Ama daha fazlasını yapabileceğini biliyorum.';

  @override
  String get chrSampleAnimeGuy3 => 'Haydi ortak, seviye kendi kendine atlamaz!';

  @override
  String get chrLineAnimeGuySoft =>
      'Bugün zor mu? Olur böyle. En azından küçük bir adım atalım.';

  @override
  String get chrLineAnimeGuyNormal =>
      'İyi gidiyorsun! Bir hamle daha ve bu gün bizim.';

  @override
  String get chrLineAnimeGuyStrict =>
      'Tembelliğe yenilmeyeceksin, değil mi? Daha güçlü olduğunu kanıtla.';

  @override
  String get chrLineAnimeGuyHarsh =>
      'Ciddi misin? Tüm yapabildiğin bu mu? Kalk ve yap, sızlanmak yok!';

  @override
  String get chrNameStoicStrongman => 'Soğukkanlı pehlivan';

  @override
  String get chrDescStoicStrongman =>
      'Kaya gibi sakin. Disipline ve tekrara inanır.';

  @override
  String get chrSpeechStoicStrongman => 'kısa cümleler, gereksiz söz yok';

  @override
  String get chrSampleStoicStrongman1 => 'Yeni gün. Yapıyoruz.';

  @override
  String get chrSampleStoicStrongman2 => 'Güç, tekrardır.';

  @override
  String get chrSampleStoicStrongman3 => 'Yavaş ama her gün.';

  @override
  String get chrLineStoicStrongmanSoft => 'Dinlen. Sonra devam ederiz.';

  @override
  String get chrLineStoicStrongmanNormal => 'İyi. Sıradaki set.';

  @override
  String get chrLineStoicStrongmanStrict => 'Atladın. Böyle olmaz. Yap.';

  @override
  String get chrLineStoicStrongmanHarsh => 'Konuşmayı bırak. Kalk. Yap. Şimdi.';

  @override
  String get chrNameGrimSwordsman => 'Karanlık kılıç ustası';

  @override
  String get chrDescGrimSwordsman =>
      'Sert bir usta. Her gün iradenin eğitimidir.';

  @override
  String get chrSpeechGrimSwordsman => 'ölçülü, karanlık bir ironiyle';

  @override
  String get chrSampleGrimSwordsman1 =>
      'Kılıç boş durunca körelir. İrade de öyle.';

  @override
  String get chrSampleGrimSwordsman2 =>
      'Yine buradasın. Demek ki henüz pes etmedin.';

  @override
  String get chrSampleGrimSwordsman3 =>
      'Sözünü tutana karanlık korkutucu değildir.';

  @override
  String get chrLineGrimSwordsmanSoft =>
      'Kılıcın da dinlenmesi gerekir. Nefeslen ve geri dön.';

  @override
  String get chrLineGrimSwordsmanNormal =>
      'Vuruş sayıldı. Gün bitene kadar ritmi koru.';

  @override
  String get chrLineGrimSwordsmanStrict =>
      'Zayıflık bahane arar. Güç yol arar. Seç.';

  @override
  String get chrLineGrimSwordsmanHarsh =>
      'Utanç verici. Yeminini bırakan savaşçı artık savaşçı değildir. Düzelt bunu.';

  @override
  String chrSpeechLabel(String speech) {
    return 'Konuşma tarzı: $speech';
  }

  @override
  String get chrPreviewStates => 'Animasyonlar';

  @override
  String get chrStateIdle => 'Bekleme';

  @override
  String get chrStateWalk => 'Yürü';

  @override
  String get chrStateTalk => 'Konuş';

  @override
  String get chrStateHappy => 'Sevinç';

  @override
  String get chrStateAngry => 'Öfke';

  @override
  String get chrStateSit => 'Otur';

  @override
  String get chrStateSleep => 'Uyku';

  @override
  String get chrStatePoint => 'İşaret et';

  @override
  String get chrVoice => 'Ses';

  @override
  String get chrVoiceNote =>
      'Şimdilik telefonun sistem sesi kullanılıyor; karakter sesleri daha sonra eklenecek.';

  @override
  String get chrVoiceBright => 'Parlak';

  @override
  String get chrVoiceSoft => 'Yumuşak';

  @override
  String get chrVoiceCalm => 'Sakin';

  @override
  String get chrVoiceEnergetic => 'Enerjik';

  @override
  String get chrVoiceDeep => 'Derin';

  @override
  String get chrVoiceLow => 'Pes';

  @override
  String get chrVoiceHoarse => 'Boğuk';

  @override
  String get chrListen => 'Dinle';

  @override
  String get chrStop => 'Durdur';

  @override
  String get chrTtsUnavailable =>
      'Bu cihazda arayüz dili için konuşma sentezi yok — sesi daha sonra dinleyebilirsiniz.';

  @override
  String get chrMotivation => 'Motivasyon modu';

  @override
  String get chrModeSoft => 'Yumuşak';

  @override
  String get chrModeSoftDesc => 'Destek ve nazik hatırlatmalar, baskı yok.';

  @override
  String get chrModeNormal => 'Normal';

  @override
  String get chrModeNormalDesc => 'Başarıya övgü, aksatmalara sakin uyarılar.';

  @override
  String get chrModeStrict => 'Katı';

  @override
  String get chrModeStrictDesc =>
      'Net talepler ve başarısızlıklara doğrudan eleştiri.';

  @override
  String get chrModeHarsh => 'Sert';

  @override
  String get chrModeHarshDesc =>
      'Tüm sertliğiyle azarlar ama görünüş ve sağlık üzerinden aşağılamaz.';

  @override
  String get chrModeExample => 'Örnek replik';

  @override
  String get chrModeTry => 'Bu modda dinle';

  @override
  String get chrProfanity => 'Küfre izin ver';

  @override
  String get chrProfanityHint => 'Nadiren ve yalnızca sert modda';

  @override
  String get chrTapSoft1 => 'Yanındayım. Biraz yapalım — bu bile iyi.';

  @override
  String get chrTapSoft2 => 'Acele etme, her şey yoluna girecek.';

  @override
  String get chrTapSoft3 => 'Uğraman çok güzel.';

  @override
  String get chrTapNormal1 => 'Görevler nasıl gidiyor?';

  @override
  String get chrTapNormal2 => 'İyi tempo. Devam.';

  @override
  String get chrTapNormal3 => 'Suyu unutma.';

  @override
  String get chrTapStrict1 => 'Görevler bekliyor. Gevşeme.';

  @override
  String get chrTapStrict2 => 'Önce iş, sonra dinlenme.';

  @override
  String get chrTapStrict3 => 'Listeye bak. Ne yapılmadı?';

  @override
  String get chrTapHarsh1 => 'Kaydırmayı bırak. Git ve yap.';

  @override
  String get chrTapHarsh2 => 'Bahaneler sayılmaz.';

  @override
  String get chrTapHarsh3 => 'Gün uzamıyor. Harekete geç.';

  @override
  String get chrPocketTab => 'Karakteri geri getir';

  @override
  String chrSemantics(String name) {
    return '$name: replik için dokunun; kaldırmak için aşağı kaydırın';
  }

  @override
  String get chtTitle => 'Sohbet';

  @override
  String get chtHint => 'Karakterine yaz…';

  @override
  String get chtEmpty =>
      'Sohbete başla: planı sor, yardım iste ya da sadece nasıl olduğunu anlat.';

  @override
  String get chtSend => 'Gönder';

  @override
  String get chtMic => 'Sesli giriş: dokun veya basılı tut';

  @override
  String get chtListening => 'Dinliyorum…';

  @override
  String get chtMicUnavailable =>
      'Konuşma tanıma kullanılamıyor — mikrofon ve konuşma iznini kontrol et';

  @override
  String get chtThinking => 'Yazıyor…';

  @override
  String chtAction(String summary) {
    return 'Sistem planı değiştirdi: $summary';
  }

  @override
  String get chtUndo => 'Geri al';

  @override
  String get chtUndone => 'Geri alındı';

  @override
  String get chtUndoFailed => 'Geri alınamadı';

  @override
  String get chtRetry => 'Tekrar dene';

  @override
  String get chtVoiceOn => 'Yanıtların seslendirilmesi açık';

  @override
  String get chtVoiceOff => 'Yanıtların seslendirilmesi kapalı';

  @override
  String get chtErrNotSignedIn =>
      'Yapay zekâ ile konuşmak için hesabına giriş yap: Diğer → Hesap.';

  @override
  String get chtErrOffline =>
      'Sunucuya bağlantı yok. Mesaj kaydedildi — internet gelince “Tekrar dene”ye bas.';

  @override
  String get chtErrBudget =>
      'Bu ayın yapay zekâ bütçesi doldu. Gelecek aya kadar karakter hazır cevaplarla konuşacak.';

  @override
  String get chtErrUnavailable =>
      'Yapay zekâ şu an kullanılamıyor. Biraz sonra tekrar dene.';

  @override
  String get chtErrRateLimited => 'Çok fazla istek. Biraz bekle.';

  @override
  String get chtErrServer => 'Yapay zekâ sunucusu hatası. Tekrar dene.';

  @override
  String get chtFallbackSoft =>
      'Şu an düzgün cevap veremiyorum ama yanındayım. Plana adım adım devam et — gayet iyi gidiyorsun.';

  @override
  String get chtFallbackNormal =>
      'Sistem\'le bağlantı yok. Plan geçerli — görevlerini yap, sonra konuşuruz.';

  @override
  String get chtFallbackStrict =>
      'Bağlantı yok — bu gevşemek için bahane değil. Görevleri aç ve yap.';

  @override
  String get chtFallbackHarsh =>
      'Sunucu sessiz, sen neyi bekliyorsun? Görevler kendi kendine yapılmaz. Hadi.';

  @override
  String get chtJournal => 'Yapay zekâ günlüğü';

  @override
  String get chtUsageTitle => 'Yapay zekâ harcamaları';

  @override
  String chtUsageMonth(String spent, String budget) {
    return 'Bu ay $spent / $budget';
  }

  @override
  String chtUsageToday(String usd) {
    return 'Bugün: $usd';
  }

  @override
  String get chtUsageDegraded =>
      'Tasarruf modu: bütçe neredeyse doldu, yapay zekâ daha ucuz modellerle çalışıyor';

  @override
  String get chtUsageByTask => 'Görevlere göre';

  @override
  String chtUsageCalls(int count) {
    return '$count çağrı';
  }

  @override
  String get chtUsageEmpty => 'Bu ay yapay zekâ henüz kullanılmadı.';

  @override
  String get chtTaskChat => 'Sohbet';

  @override
  String get chtTaskAnalysis => 'Gün ve hafta analizi';

  @override
  String get chtTaskPlan => 'Plan oluşturma';

  @override
  String get chtTaskPlanEdit => 'Plan değişikliği';

  @override
  String get chtTaskShort => 'Kısa replikler';

  @override
  String get chtTaskBankParse => 'Banka bildirimleri';

  @override
  String get chtTaskFoodVision => 'Fotoğraftan yemek ve fiş';

  @override
  String get chtTaskBodyVision => 'Vücut ve cilt fotoğrafları';

  @override
  String get chtTaskLearning => 'Öğrenme';

  @override
  String get chtTaskTts => 'Ses';

  @override
  String get chtActionsTitle => 'Yapay zekâ eylemleri';

  @override
  String get chtActionsEmpty => 'Yapay zekâ henüz hiçbir şeyi değiştirmedi.';

  @override
  String get chtLoadFailed => 'Yüklenemedi';

  @override
  String get chtVoiceTitle => 'Karakterin sesi';

  @override
  String get chtVoiceSystem => 'Telefonun sistem sesi';

  @override
  String get chtVoiceSystemDesc => 'İnternetsiz ve ücretsiz çalışır';

  @override
  String get chtVoiceListen => 'Dinle';

  @override
  String get chtVoiceEmpty => 'Sunucuda bu dil için ses yok.';

  @override
  String get chtVoiceListenFailed => 'Ses çalınamadı';

  @override
  String get chtVoiceFemale => 'kadın';

  @override
  String get chtVoiceMale => 'erkek';

  @override
  String get commonNext => 'İleri';

  @override
  String get commonBack => 'Geri';

  @override
  String get commonDone => 'Tamam';

  @override
  String get commonClose => 'Kapat';

  @override
  String get commonSave => 'Kaydet';

  @override
  String get commonCancel => 'İptal';

  @override
  String get commonDelete => 'Sil';

  @override
  String get commonAdd => 'Ekle';

  @override
  String get commonEdit => 'Düzenle';

  @override
  String get commonSkip => 'Atla';

  @override
  String get commonOptional => 'isteğe bağlı';

  @override
  String get commonOutOfRange => 'Değeri kontrol edin';

  @override
  String get commonRequired => 'Zorunlu alan';

  @override
  String get commonEstimateNote =>
      'fotoğrafa dayalı tahmin, tıbbi ölçüm değildir';

  @override
  String get commonCalculatedBySystem => 'Sistem tarafından hesaplanacak';

  @override
  String get onbIntroLabel => 'Bildirim';

  @override
  String get onbIntroTitle => 'Oyuncu olma hakkını kazandınız';

  @override
  String get onbIntroMessage =>
      'Sistem, size bir plan hazırlamak için bilgilerinizi toplayacak. Cevaplar hemen kaydedilir — ara verip daha sonra devam edebilirsiniz. Her bölüm ayarlardan değiştirilebilir.';

  @override
  String get onbIntroAccept => 'Kabul et';

  @override
  String onbStepCounter(int current, int total) {
    return 'Aşama $current/$total';
  }

  @override
  String get onbFinish => 'Bitir';

  @override
  String get onbStepProfile => 'Profil';

  @override
  String get onbStepBody => 'Vücut';

  @override
  String get onbStepBodyPhotos => 'Vücut fotoğrafları';

  @override
  String get onbStepSkin => 'Cilt';

  @override
  String get onbStepHealth => 'Sağlık';

  @override
  String get onbStepGoals => 'Hedefler';

  @override
  String get onbStepSchedule => 'Program';

  @override
  String get onbStepNutrition => 'Beslenme';

  @override
  String get onbStepTraining => 'Antrenman';

  @override
  String get onbStepFinance => 'Finans';

  @override
  String get onbStepCharacter => 'Karakter ve ses';

  @override
  String get onbStepPermissions => 'İzinler';

  @override
  String get almTitle => 'Alarmlar';

  @override
  String get almRingTitle => 'Kalk!';

  @override
  String almRingBodySquats(int count) {
    return 'Kapatmak için $count squat yapın';
  }

  @override
  String get almRingBodyQr => 'Kapatmak için başka odadaki QR kodu okutun';

  @override
  String get almDoTask => 'Görevi yap';

  @override
  String get almStop => 'Durdur';

  @override
  String get almChannelName => 'Alarm';

  @override
  String get almChannelDesc => 'Görev alarmının çalması';

  @override
  String get almFallbackBody =>
      'Alarm kapatılmadı — uygulamayı açın ve görevi yapın.';

  @override
  String get almReasonWake => 'Alarmla kalkış';

  @override
  String get almPermTitle => 'İzinler';

  @override
  String get almPermReady =>
      'Alarm hazır: kilit ekranının üzerinde çalar ve yalnızca görevle kapanır.';

  @override
  String get almPermExact => 'Tam zamanlı alarmlar';

  @override
  String get almPermFullScreen => 'Kilit ekranında gösterme';

  @override
  String get almPermNotifications => 'Bildirimler';

  @override
  String get almPermAlarmKit => 'Sistem alarmı (AlarmKit)';

  @override
  String get almPermFallback =>
      'Sistem alarmı kullanılamıyor — bir dizi yüksek sesli bildirim çalacak. Gece sessiz modu ve “Odak” modunu açmayın.';

  @override
  String get almPermBackup =>
      'Alarmı “Durdur” ile kapatırsanız, 3 dakika sonra görevi yapana kadar bildirimler gelir.';

  @override
  String get almPermGrant => 'İzin ver';

  @override
  String get almPermOn => 'var';

  @override
  String get almPermOff => 'yok';

  @override
  String get almEmpty =>
      'Henüz alarm yok. İlkini ekleyin — yalnızca görevle kapatılabilecek.';

  @override
  String get almAdd => 'Alarm ekle';

  @override
  String get almNew => 'Yeni alarm';

  @override
  String get almEditTitle => 'Alarm';

  @override
  String get almDaysEveryday => 'Her gün';

  @override
  String get almDaysWeekdays => 'Hafta içi';

  @override
  String get almDaysWeekend => 'Hafta sonu';

  @override
  String get almDaysOnce => 'Bir kez';

  @override
  String get almDayMon => 'Pzt';

  @override
  String get almDayTue => 'Sal';

  @override
  String get almDayWed => 'Çar';

  @override
  String get almDayThu => 'Per';

  @override
  String get almDayFri => 'Cum';

  @override
  String get almDaySat => 'Cmt';

  @override
  String get almDaySun => 'Paz';

  @override
  String get almDaysHint => 'Hiç gün seçilmedi — alarm bir kez çalacak.';

  @override
  String get almTime => 'Saat';

  @override
  String get almDays => 'Günler';

  @override
  String get almLabel => 'Etiket';

  @override
  String get almTask => 'Görev';

  @override
  String get almTaskSquats => 'Squat';

  @override
  String get almTaskQr => 'QR kod';

  @override
  String almTaskSquatsShort(int count) {
    return '$count squat';
  }

  @override
  String get almSquatsCount => 'Squat sayısı';

  @override
  String get almQrHint =>
      'Kodu yazdırıp başka bir odaya asın — örneğin mutfağa veya banyoya. Alarmı kapatmak için kalkıp yanına gitmeniz gerekecek.';

  @override
  String get almQrShare => 'Yazdırmak için paylaş';

  @override
  String get almQrShareText =>
      '“Sistem” alarmının QR kodu. Başka bir odaya asın.';

  @override
  String get almQrRegenerate => 'Yeni kod';

  @override
  String get almQrShareFailed => 'Kod paylaşılamadı.';

  @override
  String get almDiscipline => 'Disiplin modu';

  @override
  String get almDisciplineHint =>
      'Disiplin modunun kalkış alarmı: saat ve günleri mod belirler, görev değiştirilebilir.';

  @override
  String get almTest => '1 dk sonra test et';

  @override
  String get almTestScheduled =>
      'Deneme alarmı bir dakika sonra çalacak. Ekranı kilitleyebilirsiniz.';

  @override
  String get almTestRing => 'Deneme';

  @override
  String get almDeleteConfirm => 'Alarm silinsin mi?';

  @override
  String get almNotFound => 'Alarm bulunamadı.';

  @override
  String get almSquatsHint =>
      'Telefonu göğsünüzde tutun ve tam squat yapın — aşağı ve yukarı.';

  @override
  String almSquatsProgress(int done, int total) {
    return '$done / $total';
  }

  @override
  String get almSensorError => 'Hareket sensörü kullanılamıyor.';

  @override
  String get almHoldFallback => 'Kapatmak için basılı tutun';

  @override
  String get almScanQr => 'QR okut';

  @override
  String get almScanTitle => 'Alarm QR kodu';

  @override
  String get almScanHint => 'Kamerayı yazdırılmış koda tutun.';

  @override
  String get almScanNoCamera =>
      'Kamera kullanılamıyor. Ayarlardan kamera erişimine izin verin.';

  @override
  String get almQrWrong => 'Bu doğru kod değil.';

  @override
  String get almQrMissing => 'Bu alarm için kod oluşturulmadı — squat yapın.';

  @override
  String almSnooze(int left) {
    return '5 dk ertele ($left kaldı)';
  }

  @override
  String get almSnoozeNone => 'Artık ertelenemez.';

  @override
  String almReward(int count) {
    return 'Zamanında kalkış için +$count ◆';
  }

  @override
  String get almDone => 'Kalkış sayıldı';

  @override
  String get almDoneBody => 'Alarm kapatıldı. Günaydın!';

  @override
  String get finTitle => 'Finans';

  @override
  String get finBalance => 'Bakiye';

  @override
  String get finCryptoValue => 'Kripto';

  @override
  String get finFreeToMonthEnd => 'Ay sonuna kadar harcanabilir';

  @override
  String get finNextIncome => 'Sıradaki gelir';

  @override
  String get finMonthExpenses => 'Bu ayki giderler';

  @override
  String get finMonthIncome => 'Bu ayki gelirler';

  @override
  String get finMissingRates =>
      'Bazı tutarların kuru yok, toplama dahil edilmedi. Kurları güncelleyin.';

  @override
  String get finRatesNever => 'Kurlar henüz yüklenmedi';

  @override
  String finRatesUpdated(String time) {
    return 'Kurlar: $time';
  }

  @override
  String get finRefreshRates => 'Kurları güncelle';

  @override
  String get finRefreshing => 'Güncelleniyor…';

  @override
  String get finInput => 'Giriş';

  @override
  String get finExpense => 'Gider';

  @override
  String get finIncome => 'Gelir';

  @override
  String get finTransfer => 'Transfer';

  @override
  String get finExpenses => 'Giderler';

  @override
  String get finIncomes => 'Gelirler';

  @override
  String get finReceiptQr => 'Fiş QR';

  @override
  String get finReceiptPhoto => 'Fiş fotoğrafı';

  @override
  String get finBanks => 'Bankalar';

  @override
  String get finStatement => 'Ekstre';

  @override
  String get finMarket => 'Market';

  @override
  String get finAccounts => 'Hesaplar';

  @override
  String get finNoAccounts =>
      'Henüz hesap yok. Nakit veya kart ekleyin ya da bir gider girin; “Nakit” hesabı otomatik oluşur.';

  @override
  String get finManageAccounts => 'Hesaplar ve kripto';

  @override
  String get finBudgets => 'Limitler';

  @override
  String get finBudgetsEmptyShort => 'Limit yok.';

  @override
  String finBudgetsProposed(int n) {
    return 'Yapay zekâ önerisi: $n — onay bekliyor';
  }

  @override
  String get finManageBudgets => 'Limitleri ayarla';

  @override
  String get finSoon => 'Yakında';

  @override
  String get finChargeSoon => 'yakında ödeme';

  @override
  String get finRecent => 'Son işlemler';

  @override
  String get finNoOperations => 'İşlem yok.';

  @override
  String get finAllOperations => 'Tüm işlemler';

  @override
  String get finMore => 'Bölümler';

  @override
  String get finReports => 'Raporlar';

  @override
  String get finGoals => 'Birikim hedefleri';

  @override
  String get finSubscriptions => 'Abonelikler';

  @override
  String get finDebts => 'Borçlar';

  @override
  String get finSettings => 'Finans ayarları';

  @override
  String get finWarning => 'Uyarı';

  @override
  String get finSaveError => 'Kaydedilemedi';

  @override
  String get finAll => 'Tümü';

  @override
  String get finChoose => 'Seç';

  @override
  String get finTxNew => 'Yeni işlem';

  @override
  String get finTxEdit => 'İşlem';

  @override
  String get finTxDeleteConfirm => 'İşlem silinsin mi?';

  @override
  String get finAmount => 'Tutar';

  @override
  String get finAccount => 'Hesap';

  @override
  String get finFromAccount => 'Hesaptan';

  @override
  String get finToAccount => 'Hesaba';

  @override
  String get finToAmount => 'Yatırılan tutar';

  @override
  String get finToAmountHint =>
      'Hesaplar farklı para biriminde: yatırılan tutarı girin, yoksa kurdan hesaplanır.';

  @override
  String get finTransferNeedsTwo => 'İki farklı hesap seçin';

  @override
  String get finNoAccountsAuto => 'Nakit (oluşturulacak)';

  @override
  String get finNoAccountsAutoHint =>
      '“Nakit · RUB” hesabı otomatik oluşturulacak.';

  @override
  String get finCategory => 'Kategori';

  @override
  String get finCategoryAutoHint =>
      'seçilmedi — Sistem satıcıya göre tahmin eder';

  @override
  String get finMerchant => 'Nerede';

  @override
  String get finPayer => 'Kimden';

  @override
  String get finDate => 'Tarih';

  @override
  String get finTime => 'Saat';

  @override
  String get finNote => 'Not';

  @override
  String get finSource => 'Kaynak';

  @override
  String get finNoCategory => 'Kategorisiz';

  @override
  String get finOperations => 'İşlemler';

  @override
  String get finAddOperation => 'İşlem ekle';

  @override
  String finOperationsCount(int n) {
    return 'İşlem: $n';
  }

  @override
  String get finShowMore => 'Daha fazla';

  @override
  String get finPeriodWeek => 'Hafta';

  @override
  String get finPeriodMonth => 'Ay';

  @override
  String get finPeriodYear => 'Yıl';

  @override
  String get finPeriodAll => 'Tümü';

  @override
  String get finAccountAdd => 'Hesap ekle';

  @override
  String get finAccountNew => 'Yeni hesap';

  @override
  String get finAccountEdit => 'Hesap';

  @override
  String get finAccountDeleteConfirm =>
      'Hesap silinsin mi? İşlemler kalır ama hesapsız.';

  @override
  String get finAccountKind => 'Tür';

  @override
  String get finAccKindCash => 'Nakit';

  @override
  String get finAccKindCard => 'Kart';

  @override
  String get finAccKindDeposit => 'Mevduat';

  @override
  String get finAccKindCrypto => 'Kripto cüzdan';

  @override
  String get finAccountName => 'Ad';

  @override
  String get finCurrency => 'Para birimi';

  @override
  String get finOpeningBalance => 'Başlangıç bakiyesi';

  @override
  String get finOpeningBalanceHint => 'Kayda başlamadan önce hesaptaki tutar.';

  @override
  String get finBank => 'Banka';

  @override
  String get finBankHint => 'Örneğin: Ziraat, Garanti, İş Bankası';

  @override
  String get finCardLast4 => 'Kartın son 4 hanesi';

  @override
  String get finCardLast4Hint => 'Banka bildirimlerini eşleştirmek için';

  @override
  String get finArchive => 'Arşivde';

  @override
  String get finArchiveHint => 'Listelerden ve toplamdan gizle';

  @override
  String get finArchived => 'Arşiv';

  @override
  String get finCrypto => 'Kripto';

  @override
  String get finCryptoEmpty => 'Coin yok.';

  @override
  String get finCryptoRateNote =>
      'Miktar elle girilir, kur otomatik (sunucu üzerinden CoinGecko).';

  @override
  String get finCryptoAdd => 'Coin ekle';

  @override
  String get finCryptoEdit => 'Coin';

  @override
  String get finCryptoSymbol => 'Sembol';

  @override
  String get finCryptoCoinId => 'CoinGecko id';

  @override
  String get finCryptoCoinIdHint => 'bitcoin, ethereum, the-open-network…';

  @override
  String get finCryptoAmount => 'Miktar';

  @override
  String get finNoRate => 'kur yok';

  @override
  String get finCategories => 'Kategoriler';

  @override
  String get finCategoryAdd => 'Yeni kategori';

  @override
  String get finCategoryName => 'Ad';

  @override
  String get finCategoryIcon => 'Simge';

  @override
  String get finJunkFood => 'Abur cubur';

  @override
  String get finJunkFoodHint =>
      'Buradaki alışverişlere “fast food vergisi” (◆) uygulanır';

  @override
  String get finHide => 'Gizle';

  @override
  String get finHidden => 'gizli';

  @override
  String get finHideHint => 'Girişte gösterme';

  @override
  String get finCatGroceries => 'Market';

  @override
  String get finCatCafe => 'Kafe ve kahve';

  @override
  String get finCatFastfood => 'Fast food';

  @override
  String get finCatTransport => 'Ulaşım';

  @override
  String get finCatHousing => 'Konut';

  @override
  String get finCatUtilities => 'Faturalar';

  @override
  String get finCatPhone => 'Telefon ve internet';

  @override
  String get finCatHealth => 'Sağlık ve eczane';

  @override
  String get finCatBeauty => 'Bakım ve güzellik';

  @override
  String get finCatClothes => 'Giyim';

  @override
  String get finCatEducation => 'Eğitim ve kitap';

  @override
  String get finCatSport => 'Spor';

  @override
  String get finCatFun => 'Eğlence';

  @override
  String get finCatSubscriptions => 'Abonelikler';

  @override
  String get finCatGifts => 'Hediyeler';

  @override
  String get finCatMarketplace => 'Pazaryerleri';

  @override
  String get finCatOther => 'Diğer';

  @override
  String get finCatStipend => 'Burs';

  @override
  String get finCatSalary => 'Maaş';

  @override
  String get finCatGiftIncome => 'Hediye geliri';

  @override
  String get finCatCashback => 'Nakit iade';

  @override
  String get finCatOtherIncome => 'Diğer gelirler';

  @override
  String get finBudgetsActive => 'Aktif limitler';

  @override
  String get finBudgetsEmpty =>
      'Limit yok. Elle ekleyin veya yapay zekâdan öneri isteyin.';

  @override
  String get finBudgetsRule =>
      'Limiti aştınız — ◆ ceza, dönemi limit içinde bitirdiniz — ◆ ödül.';

  @override
  String get finBudgetAdd => 'Limit ekle';

  @override
  String get finBudgetEdit => 'Limit';

  @override
  String get finLimit => 'Limit';

  @override
  String get finRewardDiamonds => 'Ödül';

  @override
  String get finPenaltyDiamonds => 'Ceza';

  @override
  String get finBudgetsAi => 'Yapay zekâ planı';

  @override
  String finBudgetsAiReady(int days) {
    return 'Gözlem: $days gün — yapay zekâdan limit önerisi isteyebilirsiniz.';
  }

  @override
  String finBudgetsAiNeedMore(int days) {
    return '2–4 haftalık gözlem gerekli (şu an $days gün). Harcamalarınızı kaydedin — yapay zekâ alışkanlıklarınıza göre limit önerecek.';
  }

  @override
  String get finBudgetsAiAsk => 'Limit öner (YZ)';

  @override
  String finAiSuggested(int n) {
    return 'Önerilen limit: $n. Onaylayın veya reddedin.';
  }

  @override
  String get finAiNoSuggestions => 'Yapay zekâ limit önermedi — veri henüz az.';

  @override
  String get finAccept => 'Kabul et';

  @override
  String get finReject => 'Reddet';

  @override
  String get finAiThinking => 'Sistem düşünüyor…';

  @override
  String get finAiNotSignedIn =>
      'Yapay zekâ hesaba giriş yapınca kullanılabilir. Diğer her şey çevrimdışı çalışır.';

  @override
  String get finAiOffline =>
      'Ağ yok. Daha sonra deneyin — veriler cihazda kayıtlı.';

  @override
  String get finAiBudget => 'Yapay zekâ harcama limiti doldu.';

  @override
  String get finAiRateLimited => 'Çok fazla istek. Biraz bekleyin.';

  @override
  String get finAiUnavailable =>
      'Yapay zekâ şu an kullanılamıyor. Daha sonra deneyin.';

  @override
  String get finGoalsEmpty => 'Hedef yok.';

  @override
  String get finGoalsHint => 'İlerleme — seçilen birikim hesabının bakiyesi.';

  @override
  String get finGoalAdd => 'Yeni hedef';

  @override
  String get finGoalEdit => 'Hedef';

  @override
  String get finGoalTitle => 'Ne için biriktiriyoruz';

  @override
  String get finGoalTarget => 'Gereken tutar';

  @override
  String get finGoalAccount => 'Birikim hesabı';

  @override
  String get finGoalAccountHint => 'Bu hesabın bakiyesi — biriken tutar';

  @override
  String get finGoalDeadline => 'Hangi tarihe kadar';

  @override
  String get finGoalNoAccount => 'İlerlemeyi görmek için birikim hesabı seçin.';

  @override
  String get finGoalReached => 'Hedefe ulaşıldı!';

  @override
  String finUntil(String date) {
    return '$date tarihine kadar';
  }

  @override
  String get finSubscriptionsEmpty => 'Abonelik yok.';

  @override
  String get finSubscriptionsHint =>
      'Ödeme gününde Sistem gideri kendisi kaydeder ve tarihi kaydırır.';

  @override
  String get finSubscriptionsMonthly => 'Aylık';

  @override
  String get finSubscriptionAdd => 'Yeni abonelik';

  @override
  String get finSubscriptionEdit => 'Abonelik';

  @override
  String get finSubscriptionTitle => 'Ad';

  @override
  String finNextCharge(String date) {
    return 'ödeme $date';
  }

  @override
  String get finNextChargeDate => 'Sonraki ödeme tarihi';

  @override
  String get finPaused => 'duraklatıldı';

  @override
  String get finActive => 'Aktif';

  @override
  String get finDebtsOpen => 'Açık borçlar';

  @override
  String get finDebtsClosed => 'Kapanan';

  @override
  String get finDebtsEmpty => 'Borç yok.';

  @override
  String get finDebtAdd => 'Yeni borç';

  @override
  String get finDebtEdit => 'Borç';

  @override
  String get finDebtOwe => 'Borçluyum';

  @override
  String get finDebtLent => 'Alacaklıyım';

  @override
  String get finDebtPerson => 'Kim';

  @override
  String get finDebtDue => 'Vade';

  @override
  String get finDebtSettle => 'Ödendi';

  @override
  String get finDebtSettleHint => 'Borcu kapatır ve işlem kaydını açar.';

  @override
  String get finOverdue => 'gecikmiş';

  @override
  String get finSettled => 'ödendi';

  @override
  String get finTotals => 'Toplamlar';

  @override
  String get finNet => 'Fark';

  @override
  String get finByCategory => 'Kategorilere göre giderler';

  @override
  String get finNoExpensesPeriod => 'Bu dönemde gider yok.';

  @override
  String get finDynamics => 'Dönemlere göre gelir ve gider';

  @override
  String get finPrevPeriod => 'Önceki dönem';

  @override
  String get finNextPeriod => 'Sonraki dönem';

  @override
  String get finAiComment => 'Yapay zekâ yorumu';

  @override
  String get finAiCommentHint =>
      'Yapay zekâ dönemi inceler: para nereye gitti, nerede tasarruf edilebilir.';

  @override
  String get finAiCommentAsk => 'YZ yorumu';

  @override
  String get finSrcManual => 'elle';

  @override
  String get finSrcReceiptQr => 'fiş QR';

  @override
  String get finSrcReceiptPhoto => 'fiş fotoğrafı';

  @override
  String get finSrcFood => 'yemek fotoğrafı';

  @override
  String get finSrcBank => 'banka bildirimi';

  @override
  String get finSrcSms => 'banka SMS\'i';

  @override
  String get finSrcStatement => 'ekstre';

  @override
  String get finSrcSubscription => 'abonelik';

  @override
  String get finSrcMarket => 'market';

  @override
  String get finReasonJunkTax => 'fast food vergisi';

  @override
  String get finReasonBudgetOver => 'harcama limiti aşıldı';

  @override
  String get finReasonBudgetKept => 'limit içinde kalındı';

  @override
  String get finLockTitle => 'Sistem kilitli';

  @override
  String get finLockReason => '“Sistem”e girişi onaylayın';

  @override
  String get finLockEnterPin => 'PIN girin';

  @override
  String get finLockUseBiometric =>
      'Face ID veya parmak iziyle girişi onaylayın';

  @override
  String get finLockBiometricButton => 'Face ID / parmak izi';

  @override
  String get finLockWrongPin => 'Yanlış PIN';

  @override
  String finLockCooldown(int sec) {
    return 'Çok fazla deneme. $sec sn bekleyin';
  }

  @override
  String finLockDigits(int n) {
    return 'Girilen hane: $n';
  }

  @override
  String get finLockErase => 'Sil';

  @override
  String get finLockOk => 'Tamam';

  @override
  String get finLockSection => 'Uygulamaya giriş';

  @override
  String get finLockIntro =>
      'Uygulamayı koruyun: açılışta ve arka plandan dönünce Sistem Face ID, parmak izi veya PIN ister.';

  @override
  String get finLockModeOff => 'Kapalı';

  @override
  String get finLockModeBiometric => 'Face ID / parmak izi';

  @override
  String get finLockModePin => 'PIN';

  @override
  String get finLockModeBoth => 'Biyometri + PIN';

  @override
  String get finLockNoBiometric => 'Cihazda biyometri yok veya ayarlanmamış.';

  @override
  String get finLockTimeout => 'Arka plandan sonra tekrar sor';

  @override
  String get finLockTimeoutNow => 'Hemen';

  @override
  String finMinutes(int n) {
    return '$n dk';
  }

  @override
  String get finLockChangePin => 'PIN değiştir';

  @override
  String get finLockNewPin => 'Yeni PIN';

  @override
  String get finLockRepeatPin => 'PIN\'i tekrar girin';

  @override
  String get finLockPinMismatch => 'PIN kodları eşleşmedi';

  @override
  String get finLockPinChanged => 'PIN değiştirildi';

  @override
  String finLockPinRule(int min, int max) {
    return '$min–$max hane';
  }

  @override
  String get finLockPinWarning =>
      'Unutulan PIN kurtarılamaz — mümkünse biyometriyi de açın.';

  @override
  String get finJunkTaxSection => 'Fast food vergisi';

  @override
  String get finJunkTaxEnabled => 'Abur cubur için ◆ düş';

  @override
  String get finJunkTaxHint =>
      '“Abur cubur” kategorilerindeki her alışveriş için';

  @override
  String get finJunkTaxAmount => 'Alışveriş başına vergi';

  @override
  String get finSummaryFood => 'Bu ay yemek';

  @override
  String get finSummaryUntilIncome => 'Gelire kalan';

  @override
  String finDays(int n) {
    return '$n gün';
  }

  @override
  String finRemindSubTitle(String title) {
    return 'Yarın ödeme: $title';
  }

  @override
  String finRemindSubBody(String amount, String date) {
    return '$amount · $date';
  }

  @override
  String get finRemindDebtOweTitle => 'Borç vadesi';

  @override
  String get finRemindDebtLentTitle => 'Alacağınızın vadesi';

  @override
  String finRemindDebtBody(String person, String amount, String date) {
    return '$person: $amount, son tarih $date';
  }

  @override
  String get fniAccount => 'Hesap';

  @override
  String get fniAuto => 'Otomatik';

  @override
  String get fniCategory => 'Kategori';

  @override
  String get fniQrNotReceipt => 'Bu bir fiş QR kodu değil.';

  @override
  String get fniDuplicate => 'Bu işlem zaten kayıtlı.';

  @override
  String get fniAdded => 'İşlem eklendi.';

  @override
  String get fniSaveFailed => 'İşlem kaydedilemedi.';

  @override
  String get fniRetry => 'Tekrar dene';

  @override
  String get fniReceiptTitle => 'Fiş';

  @override
  String get fniStore => 'Mağaza';

  @override
  String get fniDate => 'Tarih';

  @override
  String get fniKind => 'Tür';

  @override
  String get fniRefund => 'İade';

  @override
  String get fniTotal => 'Toplam';

  @override
  String get fniQrNoItems =>
      'Fiş kalemleri şu an alınamıyor — QR\'daki tutar kaydedildi.';

  @override
  String get fniAdd => 'Ekle';

  @override
  String get fniReceiptQrTitle => 'QR ile fiş';

  @override
  String get fniReceiptPhotoTitle => 'Fotoğrafla fiş';

  @override
  String get fniNoCamera => 'Kamera kullanılamıyor. Ayarlardan izin verin.';

  @override
  String get fniClose => 'Kapat';

  @override
  String get fniQrHint => 'Kamerayı fişteki QR koduna tutun';

  @override
  String get fniFileFailed => 'Dosya açılamadı.';

  @override
  String get fniFileTooLarge =>
      'Dosya 3 MB\'den büyük. Daha kısa bir dönem için ekstre alın.';

  @override
  String get fniStatementTitle => 'Ekstre içe aktarma';

  @override
  String get fniStatementFile => 'Ekstre dosyası';

  @override
  String get fniStatementHint =>
      'Banka uygulamasından ekstreyi (CSV veya PDF) indirin ve dosyayı seçin.';

  @override
  String get fniPickFile => 'Dosya seç';

  @override
  String get fniStatementParsing => 'Ekstre okunuyor…';

  @override
  String get fniStatementEmpty => 'Dosyada işlem bulunamadı.';

  @override
  String get fniBank => 'Banka';

  @override
  String get fniSelectAll => 'Tümü';

  @override
  String get fniAlreadyImported => 'zaten var';

  @override
  String get fniBanksTitle => 'Bankalar';

  @override
  String get fniBanksAndroidOnly =>
      'Banka bildirimleri ve SMS okuma yalnızca Android\'de var. iPhone\'da ekstre içe aktarmayı kullanın.';

  @override
  String get fniAccess => 'Erişim';

  @override
  String get fniAccessNotifications => 'Banka bildirimleri';

  @override
  String get fniOpenSettings => 'Ayarları aç';

  @override
  String get fniAccessSms => 'Banka SMS\'leri';

  @override
  String get fniAllow => 'İzin ver';

  @override
  String get fniAccessHint =>
      'Yalnızca seçili bankaların mesajları okunur. Metinler uygulamada saklanır ve sunucunuzla eşitlenir.';

  @override
  String get fniBanksList => 'Bankalarım';

  @override
  String get fniProcessNow => 'İşle';

  @override
  String get fniSmsHistory => 'Son 30 gün SMS';

  @override
  String get fniGranted => 'Var';

  @override
  String get fniOtherBank => 'Diğer banka';

  @override
  String get fniSourceNotifications => 'Uygulama bildirimleri';

  @override
  String get fniSourceSms => 'SMS';

  @override
  String get fniPackages => 'Uygulama paketleri';

  @override
  String get fniExtraSenders => 'Ek SMS göndericileri';

  @override
  String get fniExtraSendersHint => 'Ad veya numara, virgülle';

  @override
  String get fniInbox => 'Gelenler';

  @override
  String get fniInboxEmpty =>
      'Henüz bir şey yok. Yeni banka bildirimleri ve SMS\'ler burada görünecek.';

  @override
  String get fniStatusReview => 'Kontrol edin';

  @override
  String get fniStatusAdded => 'Eklendi';

  @override
  String get fniStatusDuplicate => 'Tekrar';

  @override
  String get fniStatusIgnored => 'İşlem değil';

  @override
  String get fniStatusFailed => 'Hata';

  @override
  String get fniStatusPending => 'Bekliyor';

  @override
  String get fniConfirm => 'Doğru';

  @override
  String get fniFix => 'Düzelt';

  @override
  String get fniAddManually => 'Elle ekle';

  @override
  String get fniFixInFinance =>
      'Bu işlemi “Finans” bölümünde düzenleyin veya silin.';

  @override
  String get fniIgnore => 'Yok say';

  @override
  String get fniEditTitle => 'İşlem';

  @override
  String get fniExpense => 'Gider';

  @override
  String get fniIncome => 'Gelir';

  @override
  String get fniTransfer => 'Transfer';

  @override
  String get fniAmount => 'Tutar';

  @override
  String get fniMerchant => 'Nerede / kimden';

  @override
  String get fniCancel => 'İptal';

  @override
  String get fniSave => 'Kaydet';

  @override
  String fniImported(int added, int dup) {
    return 'Eklendi: $added, zaten vardı: $dup';
  }

  @override
  String fniImporting(int done, int total) {
    return 'İçe aktarılıyor $done / $total';
  }

  @override
  String fniImportN(int n) {
    return 'İçe aktar ($n)';
  }

  @override
  String fniRows(int n) {
    return 'İşlemler: $n';
  }

  @override
  String fniSmsFound(int n) {
    return 'Bulunan SMS: $n';
  }

  @override
  String fniSenders(String list) {
    return 'Göndericiler: $list';
  }

  @override
  String get actStepsTitle => 'Adımlar';

  @override
  String actGoal(String goal) {
    return 'Hedef: $goal';
  }

  @override
  String get actDistance => 'Mesafe';

  @override
  String actDistanceKm(String km) {
    return '$km km';
  }

  @override
  String get actFloors => 'Katlar';

  @override
  String get actNoValue => '—';

  @override
  String get actWeek => '7 gün';

  @override
  String get actAllow => 'İzin ver';

  @override
  String get actPermissionHint =>
      'Hareket sensörlerine erişim izni verin — adımlar otomatik sayılsın.';

  @override
  String get actUnavailableHint =>
      'Cihazda adım sayar yok — adımları elle girin.';

  @override
  String get actManual => 'Elle gir';

  @override
  String get actManualLabel => 'Bugünkü adımlar';

  @override
  String get actManualRange => '0 ile 100.000 arası';

  @override
  String get actSave => 'Kaydet';

  @override
  String get actCancel => 'İptal';

  @override
  String actStepsSemantic(String steps, String goal) {
    return 'Bugünkü adımlar: $steps / $goal';
  }

  @override
  String get int6PlanAi => 'Yapay zekâ ile plan oluştur';

  @override
  String get int6PlanAiError =>
      'Yapay zekâ ile plan oluşturulamadı. Hesap girişini ve bağlantıyı kontrol edin.';

  @override
  String get int6Learning => 'Bilgi';

  @override
  String get int6LearningHint => 'Kurslar, günün dersleri ve tekrarlar';

  @override
  String get int6AiJournal => 'Yapay zekâ: harcamalar ve eylemler';

  @override
  String get int6AiJournalHint =>
      'Bütçe ve Sistem\'in yaptığı değişiklikler (geri alınabilir)';

  @override
  String get int6Voice => 'Karakter sesi';

  @override
  String get int6VoiceHint => 'Sunucudaki hazır sesler, dinle';

  @override
  String get int7Finance => 'Finans';

  @override
  String get int7FinanceHint => 'Hesaplar, işlemler, limitler, raporlar';

  @override
  String get int7Market => 'Alışveriş marketi';

  @override
  String get int7MarketHint => 'Plana göre seçki ve fiyatlar';

  @override
  String get int7Blocker => 'Uygulama engelleme';

  @override
  String get int7BlockerHint => 'Disiplin modunda yatma saatinden sonra';

  @override
  String get int7Alarms => 'Görev alarmı';

  @override
  String get int7AlarmsHint => 'Yalnızca görevle kapanır';

  @override
  String get int7Setup => 'Ayarla';

  @override
  String get livNextQuest => 'Sıradaki görev';

  @override
  String get livNoQuest => 'Görev yok';

  @override
  String get livOverdue => 'Süresi geçti';

  @override
  String get livSteps => 'Adım';

  @override
  String get livWater => 'Su';

  @override
  String get livAddWater => '+250 ml';

  @override
  String get livMl => 'ml';

  @override
  String get livKm => 'km';

  @override
  String get livPerKm => '/km';

  @override
  String get livReward => 'Ödül';

  @override
  String get livWalk => 'Yürüyüş';

  @override
  String get livQuest => 'Görev';

  @override
  String get livWorkout => 'Antrenman';

  @override
  String get livChannelName => 'Etkinlik';

  @override
  String get livChannelDesc =>
      'Bildirim panelinde yürüyüş, aktif görev ve antrenman';

  @override
  String livWalkNextIn(int m) {
    return '$m m sonra dönüş';
  }

  @override
  String get locNotifTitle => 'Sistem · yürüyüş';

  @override
  String get locNotifText => 'Rota kaydediliyor';

  @override
  String get locNotifChannel => 'Yürüyüş';

  @override
  String get lrnTitle => 'Bilgi';

  @override
  String get lrnToday => 'Bugün';

  @override
  String get lrnCourses => 'Kurslar';

  @override
  String get lrnNewCourse => 'Yeni kurs';

  @override
  String get lrnTopic => 'Ne öğrenmek istiyorsunuz?';

  @override
  String get lrnTopicHint => 'Örneğin: nunçaku, C++, Rusça';

  @override
  String get lrnPerDay => 'Günlük ders';

  @override
  String get lrnLength => 'Kurstaki ders sayısı';

  @override
  String get lrnCreate => 'Kursu oluştur';

  @override
  String get lrnCreating => 'Sistem kursu oluşturuyor…';

  @override
  String get lrnTodayEmpty => 'Bugünlük bu kadar: dersler ve tekrarlar tamam.';

  @override
  String get lrnNoCourses =>
      'Henüz kurs yok. Ne öğrenmek istediğinizi yazın, Sistem kursu oluştursun.';

  @override
  String lrnLessonOf(int n, int total) {
    return 'Ders $n / $total';
  }

  @override
  String get lrnReview => 'Tekrar';

  @override
  String get lrnLessonDay => 'Günün dersi';

  @override
  String get lrnStatusPaused => 'Duraklatıldı';

  @override
  String get lrnStatusDone => 'Kurs tamamlandı';

  @override
  String get lrnPause => 'Duraklat';

  @override
  String get lrnResume => 'Devam et';

  @override
  String get lrnDelete => 'Kursu sil';

  @override
  String lrnDeleteConfirm(String title) {
    return '“$title” kursu silinsin mi? İlerleme kaybolacak.';
  }

  @override
  String get lrnLoading => 'Ders yükleniyor…';

  @override
  String get lrnGoal => 'Hedef';

  @override
  String get lrnExample => 'Örnek';

  @override
  String get lrnTip => 'İpucu';

  @override
  String get lrnStartQuiz => 'Teste geç';

  @override
  String get lrnFinish => 'Dersi bitir';

  @override
  String lrnQuestion(int n, int total) {
    return 'Soru $n / $total';
  }

  @override
  String get lrnNext => 'İleri';

  @override
  String get lrnCorrect => 'Doğru';

  @override
  String get lrnWrong => 'Yanlış';

  @override
  String get lrnResult => 'Sonuç';

  @override
  String lrnScore(int p) {
    return 'Doğru: %$p';
  }

  @override
  String lrnNextReview(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Tekrar $days gün sonra',
    );
    return '$_temp0';
  }

  @override
  String get lrnMastered => 'Konu pekişti — başka tekrar yok.';

  @override
  String get lrnPassed => 'Ders tamamlandı.';

  @override
  String lrnFailed(int p) {
    return 'Geçmek için %$p gerekli — tekrar deneyin.';
  }

  @override
  String get lrnReviewPassed => 'Tekrar başarılı.';

  @override
  String get lrnReviewFailed => 'Tekrar başarısız — aralık kısaltıldı.';

  @override
  String get lrnRetry => 'Yeniden dene';

  @override
  String get lrnLessonDone => 'Tamamlandı';

  @override
  String get lrnErrOffline =>
      'Sunucuya bağlantı yok. Yüklenmiş dersler çevrimdışı kullanılabilir.';

  @override
  String get lrnErrNotSignedIn =>
      'Sistem\'in kurs ve ders oluşturması için hesabınıza giriş yapın (Diğer → Hesap).';

  @override
  String get lrnErrBudget => 'Yapay zekâ limiti doldu. Daha sonra deneyin.';

  @override
  String get lrnErrUnavailable => 'Yapay zekâ şu anda sunucuda kullanılamıyor.';

  @override
  String get lrnErrServer => 'Yanıt alınamadı. Tekrar deneyin.';

  @override
  String get mktTitle => 'Market';

  @override
  String get mktSuggest => 'Öner (YZ)';

  @override
  String get mktSuggesting => 'Plana uygun ürünler seçiliyor…';

  @override
  String get mktCatAll => 'Tümü';

  @override
  String get mktCatSkin => 'Cilt bakımı';

  @override
  String get mktCatNutrition => 'Beslenme';

  @override
  String get mktCatEquipment => 'Ekipman';

  @override
  String get mktCatOther => 'Diğer';

  @override
  String get mktTabNew => 'Öneriler';

  @override
  String get mktTabSaved => 'Kaydedilenler';

  @override
  String get mktTabBought => 'Alınanlar';

  @override
  String get mktEmptyNew =>
      'Henüz boş. “Öner (YZ)” düğmesine basın — Sistem planınıza uygun ürünler seçsin.';

  @override
  String get mktEmptySaved => 'Kaydedilmiş ürün yok.';

  @override
  String get mktEmptyBought => 'Henüz alışveriş yok.';

  @override
  String get mktEstimateNote =>
      'Fiyatlar yaklaşıktır — belirtilen tarihteki web aramasına göre.';

  @override
  String mktPriceLine(String price, String source, String date) {
    return '≈ $price · $source · $date';
  }

  @override
  String mktPriceShort(String price, String date) {
    return '≈ $price · $date';
  }

  @override
  String get mktPriceUnknown => 'Fiyat bilinmiyor';

  @override
  String mktPricePaid(String price) {
    return '$price karşılığında alındı';
  }

  @override
  String get mktBudgetOk => 'Alınabilir';

  @override
  String get mktBudgetAfterIncome => 'Para gelince';

  @override
  String get mktBudgetOver => 'Bütçe dışı';

  @override
  String get mktSave => 'Kaydet';

  @override
  String get mktHide => 'Gizle';

  @override
  String get mktBought => 'Aldım';

  @override
  String get mktRefreshPrice => 'Fiyatı güncelle';

  @override
  String get mktPriceUpdated => 'Fiyat güncellendi.';

  @override
  String get mktPriceNotFound => 'Güncel fiyat bulunamadı.';

  @override
  String get mktSearchSuffix => 'arama';

  @override
  String get mktLinkCopied => 'Bağlantı kopyalandı.';

  @override
  String get mktOpenFailed => 'Bağlantı açılamadı — kopyalandı.';

  @override
  String get mktBoughtTitle => 'Alışveriş';

  @override
  String mktBoughtMessage(String title) {
    return '“$title” kaça mal oldu?';
  }

  @override
  String get mktBoughtPrice => 'Gerçek fiyat';

  @override
  String get mktBoughtConfirm => 'Kaydet';

  @override
  String get mktBoughtRecorded => 'Alışveriş finansa kaydedildi.';

  @override
  String get mktBoughtNoFinance =>
      'Alındı olarak işaretlendi. Finansa kaydedilmedi — bölüm henüz kullanılamıyor.';

  @override
  String get mktNoticeLabel => 'Sistem';

  @override
  String get mktNothingFound =>
      'Sistem yeni ürün bulamadı. Başka bir kategori deneyin.';

  @override
  String mktAdded(int count) {
    return 'Eklenen ürün: $count';
  }

  @override
  String get mktErrOffline =>
      'Sunucuya bağlantı yok. Kaydedilen ürünler çevrimdışı da görünür.';

  @override
  String get mktErrNotSignedIn =>
      'Sistem\'in ürün seçmesi için hesabınıza giriş yapın (“Diğer” → “Hesap”).';

  @override
  String get mktErrBudget =>
      'Yapay zekâ limiti şu an doldu. Daha sonra deneyin.';

  @override
  String get mktErrUnavailable => 'Sunucudaki yapay zekâ şu an kullanılamıyor.';

  @override
  String get mktErrRateLimited => 'Çok fazla istek. Bir süre sonra deneyin.';

  @override
  String get mktErrServer => 'Yanıt alınamadı. Tekrar deneyin.';

  @override
  String get msgChannelName => 'Sistem mesajları';

  @override
  String get msgChannelDesc => 'Karakterden brifingler, moral ve sitemler';

  @override
  String get msgTplBriefingTitle => '[ Sistem ] Sabah brifingi';

  @override
  String get msgTplBriefing1 =>
      'Yeni gün, yeni görevler. Listeyi aç ve ilkinden başla.';

  @override
  String get msgTplBriefing2 => 'Oyuncu, kalk. Bugünün planı seni bekliyor.';

  @override
  String get msgTplBriefing3 =>
      'Sistem çevrimiçi. Bugünün görevleri kendi kendine tamamlanmaz.';

  @override
  String get msgTplCheerTitle => '[ Sistem ]';

  @override
  String get msgTplCheer1 => 'Tempoyu koruyorsun. Yavaşlama.';

  @override
  String get msgTplCheer2 =>
      'Tamamlanan her görev bir sonraki rütbeye bir adım.';

  @override
  String get msgTplCheer3 => 'Görevlere bak: şu an neyi kapatabilirsin?';

  @override
  String get msgTplCheer4 =>
      'Bir yudum su ve devam. Sistem ilerlemeni izliyor.';

  @override
  String get msgWaterQuestTitle => 'Su için markete yürü';

  @override
  String ntfQuestTitle(String title) {
    return '[ Görev ] $title';
  }

  @override
  String ntfPenaltyQuestTitle(String title) {
    return '[ Ceza görevi ] $title';
  }

  @override
  String ntfBossTitle(String title) {
    return '[ Haftanın bossu ] $title';
  }

  @override
  String ntfQuestBody(String time, int diamonds) {
    return 'Son süre: $time. Ödül: +$diamonds ◆';
  }

  @override
  String ntfQuestBodyNoReward(String time) {
    return 'Son süre: $time.';
  }

  @override
  String ntfPenaltyQuestBody(String time) {
    return 'Son süre: $time. Reddedilemez.';
  }

  @override
  String get ntfReproachTitle => '[ Sistem ] Görev tamamlanmadı';

  @override
  String ntfReproachBody(String title) {
    return '“$title” gecikti. Sistem eylemsizliği kaydetti. Hemen tamamla.';
  }

  @override
  String get ntfActionDone => 'Tamamlandı';

  @override
  String get ntfActionSnooze => '+10 dk';

  @override
  String get ntfChannelQuests => 'Görevler';

  @override
  String get ntfChannelQuestsDesc =>
      'Görev hatırlatmaları, sitemler ve Sistem mesajları';

  @override
  String get ntfChannelNag => 'Israrcı hatırlatma';

  @override
  String get ntfChannelNagDesc => 'Görev tamamlanana kadar her dakika tekrar';

  @override
  String get ntfFailedTitle => '[ Sistem ] Görev başarısız';

  @override
  String ntfFailedBody(String title, int diamonds) {
    return '“$title”: −$diamonds ◆';
  }

  @override
  String ntfPenaltyTitle(int diamonds) {
    return '[ Ceza ] −$diamonds ◆';
  }

  @override
  String get ntfLevelUpTitle => '[ Sistem ] Seviye atladın';

  @override
  String ntfLevelUpBody(int level, int points) {
    return 'Seviye $level. Serbest puan: $points';
  }

  @override
  String get ntfTestTitle => '[ Sistem ] Bağlantı testi';

  @override
  String get ntfTestBody => 'Bildirimler çalışıyor. Oyuncu, emirleri bekle.';

  @override
  String get ntfTestSent => 'Bildirim gönderildi';

  @override
  String get ntfSectionGeneral => 'Genel';

  @override
  String get ntfEnabled => 'Hatırlatmalar';

  @override
  String get ntfEnabledHint => 'Görevler için yerel bildirimler';

  @override
  String get ntfNag => 'Her dakika hatırlat';

  @override
  String get ntfNagHint => '“Tamamlandı”ya basana kadar tekrar';

  @override
  String get ntfReproach => 'Sitemler';

  @override
  String get ntfReproachHint =>
      'Süre dolduktan 15 dk sonra, görev tamamlanmadıysa';

  @override
  String get ntfVoice => 'Bildirim sesi olarak karakterin sesi';

  @override
  String get ntfVoiceHint => '6. aşamada gelecek — şimdilik standart ses';

  @override
  String get ntfSectionQuiet => 'Sessiz saatler';

  @override
  String get ntfQuietEnabled => 'Rahatsız etme';

  @override
  String get ntfQuietHint => 'Bu sürede ses yok, sitem bitişten sonra gelir';

  @override
  String get ntfQuietFrom => 'Başlangıç';

  @override
  String get ntfQuietTo => 'Bitiş';

  @override
  String get ntfSectionPermission => 'İzin';

  @override
  String get ntfPermGranted => 'Bildirimlere izin verildi';

  @override
  String get ntfPermDenied =>
      'Bildirimler kapalı — görevler hatırlatma yapamaz';

  @override
  String get ntfPermUnknown => 'İzin durumu bilinmiyor';

  @override
  String get ntfPermExactOff =>
      'Tam zamanlı alarmlar kapalı — hatırlatmalar gecikebilir';

  @override
  String get ntfPermRequest => 'İzin iste';

  @override
  String get ntfTest => 'Bildirimi test et';

  @override
  String get ntfUnavailable => 'Bu platformda bildirimler kullanılamaz';

  @override
  String get nutYesterday => 'Dün';

  @override
  String get nutToday => 'Bugün';

  @override
  String get nutNoticeLabel => 'Bildirim';

  @override
  String get nutProtein => 'Protein';

  @override
  String get nutFat => 'Yağ';

  @override
  String get nutCarbs => 'Karbonhidrat';

  @override
  String get nutBalance => 'Denge';

  @override
  String get nutNoNorm =>
      'Hedef yok: kalori ve makro hedeflerini görmek için planı kabul edin.';

  @override
  String get nutNoWaterNorm =>
      'Su hedefi plan kabul edildikten sonra görünecek.';

  @override
  String nutGrams(String value) {
    return '$value g';
  }

  @override
  String nutGramsProgress(String current, String total) {
    return '$current / $total g';
  }

  @override
  String nutLiters(String value) {
    return '$value L';
  }

  @override
  String nutMacrosLine(String protein, String fat, String carbs) {
    return 'P $protein · Y $fat · K $carbs';
  }

  @override
  String nutTotalLine(String kcal, String macros) {
    return 'Toplam: $kcal kcal · $macros';
  }

  @override
  String nutPerServing(String kcal, String macros) {
    return 'Porsiyon: $kcal · $macros';
  }

  @override
  String nutWaterAdd(int ml) {
    return '+$ml ml';
  }

  @override
  String get nutWaterUndo => 'Son su kaydını geri al';

  @override
  String get nutTrainingDay => 'Antrenman günü';

  @override
  String get nutAddTitle => 'Yemek ekle';

  @override
  String get nutAddBarcode => 'Barkod';

  @override
  String get nutAddManual => 'Elle';

  @override
  String get nutAddPhoto => 'Fotoğraf';

  @override
  String get nutRecipes => 'Tariflerim';

  @override
  String get nutSearching => 'Aranıyor…';

  @override
  String get nutDiaryEmpty =>
      'Bu gün için kayıt yok. Barkod, elle giriş, fotoğraf veya tarifle yemek ekleyin.';

  @override
  String get nutWithPhoto => 'fotoğraflı';

  @override
  String get nutMealBreakfast => 'Kahvaltı';

  @override
  String get nutMealLunch => 'Öğle';

  @override
  String get nutMealDinner => 'Akşam';

  @override
  String get nutMealSnack => 'Ara öğün';

  @override
  String get nutNewEntry => 'Yeni kayıt';

  @override
  String get nutEditEntry => 'Günlük kaydı';

  @override
  String get nutRecipeLineTitle => 'Tarif satırı';

  @override
  String get nutPhotoSaved => 'Fotoğraf kaydedildi';

  @override
  String get nutPhotoAiLater =>
      'Fotoğraftan yemek tanıma daha sonra açılacak. Şimdilik adı ve besin değerlerini kendiniz girin.';

  @override
  String get nutFieldTitle => 'Ad';

  @override
  String get nutFieldTitleHint => 'Örneğin: muzlu yulaf ezmesi';

  @override
  String get nutFieldMeal => 'Öğün';

  @override
  String get nutFieldMode => 'Hesaplama';

  @override
  String get nutModePortion => 'Porsiyon';

  @override
  String get nutModePer100 => '100 g başına';

  @override
  String get nutFieldGrams => 'Porsiyon ağırlığı';

  @override
  String get nutErrorGrams => 'Ağırlığı gram olarak girin';

  @override
  String get nutValuesPer100 => '100 g başına değerler';

  @override
  String get nutValuesPortion => 'Tüm porsiyon için değerler';

  @override
  String get nutFieldKcal => 'Kalori';

  @override
  String get nutFieldProtein => 'Protein';

  @override
  String get nutFieldFat => 'Yağ';

  @override
  String get nutFieldCarbs => 'Karbonhidrat';

  @override
  String get nutUnitKcal => 'kcal';

  @override
  String get nutUnitG => 'g';

  @override
  String get nutUnitKg => 'kg';

  @override
  String get nutUnitPcs => 'adet';

  @override
  String get nutUnitL => 'L';

  @override
  String get nutUnitMl => 'ml';

  @override
  String get nutSaveToProducts => 'Ürünlerime kaydet';

  @override
  String get nutSaveToProductsHint =>
      'Sonra aramada bulunur, tekrar girmeye gerek kalmaz';

  @override
  String get nutMyProducts => 'Ürünlerim';

  @override
  String get nutSearchHint => 'Ad veya barkoda göre ara';

  @override
  String get nutWithoutProduct => 'Ürünsüz';

  @override
  String get nutNewProduct => 'Yeni ürün';

  @override
  String get nutNoProducts =>
      'Henüz ürün yok. Barkod okutun veya ürünü elle ekleyin.';

  @override
  String get nutPer100Short => '100 g';

  @override
  String get nutProductNameHint => 'Örneğin: sade yoğurt';

  @override
  String get nutFieldBrand => 'Marka';

  @override
  String get nutFieldBarcode => 'Barkod';

  @override
  String get nutFieldServing => 'Normal porsiyon';

  @override
  String get nutBarcodeNotFound =>
      'Ürün Open Food Facts veritabanında yok. Ambalajdaki bilgileri girin — Sistem barkoddan hatırlayacak.';

  @override
  String get nutBarcodeOffline =>
      'Ürün veritabanına bağlanılamadı. Ambalajdaki bilgileri girin — Sistem ürünü barkoddan hatırlayacak.';

  @override
  String get nutScanTitle => 'Barkod';

  @override
  String get nutScanHint => 'Kamerayı ambalajdaki barkoda tutun';

  @override
  String get nutScanNoCamera =>
      'Kamera kullanılamıyor. Ayarlardan kamera erişimine izin verin veya ürünü elle girin.';

  @override
  String get nutPhotoTitle => 'Yemek fotoğrafı';

  @override
  String get nutPhotoMessage =>
      'Yemeğin fotoğrafını çekin veya galeriden seçin. Fotoğraf günlük kaydına eklenecek.';

  @override
  String get nutPhotoCamera => 'Kamera';

  @override
  String get nutPhotoGallery => 'Galeri';

  @override
  String get nutPortions => 'Porsiyon';

  @override
  String get nutAddToDiary => 'Günlüğe ekle';

  @override
  String get nutRecipesEmpty =>
      'Henüz tarif yok. Yemeği bir kez ürünlerden oluşturun — sonra tek dokunuşla ekleyin.';

  @override
  String get nutNewRecipe => 'Yeni tarif';

  @override
  String get nutEditRecipe => 'Tarif';

  @override
  String get nutRecipeTitleHint => 'Örneğin: sebzeli omlet';

  @override
  String get nutServings => 'Yemekteki porsiyon';

  @override
  String get nutIngredients => 'İçindekiler';

  @override
  String get nutIngredientsEmpty => 'En az bir ürün veya satır ekleyin.';

  @override
  String get nutFromProducts => 'Ürünlerden';

  @override
  String get nutManualLine => 'Elle';

  @override
  String get nutShopping => 'Alışveriş listesi';

  @override
  String get nutShopNothing => 'Liste boş — alışveriş eklemek için açın.';

  @override
  String nutShopRemainingCount(int count, String sum) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Alınacak: $count ürün · $sum',
    );
    return '$_temp0';
  }

  @override
  String get nutShopAdd => 'Ürün ekle';

  @override
  String get nutShopEdit => 'Ürün';

  @override
  String get nutShopTotal => 'Toplam (yaklaşık)';

  @override
  String get nutShopRemaining => 'Henüz alınmadı';

  @override
  String get nutShopPriceNote => 'Tutarlar girdiğiniz fiyatlara göredir.';

  @override
  String get nutShopFromPlan => 'Beslenme planından';

  @override
  String get nutShopFromPlanHint =>
      'Plan hedeflerine göre haftalık temel liste: protein, tahıllar, sebze, meyve, su. Fiyatları kendiniz girin.';

  @override
  String get nutShopNoPlan =>
      'Planı kabul edin — Sistem haftalık temel listeyi hazırlasın.';

  @override
  String get nutShopGenerate => 'Haftalık liste oluştur';

  @override
  String get nutShopEmpty => 'Henüz ürün yok.';

  @override
  String get nutShopClearDone => 'Alınanları kaldır';

  @override
  String get nutShopTitleHint => 'Örneğin: karabuğday';

  @override
  String get nutShopQuantity => 'Miktar';

  @override
  String get nutShopPrice => 'Yaklaşık fiyat';

  @override
  String get nutGroceryChicken => 'Tavuk göğsü / hindi';

  @override
  String get nutGroceryEggs => 'Yumurta';

  @override
  String get nutGroceryCottageCheese => 'Lor peyniri';

  @override
  String get nutGroceryGrains => 'Tahıllar (karabuğday, pirinç)';

  @override
  String get nutGroceryOats => 'Yulaf ezmesi';

  @override
  String get nutGroceryVegetables => 'Sebzeler';

  @override
  String get nutGroceryFruits => 'Meyveler';

  @override
  String get nutGroceryOil => 'Bitkisel yağ';

  @override
  String get nutGroceryWater => 'İçme suyu';

  @override
  String get ovlSettingTitle => 'Karakter uygulamaların üzerinde';

  @override
  String get ovlSettingHint =>
      'Sistem arka plandayken karakter ekranın kenarında durur ve mesajları gösterir. Dokunursanız Sistem açılır, basılı tutarsanız gizlenir.';

  @override
  String get ovlPermissionDenied =>
      '“Diğer uygulamaların üzerinde göster” izni gerekli.';

  @override
  String get ovlNotificationTitle => 'Karakter ekranda';

  @override
  String get ovlNotificationBody => 'Sistem\'i açmak için dokunun';

  @override
  String get ovlHideAction => 'Gizle';

  @override
  String ovlAvatarLabel(String name) {
    return '$name: Sistem\'i açmak için dokunun; gizlemek için basılı tutun';
  }

  @override
  String get planNoticeLabel => 'Bildirim';

  @override
  String get planTitle => 'Plan hazırlandı';

  @override
  String get planDraftNote =>
      'Taslak plan — yapay zekâ bağlandıktan sonra Sistem onu netleştirecek.';

  @override
  String planAcceptedAt(String date) {
    return 'Plan kabul edildi: $date';
  }

  @override
  String get planAccept => 'Kabul et';

  @override
  String get planEditData => 'Verileri değiştir';

  @override
  String get planRecalculate => 'Yeniden hesapla';

  @override
  String get planChooseSection => 'Hangi bölüm değiştirilsin?';

  @override
  String get planLoadError => 'Plan hazırlanamadı';

  @override
  String get planRetry => 'Tekrar dene';

  @override
  String get planNormsTitle => 'Normlar';

  @override
  String get planCalories => 'Kalori';

  @override
  String planKcal(String value) {
    return '$value kcal';
  }

  @override
  String get planModeDeficit => 'Kalori açığı';

  @override
  String get planModeSurplus => 'Kalori fazlası';

  @override
  String get planModeMaintenance => 'Kilo koruma';

  @override
  String planBmrTdee(String bmr, String tdee) {
    return 'Bazal metabolizma $bmr · harcama $tdee kcal';
  }

  @override
  String get planProtein => 'Protein';

  @override
  String get planFat => 'Yağ';

  @override
  String get planCarbs => 'Karbonhidrat';

  @override
  String planGrams(String value) {
    return '$value g';
  }

  @override
  String get planWater => 'Su';

  @override
  String planMl(String value) {
    return '$value ml';
  }

  @override
  String planWaterTrainingDay(String value) {
    return 'Antrenman gününde — $value ml';
  }

  @override
  String get planSleep => 'Uyku';

  @override
  String planHours(String value) {
    return '$value sa';
  }

  @override
  String planHoursMinutes(String h, String m) {
    return '$h sa $m dk';
  }

  @override
  String planWakeBed(String wake, String bed) {
    return 'Kalkış $wake · yatış $bed';
  }

  @override
  String get planRoutineTitle => 'Günlük düzen';

  @override
  String planWeek(String n) {
    return 'Hafta $n';
  }

  @override
  String get planWdMon => 'Pzt';

  @override
  String get planWdTue => 'Sal';

  @override
  String get planWdWed => 'Çar';

  @override
  String get planWdThu => 'Per';

  @override
  String get planWdFri => 'Cum';

  @override
  String get planWdSat => 'Cmt';

  @override
  String get planWdSun => 'Paz';

  @override
  String get planRoutineWake => 'Kalkış';

  @override
  String get planRoutineSkincareAm => 'Cilt bakımı (sabah)';

  @override
  String planRoutineMeal(String n) {
    return 'Öğün $n';
  }

  @override
  String get planRoutineLeaveHome => 'Evden çıkış';

  @override
  String get planRoutineLesson => 'Ders';

  @override
  String get planRoutineWork => 'İş';

  @override
  String get planRoutineOther => 'Etkinlik';

  @override
  String get planRoutineReturnHome => 'Evde';

  @override
  String get planRoutineTraining => 'Antrenman';

  @override
  String get planRoutineSkincarePm => 'Cilt bakımı (akşam)';

  @override
  String get planRoutineBed => 'Yatış';

  @override
  String get planQuestsTitle => 'Görevler';

  @override
  String get planQuestsNote =>
      'Görevleri tamamlama bir sonraki güncellemede gelecek.';

  @override
  String planQuestLeaveHome(String time) {
    return '$time saatine kadar evden çık';
  }

  @override
  String planQuestAttendLesson(String title) {
    return 'Ders: $title';
  }

  @override
  String planQuestAttendWork(String title) {
    return 'İş: $title';
  }

  @override
  String planQuestWater(String ml) {
    return '$ml ml su iç';
  }

  @override
  String planQuestSleep(String time, String hours) {
    return '$time saatinde yat (uyku $hours sa)';
  }

  @override
  String planQuestMeals(String count) {
    return 'Plana göre öğünler: $count';
  }

  @override
  String planQuestTraining(String minutes) {
    return '$minutes dk antrenman';
  }

  @override
  String get planQuestSkincareMorning => 'Sabah cilt bakımı';

  @override
  String get planQuestSkincareEvening => 'Akşam cilt bakımı';

  @override
  String planQuestWakeOnTime(String time) {
    return '$time saatinde ertelemeden kalk';
  }

  @override
  String planQuestStudy(String minutes) {
    return '$minutes dk ders çalış';
  }

  @override
  String get planQuestTrackExpenses => 'Günün harcamalarını kaydet';

  @override
  String get planQuestEveryDay => 'her gün';

  @override
  String planQuestWeekOnly(String n) {
    return 'hafta $n';
  }

  @override
  String planQuestReward(String diamonds, String xp) {
    return '+$diamonds ◆ · +$xp deneyim';
  }

  @override
  String get planWarningsTitle => 'Uyarılar';

  @override
  String planWarnSleepShort(String scheduled, String target, String bed) {
    return 'Programa göre uyku $scheduled — norm olan $target süresinden az. Önerilen yatış saati: $bed.';
  }

  @override
  String get planWarnDeficitFloor =>
      'Kalori açığı güvenli alt sınırla kısıtlandı — Sistem bunun altına inmez.';

  @override
  String get planWarnActivityDefaulted =>
      'Aktivite düzeyi belirtilmedi — “hareketsiz” kabul edildi.';

  @override
  String planWarnNoTrainingWindow(String day) {
    return '$day: antrenman için boş zaman yok.';
  }

  @override
  String get planWarnInjuries =>
      'Sakatlık veya kısıtlamalar belirtildi — yükü dikkatli seçin, emin değilseniz doktora danışın.';

  @override
  String planMissingMessage(String fields) {
    return 'Kalori ve makroları hesaplamak için doldurun: $fields.';
  }

  @override
  String get planMissingSex => 'cinsiyet';

  @override
  String get planMissingBirthDate => 'doğum tarihi';

  @override
  String get planMissingHeight => 'boy';

  @override
  String get planMissingWeight => 'kilo';

  @override
  String planFillSection(String section) {
    return 'Doldur: $section';
  }

  @override
  String get wrkTitle => 'Antrenmanlar';

  @override
  String get wrkProgram => 'Program';

  @override
  String get wrkToday => 'Bugün';

  @override
  String wrkTodayDay(String key) {
    return 'Programa göre — $key günü';
  }

  @override
  String get wrkRestDay =>
      'Bugün programa göre dinlenme günü. Aşağıdaki listeden istediğiniz antrenmanı yapabilirsiniz.';

  @override
  String wrkDayTitle(String key) {
    return '$key günü';
  }

  @override
  String wrkMinutesShort(int minutes) {
    return '$minutes dk';
  }

  @override
  String wrkEstimate(int minutes) {
    return '≈$minutes dk';
  }

  @override
  String wrkExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count egzersiz',
    );
    return '$_temp0';
  }

  @override
  String wrkSetsReps(int sets, int reps) {
    return '$sets × $reps';
  }

  @override
  String wrkSetsSeconds(int sets, int seconds) {
    return '$sets × $seconds sn';
  }

  @override
  String wrkRestShort(int seconds) {
    return 'dinlenme $seconds sn';
  }

  @override
  String get wrkGentle =>
      'Hafif seçenek: zıplama ve omurgaya dikey yük yok — ankette sakatlık veya kısıtlama belirtilmiş.';

  @override
  String get wrkSafetyNote =>
      'Bir egzersiz ağrı veya rahatsızlık veriyorsa onu atlayın.';

  @override
  String get wrkLevelUnknown =>
      'Ankette seviye belirtilmemiş — başlangıç programı.';

  @override
  String wrkProgressionWeeks(int weeks) {
    return 'Tamamlanan hafta: $weeks';
  }

  @override
  String get wrkProgressionNote =>
      'Haftanın tüm antrenmanları (en fazla 3) yapılırsa hafta sayılır. Her biri için: +1 tekrar veya +5 sn, seviyenizin üst sınırına kadar.';

  @override
  String get wrkRegenerate => 'Programı yeniden oluştur';

  @override
  String get wrkRegenerateTitle => 'Program yeniden oluşturulsun mu?';

  @override
  String get wrkRegenerateText =>
      'Program anket ve plana göre yeniden oluşturulacak. Antrenman geçmişi korunur, ilerleme baştan başlar.';

  @override
  String get wrkAiProgram => 'Yapay zekâdan program';

  @override
  String get wrkSoon => 'yakında';

  @override
  String get wrkStart => 'Antrenmana başla';

  @override
  String wrkStartDay(String key) {
    return '$key gününe başla';
  }

  @override
  String get wrkHistory => 'Geçmiş';

  @override
  String get wrkHistoryEmpty => 'Henüz antrenman yok.';

  @override
  String get wrkSessionDone => 'tamamlandı';

  @override
  String get wrkSessionInterrupted => 'yarıda kaldı';

  @override
  String wrkSessionStats(int minutes, int kcal) {
    return '$minutes dk · ≈$kcal kcal';
  }

  @override
  String get wrkPreparing => 'Program hazırlanıyor…';

  @override
  String get wrkPhasePrepare => 'Hazırlanın';

  @override
  String get wrkPhaseWork => 'Çalışma';

  @override
  String get wrkPhaseRest => 'Dinlenme';

  @override
  String get wrkPaused => 'Duraklatıldı';

  @override
  String wrkSetOf(int set, int sets) {
    return 'Set $set / $sets';
  }

  @override
  String wrkRepsTarget(int reps) {
    String _temp0 = intl.Intl.pluralLogic(
      reps,
      locale: localeName,
      other: '$reps tekrar',
    );
    return '$_temp0';
  }

  @override
  String get wrkDoneSet => 'Set tamam';

  @override
  String get wrkPause => 'Duraklat';

  @override
  String get wrkResume => 'Devam et';

  @override
  String get wrkSkipRest => 'Dinlenmeyi atla';

  @override
  String get wrkSkipExercise => 'Egzersizi atla';

  @override
  String get wrkStop => 'Sonlandır';

  @override
  String wrkNext(String name) {
    return 'Sıradaki: $name';
  }

  @override
  String get wrkLastExercise => 'Son egzersiz';

  @override
  String get wrkTechnique => 'Teknik';

  @override
  String get wrkVoice => 'Sesli yönlendirme';

  @override
  String get wrkProgressLabel => 'Antrenman ilerlemesi';

  @override
  String get wrkStopTitle => 'Antrenman sonlandırılsın mı?';

  @override
  String get wrkStopText =>
      'Yapılanlar yarım kalan antrenman olarak kaydedilir.';

  @override
  String get wrkFinishedTitle => 'Antrenman tamamlandı';

  @override
  String wrkFinishedStats(int minutes, int kcal, int sets) {
    return 'Süre: $minutes dk · ≈$kcal kcal · set: $sets';
  }

  @override
  String get wrkWeightAssumed =>
      'Harcama 70 kg kiloya göre tahmin: kilo ölçümü yok.';

  @override
  String get wrkKcalNote => 'Harcama MET ile tahmindir, ölçüm değildir.';

  @override
  String wrkSayPrepare(String name) {
    return 'Hazırlan. $name.';
  }

  @override
  String wrkSaySet(int set, int sets, String amount) {
    return 'Set $set / $sets. $amount. Başlıyoruz!';
  }

  @override
  String wrkSecondsAmount(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds saniye',
    );
    return '$_temp0';
  }

  @override
  String wrkSayRest(String amount) {
    return 'Dinlenme: $amount.';
  }

  @override
  String wrkSayNext(String name) {
    return 'Sıradaki: $name.';
  }

  @override
  String get wrkSayFinished => 'Antrenman tamamlandı. Harika iş!';

  @override
  String get wrkExMarchInPlace => 'Yerinde yürüyüş';

  @override
  String get wrkExMarchInPlaceHint =>
      'Dizlerinizi yükseğe kaldırın.\nKollar adımla birlikte çalışsın.\nDüzenli nefes alın.';

  @override
  String get wrkExArmCircles => 'Kol çevirme';

  @override
  String get wrkExArmCirclesHint =>
      'Kollar omuz hizasında yanlara.\nÖnce ileri, sonra geri küçük daireler çizin.\nOmuzlar aşağıda.';

  @override
  String get wrkExJumpingJacks => 'Jumping jack';

  @override
  String get wrkExJumpingJacksHint =>
      'Zıplayın: bacaklar açık, kollar yukarı.\nGeri zıplayın.\nParmak uçlarına yumuşak inin.';

  @override
  String get wrkExChairSquat => 'Sandalyeye çömelme';

  @override
  String get wrkExChairSquatHint =>
      'Sandalyenin önünde durun, ayaklar omuz genişliğinde.\nKalçayı geri iterek oturun.\nSarsmadan kalkın.';

  @override
  String get wrkExGluteBridge => 'Kalça köprüsü';

  @override
  String get wrkExGluteBridgeHint =>
      'Sırtüstü yatın, ayaklar yerde.\nKalçayı kaldırın, kalça kaslarını sıkın.\nYavaşça inin.';

  @override
  String get wrkExSquat => 'Squat';

  @override
  String get wrkExSquatHint =>
      'Ayaklar omuz genişliğinde, uçlar hafif dışa.\nKalça geri, dizler parmak yönünde.\nSırt düz, topuklar yerde.';

  @override
  String get wrkExWallSit => 'Duvarda oturma';

  @override
  String get wrkExWallSitHint =>
      'Sırt duvara yaslı.\nUyluklar yere neredeyse paralel olana kadar inin.\nPozisyonu koruyun.';

  @override
  String get wrkExReverseLunge => 'Geri lunge';

  @override
  String get wrkExReverseLungeHint =>
      'Geriye adım atın, arka dizi yere doğru indirin.\nÖn diz ayağın üzerinde.\nGeri dönün, bacak değiştirin.';

  @override
  String get wrkExGobletSquat => 'Goblet squat';

  @override
  String get wrkExGobletSquatHint =>
      'Dambılı dik olarak göğsünüzde tutun.\nÇömelin, dirsekler dizlerin arasında.\nSırt düz.';

  @override
  String get wrkExKettlebellSwing => 'Kettlebell salınımı';

  @override
  String get wrkExKettlebellSwingHint =>
      'Kettlebell iki elde, ayaklar omuzdan geniş.\nKalça geri, sonra hızla ileri.\nKettlebell kalça gücüyle göğüs hizasına çıkar.';

  @override
  String get wrkExJumpSquat => 'Zıplamalı squat';

  @override
  String get wrkExJumpSquatHint =>
      'Normal squat.\nYukarı sıçrayın.\nYumuşak inip doğrudan squat pozisyonuna geçin.';

  @override
  String get wrkExWallPushUp => 'Duvarda şınav';

  @override
  String get wrkExWallPushUpHint =>
      'Avuçlar omuz hizasında duvarda.\nKolları bükün, gövde düz.\nİterek geri gelin.';

  @override
  String get wrkExKneePushUp => 'Dizüstü şınav';

  @override
  String get wrkExKneePushUpHint =>
      'Dizler ve avuçlar yerde.\nDizden başa gövde düz.\nGöğüs yere, sonra yukarı.';

  @override
  String get wrkExPushUp => 'Şınav';

  @override
  String get wrkExPushUpHint =>
      'Şınav pozisyonu, eller omuzdan biraz geniş.\nGövde düz bir çizgi.\nGöğüs yere, dirsekler 45°.';

  @override
  String get wrkExDumbbellPress => 'Yerde dambıl pres';

  @override
  String get wrkExDumbbellPressHint =>
      'Yere yatın, dambıllar göğüs üstünde.\nDirsekler yere değene kadar indirin.\nYukarı itin.';

  @override
  String get wrkExDiamondPushUp => 'Elmas şınav';

  @override
  String get wrkExDiamondPushUpHint =>
      'Avuçlar göğsün altında yan yana.\nDirsekler gövdeye yakın.\nGövde düz.';

  @override
  String get wrkExSuperman => 'Süperman';

  @override
  String get wrkExSupermanHint =>
      'Yüzüstü yatın, kollar önde.\nKol ve bacakları birkaç saniye kaldırın.\nYavaşça indirin.';

  @override
  String get wrkExReverseSnowAngel => 'Ters kar meleği';

  @override
  String get wrkExReverseSnowAngelHint =>
      'Yüzüstü yatın, kollar yanlarda.\nGöğsü ve kolları hafifçe kaldırın.\nKolları yay çizerek başın üstüne ve geri götürün.';

  @override
  String get wrkExBandRow => 'Direnç bandı çekişi';

  @override
  String get wrkExBandRowHint =>
      'Bandı göğüs hizasına sabitleyin.\nKürek kemiklerini sıkarak bele çekin.\nYavaşça bırakın.';

  @override
  String get wrkExDumbbellRow => 'Eğilerek dambıl çekiş';

  @override
  String get wrkExDumbbellRowHint =>
      'Bir el ve diz sandalyeye dayalı.\nDambılı bele çekin.\nSırt düz.';

  @override
  String get wrkExPullUp => 'Barfiks';

  @override
  String get wrkExPullUpHint =>
      'Tutuş omuzdan biraz geniş.\nÇeneyi bara kadar çekin.\nKontrollü inin.';

  @override
  String get wrkExDeadBug => 'Ölü böcek';

  @override
  String get wrkExDeadBugHint =>
      'Sırtüstü, kollar yukarı, dizler kalça üstünde.\nZıt kol ve bacağı indirin.\nBel yere bastırılı.';

  @override
  String get wrkExBirdDog => 'Kuş-köpek';

  @override
  String get wrkExBirdDogHint =>
      'Eller ve dizler yerde.\nZıt kol ve bacağı uzatın.\nBekleyin, taraf değiştirin.';

  @override
  String get wrkExPlank => 'Plank';

  @override
  String get wrkExPlankHint =>
      'Ön kollar ve ayak uçları yerde.\nGövde düz, karın sıkı.\nBelden çökmeyin.';

  @override
  String get wrkExCrunch => 'Mekik';

  @override
  String get wrkExCrunchHint =>
      'Sırtüstü, dizler bükük.\nOmuzları dizlere doğru kaldırın.\nYavaşça inin.';

  @override
  String get wrkExSidePlank => 'Yan plank';

  @override
  String get wrkExSidePlankHint =>
      'Ön kol yerde, bacaklar birlikte.\nKalça yukarıda, gövde düz.\nSürenin yarısı her tarafa.';

  @override
  String get wrkExLegRaise => 'Bacak kaldırma';

  @override
  String get wrkExLegRaiseHint =>
      'Sırtüstü, kollar yanlarda.\nDüz bacakları yukarı kaldırın.\nBel yerde, yavaşça indirin.';

  @override
  String get wrkExStepTouch => 'Yana adım';

  @override
  String get wrkExStepTouchHint =>
      'Yana adım atın, ayağı birleştirin.\nDiğer tarafa.\nKollar ritimle çalışsın.';

  @override
  String get wrkExShadowBoxing => 'Gölge boksu';

  @override
  String get wrkExShadowBoxingHint =>
      'Duruş, yumruklar çenede.\nSırayla hafif yumruklar.\nZıplamadan parmak uçlarında hareket edin.';

  @override
  String get wrkExHighKnees => 'Yüksek diz koşusu';

  @override
  String get wrkExHighKneesHint =>
      'Yerinde koşun.\nDizler bel hizasına.\nParmak uçlarına inin.';

  @override
  String get wrkExMountainClimber => 'Dağcı';

  @override
  String get wrkExMountainClimberHint =>
      'Düz kollarla şınav pozisyonu.\nDizleri sırayla göğse çekin.\nKalçayı kaldırmayın.';

  @override
  String get wrkExBurpee => 'Burpee';

  @override
  String get wrkExBurpeeHint =>
      'Çömelin, eller yere.\nŞınav pozisyonuna sıçrayın ve geri gelin.\nYukarı zıplayın.';

  @override
  String get wrkExFullBodyStretch => 'Esneme';

  @override
  String get wrkExFullBodyStretchHint =>
      'Yukarı uzanın, sonra öne eğilin.\nUyluk ve göğsü esnetin.\nYavaş nefes alın, sarsmayın.';

  @override
  String get qaUnitCm => 'cm';

  @override
  String get qaUnitKg => 'kg';

  @override
  String qaRangeHint(int min, int max) {
    return '$min ile $max arasında olmalı';
  }

  @override
  String get qaProfileIntro =>
      'Sistem size nasıl hitap edeceğini ve nerede olduğunuzu bilmeli.';

  @override
  String get qaProfileName => 'Ad';

  @override
  String get qaProfileNameHint => 'Size nasıl hitap edelim';

  @override
  String get qaProfileLanguage => 'Dil';

  @override
  String get qaLangRu => 'Русский';

  @override
  String get qaLangTr => 'Türkçe';

  @override
  String get qaLangSystem => 'Sistem dili';

  @override
  String get qaProfileSex => 'Cinsiyet';

  @override
  String get qaSexMale => 'Erkek';

  @override
  String get qaSexFemale => 'Kadın';

  @override
  String get qaProfileBirthDate => 'Doğum tarihi';

  @override
  String get qaProfileTimezone => 'Saat dilimi';

  @override
  String get qaProfileTimezoneHint => 'Cihazdan belirlendi — kontrol edin';

  @override
  String get qaProfileCity => 'Şehir';

  @override
  String get qaProfileCityHint => 'Hava durumu ve yakındaki mağazalar için';

  @override
  String get qaBodyIntro =>
      'Vücudunuzun başlangıç ölçüleri. Sistem bunlara göre kalori ve su ihtiyacını hesaplar.';

  @override
  String get qaBodyHeight => 'Boy';

  @override
  String get qaBodyWeight => 'Kilo';

  @override
  String get qaBodyGirths => 'Çevre ölçüleri';

  @override
  String get qaBodyGirthsHint =>
      'Sabah, kıyafetsiz, mezura ile ölçün. Atlayabilirsiniz.';

  @override
  String get qaBodyWaist => 'Bel';

  @override
  String get qaBodyHips => 'Kalça';

  @override
  String get qaBodyChest => 'Göğüs';

  @override
  String get qaBodyNeck => 'Boyun';

  @override
  String get qaBodyArm => 'Kol (pazı)';

  @override
  String get qaBodyActivity => 'Aktivite düzeyi';

  @override
  String get qaActivitySedentary => 'Çok düşük';

  @override
  String get qaActivitySedentaryHint => 'Günün çoğu oturarak, antrenman yok';

  @override
  String get qaActivityLight => 'Düşük';

  @override
  String get qaActivityLightHint =>
      'Haftada 1–3 kez hafif antrenman veya yürüyüş';

  @override
  String get qaActivityModerate => 'Orta';

  @override
  String get qaActivityModerateHint => 'Haftada 3–5 kez antrenman';

  @override
  String get qaActivityActive => 'Yüksek';

  @override
  String get qaActivityActiveHint => 'Haftada 6–7 kez yoğun antrenman';

  @override
  String get qaActivityVeryActive => 'Çok yüksek';

  @override
  String get qaActivityVeryActiveHint =>
      'Ağır fiziksel iş veya günde iki antrenman';

  @override
  String get qaBodyWorkload => 'Okulda / işte yük';

  @override
  String get qaBodyWorkloadHint => 'Günün büyük kısmını nasıl geçiriyorsunuz';

  @override
  String get qaWorkloadSitting => 'Oturarak';

  @override
  String get qaWorkloadMixed => 'Karışık';

  @override
  String get qaWorkloadStanding => 'Ayakta';

  @override
  String get qaWorkloadPhysical => 'Bedensel iş';

  @override
  String get qaBodyPhotosIntro =>
      'Fotoğraflar, Sistem\'in vücut yapısını ve duruşu değerlendirmesine ve ilerlemeyi takip etmesine yardımcı olur. Bu aşama atlanabilir. Fotoğraflar cihazda saklanır.';

  @override
  String get qaPhotoTipsTitle => 'Nasıl çekilir';

  @override
  String get qaBodyTipLight =>
      'Önden eşit ışık; arkanızda parlak pencere olmasın.';

  @override
  String get qaBodyTipClothes => 'Dar kıyafet veya iç çamaşırı, saçlar toplu.';

  @override
  String get qaBodyTipPose =>
      'Dik durun, kollar hafifçe açık, ileri bakın. Vücut çerçevenin içinde olsun.';

  @override
  String get qaBodyTipCamera =>
      'Kamera bel hizasında, yaklaşık 2 metre uzakta. Tripod veya bir yardımcıyla daha kolay.';

  @override
  String get qaPoseBodyFront => 'Önden';

  @override
  String get qaPoseBodyFrontHint =>
      'Kameraya dönün, kollar hafifçe yanlarda, ayaklar omuz genişliğinde.';

  @override
  String get qaPoseBodySide => 'Yandan';

  @override
  String get qaPoseBodySideHint =>
      'Sağ yanınızı kameraya dönün, kollar yanda, ileriye bakın.';

  @override
  String get qaPoseBodyBack => 'Arkadan';

  @override
  String get qaPoseBodyBackHint =>
      'Sırtınızı kameraya dönün, kollar hafifçe yanlarda.';

  @override
  String get qaPhotoTap => 'Çekmek için dokunun';

  @override
  String get qaPhotoTaken => 'Çekildi';

  @override
  String get qaPhotoNotTaken => 'Fotoğraf yok';

  @override
  String get qaPhotoRetakeHint => 'Çekildi · yeniden çekmek için dokunun';

  @override
  String get qaEstimateTitle => 'Değerlendirme';

  @override
  String get qaEstBodyFat => 'Yağ %';

  @override
  String get qaEstMuscle => 'Kas kütlesi';

  @override
  String get qaEstPosture => 'Duruş';

  @override
  String get qaEstFigure => 'Vücut tipi';

  @override
  String get qaEstFaceSwelling => 'Yüz ödemi';

  @override
  String get qaExactTitle => 'Kesin değerleri biliyorum';

  @override
  String get qaExactHint =>
      'Akıllı tartıdan veya doktordan verileriniz varsa girin; Sistem bunları esas alır.';

  @override
  String get qaExactFat => 'Yağ %';

  @override
  String get qaExactMuscle => 'Kas kütlesi';

  @override
  String get qaCameraWarningLabel => 'Uyarı';

  @override
  String get qaCameraUnavailable =>
      'Bu cihazda kamera kullanılamıyor. Bu aşamayı atlayıp daha sonra ayarlardan dönebilirsiniz.';

  @override
  String get qaCameraUnavailableInline =>
      'Kamera kullanılamıyor — fotoğrafları daha sonra ayarlardan çekebilirsiniz. Diğer alanlar çalışır.';

  @override
  String get qaCameraDenied =>
      'Kamera erişimi yok. Ayarlardan izin verin, sonra buraya dönün.';

  @override
  String get qaCameraOpenSettings => 'Ayarları aç';

  @override
  String get qaCameraRetake => 'Yeniden çek';

  @override
  String get qaCameraShutter => 'Fotoğraf çek';

  @override
  String get qaCameraSwitch => 'Kamerayı değiştir';

  @override
  String get qaSkinIntro =>
      'Yüz fotoğrafları ve birkaç soru, Sistem\'in bakım rutini seçmesine yardımcı olur. Fotoğraflar isteğe bağlıdır.';

  @override
  String get qaSkinTipLight => 'Pencere yanında gün ışığı; filtre ve flaş yok.';

  @override
  String get qaSkinTipClean => 'Makyajsız ve kremsiz temiz yüz.';

  @override
  String get qaSkinTipHair => 'Saçları alından ve yanaklardan çekin.';

  @override
  String get qaSkinFacePhotos => 'Yüz fotoğrafları';

  @override
  String get qaPoseFaceFront => 'Önden';

  @override
  String get qaPoseFaceFrontHint =>
      'Doğrudan kameraya bakın, yüzünüz ovalin içinde olsun.';

  @override
  String get qaPoseFaceLeft => 'Sol profil';

  @override
  String get qaPoseFaceLeftHint =>
      'Kameraya SOL yanağınız bakacak şekilde dönün.';

  @override
  String get qaPoseFaceRight => 'Sağ profil';

  @override
  String get qaPoseFaceRightHint =>
      'Kameraya SAĞ yanağınız bakacak şekilde dönün.';

  @override
  String get qaSkinCloseups => 'Sorunlu bölgeler yakından';

  @override
  String get qaSkinCloseupsHint => 'Birden fazla çekebilirsiniz';

  @override
  String get qaPoseCloseup => 'Yakın çekim';

  @override
  String get qaPoseCloseupHint =>
      'Kamerayı bölgeye yaklaştırın, odaklanmasını bekleyin.';

  @override
  String get qaSkinAddCloseup => 'Ekle';

  @override
  String get qaShootTitleBody => 'Fotoğraf seansı: vücut';

  @override
  String get qaShootTitleFace => 'Fotoğraf seansı: yüz';

  @override
  String get qaShootCardBody => 'Fotoğraf seansı: vücut (3 açı)';

  @override
  String get qaShootCardFace => 'Fotoğraf seansı: yüz (3 açı)';

  @override
  String get qaShootCardHint =>
      'Telefonu yerleştirip “Başla”ya dokunun — gerisini Sistem sesli anlatır ve fotoğrafları kendisi çeker.';

  @override
  String get qaShootStartSession => 'Seansı başlat';

  @override
  String get qaShootRestartSession => 'Seansı yeniden yap';

  @override
  String get qaShootCloseupButton => 'Sorunlu bölgenin yakın çekimi';

  @override
  String get qaShootAiNoteBody =>
      'Çekimden sonra yapay zekâ boyunuzu dikkate alarak vücut ölçülerini ve kompozisyonunu tahmin edip size yazacak.';

  @override
  String get qaShootAiNoteSkin =>
      'Çekimden sonra yapay zekâ cilt tipinizi ve sivilcelerin yoğunluğunu tahmin edip size yazacak.';

  @override
  String get qaShootPrepTitle => 'Hazırlık';

  @override
  String get qaShootPrepPhoneBody =>
      'Telefonu bel hizasında dikey koyun: duvara, kitap yığınına dayayın ya da tripoda takın. Ekran size dönük.';

  @override
  String get qaShootPrepDistanceBody =>
      'Yaklaşık 2 metre uzakta duracaksınız. Vücudunuz çerçeveyle örtüşene kadar yaklaşın veya uzaklaşın.';

  @override
  String get qaShootPrepPhoneFace =>
      'Telefonu göz hizasında, yüzünüzden yaklaşık 50 cm uzağa dikey koyun.';

  @override
  String get qaShootPrepLight =>
      'Işık: yüzünüz pencereye veya lambaya dönük olsun. Arkanızda parlak pencere olmamalı.';

  @override
  String get qaShootPrepSound =>
      'Sesi açın: Sistem nerede durmanız gerektiğini söyleyecek ve çekime kadar sayacak. Hiçbir şeye basmanız gerekmez.';

  @override
  String get qaShootDelay => 'Geri sayım süresi';

  @override
  String qaShootDelaySec(int n) {
    return '$n sn';
  }

  @override
  String get qaShootDelayManual => 'Düğmeyle';

  @override
  String get qaShootOperator => 'Başka biri çekiyor';

  @override
  String get qaShootOperatorHint =>
      'Arka kamera. Geri sayımı kapatıp düğmeyle çekebilirsiniz.';

  @override
  String get qaShootStart => 'Başla';

  @override
  String get qaShootPause => 'Duraklat';

  @override
  String get qaShootResume => 'Devam et';

  @override
  String get qaShootPausedTitle => 'Seans duraklatıldı';

  @override
  String get qaShootPausedHint => 'Geçerli açı baştan başlayacak.';

  @override
  String get qaShootStop => 'Sonlandır';

  @override
  String qaShootShotOf(int n, int total) {
    return 'Açı $n / $total';
  }

  @override
  String get qaShootWaitShutter => 'Kişi çerçeveye girdiğinde düğmeye basın.';

  @override
  String get qaShootRetry => 'Tekrarla';

  @override
  String get qaShootReviewTitle => 'Fotoğrafları kontrol edin';

  @override
  String get qaShootReviewHint =>
      'Bir açı olmadıysa yalnızca onu yeniden çekin.';

  @override
  String get qaShootSaveFailed => 'Fotoğraflar kaydedilemedi. Tekrar deneyin.';

  @override
  String get qaShootSayBodyFront =>
      'Yaklaşık 2 metre uzaklaş, yüzün kameraya dönük olsun. Çerçeveyle örtüşene kadar yaklaş veya geri çekil. Kollar hafif yanlara.';

  @override
  String get qaShootSayBodySide =>
      'Sağ yanını kameraya dön. Kollar yanda, ileriye bak.';

  @override
  String get qaShootSayBodyBack =>
      'Sırtını kameraya dön. Kollar hafif yanlara.';

  @override
  String get qaShootSayFaceFront =>
      'Telefondan yaklaşık 50 santimetre uzağa otur. Doğrudan kameraya bak, yüzün ovalin içinde olsun.';

  @override
  String get qaShootSayFaceLeft =>
      'Kameraya sol yanağın bakacak şekilde dön. Başın ovalin içinde, dik tut.';

  @override
  String get qaShootSayFaceRight =>
      'Şimdi kameraya sağ yanağın bakacak şekilde dön. Başın ovalin içinde.';

  @override
  String qaShootTaken(String next) {
    return 'Fotoğraf çekildi. Sıradaki: $next.';
  }

  @override
  String get qaShootTakenLast => 'Fotoğraf çekildi. Çekim tamamlandı.';

  @override
  String get qaShootFailed => 'Fotoğraf çekilemedi. Tekrar dene.';

  @override
  String get qaBodyGirthsOptionalTitle => 'Çevre ölçüleri — biliyorsanız';

  @override
  String get qaBodyGirthsOptionalHint =>
      'İsteğe bağlı. Bilmiyorsanız Sistem bunları boyunuzu dikkate alarak fotoğraftan yaklaşık tahmin edip size bildirir.';

  @override
  String get qaBodyGirthsHowTitle => 'Nasıl ölçülür';

  @override
  String get qaBodyGirthsHowGeneral =>
      'Mezura yere paralel, tene oturuyor ama sıkmıyor. Sabah, rahat bir nefes verişte.';

  @override
  String get qaBodyWaistHow =>
      'Bel — en ince yerden, genellikle göbeğin biraz üstünden.';

  @override
  String get qaBodyHipsHow =>
      'Kalça — kalçanın en çıkıntılı noktalarından, ayaklar bitişik.';

  @override
  String get qaBodyChestHow =>
      'Göğüs — en çıkıntılı noktalardan, mezura koltuk altlarından geçer.';

  @override
  String get qaBodyNeckHow => 'Boyun — hemen gırtlak çıkıntısının altından.';

  @override
  String get qaBodyArmHow => 'Kol — üst kolun en geniş yerinden, kol gevşek.';

  @override
  String get qaSkinOily => 'Öğlene kadar yağlanma';

  @override
  String get qaSkinOilyNo => 'Yok';

  @override
  String get qaSkinOilyTzone => 'T bölgesi';

  @override
  String get qaSkinOilyAll => 'Tüm yüz';

  @override
  String get qaSkinTightness => 'Yıkadıktan sonra gerginlik';

  @override
  String get qaSkinTightNever => 'Hiç';

  @override
  String get qaSkinTightSometimes => 'Bazen';

  @override
  String get qaSkinTightOften => 'Sık';

  @override
  String get qaSkinReactions => 'Ürünlere tepkiler';

  @override
  String get qaSkinReactionsHint =>
      'Kızarıklık, kaşıntı veya sivilceye ne yol açtı';

  @override
  String get qaSkinRoutine => 'Mevcut bakım';

  @override
  String get qaSkinRoutineHint =>
      'Yüzünüzü neyle yıkıyorsunuz, hangi ürünleri kullanıyorsunuz';

  @override
  String get qaEstSkinType => 'Cilt tipi';

  @override
  String get qaEstAcne => 'Akne';

  @override
  String get qaEstBlackheads => 'Siyah noktalar';

  @override
  String get qaEstPostAcne => 'Akne izleri';

  @override
  String get qaSkinDermTitle => 'Öneri';

  @override
  String get qaSkinDermAdvice =>
      'Belirgin iltihaplanma, ağrılı sivilceler veya izler varsa bir dermatoloğa görünün. Sistem bakım önerir ama doktorun yerini tutmaz.';

  @override
  String get qaHealthIntro =>
      'Hepsi isteğe bağlı. Yanıtlar planın güvenli olması için gerekli.';

  @override
  String get qaHealthChronic => 'Kronik durumlar';

  @override
  String get qaHealthChronicHint => 'Örneğin: gastrit, astım';

  @override
  String get qaHealthMedications => 'İlaçlar';

  @override
  String get qaHealthMedicationsHint => 'Düzenli kullandıklarınız';

  @override
  String get qaHealthAllergies => 'Alerjiler';

  @override
  String get qaHealthAllergiesHint => 'Besinler, ilaçlar, ürünler';

  @override
  String get qaHealthIntolerances => 'İntoleranslar';

  @override
  String get qaHealthIntolerancesHint => 'Örneğin: laktoz, gluten';

  @override
  String get qaHealthInjuries => 'Sakatlıklar ve kısıtlamalar';

  @override
  String get qaHealthInjuriesHint =>
      'Antrenmanda yapamadığınız veya zorlandığınız şeyler';

  @override
  String get qaHealthSleep => 'Uyku kalitesi';

  @override
  String get qaHealthSleepHint => '1 — çok kötü, 5 — mükemmel';

  @override
  String get qaHealthStress => 'Stres düzeyi';

  @override
  String get qaHealthStressHint => '1 — neredeyse yok, 5 — çok yüksek';

  @override
  String get qaGoalsIntro =>
      'Neye ulaşmak istiyorsunuz? Sistem görevleri bu hedeflerin etrafında kuracak.';

  @override
  String get qaGoalsPick => 'Hedefler';

  @override
  String get qaGoalsPickHint => 'Birden fazla seçebilirsiniz';

  @override
  String get qaGoalAcne => 'Sivilcelerden kurtulmak';

  @override
  String get qaGoalBlackheads => 'Siyah noktaları gidermek';

  @override
  String get qaGoalSwelling => 'Ödemi azaltmak';

  @override
  String get qaGoalWeightLoss => 'Fazla kilo vermek';

  @override
  String get qaGoalMuscle => 'Kas kazanmak';

  @override
  String get qaGoalDiscipline => 'Disiplin';

  @override
  String get qaGoalStudy => 'Eğitim';

  @override
  String get qaGoalMoney => 'Para';

  @override
  String get qaGoalCustom => 'Kendi hedefim';

  @override
  String get qaGoalsOwn => 'Kendi hedefleriniz';

  @override
  String get qaGoalsOwnHint => 'Örneğin: Rusça öğrenmek';

  @override
  String get qaGoalsEmpty => 'En az bir hedef seçin';

  @override
  String get qaGoalPriority => 'Öncelik';

  @override
  String get qaGoalPriorityHigh => 'Yüksek';

  @override
  String get qaGoalPriorityMedium => 'Orta';

  @override
  String get qaGoalPriorityLow => 'Düşük';

  @override
  String get qaGoalDeadline => 'Son tarih';

  @override
  String get qaGoalDeadlineClear => 'Tarihi kaldır';

  @override
  String get qaTzCityHint => 'Saat dilimi şehre göre ayarlanır';

  @override
  String qaTzFromCity(String city) {
    return 'Şehre göre belirlendi: $city';
  }

  @override
  String get qaTzFromDevice => 'Telefonun geçerli saat dilimi';

  @override
  String get qaTzDeviceBadge => 'şu an telefonda';

  @override
  String get qbScheduleIntro =>
      'Sistem gününü okul, iş ve uyku etrafında kuracak. Dersleri, yolu, kalkış ve yatış saatini girin.';

  @override
  String get qbNutritionIntro =>
      'Bu bilgiler kalori hedefleri, menü ve alışveriş listesi için gerekli.';

  @override
  String get qbMealsPerDay => 'Günlük öğün sayısı';

  @override
  String get qbPreferences => 'Tercihler';

  @override
  String get qbPreferencesHint => 'Neyi sevdiğiniz, mutfak, beslenme düzeni';

  @override
  String get qbExcluded => 'Yemedikleriniz';

  @override
  String get qbExcludedHint => 'Menüden çıkarılacak ürünler';

  @override
  String get qbFoodBudget => 'Yemek bütçesi';

  @override
  String get qbRubPerWeek => '₽/hafta';

  @override
  String get qbCanCook => 'Yemek yapabiliyor musunuz?';

  @override
  String get qbCookNo => 'Hayır';

  @override
  String get qbCookBasic => 'Basit';

  @override
  String get qbCookGood => 'İyi';

  @override
  String get qbStores => 'Alışverişi nereden yapıyorsunuz';

  @override
  String get qbStoresHint => 'Birden fazla seçilebilir';

  @override
  String get qbStorePyaterochka => 'Pyaterochka';

  @override
  String get qbStoreMagnit => 'Magnit';

  @override
  String get qbStorePerekrestok => 'Perekrestok';

  @override
  String get qbStoreVkusvill => 'VkusVill';

  @override
  String get qbStoreLenta => 'Lenta';

  @override
  String get qbStoreAuchan => 'Auchan';

  @override
  String get qbStoreMarket => 'Pazar';

  @override
  String get qbStoreDelivery => 'Teslimat';

  @override
  String get qbStoreOther => 'Diğer (virgülle)';

  @override
  String get qbWaterNow => 'Şu an ne kadar su içiyorsunuz';

  @override
  String get qbWaterNowHint => 'Yaklaşık, günlük mililitre';

  @override
  String get qbWaterExact => 'Tam değer';

  @override
  String get qbMlPerDay => 'ml/gün';

  @override
  String get qbTrainingIntro =>
      'Antrenmanlar evde. Sistem programı ekipmanınıza ve zamanınıza göre seçecek.';

  @override
  String get qbPlace => 'Yer';

  @override
  String get qbPlaceHome => 'Ev';

  @override
  String get qbPlaceHomeNote => 'Program ev antrenmanları için hazırlanır';

  @override
  String get qbEquipment => 'Ekipman';

  @override
  String get qbEquipNone => 'Ekipman yok';

  @override
  String get qbEquipDumbbells => 'Dambıl';

  @override
  String get qbEquipPullupBar => 'Barfiks demiri';

  @override
  String get qbEquipBands => 'Direnç bandı';

  @override
  String get qbEquipMat => 'Mat';

  @override
  String get qbEquipKettlebell => 'Kettlebell';

  @override
  String get qbEquipOther => 'Diğer';

  @override
  String get qbLevel => 'Hazırlık seviyesi';

  @override
  String get qbLevelBeginner => 'Başlangıç';

  @override
  String get qbLevelIntermediate => 'Orta';

  @override
  String get qbLevelAdvanced => 'İleri';

  @override
  String get qbMinutesPerDay => 'Günde dakika';

  @override
  String get qbMinutesExact => 'Kendi değeriniz';

  @override
  String get qbMinutesUnit => 'dk';

  @override
  String get qbTrainingDays => 'Antrenman günleri';

  @override
  String get qbDayMon => 'Pzt';

  @override
  String get qbDayTue => 'Sal';

  @override
  String get qbDayWed => 'Çar';

  @override
  String get qbDayThu => 'Per';

  @override
  String get qbDayFri => 'Cum';

  @override
  String get qbDaySat => 'Cmt';

  @override
  String get qbDaySun => 'Paz';

  @override
  String get qbFinanceIntro =>
      'Hepsi isteğe bağlı. Gelirler ve hesaplar, Sistem\'in bütçeyi ve limitleri takip etmesine yardım eder.';

  @override
  String get qbFinIncomes => 'Gelirler';

  @override
  String get qbFinIncomesHint =>
      'Burs, maaş, havaleler — ve ne zaman geldikleri';

  @override
  String get qbFinAddIncome => 'Gelir ekle';

  @override
  String get qbFinAccounts => 'Hesaplar';

  @override
  String get qbFinAddAccount => 'Hesap ekle';

  @override
  String get qbFinCurrencies => 'Para birimleri';

  @override
  String get qbFinCurrenciesHint => 'RUB ana para birimi, raporlar rubleyle';

  @override
  String get qbFinCrypto => 'Kripto para';

  @override
  String get qbFinAddCrypto => 'Coin ekle';

  @override
  String get qbFinDebts => 'Borçlar';

  @override
  String get qbFinAddDebt => 'Borç ekle';

  @override
  String get qbFinIncome => 'Gelir';

  @override
  String get qbFinAccount => 'Hesap';

  @override
  String get qbFinCryptoItem => 'Coin';

  @override
  String get qbFinDebt => 'Borç';

  @override
  String get qbIncomeStipend => 'Burs';

  @override
  String get qbIncomeSalary => 'Maaş';

  @override
  String get qbIncomeTransfer => 'Havaleler';

  @override
  String get qbIncomeOther => 'Diğer';

  @override
  String get qbFinIncomeKind => 'Gelir türü';

  @override
  String get qbFinTitle => 'Ad';

  @override
  String get qbFinAmount => 'Tutar';

  @override
  String get qbFinDayOfMonth => 'Ödemenin geldiği gün';

  @override
  String qbFinDayOfMonthShort(int day) {
    return 'Ayın $day. günü';
  }

  @override
  String get qbFinCash => 'Nakit';

  @override
  String get qbFinCard => 'Kart';

  @override
  String get qbFinBank => 'Banka';

  @override
  String get qbFinCurrency => 'Para birimi';

  @override
  String get qbFinBalance => 'Bakiye';

  @override
  String get qbFinCryptoSymbol => 'Sembol';

  @override
  String get qbFinCryptoAmount => 'Miktar';

  @override
  String get qbFinCryptoRateNote =>
      'Miktar elle girilir, kur otomatik olarak güncellenecek';

  @override
  String get qbFinIOwe => 'Borçluyum';

  @override
  String get qbFinOweMe => 'Alacaklıyım';

  @override
  String get qbFinDebtToWhom => 'Kime';

  @override
  String get qbFinDebtWho => 'Kim';

  @override
  String get qbFinDueDate => 'Vade';

  @override
  String get qbFinClearDate => 'Vadeyi kaldır';

  @override
  String qbFinDueShort(String date) {
    return '$date tarihine kadar';
  }

  @override
  String get qbPermissionsIntro =>
      'Sistem izinleri tek tek isteyecek. Herhangi birini daha sonra ayarlardan verebilirsiniz.';

  @override
  String qbPermProgress(int done, int total) {
    return '$total izinden $done tanesi işlendi';
  }

  @override
  String get qbPermAllow => 'İzin ver';

  @override
  String get qbPermLater => 'Sonra';

  @override
  String get qbPermOpenSettings => 'Ayarları aç';

  @override
  String get qbPermGranted => 'Verildi';

  @override
  String get qbPermDenied => 'Reddedildi';

  @override
  String get qbPermSkipped => 'Sonra';

  @override
  String get qbPermUnavailable => 'Kullanılamaz';

  @override
  String get qbPermAllDone =>
      'Hazır. İzinleri istediğiniz zaman değiştirebilirsiniz.';

  @override
  String get qbPermNoneAvailable => 'Bu cihazda izin gerekmiyor.';

  @override
  String get qbPermNotifications => 'Bildirimler';

  @override
  String get qbPermNotificationsWhy =>
      'Görev, su ve uyku hatırlatmaları ile karakter mesajları.';

  @override
  String get qbPermMotion => 'Hareket ve fitness';

  @override
  String get qbPermMotionWhy =>
      'Görevler ve kaloriler için adım ve aktivite sayımı.';

  @override
  String get qbPermLocationAlways => 'Konum “Her zaman”';

  @override
  String get qbPermLocationAlwaysWhy =>
      'Yürüyüşlerin arka planda kaydı ve rota ipuçları. Telefon önce “Kullanırken”, sonra “Her zaman” iznini soracak.';

  @override
  String get qbPermCamera => 'Kamera';

  @override
  String get qbPermCameraWhy =>
      'İlerlemeyi değerlendirmek için vücut, cilt, yemek ve fiş fotoğrafları.';

  @override
  String get qbPermMicrophone => 'Mikrofon';

  @override
  String get qbPermMicrophoneWhy => 'Karakterle sesli iletişim.';

  @override
  String get qbPermMediaLibrary => 'Medya arşivi';

  @override
  String get qbPermMediaLibraryWhy =>
      'Yürüyüş ve antrenmanda çalan Apple Music parçasını gösterme.';

  @override
  String get qbPermAlarms => 'Alarmlar';

  @override
  String get qbPermAlarmsWhy =>
      'Kalkış ve önemli görevler için tam zamanlı alarmlar.';

  @override
  String get qbPermAlarmsLater => 'Alarm aşamasında ayarlanacak.';

  @override
  String qeQuestPenaltyCleaning(String minutes) {
    return 'Ceza: $minutes dk temizlik';
  }

  @override
  String qeQuestPenaltyReading(String minutes) {
    return 'Ceza: $minutes dk okuma';
  }

  @override
  String qeQuestPenaltyPlank(String seconds) {
    return 'Ceza: $seconds sn plank';
  }

  @override
  String qeQuestPenaltyWalk(String minutes) {
    return 'Ceza: $minutes dk yürüyüş';
  }

  @override
  String get qeQuestPenaltyNoGames => 'Ceza: oyunsuz ve sosyal medyasız akşam';

  @override
  String qeQuestBoostWalk(String minutes) {
    return 'Güçlendirme: $minutes dk yürüyüş';
  }

  @override
  String qeQuestBoostWater(String ml) {
    return 'Güçlendirme: $ml ml ek su';
  }

  @override
  String qeQuestBoostBedOnTime(String time) {
    return 'Güçlendirme: en geç $time yatış';
  }

  @override
  String get qeQuestBoostPlanTomorrow => 'Güçlendirme: yarını planla';

  @override
  String qeQuestBossAll(String count) {
    return 'Bu hafta $count görev tamamla';
  }

  @override
  String qeQuestBossStrength(String count) {
    return '$count güç görevi tamamla';
  }

  @override
  String qeQuestBossEndurance(String count) {
    return '$count dayanıklılık görevi tamamla';
  }

  @override
  String qeQuestBossDiscipline(String count) {
    return '$count disiplin görevi tamamla';
  }

  @override
  String qeQuestBossIntellect(String count) {
    return '$count zekâ görevi tamamla';
  }

  @override
  String qeQuestBossHealth(String count) {
    return '$count sağlık görevi tamamla';
  }

  @override
  String qeQuestBossLooks(String count) {
    return '$count görünüm görevi tamamla';
  }

  @override
  String qeEffectVigor(String pct) {
    return 'Zindelik: +%$pct deneyim';
  }

  @override
  String qeEffectDehydration(String pct) {
    return 'Susuzluk: −%$pct dayanıklılık';
  }

  @override
  String qeEffectBossAura(String pct) {
    return 'Zafer aurası: +%$pct ◆';
  }

  @override
  String get qeTitleStreak7 => 'Yılmaz';

  @override
  String get qeTitleStreak30 => 'Demir İrade';

  @override
  String get qeTitleBossSlayer => 'Boss Galibi';

  @override
  String get qeTitleBossHunter => 'Boss Avcısı';

  @override
  String get qeTitleLevel10 => 'Uyanmış';

  @override
  String get qeTitleLevel25 => 'Çelikleşmiş';

  @override
  String get qeTitleLevel50 => 'Sistem Efsanesi';

  @override
  String get qeReasonFailedQuests =>
      'Günün başarısız görevleri. Ceza görevi verildi';

  @override
  String get qeReasonMarkWalked =>
      'Beyan: arkadaşlarla dışarı çıktın. Dürüstlük cezayı hafifletir';

  @override
  String get qeReasonMarkAlcohol => 'Beyan: alkol. Yarın güçlendirilmiş plan';

  @override
  String get qeReasonMarkRelapse => 'Beyan: kaçamak. Yarın güçlendirilmiş plan';

  @override
  String get qeReasonBossFailed => 'Haftanın bossu yenilmedi';

  @override
  String get qeReasonReproach => 'Görev tamamlanmadı. Sistem memnun değil';

  @override
  String get qeReasonOther => 'Sistem cezası';

  @override
  String get qstViewToday => 'Bugün';

  @override
  String get qstViewWeek => 'Hafta';

  @override
  String get qstViewHistory => 'Geçmiş';

  @override
  String get qstFilterTitle => 'Filtre';

  @override
  String qstFilterActive(int count) {
    return 'Filtre: $count';
  }

  @override
  String get qstFilterReset => 'Sıfırla';

  @override
  String get qstFilterKind => 'Tür';

  @override
  String get qstFilterStat => 'Özellik';

  @override
  String get qstKindDaily => 'Günlük';

  @override
  String get qstKindSchedule => 'Programdan';

  @override
  String get qstKindGoal => 'Hedef';

  @override
  String get qstKindPenalty => 'Ceza';

  @override
  String get qstKindBoss => 'Boss';

  @override
  String get qstStatusPending => 'Aktif';

  @override
  String get qstStatusDone => 'Tamamlandı';

  @override
  String get qstStatusFailed => 'Başarısız';

  @override
  String get qstStatusRefused => 'Reddedildi';

  @override
  String get qstStatusExcused => 'Mola: cezasız';

  @override
  String get qstEmptyDay => 'Bugün için görev yok';

  @override
  String get qstEmptyWeek => 'Bu hafta için görev yok';

  @override
  String get qstEmptyFiltered => 'Filtreye uyan görev yok';

  @override
  String get qstEmptyHistory => 'Kayıt yok';

  @override
  String get qstLoadError =>
      'Sistem yanıt vermiyor. Daha sonra tekrar deneyin.';

  @override
  String get qstActionRejected => 'Sistem işlemi reddetti.';

  @override
  String get qstNoValue => '—';

  @override
  String get qstAllDay => 'Gün içinde';

  @override
  String get qstOpenQuest => 'Görevi aç';

  @override
  String get qstSubtasks => 'Alt görevler';

  @override
  String get qstProgress => 'İlerleme';

  @override
  String qstProgressAddLabel(String step) {
    return 'İlerleme ekle: $step';
  }

  @override
  String qstRefusePenalty(String points) {
    return 'Ret: −$points ◆';
  }

  @override
  String get qstNoRefuse => 'Ceza görevi: reddedilemez';

  @override
  String get qstArchive => 'Arşivle';

  @override
  String get qstArchiveConfirm =>
      'Görev arşivlenecek ve bir daha görünmeyecek.';

  @override
  String get qstNewQuest => 'Yeni görev';

  @override
  String get qstEditQuest => 'Görevi düzenle';

  @override
  String qstBossReward(String points, String xp) {
    return 'Ödül: +$points ◆, +$xp XP';
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
  String get qstHistCompleted => 'Tamamlandı';

  @override
  String get qstHistFailed => 'Başarısız';

  @override
  String get qstHistRefused => 'Ret';

  @override
  String get qstHistPenalty => 'Ceza';

  @override
  String get qstHistBonus => 'Bonus';

  @override
  String get qstHistPurchase => 'Satın alma';

  @override
  String get qstHistMark => 'Günün beyanı';

  @override
  String get qstHistPauseStarted => 'Mola';

  @override
  String get qstHistPauseEnded => 'Mola bitti';

  @override
  String get qstHistStatPoint => 'Özellik puanı';

  @override
  String get qstHistBossCompleted => 'Boss yenildi';

  @override
  String get qstHistBossFailed => 'Boss yenilmedi';

  @override
  String get qstHistDisciplineOn => 'Disiplin açıldı';

  @override
  String get qstHistDisciplineOff => 'Disiplin kapandı';

  @override
  String get qstHistAdjustment => 'Düzeltme';

  @override
  String get qstMarksTitle => 'Dürüst beyanlar';

  @override
  String get qstMarksHint =>
      'Dürüst beyan, gizlenen kaçamaktan daha hafiftir. Yarın güçlendirilmiş plan.';

  @override
  String get qstMarkWalked => 'Arkadaşlarla dışarı çıktım';

  @override
  String get qstMarkAlcohol => 'Alkol';

  @override
  String get qstMarkRelapse => 'Kendimi tutamadım';

  @override
  String qstMarkConfirmTitle(String mark) {
    return 'Beyan et: $mark?';
  }

  @override
  String get qstMarkConfirmMessage =>
      'Dürüst beyan, gizlenen kaçamaktan daha hafiftir: şimdi küçük bir ceza, yarın güçlendirilmiş plan.';

  @override
  String get qstMarkConfirm => 'Beyan et';

  @override
  String get qstPauseTitle => 'Mola';

  @override
  String get qstPauseHint =>
      'Hastalık, tatil, izin: ceza yazılmaz, seri bozulmaz.';

  @override
  String get qstPauseStart => 'Mola ver';

  @override
  String get qstPauseEnd => 'Molayı bitir';

  @override
  String get qstPauseConfirm => 'Molayı başlat';

  @override
  String get qstPauseReason => 'Neden';

  @override
  String get qstPauseReasonIllness => 'Hastalık';

  @override
  String get qstPauseReasonVacation => 'İzin';

  @override
  String get qstPauseReasonHolidays => 'Okul tatili';

  @override
  String get qstPauseReasonOther => 'Diğer';

  @override
  String qstPauseActive(String reason) {
    return 'Mola: $reason';
  }

  @override
  String qstPauseUntil(String date) {
    return '$date tarihine kadar';
  }

  @override
  String get qstPauseUntilRemoved => 'Kaldırılana kadar';

  @override
  String get qstPauseUntilDate => 'Tarihe kadar';

  @override
  String get qstPauseEndDate => 'Molanın son günü';

  @override
  String get qstPausedPill => 'Mola';

  @override
  String get qstDisciplinePill => 'Disiplin';

  @override
  String get qstPlayerNoName => 'Oyuncu';

  @override
  String get qstStatPointsTitle => 'Özellik puanları';

  @override
  String qstStatPointsLeft(int count) {
    return 'Serbest: $count';
  }

  @override
  String qstStatPointAdd(String stat) {
    return 'Puan ekle: $stat';
  }

  @override
  String qstWindowFailedMessage(String quest, String points) {
    return '“$quest”. Ceza: −$points ◆.';
  }

  @override
  String qstWindowFailedMany(int count, String points) {
    return 'Başarısız görev: $count. Ceza: −$points ◆.';
  }

  @override
  String get qstWindowRefusedTitle => 'Görev reddedildi';

  @override
  String get qstWindowPenaltyTitle => 'Ceza';

  @override
  String qstWindowPenaltyMessage(String reason, String points) {
    return '$reason. Ceza: −$points ◆.';
  }

  @override
  String qstWindowPenaltyQuest(String quest) {
    return 'Ceza görevi verildi: “$quest”.';
  }

  @override
  String get qstLevelUpTitle => 'Seviye atladın';

  @override
  String qstLevelUpLevel(int level) {
    return 'LV $level';
  }

  @override
  String qstLevelUpRank(String rank) {
    return 'Yeni rütbe: $rank';
  }

  @override
  String qstLevelUpPoints(int count) {
    return 'Serbest özellik puanı: $count';
  }

  @override
  String qstTitleGot(String title) {
    return 'Unvan: “$title”';
  }

  @override
  String get qstBossWonTitle => 'Boss yenildi';

  @override
  String get qstBossLostTitle => 'Boss yenilmedi';

  @override
  String get qstBossLostMessage =>
      'Hafta zafersiz kapandı. Yeni boss pazartesi geliyor.';

  @override
  String get qstDisciplineOnTitle => 'Disiplin modu açık';

  @override
  String get qstDisciplineOnMessage =>
      'Kalkış 6:00, yatış 22:00, plan sınırları içinde ek egzersiz. ◆ bakiyesi artıya geçince mod kapanır.';

  @override
  String get qstDisciplineOffTitle => 'Disiplin modu kapandı';

  @override
  String get qstDisciplineOffMessage => 'Bakiye düzeldi. Normal mod.';

  @override
  String get qstDisciplineMore => 'Ayrıntılar';

  @override
  String get qstFormTitle => 'Ad';

  @override
  String get qstFormTitleHint => 'Örneğin: 10 dakika esneme';

  @override
  String get qstFormStat => 'Özellik';

  @override
  String get qstFormTimed => 'Belirli saatte';

  @override
  String get qstFormTimedHint => 'Aksi halde gün içinde';

  @override
  String get qstFormTime => 'Saat';

  @override
  String get qstFormWindow => 'Süre penceresi';

  @override
  String get qstMinutesUnit => 'dk';

  @override
  String get qstFormWeekdays => 'Haftanın günleri';

  @override
  String get qstFormWeekdaysHint => 'Seçilmezse her gün';

  @override
  String get qstFormWeekParity => 'Dönüşümlü haftalar';

  @override
  String get qstWeekEvery => 'Her hafta';

  @override
  String get qstWeek1 => 'Hafta 1';

  @override
  String get qstWeek2 => 'Hafta 2';

  @override
  String get qstFormSubtasks => 'Alt görevler';

  @override
  String qstFormSubtaskHint(int n) {
    return 'Alt görev $n';
  }

  @override
  String get qstFormAddSubtask => 'Alt görev ekle';

  @override
  String get qstFormRemoveSubtask => 'Alt görevi kaldır';

  @override
  String get qstFormDefaultReward => 'Ödül ve ceza — Sistem kurallarına göre';

  @override
  String get qstFormDefaultRewardHint =>
      'Sistem ◆ ve deneyimi görev türüne göre hesaplar';

  @override
  String get qstFormRewardDiamonds => 'Ödül, ◆';

  @override
  String get qstFormRewardXp => 'Deneyim, XP';

  @override
  String get qstFormPenalty => 'Başarısızlık cezası, ◆';

  @override
  String get qstFormNag => 'Israrla hatırlat';

  @override
  String get qstFormNagHint => 'Tamamlanana kadar her dakika hatırlat';

  @override
  String get schTitle => 'Program';

  @override
  String get schInstitution => 'Eğitim kurumu';

  @override
  String get schInstSchool => 'Okul';

  @override
  String get schInstCollege => 'Meslek okulu';

  @override
  String get schInstUniversity => 'Üniversite';

  @override
  String get schInstNone => 'Okumuyorum';

  @override
  String get schInstitutionName => 'Adı';

  @override
  String get schInstitutionNameHint => 'Örneğin: İstanbul Üniversitesi';

  @override
  String get schWake => 'Kalkış';

  @override
  String get schBed => 'Yatış';

  @override
  String get schCommute => 'Okula yol';

  @override
  String get schCommuteHint => 'Tek yön, dakika';

  @override
  String get schMinutesUnit => 'dk';

  @override
  String get schWeekends => 'Hafta sonu günleri';

  @override
  String get schAlternation => 'Haftalar dönüşümlü (1./2. hafta)';

  @override
  String get schAlternationHint => 'Tek ve çift haftalarda farklı dersler';

  @override
  String schCurrentWeek(int week) {
    return 'Şu an: $week. hafta';
  }

  @override
  String get schSwitchWeek => 'Haftayı değiştir';

  @override
  String schWeekN(int week) {
    return '$week. hafta';
  }

  @override
  String get schItemsTitle => 'Program öğeleri';

  @override
  String get schDayEmpty => 'Öğe yok';

  @override
  String get schAddItem => 'Öğe ekle';

  @override
  String schAddItemTo(String day) {
    return 'Öğe ekle: $day';
  }

  @override
  String get schCopyDay => 'Günü kopyala';

  @override
  String schCopyDayFrom(String day) {
    return 'Günü kopyala: $day';
  }

  @override
  String get schCopyDayTo => 'Hangi güne kopyalansın?';

  @override
  String schCopied(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count öğe kopyalandı',
    );
    return '$_temp0';
  }

  @override
  String get schItemNew => 'Yeni öğe';

  @override
  String get schItemEdit => 'Program öğesi';

  @override
  String get schItemTitle => 'Başlık';

  @override
  String get schItemTitleHint => 'Örneğin: Matematik';

  @override
  String get schKind => 'Tür';

  @override
  String get schKindLesson => 'Ders';

  @override
  String get schKindWork => 'İş';

  @override
  String get schKindOther => 'Diğer';

  @override
  String get schDay => 'Haftanın günü';

  @override
  String get schStart => 'Başlangıç';

  @override
  String get schDuration => 'Süre, dk';

  @override
  String schEndsAt(String time) {
    return 'Bitiş: $time';
  }

  @override
  String get schParity => 'Hafta';

  @override
  String get schParityEvery => 'Her hafta';

  @override
  String get schLocation => 'Yer';

  @override
  String get schLocationHint => 'Derslik, adres';

  @override
  String get schRequiresCommute => 'Yol gerekiyor';

  @override
  String get schRequiresCommuteHint => 'Evden çıkış saatinde dikkate al';

  @override
  String get schDeleteConfirm => 'Öğe silinsin mi?';

  @override
  String get schWd1 => 'Pzt';

  @override
  String get schWd2 => 'Sal';

  @override
  String get schWd3 => 'Çar';

  @override
  String get schWd4 => 'Per';

  @override
  String get schWd5 => 'Cum';

  @override
  String get schWd6 => 'Cmt';

  @override
  String get schWd7 => 'Paz';

  @override
  String get schWdFull1 => 'Pazartesi';

  @override
  String get schWdFull2 => 'Salı';

  @override
  String get schWdFull3 => 'Çarşamba';

  @override
  String get schWdFull4 => 'Perşembe';

  @override
  String get schWdFull5 => 'Cuma';

  @override
  String get schWdFull6 => 'Cumartesi';

  @override
  String get schWdFull7 => 'Pazar';

  @override
  String get schWeekend => 'Tatil';

  @override
  String schHeader(int week, String day) {
    return '$week. hafta · $day';
  }

  @override
  String schHeaderNoAlt(String day) {
    return 'Dönüşüm yok · $day';
  }

  @override
  String get schPrevWeek => 'Önceki hafta';

  @override
  String get schNextWeek => 'Sonraki hafta';

  @override
  String get schToday => 'Bugün';

  @override
  String get schDayFeed => 'Gün';

  @override
  String get schSlotSleep => 'Uyku';

  @override
  String get schSlotCommute => 'Yol';

  @override
  String get schSlotFree => 'Boş';

  @override
  String schLeaveHome(String time) {
    return 'Evden çıkış: $time';
  }

  @override
  String get schNoLeave => 'Bu gün dışarı çıkmak gerekmiyor';

  @override
  String schFreeTotal(String duration) {
    return 'Boş: $duration';
  }

  @override
  String schHoursMinutes(int hours, int minutes) {
    return '$hours sa $minutes dk';
  }

  @override
  String schMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String schTimeRange(String start, String end) {
    return '$start–$end';
  }

  @override
  String get schEditSchedule => 'Programı düzenle';

  @override
  String get schBack => 'Geri';

  @override
  String get schWarningLabel => 'Uyarı';

  @override
  String get setSectionQuestionnaire => 'Anket';

  @override
  String get setSectionPlan => 'Plan';

  @override
  String get setPlan => 'Plan';

  @override
  String get setPlanHint => 'Planı önizle ve kabul et';

  @override
  String get setSchedule => 'Program';

  @override
  String get setScheduleHint => 'Dersler, iş, uyku';

  @override
  String get setSectionLanguage => 'Dil';

  @override
  String get setLangRu => 'Русский';

  @override
  String get setLangTr => 'Türkçe';

  @override
  String get setLangSystem => 'Sistem dili';

  @override
  String get setSectionData => 'Veriler';

  @override
  String get setExport => 'JSON olarak dışa aktar';

  @override
  String get setExportHint =>
      'Tüm veriler tek dosyada — “Dosyalar”a kaydedin veya kendinize gönderin';

  @override
  String get setIncludePhotos => 'Fotoğrafları dahil et';

  @override
  String get setIncludePhotosHint => 'Dosya daha büyük olur';

  @override
  String get setPhotosWebNote => 'Tarayıcıda fotoğraflar aktarılmaz';

  @override
  String get setImport => 'JSON\'dan içe aktar';

  @override
  String get setImportHint => 'Bu cihazdaki tüm verilerin yerini alır';

  @override
  String get setRestart => 'Anketi yeniden doldur';

  @override
  String get setRestartHint => 'Yanıtlar korunur, değiştirebilirsiniz';

  @override
  String get setRestartMessage =>
      'Anket ilk aşamadan başlayacak. Girilen veriler silinmez.';

  @override
  String get setRestartConfirm => 'Yeniden başla';

  @override
  String get setSectionAbout => 'Uygulama hakkında';

  @override
  String get setVersion => 'Sürüm';

  @override
  String get setPlatform => 'Platform';

  @override
  String get setPlatformOther => 'Diğer';

  @override
  String get setCertExpires => 'Sertifika geçerlilik sonu';

  @override
  String setGoalsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hedef',
    );
    return '$_temp0';
  }

  @override
  String setHeightValue(String value) {
    return '$value cm';
  }

  @override
  String setWeightValue(String value) {
    return '$value kg';
  }

  @override
  String get setNoticeLabel => 'Bildirim';

  @override
  String get setWarningLabel => 'Uyarı';

  @override
  String get setErrorLabel => 'Hata';

  @override
  String get setExportReady => 'Yedek dosyası hazır';

  @override
  String get setExportFailed => 'Dosya hazırlanamadı. Tekrar deneyin.';

  @override
  String get setShareUnavailable =>
      'Bu cihazda dosya paylaşımı kullanılamıyor.';

  @override
  String get setPickUnavailable => 'Bu cihazda dosya seçimi kullanılamıyor.';

  @override
  String get setImportPreviewTitle => 'İçe aktarılacaklar';

  @override
  String setImportExportedAt(String date) {
    return 'Oluşturulma: $date';
  }

  @override
  String setImportRows(String table, int count) {
    return '$table: $count';
  }

  @override
  String setImportPhotos(int count) {
    return 'Fotoğraf dosyası: $count';
  }

  @override
  String get setImportNoPhotos => 'Dosyada fotoğraf yok';

  @override
  String get setImportWarning =>
      'Bu cihazdaki tüm mevcut verilerin yerini alacak.';

  @override
  String get setImportReplace => 'Tüm verileri değiştir';

  @override
  String get setImportHoldHint => 'Onaylamak için basılı tutun';

  @override
  String get setImportDone => 'Veriler içe aktarıldı';

  @override
  String get setImportFailed => 'İçe aktarma başarısız. Veriler değişmedi.';

  @override
  String get setErrNotJson => 'Dosya JSON olarak okunamıyor.';

  @override
  String get setErrWrongFormat => 'Bu bir Sistem yedeği değil.';

  @override
  String get setErrFormatVersion => 'Dosya biçimi sürümü desteklenmiyor.';

  @override
  String get setErrNewerSchema =>
      'Dosya uygulamanın daha yeni bir sürümüyle oluşturulmuş. Uygulamayı güncelleyip tekrar deneyin.';

  @override
  String get setErrInvalid => 'Dosya bozuk.';

  @override
  String get setTableAppSettings => 'Ayarlar';

  @override
  String get setTableProfiles => 'Profil';

  @override
  String get setTableBodyMeasurements => 'Vücut ölçümleri';

  @override
  String get setTablePhotos => 'Fotoğraf kayıtları';

  @override
  String get setTableGoals => 'Hedefler';

  @override
  String get setTableScheduleSettings => 'Program ayarları';

  @override
  String get setTableScheduleItems => 'Program öğeleri';

  @override
  String get setTablePlans => 'Planlar';

  @override
  String get setTableQuestionnaireSections => 'Anket bölümleri';

  @override
  String get setSectionQuests => 'Görevler';

  @override
  String get setReminders => 'Hatırlatmalar';

  @override
  String get setRemindersHint => 'Sessiz saatler, tekrar, sitemler';

  @override
  String get setDiscipline => 'Disiplin modu';

  @override
  String get setDisciplineHint => '06:00 kalkış, 22:00 yatış, ek egzersiz';

  @override
  String get setBody => 'Vücut ve sağlık';

  @override
  String get setBodyHint => 'Adımlar, uyku, ölçüler, fotoğraflar, cilt bakımı';

  @override
  String get setWorkouts => 'Antrenmanlar';

  @override
  String get setWorkoutsHint => 'Seviyeye göre program, zamanlayıcılar, ses';

  @override
  String get setWalks => 'Yürüyüşler';

  @override
  String get setWalksHint => 'Dairesel rota, bölümler, müziğin üstünde ses';

  @override
  String get shpNoticeLabel => 'Bildirim';

  @override
  String get shpWarningLabel => 'Uyarı';

  @override
  String get shpTitle => 'Ödül mağazası';

  @override
  String get shpBalance => 'Bakiye';

  @override
  String get shpClosedMessage => 'Mağaza kapalı: bakiye eksi';

  @override
  String get shpClosedHint =>
      'Bakiyeyi artıya çevirmek için görevleri tamamlayın. Disiplin modu zaten açıldı.';

  @override
  String get shpRewards => 'Ödüller';

  @override
  String get shpAdd => 'Yeni ödül';

  @override
  String get shpEmptyTitle => 'Henüz ödül yok';

  @override
  String get shpEmptyText =>
      'Ödülleri siz belirler, ◆ ile satın alırsınız. Formu doldurmak için bir örneğe dokunun:';

  @override
  String get shpExampleChocolate => 'Çikolata';

  @override
  String get shpExampleFastFood => 'Fast food';

  @override
  String get shpExampleGames => 'Bir saat oyun';

  @override
  String get shpExampleFreeEvening => 'Görevsiz bir akşam';

  @override
  String get shpBuy => 'Satın al';

  @override
  String get shpLimitNone => 'Sınırsız';

  @override
  String shpLimitDay(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Günde $count kez',
    );
    return '$_temp0';
  }

  @override
  String shpLimitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Haftada $count kez',
    );
    return '$_temp0';
  }

  @override
  String shpLimitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ayda $count kez',
    );
    return '$_temp0';
  }

  @override
  String shpLimitLeft(int count) {
    return 'kalan $count';
  }

  @override
  String shpLimitReachedUntil(String date) {
    return '$date tarihine kadar sınır doldu';
  }

  @override
  String shpNotEnough(int count) {
    return '$count ◆ eksik';
  }

  @override
  String get shpConfirmTitle => 'Satın almayı onaylayın';

  @override
  String shpConfirmMessage(String title, int price, int after) {
    return '“$title” — $price ◆. Satın alma sonrası bakiye: $after ◆.';
  }

  @override
  String shpBoughtMessage(String title) {
    return '“$title” ödülü alındı. Sistem satın almayı kaydetti.';
  }

  @override
  String get shpFailedMessage =>
      'Satın alma reddedildi: yetersiz ◆ veya mağaza kapalı.';

  @override
  String get shpLimitReachedMessage => 'Bu ödülün dönem sınırı doldu.';

  @override
  String get shpHistory => 'Satın alma geçmişi';

  @override
  String get shpHistoryEmpty => 'Henüz satın alma yok';

  @override
  String get shpArchive => 'Arşiv';

  @override
  String get shpRestore => 'Geri al';

  @override
  String get shpReorder => 'Sıralama';

  @override
  String get shpMoveUp => 'Yukarı';

  @override
  String get shpMoveDown => 'Aşağı';

  @override
  String get shpEditorNew => 'Yeni ödül';

  @override
  String get shpEditorEdit => 'Ödül';

  @override
  String get shpFieldTitle => 'Ad';

  @override
  String get shpFieldTitleHint => 'Örneğin: bir saat oyun';

  @override
  String get shpFieldPrice => 'Fiyat';

  @override
  String get shpFieldPriceHint => 'Ödül kaç ◆ değerinde';

  @override
  String get shpFieldLimit => 'Sıklık sınırı';

  @override
  String get shpPeriodNone => 'Yok';

  @override
  String get shpPeriodDay => 'Gün';

  @override
  String get shpPeriodWeek => 'Hafta';

  @override
  String get shpPeriodMonth => 'Ay';

  @override
  String get shpFieldLimitCount => 'Dönem başına kaç kez';

  @override
  String get shpToArchive => 'Arşivle';

  @override
  String get shpErrorPrice => '1 ile 100000 arası';

  @override
  String get shpErrorCount => '1 ile 99 arası';

  @override
  String get dscTitle => 'Disiplin modu';

  @override
  String get dscStatus => 'Durum';

  @override
  String get dscOn => 'Açık';

  @override
  String get dscOff => 'Kapalı';

  @override
  String get dscReasonLabel => 'Neden';

  @override
  String get dscReasonDebt => 'eksi bakiye';

  @override
  String get dscReasonManual => 'elle açıldı';

  @override
  String get dscReasonAi => 'kaçamaktan sonra Sistem kararı';

  @override
  String get dscExitLabel => 'Kapanacak';

  @override
  String get dscExitBalancePositive => 'bakiye artıya geçtiğinde';

  @override
  String get dscExitManual => 'elle, bakiye eksi değilken';

  @override
  String get dscSinceLabel => 'Başlangıç';

  @override
  String get dscOffText =>
      '◆ bakiyesi eksiye düşerse mod kendiliğinden açılır. Elle de açılabilir.';

  @override
  String get dscBalance => 'Bakiye';

  @override
  String get dscToday => 'Bugünün kuralları';

  @override
  String get dscRulesNote =>
      'Yük seviyenizi aşmaz. Yemek ve uyku kısılmaz: yatış ve kalkış her zamankinden geç olmaz.';

  @override
  String get dscCannotRefuse => 'Mod görevleri iptal edilemez.';

  @override
  String get dscPreviewNote => 'Disiplin modunda bir gün böyle görünecek.';

  @override
  String get dscBlockerTitle => 'Uygulama engelleme';

  @override
  String get dscBlockerText =>
      'Disiplin modunda yatma saatinden sonra eğlence uygulamaları engellenir: Android\'de “Sistem: yatma vakti” ekranıyla, iPhone\'da Kestirmeler otomasyonuyla.';

  @override
  String get dscBlockerSoon => 'Sonra';

  @override
  String get dscEnable => 'Modu aç';

  @override
  String get dscDisable => 'Modu kapat';

  @override
  String get dscEnableConfirmMessage =>
      'Kalkış 6:00, yatış 22:00, ek egzersiz. Mod görevleri iptal edilemez.';

  @override
  String get dscDisableLocked => 'Bakiye eksiyken kapatılamaz.';

  @override
  String get dscChangedOnMessage =>
      'Disiplin modu açıldı. Kalkış 6:00, yatış 22:00, ek egzersiz.';

  @override
  String get dscChangedOffMessage => 'Disiplin modu kapatıldı.';

  @override
  String dscQuestWake(String time) {
    return 'Kalkış: $time';
  }

  @override
  String dscQuestBed(String time) {
    return 'Yatış: $time';
  }

  @override
  String dscQuestWorkout(int minutes) {
    return 'Ek antrenman: $minutes dk';
  }

  @override
  String dscQuestWalk(int minutes) {
    return 'Sakin yürüyüş: $minutes dk';
  }

  @override
  String get synTitle => 'Hesap';

  @override
  String get synServer => 'Sunucu adresi';

  @override
  String get synName => 'Ad';

  @override
  String get synPassword => 'Şifre';

  @override
  String get synNewPassword => 'Yeni şifre';

  @override
  String get synTotpCode => 'Doğrulayıcı uygulamadaki kod';

  @override
  String get synLogin => 'Giriş yap';

  @override
  String get synRegister => 'Hesap oluştur';

  @override
  String get synForgot => 'Şifrenizi mi unuttunuz?';

  @override
  String get synReset => 'Şifreyi sıfırla';

  @override
  String get synResetHint =>
      'Sıfırlama yalnızca iki adımlı doğrulama (TOTP) açıksa mümkündür';

  @override
  String get synResetDone => 'Şifre değiştirildi — yeni şifreyle giriş yapın';

  @override
  String get synBackToLogin => 'Girişe dön';

  @override
  String synSignedInAs(String name) {
    return '$name olarak giriş yapıldı';
  }

  @override
  String get synLogout => 'Çıkış yap';

  @override
  String get synSectionLogin => 'Giriş';

  @override
  String get synSectionTotp => 'İki adımlı doğrulama';

  @override
  String get synTotpOn => 'Açık';

  @override
  String get synTotpOff => 'Kapalı — o olmadan şifre kurtarılamaz';

  @override
  String get synTotpSetup => 'TOTP\'yi aç';

  @override
  String get synTotpScan =>
      'QR kodunu doğrulayıcı uygulamada tarayın veya gizli anahtarı elle girin';

  @override
  String get synCopy => 'Kopyala';

  @override
  String get synCopied => 'Kopyalandı';

  @override
  String get synTotpConfirm => 'Onayla';

  @override
  String get synTotpEnabled => 'TOTP açıldı';

  @override
  String get synTotpNeeded => 'Doğrulayıcı uygulamadaki kodu girin';

  @override
  String get synSectionSync => 'Senkronizasyon';

  @override
  String get synSyncNow => 'Şimdi senkronize et';

  @override
  String get synStatusOff => 'Kapalı — hesaba giriş yapın';

  @override
  String get synStatusIdle => 'Senkronize edildi';

  @override
  String get synStatusSyncing => 'Senkronize ediliyor…';

  @override
  String get synStatusOffline => 'Sunucuya bağlantı yok';

  @override
  String get synStatusError => 'Senkronizasyon hatası';

  @override
  String synLastSync(String time) {
    return 'Son: $time';
  }

  @override
  String synPending(int count) {
    return 'Gönderilmedi: $count';
  }

  @override
  String get synErrNetwork =>
      'Sunucuya ulaşılamıyor — adresi ve interneti kontrol edin';

  @override
  String get synErrCredentials => 'Ad veya şifre yanlış';

  @override
  String get synErrTotp => 'Kod yanlış';

  @override
  String get synErrNameTaken => 'Bu ad zaten alınmış';

  @override
  String get synErrWeakPassword => 'Şifre en az 8 karakter olmalı';

  @override
  String get synErrRateLimited => 'Çok fazla deneme — bekleyin';

  @override
  String get synErrServer => 'Sunucu hatası — daha sonra deneyin';

  @override
  String get synErrInvalidName =>
      'Ad: 3–32 karakter — harf, rakam, _ - . boşluksuz';

  @override
  String get synErrFill => 'Sunucu adresini, adı ve şifreyi doldurun';

  @override
  String get visEstimate => 'Tahmin';

  @override
  String get visNoticeLabel => 'Sistem';

  @override
  String get visSourceTitle => 'Fotoğraf';

  @override
  String get visSourceMessage => 'Fotoğraf çekilsin mi, galeriden mi seçilsin?';

  @override
  String get visCamera => 'Kamera';

  @override
  String get visGallery => 'Galeri';

  @override
  String get visAnalyzing => 'Fotoğraf analiz ediliyor…';

  @override
  String get visErrOffline =>
      'Sunucuya bağlanılamadı. Daha sonra tekrar deneyin.';

  @override
  String get visErrNotSignedIn =>
      'Fotoğraf analizi için hesabınıza giriş yapın (“Diğer” → “Hesap”).';

  @override
  String get visErrBudget =>
      'Yapay zekâ limiti şu an dolu. Daha sonra tekrar deneyin.';

  @override
  String get visErrUnavailable => 'Sunucudaki yapay zekâ şu an kullanılamıyor.';

  @override
  String get visErrServer => 'Fotoğraf çözümlenemedi. Tekrar deneyin.';

  @override
  String get visRetry => 'Tekrar dene';

  @override
  String get visRemove => 'Kaldır';

  @override
  String get visBack => 'Geri';

  @override
  String get visDone => 'Tamam';

  @override
  String get visFoodTitle => 'Yemek fotoğrafı';

  @override
  String get visFoodSeen => 'Fotoğrafta ne var';

  @override
  String get visFoodNothing => 'Yemek tanınmadı — öğeleri elle ekleyin.';

  @override
  String get visFoodItemName => 'Ad';

  @override
  String get visFoodGrams => 'Gram';

  @override
  String visFoodItemLine(String name, String grams) {
    return '$name — $grams g';
  }

  @override
  String get visFoodAddItem => 'Öğe ekle';

  @override
  String get visFoodQuestion => 'Satın mı aldın, kendin mi yaptın?';

  @override
  String get visFoodBought => 'Satın aldım';

  @override
  String get visFoodCooked => 'Kendim yaptım';

  @override
  String get visFoodWhere => 'Nereden aldın?';

  @override
  String get visFoodWhereHint => 'Kafe, market, zincir — boş bırakılabilir';

  @override
  String get visFoodFind => 'Besin değerlerini bul';

  @override
  String get visFoodScanHint => 'Paketi var mı? Barkod daha doğru.';

  @override
  String get visFoodScan => 'Barkod tara';

  @override
  String visFoodPer100(String kcal, String macros) {
    return '100 g\'da: $kcal · $macros';
  }

  @override
  String visFoodSource(String title) {
    return 'Kaynak: $title';
  }

  @override
  String get visFoodCached => 'kayıtlı veriden';

  @override
  String get visFoodSaveDiary => 'Günlüğe yaz';

  @override
  String get visFoodRecipeName => 'Yemeğin adı';

  @override
  String get visFoodSaveRecipe => 'Tariflerime ve günlüğe';

  @override
  String get visFoodTotal => 'Toplam';

  @override
  String get visBodyTitle => 'Vücut analizi';

  @override
  String get visSkinTitle => 'Cilt analizi';

  @override
  String get visBodyFat => 'Yağ oranı';

  @override
  String visFatRange(String min, String max) {
    return '%$min–$max';
  }

  @override
  String get visMuscle => 'Kas';

  @override
  String get visLevelLow => 'ortalamanın altında';

  @override
  String get visLevelMedium => 'orta';

  @override
  String get visLevelHigh => 'ortalamanın üstünde';

  @override
  String get visSwelling => 'Ödem';

  @override
  String get visSwellingNone => 'görünmüyor';

  @override
  String get visSwellingMild => 'hafif';

  @override
  String get visSwellingNoticeable => 'belirgin';

  @override
  String get visPosture => 'Duruş';

  @override
  String get visComparison => 'Öncekiyle karşılaştırma';

  @override
  String visPreviousAt(String date) {
    return 'Önceki fotoğraf: $date';
  }

  @override
  String get visSkinType => 'Cilt tipi';

  @override
  String get visSkinDry => 'kuru';

  @override
  String get visSkinNormal => 'normal';

  @override
  String get visSkinOily => 'yağlı';

  @override
  String get visSkinCombination => 'karma';

  @override
  String get visSkinSensitive => 'hassas';

  @override
  String get visAcne => 'Sivilce';

  @override
  String visAcneScore(String score) {
    return '10 üzerinden $score';
  }

  @override
  String get visDisclaimer =>
      'Fotoğraftan tahmin: ışık, açı ve kamera sonucu etkiler. Tıbbi bir değerlendirme değildir.';

  @override
  String get visReceiptTitle => 'Fiş';

  @override
  String get visReceiptStore => 'Mağaza';

  @override
  String get visReceiptDate => 'Tarih';

  @override
  String get visReceiptFinanceLater =>
      'Kalemleri kontrol edin — ardından fiş finansa kaydedilebilir.';

  @override
  String get wlkTitle => 'Yürüyüş';

  @override
  String get wlkPlan => 'Rota';

  @override
  String get wlkByDistance => 'Kilometre';

  @override
  String get wlkByTime => 'Dakika';

  @override
  String wlkKm(String value) {
    return '$value km';
  }

  @override
  String wlkMin(int n) {
    return '$n dk';
  }

  @override
  String get wlkIntervals => 'Aralıklar: yürüyüş, hızlanma, kardiyo';

  @override
  String get wlkIntervalsHint => 'Kapalı — tüm tur sakin tempoda';

  @override
  String get wlkBuild => 'Tur oluştur';

  @override
  String get wlkBuilding => 'Rota oluşturuluyor…';

  @override
  String get wlkNoLocation => 'Konum erişimi yok. Ayarlardan izin verin.';

  @override
  String get wlkNoRoute =>
      'Rota oluşturulamadı. Bağlantıyı kontrol edip tekrar deneyin.';

  @override
  String wlkRouteInfo(String km, int min) {
    return '$km km · ~$min dk';
  }

  @override
  String get wlkStart => 'Yürüyüşe başla';

  @override
  String get wlkStartFree => 'Rotasız';

  @override
  String get wlkPause => 'Duraklat';

  @override
  String get wlkResume => 'Devam et';

  @override
  String get wlkFinish => 'Bitir';

  @override
  String get wlkActive => 'Yürüyüş sürüyor';

  @override
  String get wlkPaused => 'Duraklatıldı';

  @override
  String get wlkDistance => 'Mesafe';

  @override
  String get wlkTime => 'Süre';

  @override
  String get wlkPace => 'Tempo';

  @override
  String wlkPaceValue(String value) {
    return '$value /km';
  }

  @override
  String get wlkNext => 'Sonraki';

  @override
  String wlkInMeters(int m) {
    return '$m m sonra';
  }

  @override
  String get wlkOffRoute => 'Rotadan çıktınız';

  @override
  String get wlkModeWalk => 'Yürüyüş';

  @override
  String get wlkModeBrisk => 'Hızlanma';

  @override
  String get wlkModeCardio => 'Kardiyo';

  @override
  String get wlkModeRest => 'Dinlenme';

  @override
  String get wlkTurnStart => 'Başlangıç';

  @override
  String get wlkTurnStraight => 'Düz';

  @override
  String get wlkTurnLeft => 'Sola';

  @override
  String get wlkTurnRight => 'Sağa';

  @override
  String get wlkTurnSlightLeft => 'Hafif sola';

  @override
  String get wlkTurnSlightRight => 'Hafif sağa';

  @override
  String get wlkTurnUTurn => 'Geri dönüş';

  @override
  String get wlkTurnArrive => 'Varış';

  @override
  String get wlkSayTurnLeft => 'sola dön';

  @override
  String get wlkSayTurnRight => 'sağa dön';

  @override
  String get wlkSayTurnSlightLeft => 'hafif sola dön';

  @override
  String get wlkSayTurnSlightRight => 'hafif sağa dön';

  @override
  String get wlkSayTurnUTurn => 'geri dön';

  @override
  String get wlkSayModeWalk => 'sakin tempoda yürü';

  @override
  String get wlkSayModeBrisk => 'hızlan';

  @override
  String get wlkSayModeCardio => 'kardiyo aralığı, en yüksek tempo';

  @override
  String get wlkSayModeRest => 'dinlenme, tempoyu düşür';

  @override
  String wlkSayAnd(String first, String second) {
    return '$first ve $second';
  }

  @override
  String get wlkSayStart => 'Yürüyüşe başlıyoruz';

  @override
  String get wlkSayArrive => 'Rota tamamlandı. Harika iş';

  @override
  String get wlkSayOffRoute => 'Rotadan çıktın, çizgiye geri dön';

  @override
  String get wlkSummary => 'Yürüyüş özeti';

  @override
  String wlkKcal(int n) {
    return '$n kcal';
  }

  @override
  String get wlkHistory => 'Geçmiş';

  @override
  String get wlkHistoryEmpty => 'Henüz yürüyüş yok.';

  @override
  String get wlkShop => 'Yakındaki market';

  @override
  String get wlkGrocery => 'Market';

  @override
  String get wlkWater => 'Su';

  @override
  String get wlkSearching => 'Yakında aranıyor…';

  @override
  String get wlkNothingNearby => 'Yakında bir şey bulunamadı.';

  @override
  String get wlkUnnamed => 'İsimsiz';

  @override
  String wlkToPlace(String name) {
    return 'Hedef: $name';
  }

  @override
  String get wlkTrackerUnavailable => 'Yürüyüş takibi kullanılamıyor.';

  @override
  String get wlkMapAttribution => '© OpenStreetMap katkıcıları';

  @override
  String get polShowPassword => 'Şifreyi göster';

  @override
  String get polHidePassword => 'Şifreyi gizle';

  @override
  String get navHealth => 'Sağlık';

  @override
  String get navSettings => 'Ayarlar';

  @override
  String get healthBody => 'Vücut';

  @override
  String get shopTabPoints => 'Puanla';

  @override
  String get shopTabPurchases => 'Alışveriş';

  @override
  String get moreAddExpense => 'Harcama';

  @override
  String get moreSections => 'Bölümler';

  @override
  String get moreSettingsHint => 'Hesap, anket, hatırlatıcılar, ses, dil, veriler';

  @override
  String get setSectionAi => 'Karakter ve yapay zekâ';

  @override
  String get mktSettingsTitle => 'Alışveriş';

  @override
  String get mktSettingsHint => 'Yapay zekâ önerileri için mağazalar ve bütçe';

  @override
  String get mktSettingsStores => 'Mağazalar';

  @override
  String get mktSettingsBudget => 'Aylık alışveriş bütçesi';

  @override
  String get mktSettingsBudgetHint => 'Daha pahalı ürünler «bütçe dışı» olarak işaretlenir. Boş — sınırsız.';

  @override
  String get homeQuickFood => 'Yemek';

  @override
  String get homeQuickWorkout => 'Antrenman';

  @override
  String get homeQuickWalk => 'Yürüyüş';

  @override
  String get homeQuickWaterAdded => 'Su kaydedildi';
}
