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
}
