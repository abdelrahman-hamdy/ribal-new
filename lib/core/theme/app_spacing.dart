import 'package:flutter/material.dart';

/// Ribal app spacing system
///
/// Consistent spacing scale for margins, paddings, and gaps.
/// Never hardcode spacing values - always use this class.
abstract final class AppSpacing {
  // ============================================
  // SPACING SCALE
  // ============================================

  /// 2px - Minimal spacing
  static const double xxs = 2.0;

  /// 4px - Extra small
  static const double xs = 4.0;

  /// 8px - Small
  static const double sm = 8.0;

  /// 12px - Small-Medium
  static const double smd = 12.0;

  /// 16px - Medium (default)
  static const double md = 16.0;

  /// 20px - Medium-Large
  static const double mlg = 20.0;

  /// 24px - Large
  static const double lg = 24.0;

  /// 32px - Extra large
  static const double xl = 32.0;

  /// 48px - 2X Extra large
  static const double xxl = 48.0;

  /// 64px - 3X Extra large
  static const double xxxl = 64.0;

  // ============================================
  // BORDER RADIUS
  // ============================================

  /// 4px radius
  static const double radiusXs = 4.0;

  /// 8px radius
  static const double radiusSm = 8.0;

  /// 12px radius (default for cards)
  static const double radiusMd = 12.0;

  /// 16px radius
  static const double radiusLg = 16.0;

  /// 24px radius
  static const double radiusXl = 24.0;

  /// Full circular radius
  static const double radiusFull = 999.0;

  // ============================================
  // BORDER RADIUS (BorderRadius objects)
  // ============================================

  static const BorderRadius borderRadiusXs = BorderRadius.all(Radius.circular(radiusXs));
  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(radiusSm));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(radiusMd));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(radiusLg));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(radiusXl));
  static const BorderRadius borderRadiusFull = BorderRadius.all(Radius.circular(radiusFull));

  // ============================================
  // COMMON PADDING PRESETS
  // ============================================

  /// Page padding (horizontal)
  static const EdgeInsets pagePaddingHorizontal = EdgeInsets.symmetric(horizontal: md);

  /// Page padding (all sides)
  static const EdgeInsets pagePadding = EdgeInsets.all(md);

  /// Card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(md);

  /// Card padding (small)
  static const EdgeInsets cardPaddingSm = EdgeInsets.all(smd);

  /// List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: smd,
  );

  /// Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: smd,
  );

  /// Button padding (small)
  static const EdgeInsets buttonPaddingSm = EdgeInsets.symmetric(
    horizontal: md,
    vertical: sm,
  );

  /// Input padding
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: md,
    vertical: smd,
  );

  /// Chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: smd,
    vertical: xs,
  );

  /// Dialog padding
  static const EdgeInsets dialogPadding = EdgeInsets.all(lg);

  /// Bottom sheet padding
  static const EdgeInsets bottomSheetPadding = EdgeInsets.fromLTRB(md, sm, md, md);

  // ============================================
  // ICON SIZES
  // ============================================

  /// 16px - Small icons
  static const double iconSm = 16.0;

  /// 20px - Default icons
  static const double iconMd = 20.0;

  /// 24px - Large icons
  static const double iconLg = 24.0;

  /// 32px - Extra large icons
  static const double iconXl = 32.0;

  /// 48px - Feature icons
  static const double iconXxl = 48.0;

  // ============================================
  // BUTTON HEIGHTS
  // ============================================

  /// 36px - Small button
  static const double buttonHeightSm = 36.0;

  /// 44px - Medium button
  static const double buttonHeightMd = 44.0;

  /// 52px - Large button
  static const double buttonHeightLg = 52.0;

  // ============================================
  // INPUT HEIGHTS
  // ============================================

  /// 48px - Default input height
  static const double inputHeight = 48.0;

  /// 56px - Large input height
  static const double inputHeightLg = 56.0;

  // ============================================
  // AVATAR SIZES
  // ============================================

  /// 24px - Extra small avatar
  static const double avatarXs = 24.0;

  /// 32px - Small avatar
  static const double avatarSm = 32.0;

  /// 40px - Medium avatar
  static const double avatarMd = 40.0;

  /// 48px - Large avatar
  static const double avatarLg = 48.0;

  /// 64px - Extra large avatar
  static const double avatarXl = 64.0;

  /// 96px - Profile avatar
  static const double avatarXxl = 96.0;

  // ============================================
  // APP BAR
  // ============================================

  /// App bar height
  static const double appBarHeight = 56.0;

  /// Bottom nav height
  static const double bottomNavHeight = 64.0;

  // ============================================
  // CARD DIMENSIONS
  // ============================================

  /// Minimum card width
  static const double cardMinWidth = 280.0;

  /// Maximum content width (for tablets/web)
  static const double maxContentWidth = 600.0;

  // ============================================
  // ANIMATION DURATIONS
  // ============================================

  /// Fast animation (150ms)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Normal animation (250ms)
  static const Duration animationNormal = Duration(milliseconds: 250);

  /// Slow animation (350ms)
  static const Duration animationSlow = Duration(milliseconds: 350);

  /// Page transition (300ms)
  static const Duration pageTransition = Duration(milliseconds: 300);
}
