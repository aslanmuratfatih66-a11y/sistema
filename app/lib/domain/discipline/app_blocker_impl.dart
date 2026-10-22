// Реализации AppBlocker (SPEC §8.6): Android — UsageStats + оверлей через канал; iOS — без настоящей
// блокировки (мастер «Команд» в BlockerSetupScreen), только запоминает окно для BlockedScreen.
import 'package:flutter/foundation.dart';

import '../../core/db/database.dart';
import '../../core/notifications/reminder_texts.dart';
import '../../l10n/app_localizations.dart';
import 'app_blocker.dart';
import 'app_blocker_catalog.dart';
import 'app_blocker_channel.dart';
import 'app_blocker_repository.dart';
import 'app_blocker_window.dart';

/// Блокировщик для текущей платформы (для override appBlockerProvider в main).
AppBlocker createPlatformAppBlocker(AppDatabase db) {
  if (kIsWeb) return const NoopAppBlocker();
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => AndroidAppBlocker(db),
    TargetPlatform.iOS => IosAppBlocker(db),
    _ => const NoopAppBlocker(),
  };
}

/// Тексты оверлея/уведомления на языке профиля.
BlockerTexts blockerTexts(AppLocalizations l, DateTime until) {
  final time = reminderTime(until);
  return BlockerTexts(
    title: l.blkOverlayTitle,
    body: l.blkOverlayBody(time),
    button: l.blkOverlayButton,
    notificationTitle: l.blkNotifTitle,
    notificationBody: l.blkNotifBody(time),
  );
}

class AndroidAppBlocker implements AppBlocker {
  AndroidAppBlocker(this._db, {this._channel = const BlockerChannel()})
      : _repo = AppBlockerRepository(_db);

  final AppDatabase _db;
  final BlockerChannel _channel;
  final AppBlockerRepository _repo;

  BlockerChannel get channel => _channel;

  @override
  Future<bool> isAvailable() async => await _channel.hasUsageAccess() && await _channel.canDrawOverlays();

  @override
  Future<void> blockFrom(DateTime from, DateTime until, {List<String> appIds = const []}) async {
    final ids = appIds.isNotEmpty ? appIds : await _repo.enabledAppIds(BlockerPlatformKey.android);
    await BlockWindowStore.write(_db, BlockWindow(from, until));
    if (ids.isEmpty) {
      await _channel.clear();
      return;
    }
    final l = await reminderL10n(_db);
    await _channel.setSchedule(appIds: ids, from: from, until: until, texts: blockerTexts(l, until));
  }

  @override
  Future<void> unblock() async {
    await BlockWindowStore.clear(_db);
    await _channel.clear();
  }
}

/// iOS: прямой блокировки нет (SPEC §3) — isAvailable=false. Автоматизации «Команд» открывают
/// sistema://app/blocked?app=…, а BlockedScreen по сохранённому окну решает, «сейчас блок» или нет.
class IosAppBlocker implements AppBlocker {
  const IosAppBlocker(this._db);

  final AppDatabase _db;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<void> blockFrom(DateTime from, DateTime until, {List<String> appIds = const []}) =>
      BlockWindowStore.write(_db, BlockWindow(from, until));

  @override
  Future<void> unblock() => BlockWindowStore.clear(_db);
}
