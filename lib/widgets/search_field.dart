import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Search field konsisten dengan tombol clear (X) yang muncul saat ada query.
///
/// - `controller`  : TextEditingController dari parent (agar parent bisa baca
///                   nilai terbaru via `controller.text`).
/// - `onChanged`   : dipanggil tiap perubahan teks.
/// - `onClear`     : opsional, dipanggil saat tombol X ditekan.
///                    Parent cukup memanggil `controller.clear()` sendiri di
///                    dalam callback; widget ini tidak auto-clear supaya parent
///                    tetap punya kontrol penuh atas state & filter.
class SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  const SearchField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.onChanged,
    this.onClear,
  });

  void _handleClear() {
    controller.clear();
    onChanged('');
    onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: context.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: context.textMuted,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: context.textMuted,
            size: 20,
          ),
          // suffixIcon dibungkus ValueListenableBuilder agar icon X
          // muncul/hilang reaktif terhadap perubahan teks.
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: Icon(
                  Icons.close,
                  size: 18,
                  color: context.textMuted,
                ),
                onPressed: _handleClear,
                tooltip: 'Hapus pencarian',
                splashRadius: 18,
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
