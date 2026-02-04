/// Utility helper functions for common operations.
library;

import 'package:intl/intl.dart';

/// Formats a [DateTime] to a human-readable relative string.
///
/// Examples:
/// - "Just now" (< 1 minute ago)
/// - "5 minutes ago"
/// - "2 hours ago"
/// - "Yesterday"
/// - "Oct 24" (this year)
/// - "Oct 24, 2023" (previous years)
String formatRelativeTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    final minutes = difference.inMinutes;
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
  } else if (difference.inHours < 24) {
    final hours = difference.inHours;
    return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
  } else if (difference.inDays == 1) {
    return 'Yesterday';
  } else if (difference.inDays < 7) {
    final days = difference.inDays;
    return '$days ${days == 1 ? 'day' : 'days'} ago';
  } else if (dateTime.year == now.year) {
    return DateFormat('MMM d').format(dateTime);
  } else {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}

/// Formats a [DateTime] to time only (e.g., "10:45 AM").
String formatTime(DateTime dateTime) {
  return DateFormat('h:mm a').format(dateTime);
}

/// Formats a [DateTime] to date only (e.g., "Oct 24").
String formatDate(DateTime dateTime) {
  return DateFormat('MMM d').format(dateTime);
}

/// Formats a [DateTime] to full date (e.g., "October 24, 2024").
String formatFullDate(DateTime dateTime) {
  return DateFormat('MMMM d, yyyy').format(dateTime);
}

/// Truncates a string to the specified length with ellipsis.
String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength).trimRight()}...';
}

/// Extracts the first N lines from a multi-line string.
String getFirstLines(String text, int lineCount) {
  final lines = text.split('\n');
  if (lines.length <= lineCount) return text;
  return lines.take(lineCount).join('\n');
}

/// Capitalizes the first letter of a string.
String capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

/// Generates initials from a name (e.g., "John Doe" -> "JD").
String getInitials(String name, {int count = 2}) {
  if (name.isEmpty) return '';

  final words = name.trim().split(RegExp(r'\s+'));
  final initials = words
      .take(count)
      .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
      .join();

  return initials;
}

/// Removes HTML tags from a string.
String stripHtml(String html) {
  return html.replaceAll(RegExp(r'<[^>]*>'), '');
}

/// Checks if a string is a valid email.
bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}

/// Debounce utility for search and other input operations.
class Debouncer {
  final Duration delay;
  DateTime? _lastCallTime;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Returns true if enough time has passed since the last call.
  bool shouldExecute() {
    final now = DateTime.now();
    if (_lastCallTime == null || now.difference(_lastCallTime!) >= delay) {
      _lastCallTime = now;
      return true;
    }
    return false;
  }

  /// Resets the debouncer.
  void reset() {
    _lastCallTime = null;
  }
}
