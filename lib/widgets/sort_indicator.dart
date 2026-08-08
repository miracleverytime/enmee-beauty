import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Chip indikator sort aktif. Tampil sebagai row kecil di bawah toolbar.
///
/// - `label`  : teks yang ditampilkan (mis. "Diurutkan: Harga").
/// - `onTap`  : aksi ketika chip body ditekan (buka bottom sheet sort).
/// - `onClear`: aksi ketika tombol X ditekan (reset ke default).
class SortIndicator extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final VoidCallback? onClear;

  const SortIndicator({
    super.key,
    required this.label,
    this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: Container(
            padding: const EdgeInsets.only(
              left: AppSpacing.md,
              right: AppSpacing.xs,
              top: AppSpacing.xs,
              bottom: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.swap_vert,
                  size: 14,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                if (onClear != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  InkWell(
                    onTap: onClear,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        Icons.close,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
