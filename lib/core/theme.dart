import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Thème sombre "media" : indigo profond, surfaces quasi noires, Poppins.
ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF6366F1),
    brightness: Brightness.dark,
    surface: const Color(0xFF12121F),
  );

  final base = ThemeData(colorScheme: scheme);

  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF0D0D17),
    textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF0D0D17),
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF12121F),
      indicatorColor: scheme.primaryContainer,
      height: 68,
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        visualDensity: VisualDensity.compact,
        textStyle: GoogleFonts.poppins(
            fontSize: 12.5, fontWeight: FontWeight.w500),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    expansionTileTheme: const ExpansionTileThemeData(
      shape: Border(),
      collapsedShape: Border(),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
    }),
  );
}
