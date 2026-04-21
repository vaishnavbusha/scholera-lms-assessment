import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'palette.dart';
import 'role_theme.dart';
import 'tokens.dart';

/// Builds the Scholera [ThemeData] for a given [RoleTheme].
///
/// Typography is a single family (Plus Jakarta Sans) to keep the product
/// surface feeling modern and coherent. Only the accent colors vary across
/// roles so each shell feels distinct without fragmenting the look.
ThemeData buildAppTheme(RoleTheme role) {
  final colorScheme = _buildColorScheme(role);
  final textTheme = _buildTextTheme(colorScheme);

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: Palette.paper,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    splashFactory: InkSparkle.splashFactory,
    // Android's default ZoomPageTransitionsBuilder feels heavy when the
    // destination screen renders a loading skeleton mid-animation. Using
    // Cupertino's horizontal slide gives a calmer transition on both
    // platforms without importing Cupertino widgets elsewhere.
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      backgroundColor: Palette.paper,
      surfaceTintColor: Colors.transparent,
      foregroundColor: Palette.ink,
      elevation: Elevation.none,
      scrolledUnderElevation: Elevation.none,
      titleTextStyle: GoogleFonts.plusJakartaSans(
        color: Palette.ink,
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: Elevation.none,
      color: Palette.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: const BorderSide(color: Palette.outline, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: role.primary,
        foregroundColor: Palette.surface,
        minimumSize: const Size.fromHeight(52),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          letterSpacing: 0,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.button),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: role.primary,
        side: BorderSide(color: role.primary.withValues(alpha: 0.45)),
        minimumSize: const Size.fromHeight(48),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        shape: const RoundedRectangleBorder(borderRadius: Radii.button),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: role.primary,
        textStyle: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Palette.surface,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      hintStyle: GoogleFonts.plusJakartaSans(
        color: Palette.inkSubtle,
        fontSize: 15,
      ),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: Palette.inkMuted,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: GoogleFonts.plusJakartaSans(
        color: role.primary,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      enabledBorder: const OutlineInputBorder(
        borderRadius: Radii.input,
        borderSide: BorderSide(color: Palette.outline, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: Radii.input,
        borderSide: BorderSide(color: role.primary, width: 1.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: Radii.input,
        borderSide: BorderSide(color: Palette.error, width: 1),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: Radii.input,
        borderSide: BorderSide(color: Palette.error, width: 1.5),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: Palette.outline,
      thickness: 1,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Palette.surface,
      side: const BorderSide(color: Palette.outline),
      labelStyle: GoogleFonts.plusJakartaSans(
        color: Palette.ink,
        fontWeight: FontWeight.w500,
        fontSize: 13,
      ),
      shape: const RoundedRectangleBorder(borderRadius: Radii.pill),
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.xs,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Palette.ink,
      contentTextStyle: GoogleFonts.plusJakartaSans(
        color: Palette.surface,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: Radii.card),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: role.primary,
    ),
    iconTheme: const IconThemeData(color: Palette.ink, size: 22),
  );
}

ColorScheme _buildColorScheme(RoleTheme role) {
  return ColorScheme(
    brightness: Brightness.light,
    primary: role.primary,
    onPrimary: Palette.surface,
    primaryContainer: role.primaryContainer,
    onPrimaryContainer: role.onPrimaryContainer,
    secondary: Palette.ink,
    onSecondary: Palette.surface,
    secondaryContainer: Palette.neutralContainer,
    onSecondaryContainer: Palette.neutralOnContainer,
    tertiary: Palette.statusInProgress,
    onTertiary: Palette.surface,
    error: Palette.error,
    onError: Palette.surface,
    errorContainer: Palette.errorContainer,
    onErrorContainer: Palette.error,
    surface: Palette.paper,
    onSurface: Palette.ink,
    surfaceContainerHighest: Palette.surface,
    surfaceContainer: Palette.surface,
    surfaceContainerHigh: Palette.surface,
    surfaceContainerLow: Palette.surfaceMuted,
    surfaceContainerLowest: Palette.paper,
    onSurfaceVariant: Palette.inkMuted,
    outline: Palette.outline,
    outlineVariant: Palette.outlineStrong,
    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: Palette.ink,
    onInverseSurface: Palette.paper,
    inversePrimary: role.primaryContainer,
  );
}

TextTheme _buildTextTheme(ColorScheme colorScheme) {
  final ink = colorScheme.onSurface;
  final muted = colorScheme.onSurfaceVariant;

  return TextTheme(
    displayLarge: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 40,
      height: 1.1,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 32,
      height: 1.15,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.6,
    ),
    displaySmall: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 26,
      height: 1.2,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.4,
    ),
    headlineLarge: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 22,
      height: 1.25,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.3,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 19,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    ),
    titleLarge: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 17,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.1,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 15,
      height: 1.35,
      fontWeight: FontWeight.w600,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 13,
      height: 1.35,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
    ),
    bodyLarge: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 15,
      height: 1.5,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 14,
      height: 1.45,
      fontWeight: FontWeight.w400,
    ),
    bodySmall: GoogleFonts.plusJakartaSans(
      color: muted,
      fontSize: 12,
      height: 1.4,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
    ),
    labelLarge: GoogleFonts.plusJakartaSans(
      color: ink,
      fontSize: 14,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelMedium: GoogleFonts.plusJakartaSans(
      color: muted,
      fontSize: 12,
      height: 1.3,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
    ),
    labelSmall: GoogleFonts.plusJakartaSans(
      color: muted,
      fontSize: 11,
      height: 1.3,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}
