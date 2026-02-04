/// Custom exceptions for database operations.
///
/// Provides specific exception types for different database error scenarios.
library;

/// Base exception class for database-related errors.
class DatabaseException implements Exception {
  /// Human-readable error message.
  final String message;

  /// The original error that caused this exception.
  final Object? originalError;

  /// Stack trace when the error occurred.
  final StackTrace? stackTrace;

  /// Creates a [DatabaseException].
  const DatabaseException(this.message, {this.originalError, this.stackTrace});

  @override
  String toString() => 'DatabaseException: $message';
}

/// Exception thrown when database connection fails.
class DatabaseConnectionException extends DatabaseException {
  /// Creates a [DatabaseConnectionException].
  const DatabaseConnectionException(
    super.message, {
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() => 'DatabaseConnectionException: $message';
}

/// Exception thrown when a database query fails.
class DatabaseQueryException extends DatabaseException {
  /// The SQL query that failed.
  final String? query;

  /// Creates a [DatabaseQueryException].
  const DatabaseQueryException(
    super.message, {
    this.query,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'DatabaseQueryException: $message${query != null ? ' (Query: $query)' : ''}';
}

/// Exception thrown when a database migration fails.
class DatabaseMigrationException extends DatabaseException {
  /// The version being migrated from.
  final int? fromVersion;

  /// The version being migrated to.
  final int? toVersion;

  /// Creates a [DatabaseMigrationException].
  const DatabaseMigrationException(
    super.message, {
    this.fromVersion,
    this.toVersion,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'DatabaseMigrationException: $message (from v$fromVersion to v$toVersion)';
}
