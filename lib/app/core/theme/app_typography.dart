import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/app_colors.dart';

/// Typography translated from the live prototype's CSS.
///
/// The interface uses Inter. The website uses Georgia for display copy; the
/// Georgia family is requested first and Lora is registered as its
/// cross-platform Google Fonts fallback for Android devices without Georgia.
abstract final class AppTypography {
  static TextStyle sans({
    double size = 10,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );

  static TextStyle serif({
    double size = 20,
    FontWeight weight = FontWeight.w400,
    Color color = AppColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    final loraFallback = GoogleFonts.lora(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
    return loraFallback.copyWith(
      fontFamily: 'Georgia',
      fontFamilyFallback: [loraFallback.fontFamily!],
    );
  }

  static TextTheme get textTheme => TextTheme(
        displayLarge: serif(size: 29, height: 1),
        displayMedium: serif(size: 25, height: 1),
        displaySmall: serif(size: 23, height: .99),
        headlineLarge: serif(size: 29, height: 1),
        headlineMedium: serif(size: 24, height: 1),
        headlineSmall: serif(size: 22, height: 1),
        titleLarge: serif(size: 20, height: 1.05),
        titleMedium: serif(size: 18, height: 1),
        titleSmall: sans(size: 11, weight: FontWeight.w600),
        bodyLarge: sans(size: 12, height: 1.45),
        bodyMedium: sans(size: 10, height: 1.45),
        bodySmall: sans(size: 8, color: AppColors.muted, height: 1.4),
        labelLarge: sans(size: 10, weight: FontWeight.w700),
        labelMedium: sans(size: 8, weight: FontWeight.w700),
        labelSmall: sans(size: 7, weight: FontWeight.w700),
      );
}
