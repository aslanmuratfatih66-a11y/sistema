import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'tokens.dart';

/// Единственная (тёмная) тема приложения.
ThemeData buildSystemTheme() {
  const scheme = ColorScheme.dark(
    primary: SysColors.accent,
    onPrimary: SysColors.background,
    primaryContainer: SysColors.panelTop,
    onPrimaryContainer: SysColors.accentLighter,
    secondary: SysColors.accentLight,
    onSecondary: SysColors.background,
    tertiary: SysColors.gold,
    onTertiary: SysColors.background,
    error: SysColors.danger,
    onError: SysColors.background,
    errorContainer: Color(0xFF3C0C14),
    onErrorContainer: SysColors.dangerLight,
    surface: Color(0xFF060D1C),
    onSurface: SysColors.textPrimary,
    onSurfaceVariant: SysColors.textSecondary,
    surfaceContainerLowest: SysColors.background,
    surfaceContainerLow: Color(0xFF050B18),
    surfaceContainer: Color(0xFF081226),
    surfaceContainerHigh: Color(0xFF0B1830),
    surfaceContainerHighest: Color(0xFF0D2044),
    outline: SysColors.panelBorder,
    outlineVariant: Color.fromRGBO(63, 180, 255, .22),
    shadow: Color(0xFF000000),
    scrim: SysColors.barrier,
    inverseSurface: SysColors.textPrimary,
    onInverseSurface: SysColors.background,
    inversePrimary: Color(0xFF0D5C99),
    surfaceTint: Colors.transparent,
  );

  final textTheme = TextTheme(
    displayLarge: SysText.display.copyWith(fontSize: 40, letterSpacing: SysDims.headingSpacing(40)),
    displayMedium: SysText.display.copyWith(fontSize: 34, letterSpacing: SysDims.headingSpacing(34)),
    displaySmall: SysText.display,
    headlineLarge: SysText.heading.copyWith(fontSize: 24, letterSpacing: SysDims.headingSpacing(24)),
    headlineMedium: SysText.heading.copyWith(fontSize: 20, letterSpacing: SysDims.headingSpacing(20)),
    headlineSmall: SysText.heading.copyWith(fontSize: 18, letterSpacing: SysDims.headingSpacing(18)),
    titleLarge: SysText.heading,
    titleMedium: SysText.title,
    titleSmall: SysText.label,
    bodyLarge: SysText.body.copyWith(fontSize: 16),
    bodyMedium: SysText.body,
    bodySmall: SysText.secondary,
    labelLarge: SysText.label,
    labelMedium: SysText.caption.copyWith(fontSize: 12),
    labelSmall: SysText.caption,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: SysColors.background,
    canvasColor: SysColors.background,
    fontFamily: SysFonts.body,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    splashColor: SysColors.accent.withValues(alpha: .16),
    highlightColor: SysColors.accent.withValues(alpha: .08),
    hoverColor: SysColors.accent.withValues(alpha: .06),
    focusColor: SysColors.accent.withValues(alpha: .18),
    splashFactory: InkRipple.splashFactory,
    dividerColor: const Color.fromRGBO(63, 180, 255, .18),
    dividerTheme: const DividerThemeData(color: Color.fromRGBO(63, 180, 255, .18), thickness: 1, space: 1),
    iconTheme: const IconThemeData(color: SysColors.accentLight, size: 20),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: SysColors.accentLight,
      selectionColor: SysColors.accent.withValues(alpha: .35),
      selectionHandleColor: SysColors.accent,
    ),
    scrollbarTheme: ScrollbarThemeData(
      thickness: const WidgetStatePropertyAll(3),
      radius: const Radius.circular(2),
      thumbColor: WidgetStatePropertyAll(SysColors.accent.withValues(alpha: .45)),
      trackColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF081226),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SysDims.radius),
        side: const BorderSide(color: SysColors.panelBorder),
      ),
      titleTextStyle: SysText.heading,
      contentTextStyle: SysText.body,
      barrierColor: SysColors.barrier,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Color(0xFF081226),
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: SysColors.barrier,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SysDims.radius)),
        side: BorderSide(color: SysColors.panelBorder),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: const Color(0xFF0B1830),
      contentTextStyle: SysText.body,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SysDims.radius),
        side: const BorderSide(color: SysColors.panelBorder),
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: const Color(0xFF0B1830),
        border: Border.all(color: SysColors.panelBorder),
        borderRadius: BorderRadius.circular(SysDims.radius),
      ),
      textStyle: SysText.caption.copyWith(color: SysColors.textPrimary),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(13, 32, 68, .6),
      hintStyle: SysText.secondary.copyWith(color: SysColors.textInactive),
      labelStyle: SysText.secondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SysDims.radius),
        borderSide: const BorderSide(color: SysColors.panelBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SysDims.radius),
        borderSide: const BorderSide(color: Color.fromRGBO(63, 180, 255, .35)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SysDims.radius),
        borderSide: const BorderSide(color: SysColors.accentLight, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(SysDims.radius),
        borderSide: const BorderSide(color: SysColors.danger),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: SysColors.accent,
      linearTrackColor: Color.fromRGBO(63, 180, 255, .12),
      circularTrackColor: Color.fromRGBO(63, 180, 255, .12),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(backgroundColor: SysColors.background),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(backgroundColor: SysColors.background),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(backgroundColor: SysColors.background),
      },
    ),
    materialTapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );
}

/// Готовые стили текста. Заголовки — капс: вызывающий передаёт текст как есть,
/// компоненты сами делают toUpperCase. Заголовки — Oswald с интервалом 0.13em,
/// числа — JetBrains Mono с табличными цифрами.
abstract final class SysText {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Крупный заголовок экрана / уровень.
  static const TextStyle display = TextStyle(
    fontFamily: SysFonts.heading,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 28 * 0.13,
    height: 1.15,
    color: SysColors.textPrimary,
  );

  static const TextStyle heading = TextStyle(
    fontFamily: SysFonts.heading,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 16 * 0.13,
    height: 1.25,
    color: SysColors.textPrimary,
  );

  static const TextStyle title = TextStyle(
    fontFamily: SysFonts.heading,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 13 * 0.13,
    height: 1.25,
    color: SysColors.textPrimary,
  );

  /// Подписи кнопок, вкладок, пилюль (Oswald, капс).
  static const TextStyle label = TextStyle(
    fontFamily: SysFonts.heading,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    letterSpacing: 13 * 0.13,
    height: 1.2,
    color: SysColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: SysFonts.body,
    fontSize: 14,
    height: 1.4,
    color: SysColors.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontFamily: SysFonts.body,
    fontSize: 13,
    height: 1.4,
    color: SysColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: SysFonts.body,
    fontSize: 11,
    height: 1.35,
    color: SysColors.textCaption,
  );

  static const TextStyle mono = TextStyle(
    fontFamily: SysFonts.mono,
    fontSize: 13,
    height: 1.3,
    color: SysColors.textPrimary,
    fontFeatures: _tabular,
  );

  static const TextStyle monoSmall = TextStyle(
    fontFamily: SysFonts.mono,
    fontSize: 11,
    height: 1.3,
    color: SysColors.textSecondary,
    fontFeatures: _tabular,
  );

  static const TextStyle monoLarge = TextStyle(
    fontFamily: SysFonts.mono,
    fontSize: 22,
    fontWeight: FontWeight.w500,
    height: 1.2,
    color: SysColors.textPrimary,
    fontFeatures: _tabular,
  );
}
