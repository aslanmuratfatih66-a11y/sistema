// Фабрики реализаций для override в main:
//   liveActivityServiceProvider.overrideWithValue(createLiveActivityService(l10n: () => reminderL10n(db))),
//   widgetSyncProvider.overrideWithValue(createWidgetSync(l10n: () => reminderL10n(db))),
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';
import 'live_activity_service.dart';
import 'live_api.dart';
import 'widget_sync.dart';

LiveActivityService createLiveActivityService({
  required Future<AppLocalizations> Function() l10n,
  TargetPlatform? platform,
}) {
  if (kIsWeb) return const NoLiveActivityService();
  return switch (platform ?? defaultTargetPlatform) {
    TargetPlatform.iOS => ChannelLiveActivityService(),
    TargetPlatform.android => NotificationLiveActivityService(l10n: l10n),
    _ => const NoLiveActivityService(),
  };
}

WidgetSync createWidgetSync({
  required Future<AppLocalizations> Function() l10n,
  TargetPlatform? platform,
}) {
  if (kIsWeb) return const NoWidgetSync();
  final p = platform ?? defaultTargetPlatform;
  return switch (p) {
    TargetPlatform.iOS || TargetPlatform.android => HomeWidgetSync(platform: p, l10n: l10n),
    _ => const NoWidgetSync(),
  };
}
