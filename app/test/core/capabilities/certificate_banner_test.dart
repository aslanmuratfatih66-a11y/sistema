import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sistema/core/capabilities/capability_service.dart';
import 'package:sistema/core/capabilities/certificate_banner.dart';
import 'package:sistema/core/capabilities/certificate_status.dart';
import 'package:sistema/l10n/app_localizations.dart';

void main() {
  final now = DateTime(2026, 10, 21, 10, 46);

  Widget app(DateTime? expiresAt) => ProviderScope(
        overrides: [
          deviceCapabilitiesProvider.overrideWith(
            (ref) async => DeviceCapabilities(
              platform: 'ios',
              available: const {},
              provisioningExpiresAt: expiresAt,
            ),
          ),
          certificateClockProvider.overrideWithValue(() => now),
        ],
        child: const MaterialApp(
          locale: Locale('ru'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CertificateBanner()),
        ),
      );

  testWidgets('3 дня — «Сертификат истекает через 3 дня»', (tester) async {
    await tester.pumpWidget(app(DateTime(2026, 10, 24, 9)));
    await tester.pumpAndSettle();
    expect(find.text('Сертификат истекает через 3 дня'), findsOneWidget);
  });

  testWidgets('истёк — certExpired', (tester) async {
    await tester.pumpWidget(app(DateTime(2026, 10, 20)));
    await tester.pumpAndSettle();
    expect(find.text('Сертификат истёк — переустановите приложение'), findsOneWidget);
  });

  testWidgets('профиля нет — пусто', (tester) async {
    await tester.pumpWidget(app(null));
    await tester.pumpAndSettle();
    expect(find.byType(CertificateBanner), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });
}
