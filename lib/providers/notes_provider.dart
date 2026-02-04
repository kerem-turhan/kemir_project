/// Notes provider for managing notes state and operations.
///
/// Provides CRUD operations and search functionality for notes
/// with real SQLite database persistence.
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../exceptions/database_exception.dart';
import '../models/note.dart';
import '../services/database_service.dart';

/// UUID generator for creating unique note IDs.
const _uuid = Uuid();

/// State class for notes with loading and error states.
@immutable
class NotesState {
  /// All notes in the application.
  final List<Note> notes;

  /// Current search query (empty = show all).
  final String searchQuery;

  /// Whether notes are currently loading.
  final bool isLoading;

  /// Error message if any operation failed.
  final String? errorMessage;

  const NotesState({
    this.notes = const [],
    this.searchQuery = '',
    this.isLoading = false,
    this.errorMessage,
  });

  /// Returns filtered notes based on search query.
  List<Note> get filteredNotes {
    if (searchQuery.isEmpty) return notes;

    final query = searchQuery.toLowerCase();
    return notes.where((note) {
      return note.title.toLowerCase().contains(query) ||
          note.contentPreview.toLowerCase().contains(query) ||
          (note.category?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// Returns notes sorted by last updated (most recent first).
  List<Note> get sortedNotes {
    final sorted = List<Note>.from(filteredNotes);
    sorted.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return sorted;
  }

  /// Creates a copy with the specified fields replaced.
  NotesState copyWith({
    List<Note>? notes,
    String? searchQuery,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Provider for the database service singleton.
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService.instance;
});

/// Provider for notes state.
final notesProvider = NotifierProvider<NotesNotifier, NotesState>(
  NotesNotifier.new,
);

/// Notifier for managing notes operations.
class NotesNotifier extends Notifier<NotesState> {
  @override
  NotesState build() {
    // Load notes on initialization
    Future.microtask(_loadNotes);
    return const NotesState(isLoading: true);
  }

  /// Reference to the database service.
  DatabaseService get _db => ref.read(databaseServiceProvider);

  /// Loads all notes from the database.
  Future<void> _loadNotes() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final notes = await _db.fetchAllNotes();

      state = state.copyWith(notes: notes, isLoading: false);

      debugPrint('Loaded ${notes.length} notes from database');
    } on DatabaseException catch (e) {
      debugPrint('Database error loading notes: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load notes. Please try again.',
      );
    } catch (e) {
      debugPrint('Failed to load notes: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'An unexpected error occurred.',
      );
    }
  }

  /// Refreshes the notes list from the database.
  Future<void> refresh() async {
    await _loadNotes();
  }

  /// Creates a new note and returns it.
  Future<Note?> createNote({
    String title = '',
    String content = '',
    String? category,
  }) async {
    try {
      state = state.copyWith(clearError: true);

      final note = Note.create(
        id: _uuid.v4(),
        title: title,
        content: content,
        category: category,
      );

      // Save to database
      await _db.createNote(note);

      // Update local state
      state = state.copyWith(notes: [note, ...state.notes]);

      debugPrint('Created note: ${note.id}');
      return note;
    } on DatabaseException catch (e) {
      debugPrint('Database error creating note: $e');
      state = state.copyWith(
        errorMessage: 'Failed to create note. Please try again.',
      );
      return null;
    } catch (e) {
      debugPrint('Failed to create note: $e');
      state = state.copyWith(errorMessage: 'An unexpected error occurred.');
      return null;
    }
  }

  /// Updates an existing note.
  Future<bool> updateNote(Note note) async {
    try {
      state = state.copyWith(clearError: true);

      final updatedNote = note.copyWith(updatedAt: DateTime.now());

      // Save to database
      await _db.updateNote(updatedNote);

      // Update local state
      final notes = state.notes.map((n) {
        return n.id == note.id ? updatedNote : n;
      }).toList();

      state = state.copyWith(notes: notes);

      debugPrint('Updated note: ${note.id}');
      return true;
    } on DatabaseException catch (e) {
      debugPrint('Database error updating note: $e');
      state = state.copyWith(
        errorMessage: 'Failed to save note. Please try again.',
      );
      return false;
    } catch (e) {
      debugPrint('Failed to update note: $e');
      state = state.copyWith(errorMessage: 'An unexpected error occurred.');
      return false;
    }
  }

  /// Deletes a note by ID.
  ///
  /// By default uses soft delete. Set [hardDelete] to true for permanent removal.
  Future<bool> deleteNote(String id, {bool hardDelete = false}) async {
    try {
      state = state.copyWith(clearError: true);

      // Delete from database
      await _db.deleteNote(id, hardDelete: hardDelete);

      // Update local state
      final notes = state.notes.where((n) => n.id != id).toList();
      state = state.copyWith(notes: notes);

      debugPrint('Deleted note: $id (hard: $hardDelete)');
      return true;
    } on DatabaseException catch (e) {
      debugPrint('Database error deleting note: $e');
      state = state.copyWith(
        errorMessage: 'Failed to delete note. Please try again.',
      );
      return false;
    } catch (e) {
      debugPrint('Failed to delete note: $e');
      state = state.copyWith(errorMessage: 'An unexpected error occurred.');
      return false;
    }
  }

  /// Sets the search query.
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Clears the search query.
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  /// Gets a note by ID from local state.
  Note? getNoteById(String id) {
    try {
      return state.notes.firstWhere((n) => n.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Clears any error message.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Gets the count of notes.
  Future<int> getNotesCount() async {
    try {
      return await _db.getNotesCount();
    } catch (e) {
      return state.notes.length;
    }
  }
}

/// Provider for a single note by ID.
final noteByIdProvider = Provider.family<Note?, String>((ref, id) {
  final notesState = ref.watch(notesProvider);
  try {
    return notesState.notes.firstWhere((n) => n.id == id);
  } catch (_) {
    return null;
  }
});

/// Provider for the current search query.
final searchQueryProvider = Provider<String>((ref) {
  return ref.watch(notesProvider).searchQuery;
});

/// Provider for loading state.
final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(notesProvider).isLoading;
});

/// Provider for error message.
final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(notesProvider).errorMessage;
});
