/// Theme provider for managing light/dark mode state.
///
/// Uses SharedPreferences for persistence across app restarts.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import '../themes/app_theme.dart';

/// Key for storing theme preference in SharedPreferences.
const String _themePrefKey = 'app_settings';

/// Provider for [SharedPreferences] instance.
/// Must be overridden in main.dart with actual instance.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for current app settings.
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

/// Provider for current [ThemeData] based on settings.
final themeProvider = Provider<ThemeData>((ref) {
  final settings = ref.watch(appSettingsProvider);
  return settings.isDarkMode ? AppTheme.dark : AppTheme.light;
});

/// Provider for current [ThemeMode].
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(appSettingsProvider);
  switch (settings.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

/// Notifier for managing app settings state.
class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    _loadSettings();
    return AppSettings.defaults;
  }

  /// Loads settings from SharedPreferences.
  Future<void> _loadSettings() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final json = prefs.getString(_themePrefKey);
      if (json != null) {
        state = AppSettings.fromJson(json);
      }
    } catch (e) {
      // Use defaults on error
      debugPrint('Failed to load settings: $e');
    }
  }

  /// Toggles between light and dark mode.
  Future<void> toggleTheme() async {
    final newMode = state.isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Sets the theme mode and persists it.
  Future<void> setThemeMode(AppThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    await _saveSettings();
  }

  /// Updates user information.
  Future<void> setUserInfo({String? name, String? email}) async {
    state = state.copyWith(userName: name, userEmail: email);
    await _saveSettings();
  }

  /// Clears user information (sign out).
  Future<void> clearUserInfo() async {
    state = state.copyWith(userName: null, userEmail: null);
    await _saveSettings();
  }

  /// Saves current settings to SharedPreferences.
  Future<void> _saveSettings() async {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_themePrefKey, state.toJson());
    } catch (e) {
      debugPrint('Failed to save settings: $e');
    }
  }
}
