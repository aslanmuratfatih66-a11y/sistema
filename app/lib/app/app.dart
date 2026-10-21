import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/data/app_locale.dart';
import '../features/onboarding/onboarding_progress.dart';
import '../l10n/app_localizations.dart';
import '../ui/ui.dart';
import 'router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = buildRouter(ref.watch(onboardingProgressProvider));
  ref.onDispose(router.dispose);
  return router;
});

class SistemaApp extends ConsumerWidget {
  const SistemaApp({super.key, this.locale});

  /// Принудительный язык (тесты). null — язык из профиля, иначе системы: tr → турецкий, иначе русский.
  final Locale? locale;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp.router(
        onGenerateTitle: (c) => AppLocalizations.of(c).appTitle,
        debugShowCheckedModeBanner: false,
        theme: buildSystemTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: ref.watch(routerProvider),
        locale: locale ?? ref.watch(appLocaleProvider),
        localeListResolutionCallback: resolveAppLocale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      );
}

/// Первый поддерживаемый язык из списка системы, иначе русский (SPEC §1).
Locale resolveAppLocale(List<Locale>? preferred, Iterable<Locale> supported) {
  for (final p in preferred ?? const <Locale>[]) {
    for (final s in supported) {
      if (s.languageCode == p.languageCode) return s;
    }
  }
  return const Locale('ru');
}
