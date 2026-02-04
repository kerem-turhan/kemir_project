/// Settings screen for app preferences and user account.
///
/// Features theme toggle, account info, and app information.
library;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../providers/theme_provider.dart';
import '../themes/theme_config.dart';
import '../utils/constants.dart';

/// Settings screen with appearance, account, and support sections.
class SettingsScreen extends ConsumerWidget {
  /// Creates a [SettingsScreen] widget.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(appSettingsProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(context, isDark),

            // Settings content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(ThemeConfig.spacingMd),
                children: [
                  // Account section
                  _buildSectionHeader(context, Strings.account),
                  _buildAccountCard(context, isDark, settings),

                  const SizedBox(height: ThemeConfig.spacingLg),

                  // App Settings section
                  _buildSectionHeader(context, Strings.appSettings),
                  _buildSettingsCard(context, isDark, settings, ref),

                  const SizedBox(height: ThemeConfig.spacingLg),

                  // Support section
                  _buildSectionHeader(context, Strings.support),
                  _buildSupportCard(context, isDark),

                  const SizedBox(height: ThemeConfig.spacingLg),

                  // Sign out button
                  _buildSignOutButton(context),

                  const SizedBox(height: ThemeConfig.spacingXl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the header.
  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(ThemeConfig.spacingMd),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 60), // Balance for Done button
          Text(Strings.settings, style: theme.textTheme.headlineMedium),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              // Close settings
            },
            child: Text(
              Strings.done,
              style: TextStyle(
                color: ThemeConfig.primaryAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a section header.
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ThemeConfig.spacingXs,
        bottom: ThemeConfig.spacingSm,
      ),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(letterSpacing: 1.2),
      ),
    );
  }

  /// Builds the account card.
  Widget _buildAccountCard(
    BuildContext context,
    bool isDark,
    AppSettings settings,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(ThemeConfig.spacingMd),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ThemeConfig.primaryAccent.withAlpha(51),
          ),
          child: const Icon(
            CupertinoIcons.person_fill,
            color: ThemeConfig.primaryAccent,
            size: 28,
          ),
        ),
        title: Text(
          settings.userName ?? 'Alex Rivera',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          settings.userEmail ?? 'alex.rivera@example.com',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          color: isDark
              ? ThemeConfig.darkTextSecondary
              : ThemeConfig.lightTextSecondary,
          size: 18,
        ),
      ),
    );
  }

  /// Builds the app settings card.
  Widget _buildSettingsCard(
    BuildContext context,
    bool isDark,
    AppSettings settings,
    WidgetRef ref,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
      ),
      child: Column(
        children: [
          // Appearance
          _buildSettingsRow(
            context,
            icon: CupertinoIcons.paintbrush,
            title: Strings.appearance,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  settings.isDarkMode ? 'Dark' : 'Light',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: ThemeConfig.spacingXs),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: isDark
                      ? ThemeConfig.darkTextSecondary
                      : ThemeConfig.lightTextSecondary,
                  size: 18,
                ),
              ],
            ),
            onTap: () {
              ref.read(appSettingsProvider.notifier).toggleTheme();
            },
            isDark: isDark,
          ),
          _buildDivider(isDark),

          // Dark Mode toggle (alternative quick toggle)
          _buildSettingsRow(
            context,
            icon: settings.isDarkMode
                ? CupertinoIcons.moon_fill
                : CupertinoIcons.sun_max_fill,
            title: Strings.darkMode,
            trailing: CupertinoSwitch(
              value: settings.isDarkMode,
              activeTrackColor: ThemeConfig.primaryAccent,
              onChanged: (value) {
                ref
                    .read(appSettingsProvider.notifier)
                    .setThemeMode(
                      value ? AppThemeMode.dark : AppThemeMode.light,
                    );
              },
            ),
            isDark: isDark,
          ),
          _buildDivider(isDark),

          // Notifications
          _buildSettingsRow(
            context,
            icon: CupertinoIcons.bell,
            title: Strings.notifications,
            trailing: Icon(
              CupertinoIcons.chevron_right,
              color: isDark
                  ? ThemeConfig.darkTextSecondary
                  : ThemeConfig.lightTextSecondary,
              size: 18,
            ),
            onTap: () {},
            isDark: isDark,
          ),
          _buildDivider(isDark),

          // Privacy & Security
          _buildSettingsRow(
            context,
            icon: CupertinoIcons.lock,
            title: Strings.privacySecurity,
            trailing: Icon(
              CupertinoIcons.chevron_right,
              color: isDark
                  ? ThemeConfig.darkTextSecondary
                  : ThemeConfig.lightTextSecondary,
              size: 18,
            ),
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Builds the support card.
  Widget _buildSupportCard(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkSurface : ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
      ),
      child: Column(
        children: [
          // Help Center
          _buildSettingsRow(
            context,
            icon: CupertinoIcons.question_circle,
            title: Strings.helpCenter,
            trailing: Icon(
              CupertinoIcons.arrow_up_right_square,
              color: isDark
                  ? ThemeConfig.darkTextSecondary
                  : ThemeConfig.lightTextSecondary,
              size: 18,
            ),
            onTap: () {},
            isDark: isDark,
          ),
          _buildDivider(isDark),

          // About
          _buildSettingsRow(
            context,
            icon: CupertinoIcons.info_circle,
            title: Strings.about,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'v${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: ThemeConfig.spacingXs),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: isDark
                      ? ThemeConfig.darkTextSecondary
                      : ThemeConfig.lightTextSecondary,
                  size: 18,
                ),
              ],
            ),
            onTap: () {},
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  /// Builds a settings row.
  Widget _buildSettingsRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Widget trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeConfig.spacingMd,
          vertical: ThemeConfig.spacingSm + 4,
        ),
        child: Row(
          children: [
            Icon(icon, color: ThemeConfig.primaryAccent, size: 22),
            const SizedBox(width: ThemeConfig.spacingMd),
            Expanded(
              child: Text(title, style: Theme.of(context).textTheme.bodyLarge),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  /// Builds a divider.
  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 54),
      child: Divider(
        height: 1,
        color: isDark ? ThemeConfig.darkDivider : ThemeConfig.lightDivider,
      ),
    );
  }

  /// Builds the sign out button.
  Widget _buildSignOutButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? ThemeConfig.darkSurface
            : ThemeConfig.lightSurface,
        borderRadius: BorderRadius.circular(ThemeConfig.cardRadius),
      ),
      child: ListTile(
        onTap: () {
          _showSignOutDialog(context);
        },
        title: Center(
          child: Text(
            Strings.signOut,
            style: const TextStyle(
              color: ThemeConfig.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Shows sign out confirmation dialog.
  void _showSignOutDialog(BuildContext context) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text(Strings.signOut),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text(Strings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              // Handle sign out
            },
            child: const Text(Strings.signOut),
          ),
        ],
      ),
    );
  }
}
