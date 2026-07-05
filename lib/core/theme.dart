import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Direction "salle de projection" : neutres chauds quasi noirs, un seul
/// accent ambre tungstène (lumière de marquee) — la couleur vient des
/// posters. Titres en Barlow Semi Condensed (habillage broadcast), corps en
/// Barlow, données de suivi (codes épisodes, compteurs, dates) en mono.
const screenBlack = Color(0xFF12100D);
const charcoal = Color(0xFF1C1915);
const charcoalHigh = Color(0xFF2B2620);
const tungsten = Color(0xFFE7A33C);
const linen = Color(0xFFEFE9DD);
const dust = Color(0xFF9C9284);
const outlineDim = Color(0xFF3A342B);

/// Style des données de suivi : S02E05, 123/250, dates de diffusion.
TextStyle mono({
  double size = 12,
  Color color = dust,
  FontWeight weight = FontWeight.w500,
  double? letterSpacing,
}) =>
    GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.3,
      letterSpacing: letterSpacing,
    );

/// Titres condensés (tuiles, écrans).
TextStyle condensed({
  double size = 15,
  Color color = linen,
  FontWeight weight = FontWeight.w600,
  double letterSpacing = 0.2,
}) =>
    GoogleFonts.barlowSemiCondensed(
      fontSize: size,
      fontWeight: weight,
      color: color,
      letterSpacing: letterSpacing,
      height: 1.15,
    );

ThemeData buildTheme() {
  const scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: tungsten,
    onPrimary: Color(0xFF221603),
    primaryContainer: Color(0xFF3C2F12),
    onPrimaryContainer: Color(0xFFF4D391),
    secondary: tungsten,
    onSecondary: Color(0xFF221603),
    secondaryContainer: Color(0xFF322817),
    onSecondaryContainer: Color(0xFFF0CD8E),
    tertiary: dust,
    onTertiary: screenBlack,
    error: Color(0xFFE07A6B),
    onError: Color(0xFF2B0E08),
    surface: screenBlack,
    onSurface: linen,
    onSurfaceVariant: dust,
    surfaceContainerLowest: Color(0xFF0D0B09),
    surfaceContainerLow: Color(0xFF171410),
    surfaceContainer: charcoal,
    surfaceContainerHigh: Color(0xFF231F1A),
    surfaceContainerHighest: charcoalHigh,
    outline: Color(0xFF474034),
    outlineVariant: Color(0xFF322D25),
    inverseSurface: linen,
    onInverseSurface: screenBlack,
    inversePrimary: Color(0xFF7A5A1C),
    shadow: Colors.black,
    scrim: Colors.black,
  );

  final base = ThemeData(colorScheme: scheme);
  final bodyText = GoogleFonts.barlowTextTheme(base.textTheme);

  return base.copyWith(
    scaffoldBackgroundColor: screenBlack,
    textTheme: bodyText.copyWith(
      titleLarge: condensed(size: 22),
      titleMedium: condensed(size: 17),
      titleSmall: condensed(size: 15),
      headlineMedium: condensed(size: 30, weight: FontWeight.w700),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: screenBlack,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.barlowSemiCondensed(
        fontSize: 19,
        fontWeight: FontWeight.w600,
        letterSpacing: 2.2,
        color: linen,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF171410),
      indicatorColor: Colors.transparent,
      height: 66,
      iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? tungsten : dust,
          )),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (states) => GoogleFonts.barlowSemiCondensed(
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: states.contains(WidgetState.selected) ? linen : dust,
        ),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: charcoalHigh,
      contentTextStyle: GoogleFonts.barlow(fontSize: 14, color: linen),
    ),
    expansionTileTheme: const ExpansionTileThemeData(
      shape: Border(),
      collapsedShape: Border(),
      iconColor: dust,
      collapsedIconColor: dust,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    }),
  );
}
