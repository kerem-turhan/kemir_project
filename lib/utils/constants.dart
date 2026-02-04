/// Application-wide constants and configuration values.
library;

/// Application name and branding.
abstract class AppConstants {
  /// Application name displayed in headers.
  static const String appName = 'Notes';

  /// Application version.
  static const String appVersion = '2.4.0';

  /// Company/developer name.
  static const String developerName = 'Kemir Project';
}

/// Route names for navigation.
abstract class Routes {
  /// Home screen with notes list.
  static const String home = '/';

  /// Graph visualization screen.
  static const String graph = '/graph';

  /// Settings screen.
  static const String settings = '/settings';

  /// Note editor screen. Use with note ID parameter.
  static const String editor = '/editor';

  /// Note editor with ID parameter.
  static String editorWithId(String id) => '/editor/$id';
}

/// UI text constants (for localization later).
abstract class Strings {
  // Home Screen
  static const String myNotes = 'My Notes';
  static const String allNotes = 'All Notes';
  static const String searchNotes = 'Search your notes...';
  static const String noNotesYet = 'No notes yet';
  static const String noNotesDescription =
      'Tap the button below to create your first note and start organizing your thoughts.';

  // Graph Screen
  static const String graphView = 'Graph View';
  static const String search = 'Search';
  static const String notes = 'Notes';

  // Editor Screen
  static const String save = 'Save';
  static const String untitledNote = 'Untitled Note';
  static const String startTyping = 'Start typing...';
  static const String saving = 'Saving...';
  static const String saved = 'Saved';

  // Settings Screen
  static const String settings = 'Settings';
  static const String done = 'Done';
  static const String account = 'ACCOUNT';
  static const String appSettings = 'APP SETTINGS';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String themeColor = 'Theme Color';
  static const String notifications = 'Notifications';
  static const String privacySecurity = 'Privacy & Security';
  static const String support = 'SUPPORT';
  static const String helpCenter = 'Help Center';
  static const String about = 'About';
  static const String version = 'Version';
  static const String termsOfService = 'Terms of Service';
  static const String privacyPolicy = 'Privacy Policy';
  static const String signOut = 'Sign Out';

  // Actions
  static const String delete = 'Delete';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';

  // Errors
  static const String errorLoading = 'Failed to load data';
  static const String errorSaving = 'Failed to save changes';
  static const String tryAgain = 'Try Again';
}

/// Animation durations.
abstract class Durations {
  /// Fast animation for micro-interactions.
  static const Duration fast = Duration(milliseconds: 150);

  /// Normal animation for most transitions.
  static const Duration normal = Duration(milliseconds: 300);

  /// Slow animation for emphasis.
  static const Duration slow = Duration(milliseconds: 500);

  /// Auto-save debounce duration.
  static const Duration autoSaveDebounce = Duration(seconds: 2);
}

/// Asset paths.
abstract class Assets {
  /// Path to icons directory.
  static const String icons = 'assets/icons';

  /// Path to images directory.
  static const String images = 'assets/images';
}
