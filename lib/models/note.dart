/// Note model representing a single note in the application.
///
/// This model stores all note-related data including content from the
/// AppFlowy editor (stored as JSON), associated images, and timestamps.
library;

import 'dart:convert';

/// Represents a single note with rich text content and metadata.
class Note {
  /// Unique identifier for the note.
  final String id;

  /// Title of the note, displayed prominently in lists and headers.
  final String title;

  /// Rich text content stored as JSON from AppFlowy Editor.
  /// Empty string indicates a new/empty note.
  final String content;

  /// Category/tag for organizing notes (e.g., "Work", "Personal").
  final String? category;

  /// List of local file paths to images embedded in the note.
  final List<String> imagePaths;

  /// Timestamp when the note was first created.
  final DateTime createdAt;

  /// Timestamp of the last modification.
  final DateTime updatedAt;

  /// Whether the note has been soft-deleted.
  final bool isDeleted;

  /// Creates a new [Note] instance.
  const Note({
    required this.id,
    required this.title,
    required this.content,
    this.category,
    this.imagePaths = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  /// Creates a Note with default values for a new note.
  factory Note.create({
    required String id,
    String title = '',
    String content = '',
    String? category,
    List<String> imagePaths = const [],
  }) {
    final now = DateTime.now();
    return Note(
      id: id,
      title: title,
      content: content,
      category: category,
      imagePaths: imagePaths,
      createdAt: now,
      updatedAt: now,
      isDeleted: false,
    );
  }

  /// Creates a copy of this note with the specified fields replaced.
  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  /// Converts the note to a Map for database storage.
  ///
  /// Uses milliseconds since epoch for timestamps (SQLite compatible).
  /// Note: imagePaths are stored in a separate table and not included here.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_deleted': isDeleted ? 1 : 0,
    };
  }

  /// Creates a Note from a database Map.
  ///
  /// Expects timestamps as milliseconds since epoch.
  /// imagePaths should be provided separately (loaded from note_images table).
  factory Note.fromMap(Map<String, dynamic> map, {List<String>? imagePaths}) {
    // Handle both int (from SQLite) and String (from JSON) timestamps
    final createdAt = map['created_at'];
    final updatedAt = map['updated_at'];

    DateTime parseTimestamp(dynamic value) {
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } else if (value is String) {
        // Try parsing as ISO 8601 first, then as milliseconds
        return DateTime.tryParse(value) ??
            DateTime.fromMillisecondsSinceEpoch(int.tryParse(value) ?? 0);
      }
      return DateTime.now();
    }

    // Handle imagePaths from JSON string if present
    List<String> parsedImagePaths = imagePaths ?? const [];
    if (imagePaths == null && map.containsKey('imagePaths')) {
      final pathsValue = map['imagePaths'];
      if (pathsValue is String && pathsValue.isNotEmpty) {
        try {
          parsedImagePaths = List<String>.from(jsonDecode(pathsValue) as List);
        } catch (_) {
          parsedImagePaths = const [];
        }
      } else if (pathsValue is List) {
        parsedImagePaths = List<String>.from(pathsValue);
      }
    }

    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String?,
      imagePaths: parsedImagePaths,
      createdAt: parseTimestamp(createdAt),
      updatedAt: parseTimestamp(updatedAt),
      isDeleted: (map['is_deleted'] as int?) == 1,
    );
  }

  /// Returns a preview of the content (first 100 characters).
  String get contentPreview {
    if (content.isEmpty) return '';

    // Try to extract plain text from JSON content
    try {
      final decoded = jsonDecode(content);
      if (decoded is Map<String, dynamic> && decoded.containsKey('document')) {
        // Extract text from AppFlowy document structure
        final text = _extractTextFromDocument(decoded);
        return text.length > 100 ? text.substring(0, 100) : text;
      }
    } catch (_) {
      // If not JSON, return raw content
    }

    final preview = content.length > 100 ? content.substring(0, 100) : content;
    return preview.replaceAll('\n', ' ').trim();
  }

  /// Extracts plain text from AppFlowy document structure.
  String _extractTextFromDocument(Map<String, dynamic> doc) {
    final buffer = StringBuffer();

    void extractFromNode(dynamic node) {
      if (node is Map) {
        if (node.containsKey('delta')) {
          final delta = node['delta'];
          if (delta is List) {
            for (final op in delta) {
              if (op is Map && op.containsKey('insert')) {
                buffer.write(op['insert']);
              }
            }
          }
        }
        if (node.containsKey('children')) {
          final children = node['children'];
          if (children is List) {
            for (final child in children) {
              extractFromNode(child);
            }
          }
        }
      }
    }

    if (doc.containsKey('document')) {
      extractFromNode(doc['document']);
    }

    return buffer.toString();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Note(id: $id, title: $title, category: $category, isDeleted: $isDeleted)';
  }
}
