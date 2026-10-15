import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  AppTypography._();

  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.25,
  );

  static TextStyle headlineLarge = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle headlineMedium = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
    height: 1.35,
  );

  static TextStyle headlineSmall = GoogleFonts.inter(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.35,
  );

  static TextStyle titleMedium = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.45,
  );

  static TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
    height: 1.4,
  );

  static TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.25,
    height: 1.4,
  );

  static TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: AppColors.textSecondary,
    letterSpacing: 0.8,
    height: 1.3,
  );

  /// Specialized style for High Security Registration Plate (HSRP) representation
  static TextStyle plateDisplay = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: 2.2,
    fontFeatures: const [FontFeature.tabularFigures()],
  );

  // Semantic Typography Aliases
  static TextStyle get heading2 => headlineMedium;
  static TextStyle get heading3 => headlineSmall;
  static TextStyle get label => labelSmall;
  static TextStyle get licensePlate => plateDisplay;
}
