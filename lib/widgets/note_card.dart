/// Note card widget for displaying note previews in lists.
library;

import 'dart:io';

import 'package:flutter/material.dart';

import '../models/note.dart';
import '../themes/theme_config.dart';
import '../utils/helpers.dart';

/// A card widget displaying a note preview.
///
/// Shows title, content preview, timestamp, category tag, and optional thumbnail.
class NoteCard extends StatelessWidget {
  /// The note to display.
  final Note note;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  /// Callback when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Creates a [NoteCard] widget.
  const NoteCard({super.key, required this.note, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImage = note.imagePaths.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
          borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
          boxShadow: isDark
              ? ThemeConfig.darkCardShadow
              : ThemeConfig.lightCardShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.all(ThemeConfig.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title row with timestamp
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title.isEmpty ? 'Untitled Note' : note.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: ThemeConfig.spacingSm),
                  Text(
                    formatRelativeTime(note.updatedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: ThemeConfig.spacingSm),

              // Content preview with optional thumbnail
              if (hasImage) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        note.contentPreview,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: ThemeConfig.spacingSm),
                    _buildThumbnail(context),
                  ],
                ),
              ] else ...[
                Text(
                  note.contentPreview,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: ThemeConfig.spacingSm),

              // Category tag and date row
              Row(
                children: [
                  Text(
                    formatDate(note.updatedAt),
                    style: theme.textTheme.bodySmall,
                  ),
                  if (note.category != null) ...[
                    const SizedBox(width: ThemeConfig.spacingSm),
                    Text('•', style: theme.textTheme.bodySmall),
                    const SizedBox(width: ThemeConfig.spacingSm),
                    _buildCategoryTag(context),
                  ],
                  const Spacer(),
                  // Pin indicator (placeholder for future)
                  if (hasImage)
                    Icon(
                      Icons.image_outlined,
                      size: 16,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the category tag chip.
  Widget _buildCategoryTag(BuildContext context) {
    final color = ThemeConfig.getCategoryColor(note.category);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeConfig.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(38),
        borderRadius: BorderRadius.circular(ThemeConfig.chipRadius),
      ),
      child: Text(
        note.category!,
        style: TextStyle(
          fontSize: ThemeConfig.fontSizeCaption,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Builds the thumbnail image.
  Widget _buildThumbnail(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(ThemeConfig.chipRadius),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.file(
          File(note.imagePaths.first),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: ThemeConfig.primaryAccentLight,
              child: const Icon(
                Icons.image_not_supported_outlined,
                color: ThemeConfig.primaryAccent,
                size: 24,
              ),
            );
          },
        ),
      ),
    );
  }
}
