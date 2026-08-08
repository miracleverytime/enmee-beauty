import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Header kartu yang reusable untuk semua halaman utama.
///
/// - `title`            : judul halaman (wajib).
/// - `showStatsToggle`  : tampilkan chevron collapse/expand stats di bawah header.
/// - `onStatsToggle`    : callback saat chevron ditekan.
class PageHeader extends StatelessWidget {
  final String title;
  final bool showStatsToggle;
  final VoidCallback? onStatsToggle;

  const PageHeader({
    super.key,
    required this.title,
    this.showStatsToggle = false,
    this.onStatsToggle,
  });

  @override
  Widget build(BuildContext context) {
    final header = Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              color: context.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (!showStatsToggle) return header;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        header,
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onStatsToggle,
              child: Container(
                width: 60,
                height: 20,
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                  border: Border(
                    left: BorderSide(
                      color: context.borderColor.withOpacity(0.5),
                      width: 1,
                    ),
                    right: BorderSide(
                      color: context.borderColor.withOpacity(0.5),
                      width: 1,
                    ),
                    bottom: BorderSide(
                      color: context.borderColor.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: context.textMuted.withOpacity(0.5),
                    size: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
