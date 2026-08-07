import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/product.dart';

/// Constants
const int kLowStockThreshold = 5;

/// Card untuk menampilkan item produk
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final double averageMargin;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.averageMargin = 0,
  });

  @override
  Widget build(BuildContext context) {
    final margin = _calculateMarginPercentage();
    final isLowStock = product.stock <= kLowStockThreshold;
    final isOutOfStock = product.stock == 0;
    final stockStatus = _getStockStatus();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.borderColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product thumbnail
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: context.textMuted,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Product info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Category badges
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipPrimerBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              color: AppColors.chipPrimerText,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.chipFacialBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'FACIAL',
                            style: const TextStyle(
                              color: AppColors.chipFacialText,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Price section
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Harga Satuan',
                          style: TextStyle(
                            color: context.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(product.sellPrice),
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Stock info and edit button
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Edit button
                  InkWell(
                    onTap: onEdit,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.edit_outlined,
                        color: context.textMuted,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Stock status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          stockStatus.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  // Stock number
                  Text(
                    '${product.stock} Unit',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: _getCategoryColor(context),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        product.category,
        style: AppTextStyles.labelSmall.copyWith(
          color: _getCategoryTextColor(context),
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildIconButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: color ?? context.textSecondary,
        ),
      ),
    );
  }

  Widget _buildStockBadge(
    BuildContext context,
    String status,
    bool isOutOfStock,
    bool isLowStock,
  ) {
    Color bgColor;
    Color textColor;

    if (isOutOfStock) {
      bgColor = context.destructiveColor.withOpacity(0.1);
      textColor = context.destructiveColor;
    } else if (isLowStock) {
      bgColor = context.warningColor.withOpacity(0.1);
      textColor = context.warningColor;
    } else {
      bgColor = context.successColor.withOpacity(0.1);
      textColor = context.successColor;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        status,
        style: AppTextStyles.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }

  Color _getStockColor(BuildContext context, bool isOutOfStock, bool isLowStock) {
    if (isOutOfStock) return context.destructiveColor;
    if (isLowStock) return context.warningColor;
    return context.successColor;
  }

  Color _getCategoryColor(BuildContext context) {
    // Generate warna soft berdasarkan kategori
    final hash = product.category.hashCode;
    final colors = [
      const Color(0xFFDCFCE7), // green-100
      const Color(0xFFDDEAFB), // blue-100
      const Color(0xFFFCE7F3), // pink-100
      const Color(0xFFFEF3C7), // yellow-100
      const Color(0xFFE0E7FF), // indigo-100
      const Color(0xFFF3E8FF), // purple-100
    ];
    
    final darkColors = [
      const Color(0xFF1E3A2E), // dark green
      const Color(0xFF1E2B3A), // dark blue
      const Color(0xFF3A1E2E), // dark pink
      const Color(0xFF3A331E), // dark yellow
      const Color(0xFF1E1F3A), // dark indigo
      const Color(0xFF2E1E3A), // dark purple
    ];
    
    return context.isDark 
        ? darkColors[hash.abs() % darkColors.length]
        : colors[hash.abs() % colors.length];
  }

  Color _getCategoryTextColor(BuildContext context) {
    final hash = product.category.hashCode;
    final colors = [
      const Color(0xFF065F46), // green-800
      const Color(0xFF1E40AF), // blue-800
      const Color(0xFF9F1239), // pink-800
      const Color(0xFF92400E), // yellow-800
      const Color(0xFF3730A3), // indigo-800
      const Color(0xFF6B21A8), // purple-800
    ];
    
    final darkColors = [
      const Color(0xFF86EFAC), // light green
      const Color(0xFF93C5FD), // light blue
      const Color(0xFFF9A8D4), // light pink
      const Color(0xFFFDE68A), // light yellow
      const Color(0xFFC7D2FE), // light indigo
      const Color(0xFFE9D5FF), // light purple
    ];
    
    return context.isDark 
        ? darkColors[hash.abs() % darkColors.length]
        : colors[hash.abs() % colors.length];
  }

  String _getStockStatus() {
    if (product.stock == 0) return 'Habis';
    if (product.stock <= kLowStockThreshold) return 'Stok Rendah';
    return 'Stok Aman';
  }

  int _calculateMarginPercentage() {
    if (product.buyPrice == 0) return 0;
    return (((product.sellPrice - product.buyPrice) / product.buyPrice) * 100).round();
  }

  String _formatCurrency(double amount) {
    return 'Rp ${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}';
  }
}
