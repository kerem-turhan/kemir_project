/// Custom bottom navigation bar using google_nav_bar.
library;

import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import '../themes/theme_config.dart';

/// Bottom navigation bar with Home, Graph, and Settings tabs.
class BottomNavBar extends StatelessWidget {
  /// Current selected index (0=Home, 1=Graph, 2=Settings).
  final int selectedIndex;

  /// Callback when a tab is selected.
  final ValueChanged<int> onTabChange;

  /// Creates a [BottomNavBar] widget.
  const BottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? ThemeConfig.darkBackground : ThemeConfig.lightSurface,
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withAlpha(13),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: ThemeConfig.spacingMd,
            vertical: ThemeConfig.spacingSm,
          ),
          child: GNav(
            gap: 8,
            activeColor: ThemeConfig.primaryAccent,
            iconSize: 24,
            padding: const EdgeInsets.symmetric(
              horizontal: ThemeConfig.spacingMd,
              vertical: ThemeConfig.spacingSm,
            ),
            duration: ThemeConfig.animationNormal,
            tabBackgroundColor: ThemeConfig.primaryAccent.withAlpha(26),
            color: isDark
                ? ThemeConfig.darkTextSecondary
                : ThemeConfig.lightTextSecondary,
            tabs: const [
              GButton(
                icon: Icons.home_outlined,
                text: 'Home',
                iconActiveColor: ThemeConfig.primaryAccent,
              ),
              GButton(
                icon: Icons.hub_outlined,
                text: 'Graph',
                iconActiveColor: ThemeConfig.primaryAccent,
              ),
              GButton(
                icon: Icons.settings_outlined,
                text: 'Settings',
                iconActiveColor: ThemeConfig.primaryAccent,
              ),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}
