/// App settings model for persisting user preferences.
library;

import 'dart:convert';

/// Available theme modes for the application.
enum AppThemeMode {
  /// Light theme with cream/beige background.
  light,

  /// Dark theme with dark gray background.
  dark,

  /// Follow system theme settings.
  system,
}

/// Represents application-wide settings and user preferences.
class AppSettings {
  /// Current theme mode preference.
  final AppThemeMode themeMode;

  /// Primary accent color name (e.g., "teal", "blue").
  final String accentColor;

  /// User's display name (if logged in).
  final String? userName;

  /// User's email address (if logged in).
  final String? userEmail;

  /// Creates a new [AppSettings] instance.
  const AppSettings({
    this.themeMode = AppThemeMode.light,
    this.accentColor = 'teal',
    this.userName,
    this.userEmail,
  });

  /// Default settings for new users.
  static const AppSettings defaults = AppSettings();

  /// Creates a copy with the specified fields replaced.
  AppSettings copyWith({
    AppThemeMode? themeMode,
    String? accentColor,
    String? userName,
    String? userEmail,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
    );
  }

  /// Converts settings to JSON string for SharedPreferences.
  String toJson() {
    return jsonEncode({
      'themeMode': themeMode.name,
      'accentColor': accentColor,
      'userName': userName,
      'userEmail': userEmail,
    });
  }

  /// Creates settings from JSON string.
  factory AppSettings.fromJson(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return AppSettings(
        themeMode: AppThemeMode.values.firstWhere(
          (e) => e.name == map['themeMode'],
          orElse: () => AppThemeMode.light,
        ),
        accentColor: map['accentColor'] as String? ?? 'teal',
        userName: map['userName'] as String?,
        userEmail: map['userEmail'] as String?,
      );
    } catch (_) {
      return AppSettings.defaults;
    }
  }

  /// Returns true if dark mode is currently active.
  bool get isDarkMode => themeMode == AppThemeMode.dark;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.accentColor == accentColor &&
        other.userName == userName &&
        other.userEmail == userEmail;
  }

  @override
  int get hashCode {
    return Object.hash(themeMode, accentColor, userName, userEmail);
  }

  @override
  String toString() {
    return 'AppSettings(themeMode: $themeMode, accentColor: $accentColor)';
  }
}
