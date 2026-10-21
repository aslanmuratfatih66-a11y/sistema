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
  String get navMore => 'Daha fazla';

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
      one: 'Sertifikanın süresi $days gün içinde doluyor',
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
  String get homeLevelShort => 'SV';

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
      one: '$count günlük seri',
    );
    return '$_temp0';
  }

  @override
  String homeXpLabel(int level) {
    return 'Deneyim · SV $level hedefi';
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
    return '«$quest» görevi reddedildi. Ceza: −$points ◆.';
  }

  @override
  String get homeNoWaterMessage =>
      'Görev ertelendi: su yakınında olduğunda Sistem hatırlatacak.';

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
  String get homeBossTitle => 'Haftanın patronu';

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
    return 'Ödül: +$points ◆ ve «$title» unvanı';
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
  String get homeUntilStipend => 'Bursa kalan';

  @override
  String homeDaysCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gün',
      one: '$count gün',
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
  String get homeDemoEffectVigor => 'Zindelik +%5 deneyim';

  @override
  String get homeDemoEffectDehydration => 'Susuzluk −%10 dayanıklılık';

  @override
  String get homeDemoNextQuest => '500 ml su iç';

  @override
  String get homeDemoQuestWakeUp => '07:00’den önce kalk';

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
  String get homeDemoQuestSleep => '23:00’ten önce yat';

  @override
  String get homeDemoBossGoal => 'Bu hafta 5 antrenman tamamla';

  @override
  String get homeDemoBossRewardTitle => 'Yılmaz';

  @override
  String get homeDemoAssistantLine =>
      'Su hedefinin %48’i tamam. 11:30’a kadar bir bardak iç, «Zindelik» bir saat daha sürsün.';

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
  String get bdySleepBed => 'Yattım';

  @override
  String get bdySleepWake => 'Kalktım';

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
      '«Önce» ve «sonra»yı karşılaştırmak için iki fotoğraf seçin.';

  @override
  String get bdyPhotoCompareNeedTwo =>
      'Karşılaştırma için en az iki fotoğraf gerekir.';

  @override
  String get bdyPoseOther => 'Diğer';

  @override
  String get bdyCompareSlider => 'Perde';

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
  String get chrIntro =>
      'Bir yol arkadaşı seç. Fotoğraf çekimlerinde sesiyle sana rehberlik edecek, sonra ekranın altında yaşayacak; hatırlatacak, övecek ve azarlayacak — seçtiğin modda.';

  @override
  String get chrArchetype => 'Karakter';

  @override
  String get chrArchetypeRequired => 'Devam etmek için bir karakter seç';

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
  String get chrNameAnimeGuy => 'Anime çocuk';

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
  String get chrNameStoicStrongman => 'Soğukkanlı güçlü adam';

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
      'Sert bir usta. Her gün iradeyi eğitmektir.';

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
      'Bu cihazda arayüz dili için konuşma sentezi yok — sesi daha sonra dinleyebilirsin.';

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
  String get chrModeStrict => 'Sıkı';

  @override
  String get chrModeStrictDesc =>
      'Net talepler ve başarısızlıklara doğrudan eleştiri.';

  @override
  String get chrModeHarsh => 'Sert';

  @override
  String get chrModeHarshDesc =>
      'Tüm sertliğiyle azarlar, ama görünüş ve sağlıkla aşağılamadan.';

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
    return '$name: replik için dokun; kaldırmak için aşağı kaydır';
  }

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
  String ntfQuestTitle(String title) {
    return '[ Görev ] $title';
  }

  @override
  String ntfPenaltyQuestTitle(String title) {
    return '[ Ceza görevi ] $title';
  }

  @override
  String ntfBossTitle(String title) {
    return '[ Haftanın patronu ] $title';
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
    return '«$title» gecikti. Sistem eylemsizliği kaydetti. Hemen tamamla.';
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
    return '«$title»: −$diamonds ◆';
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
  String get ntfNag => 'Her dakika ısrar et';

  @override
  String get ntfNagHint => '«Tamamlandı»ya basana kadar tekrar';

  @override
  String get ntfReproach => 'Sitemler';

  @override
  String get ntfReproachHint =>
      'Süre dolduktan 15 dk sonra, görev yapılmadıysa';

  @override
  String get ntfVoice => 'Ses olarak karakterin sesi';

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
      one: 'Alınacak: $count ürün · $sum',
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
  String get planChooseSection => 'Hangi bölümü değiştirmek istersiniz?';

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
  String get planModeDeficit => 'Açık';

  @override
  String get planModeSurplus => 'Fazla';

  @override
  String get planModeMaintenance => 'Koruma';

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
      'Aktivite düzeyi belirtilmedi — «hareketsiz» kabul edildi.';

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
      'Fotoğraflar, Sistemin vücut yapısını ve duruşu değerlendirmesine ve ilerlemeyi takip etmesine yardımcı olur. Bu aşama atlanabilir. Fotoğraflar cihazda saklanır.';

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
  String get qaEstBodyFat => 'Yağ oranı %';

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
  String get qaExactFat => 'Yağ oranı %';

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
      'Yüz fotoğrafları ve birkaç soru, Sistemin bakım rutini seçmesine yardımcı olur. Fotoğraflar isteğe bağlıdır.';

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
      'Telefonu yerleştirip «Başla»ya basın — gerisini Sistem sesli anlatır ve fotoğrafları kendisi çeker.';

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
  String get qaShootStop => 'Bitir';

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
      'Hepsi isteğe bağlı. Gelirler ve hesaplar, Sistemin bütçeyi ve limitleri takip etmesine yardım eder.';

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
  String get qbFinIOwe => 'Ben borçluyum';

  @override
  String get qbFinOweMe => 'Bana borçlu';

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
  String get qbPermLocationAlways => 'Konum «Her zaman»';

  @override
  String get qbPermLocationAlwaysWhy =>
      'Yürüyüşlerin arka planda kaydı ve rota ipuçları. Sistem önce «Kullanırken», sonra «Her zaman» izni isteyecek.';

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
    return 'Zindelik +$pct% deneyim';
  }

  @override
  String qeEffectDehydration(String pct) {
    return 'Susuzluk −$pct% dayanıklılık';
  }

  @override
  String qeEffectBossAura(String pct) {
    return 'Galip aurası +$pct% ◆';
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
      'Günün başarısızlıkları. Ceza görevi atandı';

  @override
  String get qeReasonMarkWalked =>
      'İşaret: arkadaşlarla gezdin. Dürüstlük cezayı hafifletir';

  @override
  String get qeReasonMarkAlcohol => 'İşaret: alkol. Yarın güçlendirilmiş plan';

  @override
  String get qeReasonMarkRelapse =>
      'İşaret: kaçamak. Yarın güçlendirilmiş plan';

  @override
  String get qeReasonBossFailed => 'Haftanın bossu yenilmedi';

  @override
  String get qeReasonReproach => 'Görev yapılmadı. Sistem memnun değil';

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
  String get qstHistMark => 'Gün işareti';

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
  String get qstMarksTitle => 'Dürüst işaretler';

  @override
  String get qstMarksHint =>
      'Dürüst işaret, gizli bir kaçamaktan daha hafiftir. Yarın — güçlendirilmiş plan.';

  @override
  String get qstMarkWalked => 'Arkadaşlarla gezdim';

  @override
  String get qstMarkAlcohol => 'Alkol';

  @override
  String get qstMarkRelapse => 'Kendimi tutamadım';

  @override
  String qstMarkConfirmTitle(String mark) {
    return 'İşaretle: $mark?';
  }

  @override
  String get qstMarkConfirmMessage =>
      'Dürüst işaret gizli kaçamaktan daha hafiftir: şimdi küçük bir ceza, yarın güçlendirilmiş plan.';

  @override
  String get qstMarkConfirm => 'İşaretle';

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
  String get qstPauseUntilRemoved => 'Bitirene kadar';

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
    return 'Boş: $count';
  }

  @override
  String qstStatPointAdd(String stat) {
    return 'Puan ekle: $stat';
  }

  @override
  String qstWindowFailedMessage(String quest, String points) {
    return '«$quest». Ceza: −$points ◆.';
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
    return 'Ceza görevi verildi: «$quest».';
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
    return 'Boş özellik puanı: $count';
  }

  @override
  String qstTitleGot(String title) {
    return 'Unvan: «$title»';
  }

  @override
  String get qstBossWonTitle => 'Boss yenildi';

  @override
  String get qstBossLostTitle => 'Boss yenilmedi';

  @override
  String get qstBossLostMessage =>
      'Hafta zafersiz kapandı. Yeni boss — pazartesi.';

  @override
  String get qstDisciplineOnTitle => 'Disiplin modu açık';

  @override
  String get qstDisciplineOnMessage =>
      'Kalkış 6:00, yatış 22:00, plan sınırları içinde ek yük. Bakiye ◆ pozitif olunca mod kapanır.';

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
  String get qstFormWeekParity => 'Hafta dönüşümü';

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
  String get qstFormNag => 'Israr et';

  @override
  String get qstFormNagHint => 'Tamamlanana kadar her dakika hatırlat';

  @override
  String get schTitle => 'Ders programı';

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
      one: '$count öğe kopyalandı',
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
      'Tüm veriler tek dosyada — «Dosyalar»a kaydedin veya kendinize gönderin';

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
  String get setDisciplineHint => '06:00 kalkış, 22:00 yatış, ek yük';

  @override
  String get setBody => 'Vücut ve sağlık';

  @override
  String get setBodyHint => 'Adımlar, uyku, ölçüler, fotoğraflar, cilt bakımı';

  @override
  String get setWorkouts => 'Antrenmanlar';

  @override
  String get setWorkoutsHint => 'Seviyene göre program, zamanlayıcılar, ses';

  @override
  String get setWalks => 'Yürüyüşler';

  @override
  String get setWalksHint => 'Dairesel rota, bölümler, müzik üstünde ses';

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
      'Bakiyeyi artıya çevirmek için görevleri tamamlayın. Disiplin modu zaten atandı.';

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
      one: 'Günde $count kez',
    );
    return '$_temp0';
  }

  @override
  String shpLimitWeek(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Haftada $count kez',
      one: 'Haftada $count kez',
    );
    return '$_temp0';
  }

  @override
  String shpLimitMonth(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Ayda $count kez',
      one: 'Ayda $count kez',
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
    return '«$title» — $price ◆. Satın alma sonrası bakiye: $after ◆.';
  }

  @override
  String shpBoughtMessage(String title) {
    return '«$title» ödülü alındı. Sistem satın almayı kaydetti.';
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
  String get shpFieldPriceHint => 'Ödülün kaç ◆ tuttuğu';

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
  String get shpToArchive => 'Arşive taşı';

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
  String get dscReasonAi => 'bir aksamadan sonra Sistem kararı';

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
      'Bakiye ◆ eksiye düşerse mod kendiliğinden açılır. Elle de açılabilir.';

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
      'Yatıştan sonra eğlence uygulamalarını engelleme daha sonra eklenecek.';

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
    return '$time kalkış';
  }

  @override
  String dscQuestBed(String time) {
    return '$time yatış';
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
      'Bugün programa göre dinlenme günü. Aşağıdaki listeden istediğin antrenmanı yapabilirsin.';

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
      one: '$count egzersiz',
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
      'Bir egzersiz ağrı veya rahatsızlık veriyorsa onu atla.';

  @override
  String get wrkLevelUnknown =>
      'Ankette seviye belirtilmemiş — başlangıç programı.';

  @override
  String wrkProgressionWeeks(int weeks) {
    return 'Tamamlanan hafta: $weeks';
  }

  @override
  String get wrkProgressionNote =>
      'Haftanın tüm antrenmanları (en fazla 3) yapılırsa hafta sayılır. Her hafta için: +1 tekrar veya +5 sn, seviyenin üst sınırına kadar.';

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
  String get wrkPhasePrepare => 'Hazırlan';

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
      one: '$reps tekrar',
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
  String get wrkStop => 'Bitir';

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
  String get wrkStopTitle => 'Antrenman bitirilsin mi?';

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
    return 'Set $set / $sets. $amount. Başla!';
  }

  @override
  String wrkSecondsAmount(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: '$seconds saniye',
      one: '$seconds saniye',
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
      'Dizlerini yükselt.\nKollar adımla birlikte çalışsın.\nDüzenli nefes al.';

  @override
  String get wrkExArmCircles => 'Kol çevirme';

  @override
  String get wrkExArmCirclesHint =>
      'Kollar omuz hizasında yanlara.\nÖnce ileri, sonra geri küçük daireler.\nOmuzlar aşağıda.';

  @override
  String get wrkExJumpingJacks => 'Jumping jack';

  @override
  String get wrkExJumpingJacksHint =>
      'Zıpla: bacaklar açık, kollar yukarı.\nGeri zıpla.\nParmak uçlarına yumuşak in.';

  @override
  String get wrkExChairSquat => 'Sandalyeye çömelme';

  @override
  String get wrkExChairSquatHint =>
      'Sandalyenin önünde dur, ayaklar omuz genişliğinde.\nKalçayı geri iterek otur.\nSarsmadan kalk.';

  @override
  String get wrkExGluteBridge => 'Kalça köprüsü';

  @override
  String get wrkExGluteBridgeHint =>
      'Sırtüstü yat, ayaklar yerde.\nKalçayı kaldır, kalça kaslarını sık.\nYavaşça in.';

  @override
  String get wrkExSquat => 'Squat';

  @override
  String get wrkExSquatHint =>
      'Ayaklar omuz genişliğinde, uçlar hafif dışa.\nKalça geri, dizler parmak yönünde.\nSırt düz, topuklar yerde.';

  @override
  String get wrkExWallSit => 'Duvarda oturma';

  @override
  String get wrkExWallSitHint =>
      'Sırt duvara yaslı.\nUyluklar yere neredeyse paralel olana kadar in.\nPozisyonu koru.';

  @override
  String get wrkExReverseLunge => 'Geri hamle';

  @override
  String get wrkExReverseLungeHint =>
      'Geriye adım at, arka dizi yere doğru indir.\nÖn diz ayağın üzerinde.\nGeri dön, bacak değiştir.';

  @override
  String get wrkExGobletSquat => 'Goblet squat';

  @override
  String get wrkExGobletSquatHint =>
      'Dambılı dik olarak göğüste tut.\nÇömel, dirsekler dizlerin arasında.\nSırt düz.';

  @override
  String get wrkExKettlebellSwing => 'Kettlebell salınımı';

  @override
  String get wrkExKettlebellSwingHint =>
      'Kettlebell iki elde, ayaklar omuzdan geniş.\nKalça geri, sonra hızla ileri.\nKettlebell kalça gücüyle göğüs hizasına çıkar.';

  @override
  String get wrkExJumpSquat => 'Zıplamalı squat';

  @override
  String get wrkExJumpSquatHint =>
      'Normal squat.\nYukarı sıçra.\nYumuşak inip squat\'a geç.';

  @override
  String get wrkExWallPushUp => 'Duvarda şınav';

  @override
  String get wrkExWallPushUpHint =>
      'Avuçlar omuz hizasında duvarda.\nKolları bük, gövde düz.\nİtip geri gel.';

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
  String get wrkExDumbbellPress => 'Yerde dambıl press';

  @override
  String get wrkExDumbbellPressHint =>
      'Yerde yat, dambıllar göğüs üstünde.\nDirsekler yere değene kadar indir.\nYukarı it.';

  @override
  String get wrkExDiamondPushUp => 'Elmas şınav';

  @override
  String get wrkExDiamondPushUpHint =>
      'Avuçlar göğsün altında yan yana.\nDirsekler gövdeye yakın.\nGövde düz.';

  @override
  String get wrkExSuperman => 'Süperman';

  @override
  String get wrkExSupermanHint =>
      'Yüzüstü yat, kollar önde.\nKol ve bacakları birkaç saniye kaldır.\nYavaşça indir.';

  @override
  String get wrkExReverseSnowAngel => 'Ters kar meleği';

  @override
  String get wrkExReverseSnowAngelHint =>
      'Yüzüstü yat, kollar yanlarda.\nGöğsü ve kolları hafif kaldır.\nKolları yay çizerek başın üstüne ve geri götür.';

  @override
  String get wrkExBandRow => 'Lastik çekiş';

  @override
  String get wrkExBandRowHint =>
      'Lastiği göğüs hizasına sabitle.\nKürek kemiklerini sıkarak bele çek.\nYavaşça bırak.';

  @override
  String get wrkExDumbbellRow => 'Eğilerek dambıl çekiş';

  @override
  String get wrkExDumbbellRowHint =>
      'Bir el ve diz sandalyeye dayalı.\nDambılı bele çek.\nSırt düz.';

  @override
  String get wrkExPullUp => 'Barfiks';

  @override
  String get wrkExPullUpHint =>
      'Tutuş omuzdan biraz geniş.\nÇeneyi bara çek.\nKontrollü in.';

  @override
  String get wrkExDeadBug => 'Ölü böcek';

  @override
  String get wrkExDeadBugHint =>
      'Sırtüstü, kollar yukarı, dizler kalça üstünde.\nZıt kol ve bacağı indir.\nBel yere bastırılı.';

  @override
  String get wrkExBirdDog => 'Kuş-köpek';

  @override
  String get wrkExBirdDogHint =>
      'Eller ve dizler yerde.\nZıt kol ve bacağı uzat.\nBekle, taraf değiştir.';

  @override
  String get wrkExPlank => 'Plank';

  @override
  String get wrkExPlankHint =>
      'Ön kollar ve ayak uçları yerde.\nGövde düz, karın sıkı.\nBelden çökme.';

  @override
  String get wrkExCrunch => 'Mekik';

  @override
  String get wrkExCrunchHint =>
      'Sırtüstü, dizler bükük.\nOmuzları dizlere doğru kaldır.\nYavaşça in.';

  @override
  String get wrkExSidePlank => 'Yan plank';

  @override
  String get wrkExSidePlankHint =>
      'Ön kol yerde, bacaklar birlikte.\nKalça yukarıda, gövde düz.\nSürenin yarısı her tarafa.';

  @override
  String get wrkExLegRaise => 'Bacak kaldırma';

  @override
  String get wrkExLegRaiseHint =>
      'Sırtüstü, kollar yanlarda.\nDüz bacakları yukarı kaldır.\nBel yerde, yavaş indir.';

  @override
  String get wrkExStepTouch => 'Yana adım';

  @override
  String get wrkExStepTouchHint =>
      'Yana adım at, ayağı birleştir.\nDiğer tarafa.\nKollar ritimle çalışsın.';

  @override
  String get wrkExShadowBoxing => 'Gölge boksu';

  @override
  String get wrkExShadowBoxingHint =>
      'Duruş, yumruklar çenede.\nSırayla hafif yumruklar.\nZıplamadan parmak uçlarında hareket et.';

  @override
  String get wrkExHighKnees => 'Yüksek diz koşusu';

  @override
  String get wrkExHighKneesHint =>
      'Yerinde koş.\nDizler bel hizasına.\nParmak uçlarına in.';

  @override
  String get wrkExMountainClimber => 'Dağcı';

  @override
  String get wrkExMountainClimberHint =>
      'Düz kollarla şınav pozisyonu.\nDizleri sırayla göğse çek.\nKalçayı kaldırma.';

  @override
  String get wrkExBurpee => 'Burpee';

  @override
  String get wrkExBurpeeHint =>
      'Çömel, eller yere.\nŞınav pozisyonuna sıçra ve geri gel.\nYukarı zıpla.';

  @override
  String get wrkExFullBodyStretch => 'Esneme';

  @override
  String get wrkExFullBodyStretchHint =>
      'Yukarı uzan, sonra öne eğil.\nUyluk ve göğsü esnet.\nYavaş nefes al, sarsma.';
}
