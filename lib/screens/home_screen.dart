/// Home screen displaying the list of notes.
///
/// Features search, note cards, empty state, and FAB for creating new notes.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';
import '../themes/theme_config.dart';
import '../utils/constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/note_card.dart';

/// The main home screen showing all notes.
class HomeScreen extends ConsumerStatefulWidget {
  /// Callback when navigating to the editor.
  final void Function(String? noteId) onNavigateToEditor;

  /// Creates a [HomeScreen] widget.
  const HomeScreen({super.key, required this.onNavigateToEditor});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final notesState = ref.watch(notesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context, isDark),

            // Search bar
            _buildSearchBar(context),

            // Notes list or empty state
            Expanded(child: _buildContent(context, notesState)),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(context),
    );
  }

  /// Builds the header with title and avatar.
  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ThemeConfig.spacingMd,
        ThemeConfig.spacingMd,
        ThemeConfig.spacingMd,
        ThemeConfig.spacingSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            isDark ? Strings.allNotes : Strings.myNotes,
            style: theme.textTheme.displayLarge,
          ),
          // User avatar
          GestureDetector(
            onTap: () {
              // Navigate to settings or profile
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ThemeConfig.primaryAccent.withAlpha(51),
                border: Border.all(color: ThemeConfig.primaryAccent, width: 2),
              ),
              child: const Center(
                child: Text(
                  'JD',
                  style: TextStyle(
                    color: ThemeConfig.primaryAccent,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the search bar.
  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacingMd,
        vertical: ThemeConfig.spacingSm,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
          borderRadius: BorderRadius.circular(ThemeConfig.buttonRadius),
          boxShadow: isDark ? null : ThemeConfig.lightCardShadow,
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            ref.read(notesProvider.notifier).setSearchQuery(value);
            setState(() {
              _isSearching = value.isNotEmpty;
            });
          },
          decoration: InputDecoration(
            hintText: Strings.searchNotes,
            prefixIcon: Icon(
              CupertinoIcons.search,
              color: isDark
                  ? ThemeConfig.darkTextSecondary
                  : ThemeConfig.lightTextSecondary,
            ),
            suffixIcon: _isSearching
                ? IconButton(
                    icon: const Icon(CupertinoIcons.xmark_circle_fill),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(notesProvider.notifier).clearSearch();
                      setState(() {
                        _isSearching = false;
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }

  /// Builds the main content (notes list or empty state).
  Widget _buildContent(BuildContext context, NotesState notesState) {
    // Loading state
    if (notesState.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: ThemeConfig.primaryAccent),
      );
    }

    // Error state
    if (notesState.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 48,
              color: ThemeConfig.error,
            ),
            const SizedBox(height: ThemeConfig.spacingMd),
            Text(
              Strings.errorLoading,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: ThemeConfig.spacingSm),
            TextButton(
              onPressed: () {
                ref.read(notesProvider.notifier).refresh();
              },
              child: const Text(Strings.tryAgain),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (notesState.sortedNotes.isEmpty) {
      return EmptyState(
        icon: CupertinoIcons.doc_text,
        title: Strings.noNotesYet,
        description: _isSearching
            ? 'No notes match your search.'
            : Strings.noNotesDescription,
      );
    }

    // Notes list
    return RefreshIndicator(
      onRefresh: () => ref.read(notesProvider.notifier).refresh(),
      color: ThemeConfig.primaryAccent,
      child: ListView.separated(
        padding: const EdgeInsets.all(ThemeConfig.spacingMd),
        itemCount: notesState.sortedNotes.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: ThemeConfig.spacingMd),
        itemBuilder: (context, index) {
          final note = notesState.sortedNotes[index];
          return NoteCard(
            note: note,
            onTap: () => widget.onNavigateToEditor(note.id),
            onLongPress: () => _showDeleteDialog(context, note.id),
          );
        },
      ),
    );
  }

  /// Builds the floating action button.
  Widget _buildFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        // Create a new note and navigate to editor
        final note = await ref.read(notesProvider.notifier).createNote();
        if (note != null) {
          widget.onNavigateToEditor(note.id);
        }
      },
      child: const Icon(CupertinoIcons.add),
    );
  }

  /// Shows a delete confirmation dialog.
  void _showDeleteDialog(BuildContext context, String noteId) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(noteId);
              Navigator.pop(context);
            },
            child: const Text(Strings.delete),
          ),
        ],
      ),
    );
  }
}
