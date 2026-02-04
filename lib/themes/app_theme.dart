/// Application theme definitions for light and dark modes.
///
/// Implements Material 3 theming based on the provided UI designs.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'theme_config.dart';

/// Provides light and dark [ThemeData] for the application.
abstract class AppTheme {
  // ============================================================
  // LIGHT THEME
  // ============================================================

  /// Light theme matching the UI designs.
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: ThemeConfig.primaryAccent,
        onPrimary: Colors.white,
        secondary: ThemeConfig.primaryAccent,
        onSecondary: Colors.white,
        surface: ThemeConfig.lightSurface,
        onSurface: ThemeConfig.lightTextPrimary,
        error: ThemeConfig.error,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: ThemeConfig.lightBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConfig.lightBackground,
        foregroundColor: ThemeConfig.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ThemeConfig.lightTextPrimary,
          fontSize: ThemeConfig.fontSizeHeader,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: ThemeConfig.primaryAccent),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: ThemeConfig.lightSurface,
        elevation: ThemeConfig.cardElevationLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThemeConfig.lightSurface,
        selectedItemColor: ThemeConfig.primaryAccent,
        unselectedItemColor: ThemeConfig.lightTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ThemeConfig.primaryAccent,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Text Theme
      textTheme: _buildTextTheme(
        ThemeConfig.lightTextPrimary,
        ThemeConfig.lightTextSecondary,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConfig.lightSurface,
        hintStyle: const TextStyle(color: ThemeConfig.lightTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          borderSide: const BorderSide(
            color: ThemeConfig.primaryAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConfig.spacingMd,
          vertical: ThemeConfig.spacingSm,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: ThemeConfig.lightDivider,
        thickness: 1,
        space: 1,
      ),

      // Switch (for settings)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ThemeConfig.primaryAccent;
          }
          return ThemeConfig.lightTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ThemeConfig.primaryAccentLight;
          }
          return ThemeConfig.lightDivider;
        }),
      ),

      // Cupertino overrides
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: ThemeConfig.primaryAccent,
        brightness: Brightness.light,
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  /// Dark theme matching the UI designs.
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: ThemeConfig.primaryAccent,
        onPrimary: Colors.black,
        secondary: ThemeConfig.primaryAccent,
        onSecondary: Colors.black,
        surface: ThemeConfig.darkSurface,
        onSurface: ThemeConfig.darkTextPrimary,
        error: ThemeConfig.error,
        onError: Colors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: ThemeConfig.darkBackground,

      // App Bar
      appBarTheme: const AppBarTheme(
        backgroundColor: ThemeConfig.darkBackground,
        foregroundColor: ThemeConfig.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ThemeConfig.darkTextPrimary,
          fontSize: ThemeConfig.fontSizeHeader,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: ThemeConfig.primaryAccent),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: ThemeConfig.darkSurface,
        elevation: ThemeConfig.cardElevationDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThemeConfig.darkBackground,
        selectedItemColor: ThemeConfig.primaryAccent,
        unselectedItemColor: ThemeConfig.darkTextSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: ThemeConfig.primaryAccent,
        foregroundColor: Colors.black,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Text Theme
      textTheme: _buildTextTheme(
        ThemeConfig.darkTextPrimary,
        ThemeConfig.darkTextSecondary,
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThemeConfig.darkSurface,
        hintStyle: const TextStyle(color: ThemeConfig.darkTextSecondary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          borderSide: const BorderSide(
            color: ThemeConfig.primaryAccent,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: ThemeConfig.spacingMd,
          vertical: ThemeConfig.spacingSm,
        ),
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: ThemeConfig.darkDivider,
        thickness: 1,
        space: 1,
      ),

      // Switch (for settings)
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ThemeConfig.primaryAccent;
          }
          return ThemeConfig.darkTextSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return ThemeConfig.primaryAccentDark;
          }
          return ThemeConfig.darkDivider;
        }),
      ),

      // Cupertino overrides
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: ThemeConfig.primaryAccent,
        brightness: Brightness.dark,
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  /// Builds consistent text theme.
  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    return TextTheme(
      // Large titles (My Notes header)
      displayLarge: TextStyle(
        fontSize: ThemeConfig.fontSizeTitle,
        fontWeight: FontWeight.bold,
        color: primary,
        letterSpacing: -0.5,
      ),

      // Section headers
      headlineMedium: TextStyle(
        fontSize: ThemeConfig.fontSizeHeader,
        fontWeight: FontWeight.w600,
        color: primary,
      ),

      // Card titles
      titleMedium: TextStyle(
        fontSize: ThemeConfig.fontSizeCardTitle,
        fontWeight: FontWeight.w600,
        color: primary,
      ),

      // Body text
      bodyLarge: TextStyle(
        fontSize: ThemeConfig.fontSizeBody,
        fontWeight: FontWeight.normal,
        color: primary,
      ),

      // Secondary body text
      bodyMedium: TextStyle(
        fontSize: ThemeConfig.fontSizeBody,
        fontWeight: FontWeight.normal,
        color: secondary,
      ),

      // Caption/timestamp
      bodySmall: TextStyle(
        fontSize: ThemeConfig.fontSizeCaption,
        fontWeight: FontWeight.normal,
        color: secondary,
      ),

      // Labels
      labelSmall: TextStyle(
        fontSize: ThemeConfig.fontSizeLabel,
        fontWeight: FontWeight.w500,
        color: secondary,
        letterSpacing: 0.5,
      ),
    );
  }
}
