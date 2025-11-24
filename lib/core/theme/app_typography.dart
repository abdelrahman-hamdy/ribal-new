import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Ribal app typography system
///
/// Uses Tajawal font family for Arabic support via google_fonts.
/// Never hardcode text styles - always use this class.
abstract final class AppTypography {
  /// Font family for the entire app (using Google Fonts)
  static String get fontFamily => GoogleFonts.tajawal().fontFamily!;

  // ============================================
  // DISPLAY STYLES (Large headings)
  // ============================================

  /// Display Large - 32px Bold
  /// Usage: Main page titles, hero sections
  static TextStyle get displayLarge => GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  /// Display Medium - 28px Bold
  /// Usage: Section headers, modal titles
  static TextStyle get displayMedium => GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// Display Small - 24px SemiBold
  /// Usage: Card headers, subsection titles
  static TextStyle get displaySmall => GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  // ============================================
  // HEADLINE STYLES (Medium headings)
  // ============================================

  /// Headline Large - 22px SemiBold
  static TextStyle get headlineLarge => GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.36,
        color: AppColors.textPrimary,
      );

  /// Headline Medium - 20px SemiBold
  static TextStyle get headlineMedium => GoogleFonts.tajawal(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  /// Headline Small - 18px SemiBold
  static TextStyle get headlineSmall => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        color: AppColors.textPrimary,
      );

  // ============================================
  // TITLE STYLES (List items, cards)
  // ============================================

  /// Title Large - 18px Medium
  /// Usage: List item titles, card titles
  static TextStyle get titleLarge => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        height: 1.44,
        color: AppColors.textPrimary,
      );

  /// Title Medium - 16px Medium
  /// Usage: Subtitles, secondary titles
  static TextStyle get titleMedium => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Title Small - 14px Medium
  static TextStyle get titleSmall => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  // ============================================
  // BODY STYLES (Main content)
  // ============================================

  /// Body Large - 16px Regular
  /// Usage: Main body text, descriptions
  static TextStyle get bodyLarge => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Body Medium - 14px Regular
  /// Usage: Secondary body text
  static TextStyle get bodyMedium => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.43,
        color: AppColors.textSecondary,
      );

  /// Body Small - 12px Regular
  /// Usage: Captions, timestamps
  static TextStyle get bodySmall => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  // ============================================
  // LABEL STYLES (Buttons, chips, badges)
  // ============================================

  /// Label Large - 14px Medium
  /// Usage: Buttons, action items
  static TextStyle get labelLarge => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: AppColors.textPrimary,
      );

  /// Label Medium - 12px Medium
  /// Usage: Chips, badges, small buttons
  static TextStyle get labelMedium => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
        color: AppColors.textPrimary,
      );

  /// Label Small - 10px Medium
  /// Usage: Tiny labels, counters
  static TextStyle get labelSmall => GoogleFonts.tajawal(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.textSecondary,
      );

  // ============================================
  // BUTTON STYLES
  // ============================================

  /// Button text style
  static TextStyle get button => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.43,
        letterSpacing: 0.5,
      );

  /// Large button text style
  static TextStyle get buttonLarge => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.5,
        letterSpacing: 0.5,
      );

  /// Small button text style
  static TextStyle get buttonSmall => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.33,
        letterSpacing: 0.5,
      );

  // ============================================
  // INPUT STYLES
  // ============================================

  /// Input text style
  static TextStyle get input => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  /// Input hint style
  static TextStyle get inputHint => GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.textTertiary,
      );

  /// Input label style
  static TextStyle get inputLabel => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
        color: AppColors.textSecondary,
      );

  /// Input error style
  static TextStyle get inputError => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.error,
      );

  // ============================================
  // SPECIAL STYLES
  // ============================================

  /// App bar title
  static TextStyle get appBarTitle => GoogleFonts.tajawal(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.44,
        color: AppColors.textPrimary,
      );

  /// Bottom nav label
  static TextStyle get bottomNavLabel => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.33,
      );

  /// Tab label
  static TextStyle get tabLabel => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.43,
      );

  /// Stat value (large number)
  static TextStyle get statValue => GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
        color: AppColors.textPrimary,
      );

  /// Stat label
  static TextStyle get statLabel => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.33,
        color: AppColors.textSecondary,
      );

  // ============================================
  // TEXT THEME (for ThemeData)
  // ============================================

  static TextTheme get textTheme => TextTheme(
        displayLarge: displayLarge,
        displayMedium: displayMedium,
        displaySmall: displaySmall,
        headlineLarge: headlineLarge,
        headlineMedium: headlineMedium,
        headlineSmall: headlineSmall,
        titleLarge: titleLarge,
        titleMedium: titleMedium,
        titleSmall: titleSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelLarge: labelLarge,
        labelMedium: labelMedium,
        labelSmall: labelSmall,
      );
}
