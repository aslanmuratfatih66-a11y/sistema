// Каталог известных отвлекающих приложений (SPEC §8.6).
// Android — пакеты, отмечаемые по умолчанию; iOS — ключи для ссылок sistema://app/blocked?app=<id>.
import 'package:flutter/foundation.dart';

/// Платформа строки BlockedApps.platform.
abstract final class BlockerPlatformKey {
  static const android = 'android';
  static const ios = 'ios';
}

/// Пакеты Android, которые отмечаются по умолчанию, если установлены.
const knownDistractingAndroidPackages = <String>{
  // Короткие видео и соцсети.
  'com.zhiliaoapp.musically', // TikTok
  'com.ss.android.ugc.trill', // TikTok (Азия)
  'com.ss.android.ugc.aweme.lite', // TikTok Lite
  'com.zhiliaoapp.musically.go',
  'com.google.android.youtube',
  'app.revanced.android.youtube',
  'com.instagram.android',
  'com.instagram.barcelona', // Threads
  'com.vkontakte.android',
  'com.vk.vkvideo',
  'org.telegram.messenger',
  'org.telegram.messenger.web',
  'org.thunderdog.challegram', // Telegram X
  'com.twitter.android',
  'com.reddit.frontpage',
  'com.facebook.katana',
  'com.facebook.lite',
  'com.snapchat.android',
  'com.pinterest',
  'video.like', // Likee
  'ru.ok.android',
  'ru.rutube.app',
  'com.discord',
  'tv.twitch.android.app',
  'com.netflix.mediaclient',
  'com.kick.mobile',
  // Игры.
  'com.supercell.clashofclans',
  'com.supercell.clashroyale',
  'com.supercell.brawlstars',
  'com.supercell.squad',
  'com.mojang.minecraftpe',
  'com.roblox.client',
  'com.tencent.ig', // PUBG Mobile
  'com.pubg.imobile',
  'com.dts.freefireth',
  'com.dts.freefiremax',
  'com.activision.callofduty.shooter',
  'com.mobile.legends',
  'com.miHoYo.GenshinImpact',
  'com.HoYoverse.hkrpgoversea',
  'com.kiloo.subwaysurf',
  'com.king.candycrushsaga',
  'com.innersloth.spacemafia', // Among Us
  'com.axlebolt.standoff2',
  'com.ea.gp.fifamobile',
  'com.chess',
};

/// Приложение из каталога iOS.
@immutable
class IosBlockerApp {
  const IosBlockerApp(this.id, this.name);

  /// Ключ для ссылки (?app=…) и BlockedApps.appId.
  final String id;

  /// Название (бренд, не переводится). null — локализуемое (игры, другое).
  final String? name;
}

/// Ключ «любая игра» на iOS (название локализуется — blkIosGames).
const iosGamesAppId = 'games';

const iosBlockerCatalog = <IosBlockerApp>[
  IosBlockerApp('tiktok', 'TikTok'),
  IosBlockerApp('youtube', 'YouTube'),
  IosBlockerApp('instagram', 'Instagram'),
  IosBlockerApp('vk', 'VK'),
  IosBlockerApp('telegram', 'Telegram'),
  IosBlockerApp('x', 'X'),
  IosBlockerApp('reddit', 'Reddit'),
  IosBlockerApp('facebook', 'Facebook'),
  IosBlockerApp('snapchat', 'Snapchat'),
  IosBlockerApp('threads', 'Threads'),
  IosBlockerApp('pinterest', 'Pinterest'),
  IosBlockerApp('twitch', 'Twitch'),
  IosBlockerApp('discord', 'Discord'),
  IosBlockerApp('netflix', 'Netflix'),
  IosBlockerApp('likee', 'Likee'),
  IosBlockerApp(iosGamesAppId, null),
];

/// По умолчанию на iOS отмечены самые частые.
const iosDefaultBlockerApps = <String>{'tiktok', 'youtube', 'instagram'};

/// Ссылка для действия «Открыть URL» в автоматизации «Команд».
/// Хост `app` — Flutter передаст go_router путь `/blocked?app=<id>`.
String iosBlockerLink(String appId) => 'sistema://app/blocked?app=${Uri.encodeQueryComponent(appId)}';

/// Название из каталога iOS по ключу (null — нет в каталоге или локализуемое).
String? iosBlockerAppName(String? appId) {
  for (final a in iosBlockerCatalog) {
    if (a.id == appId) return a.name;
  }
  return null;
}
