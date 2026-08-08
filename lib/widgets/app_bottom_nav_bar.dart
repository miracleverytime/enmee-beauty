import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Item descriptor untuk bottom nav.
class AppNavItem {
  final IconData icon;
  const AppNavItem({required this.icon});
}

/// Bottom navigation bar bersama untuk 4 tab utama.
///
/// [showFab] menentukan apakah slot tengah harus menyediakan ruang untuk
/// FAB (centerDocked). Saat [showFab] berubah, slot tengah beranimasi
/// dari lebar 60 ke 0 sehingga item "menyusut" ke tengah dengan mulus
/// ketika FAB menghilang.
class AppBottomNavBar extends StatelessWidget {
  static const List<AppNavItem> items = [
    AppNavItem(icon: Icons.inventory_2_outlined),
    AppNavItem(icon: Icons.receipt_long_outlined),
    AppNavItem(icon: Icons.bar_chart_outlined),
    AppNavItem(icon: Icons.settings_outlined),
  ];

  static const double _fabGap = 60;

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showFab;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.showFab,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 70,
      decoration: BoxDecoration(
        color: context.isDark
            ? AppColors.darkSurface.withOpacity(0.8)
            : AppColors.lightSurface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: (context.isDark
                  ? AppColors.darkForeground
                  : AppColors.lightBorder)
              .withOpacity(0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (int i = 0; i < items.length; i++) ...[
                Expanded(
                  child: _NavItem(
                    item: items[i],
                    isActive: i == currentIndex,
                    onTap: () => onTap(i),
                  ),
                ),
                if (i == 1)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutCubic,
                    width: showFab ? _fabGap : 0,
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final AppNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = context.isDark
        ? AppColors.darkMutedForeground
        : AppColors.lightTextSecondary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Icon(
          item.icon,
          color: isActive ? activeColor : inactiveColor,
          size: 24,
        ),
      ),
    );
  }
}
