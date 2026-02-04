/// Empty state widget for screens with no content.
///
/// Used in Home, Graph, and other screens when there's no data to display.
library;

import 'package:flutter/material.dart';

import '../themes/theme_config.dart';

/// A centered empty state with icon, title, and description.
class EmptyState extends StatelessWidget {
  /// Icon to display (typically a large icon).
  final IconData icon;

  /// Main title text.
  final String title;

  /// Descriptive text below the title.
  final String description;

  /// Optional action button.
  final Widget? action;

  /// Creates an [EmptyState] widget.
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(ThemeConfig.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon with circular background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? ThemeConfig.darkSurface
                    : ThemeConfig.primaryAccentLight.withAlpha(77),
                border: Border.all(
                  color: isDark
                      ? ThemeConfig.darkDivider
                      : ThemeConfig.primaryAccentLight,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside,
                ),
              ),
              child: Icon(icon, size: 48, color: ThemeConfig.primaryAccent),
            ),

            const SizedBox(height: ThemeConfig.spacingLg),

            // Title
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: ThemeConfig.spacingSm),

            // Description
            Text(
              description,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),

            // Optional action button
            if (action != null) ...[
              const SizedBox(height: ThemeConfig.spacingLg),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
