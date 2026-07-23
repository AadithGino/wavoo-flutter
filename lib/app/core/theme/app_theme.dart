import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.gold,
      brightness: Brightness.light,
      surface: AppColors.ivory,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.ivory,
      fontFamily: 'sans-serif',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.ivory,
        foregroundColor: AppColors.goldDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerColor: AppColors.line,
      textTheme: TextTheme(
        headlineLarge: GoogleFonts.notoSerif(
          // fontFamily: 'serif',
          fontSize: 30,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        headlineSmall: GoogleFonts.notoSerif(
          // fontFamily: 'serif',
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        titleLarge: GoogleFonts.notoSerif(
          // fontFamily: 'serif',
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        bodyMedium: GoogleFonts.notoSerif(color: AppColors.ink),
        bodySmall: GoogleFonts.notoSerif(color: AppColors.muted),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cream,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: GoogleFonts.notoSerif(color: Colors.white),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
