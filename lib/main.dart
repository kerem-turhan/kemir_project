/// Main entry point for the Notes application.
///
/// Initializes the database, providers, theme, and sets up the main navigation.
library;

import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/notes_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/graph_screen.dart';
import 'screens/home_screen.dart';
import 'screens/note_editor_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';
import 'themes/app_theme.dart';
import 'widgets/bottom_nav_bar.dart';

/// Main entry point.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize database
  try {
    await DatabaseService.instance.database;
    developer.log('Database initialized successfully', name: 'Main');
  } catch (e) {
    developer.log('Failed to initialize database: $e', name: 'Main', error: e);
    // Continue anyway - the app will show error states
  }

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const NotesApp(),
    ),
  );
}

/// Root application widget.
class NotesApp extends ConsumerWidget {
  /// Creates a [NotesApp] widget.
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Notes',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Page transitions
      onGenerateRoute: (settings) {
        return _buildRoute(settings);
      },

      // Home is the main shell with navigation
      home: const MainNavigationShell(),
    );
  }

  /// Builds routes with Cupertino transitions.
  Route<dynamic>? _buildRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/editor':
        final noteId = settings.arguments as String?;
        page = NoteEditorScreen(noteId: noteId ?? '', onSave: () {});
        break;
      default:
        return null;
    }

    return CupertinoPageRoute<dynamic>(
      builder: (_) => page,
      settings: settings,
    );
  }
}

/// Main navigation shell with bottom navigation bar.
class MainNavigationShell extends ConsumerStatefulWidget {
  /// Creates a [MainNavigationShell] widget.
  const MainNavigationShell({super.key});

  @override
  ConsumerState<MainNavigationShell> createState() =>
      _MainNavigationShellState();
}

class _MainNavigationShellState extends ConsumerState<MainNavigationShell> {
  int _selectedIndex = 0;

  // Page controller for smooth transitions
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Trigger initial notes load
    Future.microtask(() {
      ref.read(notesProvider);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToEditor(String? noteId) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => NoteEditorScreen(
          noteId: noteId ?? '',
          onSave: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Watch for error messages and show snackbar
    ref.listen<String?>(errorMessageProvider, (previous, next) {
      if (next != null && next.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ref.read(notesProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          HomeScreen(onNavigateToEditor: _navigateToEditor),
          GraphScreen(onNodeTap: _navigateToEditor),
          const SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTabChange: _onTabChange,
      ),
    );
  }
}
