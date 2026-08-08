import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Skeleton Loader dengan shimmer effect
class SkeletonLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = AppRadius.sm,
  });

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseColor = isDark ? AppColors.darkSurface : AppColors.lightBorder;
    final highlightColor = isDark 
        ? AppColors.darkSecondary 
        : const Color(0xFFF3F4F6);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ].map((e) => e.clamp(0.0, 1.0)).toList(),
            ),
          ),
        );
      },
    );
  }
}

/// Skeleton untuk product card
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 150, height: 16),
                    SizedBox(height: AppSpacing.sm),
                    SkeletonLoader(width: 80, height: 12, borderRadius: AppRadius.sm),
                  ],
                ),
              ),
              SkeletonLoader(
                width: 40,
                height: 40,
                borderRadius: AppRadius.pill,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: 100, height: 18),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonLoader(width: 70, height: 12),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SkeletonLoader(width: 60, height: 14),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonLoader(width: 80, height: 20, borderRadius: AppRadius.sm),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton untuk summary stats card
class SummaryCardSkeleton extends StatelessWidget {
  const SummaryCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    // Responsive width calculation
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - (AppSpacing.lg * 2) - (AppSpacing.sm * 1)) / 2.2;

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SkeletonLoader(width: 80, height: 10),
          SizedBox(height: AppSpacing.xs),
          SkeletonLoader(width: 60, height: 18),
        ],
      ),
    );
  }
}

/// Skeleton untuk section header di settings
class SectionHeaderSkeleton extends StatelessWidget {
  const SectionHeaderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 4, bottom: 12),
      child: SkeletonLoader(width: 60, height: 10, borderRadius: AppRadius.sm),
    );
  }
}

/// Skeleton untuk satu item setting (icon + 2 baris teks)
class SettingItemSkeleton extends StatelessWidget {
  const SettingItemSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: context.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: const Row(
        children: [
          SkeletonLoader(width: 40, height: 40, borderRadius: AppRadius.sm),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 120, height: 14),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 180, height: 11),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
