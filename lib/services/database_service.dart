/// Database service for SQLite operations.
///
/// Provides complete CRUD operations for notes and images with
/// proper error handling, transactions, and migrations.
library;

import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../exceptions/database_exception.dart';
import '../models/note.dart';

/// Database configuration constants.
class _DbConfig {
  static const String databaseName = 'notes_app.db';
  static const int databaseVersion = 1;

  // Table names
  static const String notesTable = 'notes';
  static const String noteImagesTable = 'note_images';
}

/// Service class for SQLite database operations.
///
/// Implements singleton pattern to ensure single database connection.
/// Provides complete CRUD operations for notes and associated images.
class DatabaseService {
  // Singleton instance
  static DatabaseService? _instance;
  static Database? _database;

  // Private constructor for singleton pattern
  DatabaseService._internal();

  /// Returns the singleton instance of [DatabaseService].
  static DatabaseService get instance {
    _instance ??= DatabaseService._internal();
    return _instance!;
  }

  /// Returns the database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database connection.
  Future<Database> _initDatabase() async {
    try {
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, _DbConfig.databaseName);

      developer.log(
        'Initializing database at: $dbPath',
        name: 'DatabaseService',
      );

      return await openDatabase(
        dbPath,
        version: _DbConfig.databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to initialize database: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseConnectionException(
        'Failed to initialize database',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Configures the database connection.
  Future<void> _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  /// Creates the database schema on first run.
  Future<void> _onCreate(Database db, int version) async {
    developer.log(
      'Creating database schema v$version',
      name: 'DatabaseService',
    );

    // Create notes table
    await db.execute('''
      CREATE TABLE ${_DbConfig.notesTable} (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL DEFAULT '',
        category TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        is_deleted INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Create indexes for notes table
    await db.execute('''
      CREATE INDEX idx_notes_updated_at 
      ON ${_DbConfig.notesTable} (updated_at DESC)
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_is_deleted 
      ON ${_DbConfig.notesTable} (is_deleted)
    ''');

    await db.execute('''
      CREATE INDEX idx_notes_created_at 
      ON ${_DbConfig.notesTable} (created_at DESC)
    ''');

    // Create note_images table
    await db.execute('''
      CREATE TABLE ${_DbConfig.noteImagesTable} (
        id TEXT PRIMARY KEY,
        note_id TEXT NOT NULL,
        file_path TEXT NOT NULL,
        display_order INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (note_id) REFERENCES ${_DbConfig.notesTable}(id) ON DELETE CASCADE
      )
    ''');

    // Create index for note_images
    await db.execute('''
      CREATE INDEX idx_note_images_note_id 
      ON ${_DbConfig.noteImagesTable} (note_id)
    ''');

    developer.log(
      'Database schema created successfully',
      name: 'DatabaseService',
    );
  }

  /// Handles database schema upgrades.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    developer.log(
      'Upgrading database from v$oldVersion to v$newVersion',
      name: 'DatabaseService',
    );

    // Future migrations will be added here
    // Example:
    // if (oldVersion < 2) {
    //   await db.execute('ALTER TABLE notes ADD COLUMN pinned INTEGER DEFAULT 0');
    // }
  }

  // ============================================================
  // CRUD Operations for Notes
  // ============================================================

  /// Creates a new note in the database.
  ///
  /// Returns the created note with its ID.
  Future<Note> createNote(Note note) async {
    try {
      final db = await database;
      final noteMap = _noteToDbMap(note);

      await db.insert(
        _DbConfig.notesTable,
        noteMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      developer.log('Created note: ${note.id}', name: 'DatabaseService');

      return note;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to create note: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to create note',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches a single note by ID.
  ///
  /// Returns null if the note doesn't exist or is deleted.
  Future<Note?> getNoteById(String id) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        _DbConfig.notesTable,
        where: 'id = ? AND is_deleted = 0',
        whereArgs: [id],
        limit: 1,
      );

      if (maps.isEmpty) return null;

      final note = _noteFromDbMap(maps.first);

      // Fetch associated images
      final images = await getImagesForNote(id);

      return note.copyWith(imagePaths: images);
    } catch (e, stackTrace) {
      developer.log(
        'Failed to get note by id: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to fetch note',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fetches all active (non-deleted) notes.
  ///
  /// Notes are ordered by updated_at in descending order.
  Future<List<Note>> fetchAllNotes() async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        _DbConfig.notesTable,
        where: 'is_deleted = 0',
        orderBy: 'updated_at DESC',
      );

      // Fetch images for each note
      final notes = <Note>[];
      for (final map in maps) {
        final note = _noteFromDbMap(map);
        final images = await getImagesForNote(note.id);
        notes.add(note.copyWith(imagePaths: images));
      }

      developer.log('Fetched ${notes.length} notes', name: 'DatabaseService');

      return notes;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to fetch all notes: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to fetch notes',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Updates an existing note.
  ///
  /// Returns the updated note.
  Future<Note> updateNote(Note note) async {
    try {
      final db = await database;
      final noteMap = _noteToDbMap(note.copyWith(updatedAt: DateTime.now()));

      await db.update(
        _DbConfig.notesTable,
        noteMap,
        where: 'id = ?',
        whereArgs: [note.id],
      );

      developer.log('Updated note: ${note.id}', name: 'DatabaseService');

      return note;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to update note: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to update note',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Deletes a note.
  ///
  /// If [hardDelete] is true, the note is permanently removed.
  /// Otherwise, it's soft-deleted (marked as deleted but kept in database).
  Future<bool> deleteNote(String id, {bool hardDelete = false}) async {
    try {
      final db = await database;

      if (hardDelete) {
        // Hard delete - images are cascade deleted by foreign key
        await db.delete(_DbConfig.notesTable, where: 'id = ?', whereArgs: [id]);
        developer.log('Hard deleted note: $id', name: 'DatabaseService');
      } else {
        // Soft delete
        await db.update(
          _DbConfig.notesTable,
          {
            'is_deleted': 1,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'id = ?',
          whereArgs: [id],
        );
        developer.log('Soft deleted note: $id', name: 'DatabaseService');
      }

      return true;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to delete note: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to delete note',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Searches notes by title and content.
  ///
  /// Returns notes matching the query, ordered by relevance.
  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) {
      return fetchAllNotes();
    }

    try {
      final db = await database;
      final searchTerm = '%${query.toLowerCase()}%';

      final List<Map<String, dynamic>> maps = await db.query(
        _DbConfig.notesTable,
        where:
            'is_deleted = 0 AND (LOWER(title) LIKE ? OR LOWER(content) LIKE ?)',
        whereArgs: [searchTerm, searchTerm],
        orderBy: 'updated_at DESC',
      );

      // Fetch images for each note
      final notes = <Note>[];
      for (final map in maps) {
        final note = _noteFromDbMap(map);
        final images = await getImagesForNote(note.id);
        notes.add(note.copyWith(imagePaths: images));
      }

      developer.log(
        'Search found ${notes.length} notes for query: $query',
        name: 'DatabaseService',
      );

      return notes;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to search notes: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to search notes',
        query: query,
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Gets the count of active notes.
  Future<int> getNotesCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${_DbConfig.notesTable} WHERE is_deleted = 0',
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      debugPrint('Failed to get notes count: $e');
      return 0;
    }
  }

  /// Permanently deletes notes that were soft-deleted more than [days] ago.
  Future<int> purgeDeletedNotes({int days = 30}) async {
    try {
      final db = await database;
      final cutoffTime = DateTime.now()
          .subtract(Duration(days: days))
          .millisecondsSinceEpoch;

      final count = await db.delete(
        _DbConfig.notesTable,
        where: 'is_deleted = 1 AND updated_at < ?',
        whereArgs: [cutoffTime],
      );

      developer.log(
        'Purged $count notes older than $days days',
        name: 'DatabaseService',
      );

      return count;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to purge deleted notes: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      return 0;
    }
  }

  // ============================================================
  // Image Operations
  // ============================================================

  /// Adds an image to a note.
  Future<void> addImageToNote({
    required String imageId,
    required String noteId,
    required String filePath,
    int displayOrder = 0,
  }) async {
    try {
      final db = await database;

      await db.insert(_DbConfig.noteImagesTable, {
        'id': imageId,
        'note_id': noteId,
        'file_path': filePath,
        'display_order': displayOrder,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      developer.log(
        'Added image $imageId to note $noteId',
        name: 'DatabaseService',
      );
    } catch (e, stackTrace) {
      developer.log(
        'Failed to add image to note: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      throw DatabaseQueryException(
        'Failed to add image to note',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Removes an image from a note.
  Future<bool> removeImageFromNote(String imageId) async {
    try {
      final db = await database;

      final count = await db.delete(
        _DbConfig.noteImagesTable,
        where: 'id = ?',
        whereArgs: [imageId],
      );

      return count > 0;
    } catch (e, stackTrace) {
      developer.log(
        'Failed to remove image: $e',
        name: 'DatabaseService',
        error: e,
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Gets all image paths for a note.
  Future<List<String>> getImagesForNote(String noteId) async {
    try {
      final db = await database;

      final List<Map<String, dynamic>> maps = await db.query(
        _DbConfig.noteImagesTable,
        columns: ['file_path'],
        where: 'note_id = ?',
        whereArgs: [noteId],
        orderBy: 'display_order ASC',
      );

      return maps.map((m) => m['file_path'] as String).toList();
    } catch (e) {
      debugPrint('Failed to get images for note: $e');
      return [];
    }
  }

  /// Gets all image records (for cleanup operations).
  Future<List<Map<String, dynamic>>> getAllImageRecords() async {
    try {
      final db = await database;
      return await db.query(_DbConfig.noteImagesTable);
    } catch (e) {
      debugPrint('Failed to get image records: $e');
      return [];
    }
  }

  // ============================================================
  // Utility Methods
  // ============================================================

  /// Closes the database connection.
  Future<void> closeDatabase() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
      developer.log('Database closed', name: 'DatabaseService');
    }
  }

  /// Deletes the entire database file (for testing/reset).
  Future<void> deleteDatabase() async {
    try {
      await closeDatabase();
      final documentsDirectory = await getApplicationDocumentsDirectory();
      final dbPath = path.join(documentsDirectory.path, _DbConfig.databaseName);
      await databaseFactory.deleteDatabase(dbPath);
      developer.log('Database deleted', name: 'DatabaseService');
    } catch (e) {
      debugPrint('Failed to delete database: $e');
    }
  }

  /// Gets the current database file path.
  Future<String> getDatabasePath() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    return path.join(documentsDirectory.path, _DbConfig.databaseName);
  }

  // ============================================================
  // Private Helper Methods
  // ============================================================

  /// Converts a Note to a database-compatible map.
  Map<String, dynamic> _noteToDbMap(Note note) {
    return {
      'id': note.id,
      'title': note.title,
      'content': note.content,
      'category': note.category,
      'created_at': note.createdAt.millisecondsSinceEpoch,
      'updated_at': note.updatedAt.millisecondsSinceEpoch,
      'is_deleted': note.isDeleted ? 1 : 0,
    };
  }

  /// Creates a Note from a database map.
  Note _noteFromDbMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String? ?? '',
      category: map['category'] as String?,
      imagePaths: const [], // Loaded separately
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isDeleted: (map['is_deleted'] as int) == 1,
    );
  }
}
