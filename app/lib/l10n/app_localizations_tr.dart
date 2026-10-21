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
}
