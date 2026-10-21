import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/app/app.dart';
import 'package:sistema/core/capabilities/capability_service.dart';
import 'package:sistema/core/capabilities/preview_capability_service.dart';
import 'package:sistema/l10n/app_localizations.dart';

void main() {
  const supported = AppLocalizations.supportedLocales;

  test('язык системы: tr → tr, неизвестный → ru', () {
    expect(resolveAppLocale(const [Locale('tr', 'TR')], supported), const Locale('tr'));
    expect(resolveAppLocale(const [Locale('en'), Locale('tr')], supported), const Locale('tr'));
    expect(resolveAppLocale(const [Locale('en', 'US')], supported), const Locale('ru'));
    expect(resolveAppLocale(null, supported), const Locale('ru'));
  });

  test('веб-заглушка возможностей: iOS с датой сертификата, Android без', () async {
    final now = DateTime(2026, 10, 21);
    final ios = await PreviewCapabilityService(platform: 'ios', certDays: 5, now: () => now).load();
    expect(ios.platform, 'ios');
    expect(ios.has(Capability.remotePush), isFalse);
    expect(ios.provisioningExpiresAt, DateTime(2026, 10, 26));

    final android = await PreviewCapabilityService(platform: 'android', now: () => now).load();
    expect(android.has(Capability.appBlocking), isTrue);
    expect(android.provisioningExpiresAt, isNull);
  });
}
