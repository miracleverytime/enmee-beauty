import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import '../theme/app_theme.dart';
import 'haptics.dart';

class AppToast {
  static void success(
    BuildContext context, {
    required String title,
    String? description,
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    Haptics.light();
    _showCustomToast(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.success,
      autoCloseDuration: autoCloseDuration,
      icon: Icons.check_circle_rounded,
      accentColor: AppColors.success,
    );
  }

  static void error(
    BuildContext context, {
    required String title,
    String? description,
    Duration autoCloseDuration = const Duration(seconds: 4),
  }) {
    Haptics.error();
    _showCustomToast(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.error,
      autoCloseDuration: autoCloseDuration,
      icon: Icons.error_outline_rounded,
      accentColor: AppColors.destructive,
    );
  }

  static void info(
    BuildContext context, {
    required String title,
    String? description,
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    Haptics.light();
    _showCustomToast(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.info,
      autoCloseDuration: autoCloseDuration,
      icon: Icons.info_outline_rounded,
      accentColor: AppColors.primary,
    );
  }

  static void warning(
    BuildContext context, {
    required String title,
    String? description,
    Duration autoCloseDuration = const Duration(seconds: 3),
  }) {
    Haptics.medium();
    _showCustomToast(
      context: context,
      title: title,
      description: description,
      type: ToastificationType.warning,
      autoCloseDuration: autoCloseDuration,
      icon: Icons.warning_amber_rounded,
      accentColor: AppColors.warning,
    );
  }

  static void _showCustomToast({
    required BuildContext context,
    required String title,
    String? description,
    required ToastificationType type,
    required Duration autoCloseDuration,
    required IconData icon,
    required Color accentColor,
  }) {
    final isDark = context.isDark;
    final bgColor = context.surfaceColor;
    final borderColor = context.borderColor;
    final titleColor = context.textPrimary;
    final descColor = context.textSecondary;

    toastification.showCustom(
      context: context,
      alignment: Alignment.topCenter,
      autoCloseDuration: autoCloseDuration,
      animationDuration: const Duration(milliseconds: 250),
      builder: (BuildContext context, ToastificationItem holder) {
        return Center(
          child: Container(
            margin: const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(100), // Pill / Capsule shape
              border: Border.all(
                color: isDark ? borderColor : accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.4)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (description != null && description.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          description,
                          style: TextStyle(
                            color: descColor,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
