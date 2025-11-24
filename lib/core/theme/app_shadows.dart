import 'package:flutter/material.dart';

/// Ribal app shadow definitions
///
/// Consistent shadow system for elevation effects.
/// Never hardcode shadows - always use this class.
abstract final class AppShadows {
  // ============================================
  // BOX SHADOWS
  // ============================================

  /// No shadow
  static const List<BoxShadow> none = [];

  /// Extra small shadow - Subtle elevation
  /// Usage: Chips, badges
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Small shadow - Light elevation
  /// Usage: Cards, buttons
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Medium shadow - Standard elevation
  /// Usage: Elevated cards, dropdowns
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Large shadow - High elevation
  /// Usage: Modals, dialogs
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Extra large shadow - Maximum elevation
  /// Usage: Floating elements, overlays
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  // ============================================
  // COLORED SHADOWS
  // ============================================

  /// Primary color shadow
  static List<BoxShadow> primarySm = [
    BoxShadow(
      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Success color shadow
  static List<BoxShadow> successSm = [
    BoxShadow(
      color: const Color(0xFF10B981).withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Error color shadow
  static List<BoxShadow> errorSm = [
    BoxShadow(
      color: const Color(0xFFEF4444).withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  /// Warning color shadow
  static List<BoxShadow> warningSm = [
    BoxShadow(
      color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  // ============================================
  // INNER SHADOWS
  // ============================================

  /// Inner shadow for inset effect
  static const List<BoxShadow> innerSm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 2,
      offset: Offset(0, 1),
      spreadRadius: -1,
    ),
  ];

  // ============================================
  // BOTTOM NAV SHADOW
  // ============================================

  /// Bottom navigation bar shadow
  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, -2),
    ),
  ];

  // ============================================
  // APP BAR SHADOW
  // ============================================

  /// App bar shadow (when scrolled)
  static const List<BoxShadow> appBar = [
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];
}
