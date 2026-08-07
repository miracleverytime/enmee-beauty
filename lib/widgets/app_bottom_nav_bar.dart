import 'package:flutter/material.dart';
import 'dart:ui';
import '../theme/app_theme.dart';

/// Item descriptor untuk bottom nav.
class AppNavItem {
  final IconData icon;
  final String label;
  const AppNavItem({required this.icon, required this.label});
}

/// Bottom navigation bar bersama untuk 4 tab utama.
///
/// Slot tengah (di antara item ke-2 dan ke-3) dikosongkan untuk FAB
/// yang diletakkan dengan `FloatingActionButtonLocation.centerDocked`.
class AppBottomNavBar extends StatelessWidget {
  static const List<AppNavItem> items = [
    AppNavItem(icon: Icons.inventory_2_outlined, label: 'Produk'),
    AppNavItem(icon: Icons.receipt_long_outlined, label: 'Transaksi'),
    AppNavItem(icon: Icons.bar_chart_outlined, label: 'Laporan'),
    AppNavItem(icon: Icons.settings_outlined, label: 'Setting'),
  ];

  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
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
                if (i == 1) const SizedBox(width: 60),
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
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              color: isActive ? activeColor : inactiveColor,
              size: 24,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              item.label,
              style: AppTextStyles.labelMedium.copyWith(
                color: isActive ? activeColor : inactiveColor,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
