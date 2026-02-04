/// Theme configuration with color constants and design tokens.
///
/// Colors extracted from the provided UI designs for both light and dark themes.
library;

import 'package:flutter/material.dart';

/// Design tokens and color constants for the application.
abstract class ThemeConfig {
  // ============================================================
  // LIGHT THEME COLORS (from designs)
  // ============================================================

  /// Light theme background - cream/beige (#F5F4F0)
  static const Color lightBackground = Color(0xFFF5F4F0);

  /// Light theme surface/card color - white
  static const Color lightSurface = Color(0xFFFFFFFF);

  /// Light theme primary text - near black
  static const Color lightTextPrimary = Color(0xFF1A1A1A);

  /// Light theme secondary text - gray
  static const Color lightTextSecondary = Color(0xFF6B7280);

  /// Light theme divider color
  static const Color lightDivider = Color(0xFFE5E5E5);

  // ============================================================
  // DARK THEME COLORS (from designs)
  // ============================================================

  /// Dark theme background - very dark gray (#121212)
  static const Color darkBackground = Color(0xFF121212);

  /// Dark theme surface/card color - dark gray (#1E1E1E)
  static const Color darkSurface = Color(0xFF1E1E1E);

  /// Dark theme primary text - white
  static const Color darkTextPrimary = Color(0xFFFFFFFF);

  /// Dark theme secondary text - light gray
  static const Color darkTextSecondary = Color(0xFF9CA3AF);

  /// Dark theme divider color
  static const Color darkDivider = Color(0xFF2E2E2E);

  // ============================================================
  // ACCENT COLORS (shared between themes)
  // ============================================================

  /// Primary accent color - teal (#2DD4BF)
  static const Color primaryAccent = Color(0xFF2DD4BF);

  /// Primary accent hover/pressed state
  static const Color primaryAccentDark = Color(0xFF14B8A6);

  /// Primary accent light (for backgrounds)
  static const Color primaryAccentLight = Color(0xFFCCFBF1);

  /// Error/destructive color
  static const Color error = Color(0xFFEF4444);

  /// Success color
  static const Color success = Color(0xFF22C55E);

  /// Warning color
  static const Color warning = Color(0xFFF59E0B);

  // ============================================================
  // CATEGORY TAG COLORS
  // ============================================================

  /// Work category - teal
  static const Color categoryWork = primaryAccent;

  /// Personal category - blue
  static const Color categoryPersonal = Color(0xFF3B82F6);

  /// Side Project category - purple
  static const Color categorySideProject = Color(0xFF8B5CF6);

  /// Health category - green
  static const Color categoryHealth = Color(0xFF22C55E);

  // ============================================================
  // SPACING & SIZING
  // ============================================================

  /// Extra small spacing (4px)
  static const double spacingXs = 4.0;

  /// Small spacing (8px)
  static const double spacingSm = 8.0;

  /// Medium spacing (16px)
  static const double spacingMd = 16.0;

  /// Large spacing (24px)
  static const double spacingLg = 24.0;

  /// Extra large spacing (32px)
  static const double spacingXl = 32.0;

  /// Card border radius
  static const double cardRadius = 16.0;

  /// Button border radius
  static const double buttonRadius = 12.0;

  /// Small chip/tag border radius
  static const double chipRadius = 8.0;

  /// FAB size
  static const double fabSize = 56.0;

  /// Bottom nav height
  static const double bottomNavHeight = 80.0;

  // ============================================================
  // TYPOGRAPHY SIZES
  // ============================================================

  /// Large title (e.g., "My Notes" header)
  static const double fontSizeTitle = 28.0;

  /// Section header
  static const double fontSizeHeader = 20.0;

  /// Card title
  static const double fontSizeCardTitle = 16.0;

  /// Body text
  static const double fontSizeBody = 14.0;

  /// Caption/timestamp text
  static const double fontSizeCaption = 12.0;

  /// Small label text
  static const double fontSizeLabel = 10.0;

  // ============================================================
  // ELEVATION & SHADOWS
  // ============================================================

  /// Card elevation for light theme
  static const double cardElevationLight = 2.0;

  /// Card elevation for dark theme (subtle)
  static const double cardElevationDark = 0.0;

  /// Light theme card shadow
  static const List<BoxShadow> lightCardShadow = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
  ];

  /// Dark theme card shadow (very subtle teal tint)
  static const List<BoxShadow> darkCardShadow = [
    BoxShadow(color: Color(0x0D2DD4BF), blurRadius: 4, offset: Offset(0, 1)),
  ];

  // ============================================================
  // ANIMATION DURATIONS
  // ============================================================

  /// Fast animation (150ms)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// Normal animation (300ms)
  static const Duration animationNormal = Duration(milliseconds: 300);

  /// Slow animation (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// Theme transition duration
  static const Duration themeTransition = Duration(milliseconds: 400);

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Returns the appropriate category color.
  static Color getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'work':
        return categoryWork;
      case 'personal':
        return categoryPersonal;
      case 'side project':
        return categorySideProject;
      case 'health':
        return categoryHealth;
      default:
        return primaryAccent;
    }
  }
}
