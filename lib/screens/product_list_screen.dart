import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/collapsible_stats.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import '../widgets/sort_indicator.dart';
import '../main.dart';
import 'add_product_screen.dart';

class ProductListScreen extends StatefulWidget {
  final bool initialStatsExpanded;

  const ProductListScreen({
    super.key,
    this.initialStatsExpanded = false,
  });

  @override
  State<ProductListScreen> createState() => ProductListScreenState();
}

enum SortOption { nameAsc, price, stock, margin }

class ProductListScreenState extends State<ProductListScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedCategory = 'Semua';
  List<String> _categories = ['Semua'];
  bool _showLowStockOnly = false;
  SortOption _sortOption = SortOption.nameAsc;
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<CollapsibleStatsState> _statsKey = GlobalKey<CollapsibleStatsState>();
  bool _isStatsExpanded = false;

  void _toggleStats() {
    final nextValue = !_isStatsExpanded;
    setState(() {
      _isStatsExpanded = nextValue;
    });
    _statsKey.currentState?.setExpanded(nextValue);
    SkincareApp.of(context)?.setStatsExpanded(nextValue);
  }

  @override
  void initState() {
    super.initState();
    _isStatsExpanded = widget.initialStatsExpanded;
    loadData();
  }

  Future<void> loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _db.getAllProducts();
      final cats = await _db.getAllCategories();
      setState(() {
        _products = products;
        _categories = ['Semua', ...cats];
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: context.destructiveColor,
          ),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    List<Product> result = _products;
    
    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      result = result.where((p) =>
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Filter by category
    if (_selectedCategory != 'Semua') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    
    // Filter by low stock
    if (_showLowStockOnly) {
      result = result.where((p) => p.stock <= kLowStockThreshold).toList();
    }
    
    // Apply sorting
    switch (_sortOption) {
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOption.price:
        result.sort((a, b) => b.sellPrice.compareTo(a.sellPrice));
        break;
      case SortOption.stock:
        result.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case SortOption.margin:
        result.sort((a, b) {
          final marginA = _calculateMarginPercentage(a);
          final marginB = _calculateMarginPercentage(b);
          return marginB.compareTo(marginA);
        });
        break;
    }
    
    setState(() => _filteredProducts = result);
  }

  void _deleteProduct(Product product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _db.deleteProduct(product.id!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Produk berhasil dihapus'),
                    backgroundColor: context.successColor,
                  ),
                );
              }
              loadData();
            },
            style: TextButton.styleFrom(foregroundColor: context.destructiveColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                PageHeader(
                  title: 'Daftar Produk',
                  showStatsToggle: true,
                  onStatsToggle: _toggleStats,
                ),
                CollapsibleStats(
                  key: _statsKey,
                  initialExpanded: _isStatsExpanded,
                  child: _buildSummaryStats(),
                ),
                const SizedBox(height: 12),
                _buildToolbar(),
                const SizedBox(height: 12),
                Expanded(child: _buildProductList()),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader(
            title: 'Daftar Produk',
            showStatsToggle: true,
            onStatsToggle: _toggleStats,
          ),
          const SizedBox(height: AppSpacing.lg),
          // Summary stats skeleton - 2 cards per row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Expanded(child: SummaryCardSkeleton()),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: SummaryCardSkeleton()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                const Expanded(child: SummaryCardSkeleton()),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(child: SummaryCardSkeleton()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Product cards skeleton
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 3,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, __) => const ProductCardSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalProducts = _products.length;
    final totalStockValue = _calculateTotalStockValue();
    final lowStockCount = _products.where((p) => p.stock <= kLowStockThreshold).length;
    final averageMargin = _calculateAverageMargin();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Total Produk',
                value: _formatNumber(totalProducts),
                trend: '+2%',
                trendColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Nilai Stok',
                value: _formatCurrencyCompact(totalStockValue),
                suffix: ' JT',
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Stok Rendah',
                value: '$lowStockCount',
                badge: 'WARNING',
                badgeColor: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Avg Margin',
                value: '$averageMargin',
                suffix: ' %',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    String? suffix,
    String? trend,
    Color? trendColor,
    String? badge,
    Color? badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  height: 1.1,
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    height: 1.1,
                  ),
                ),
              if (trend != null) ...[
                const SizedBox(width: 6),
                Text(
                  trend,
                  style: TextStyle(
                    color: trendColor ?? context.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    height: 1.1,
                  ),
                ),
              ],
              if (badge != null) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor?.withOpacity(0.1) ?? Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor ?? Colors.red,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Search bar
          SearchField(
            controller: _searchController,
            hintText: 'Cari produk atau SKU...',
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 10),
          // Filters row
          Row(
            children: [
              Expanded(
                child: _buildCategoryDropdown(),
              ),
              const SizedBox(width: 10),
              _buildSortButton(),
            ],
          ),
          // Sort indicator: hanya tampil saat sort bukan default.
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _sortOption == SortOption.nameAsc
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SortIndicator(
                      label: 'Diurutkan: $_currentSortLabel',
                      onTap: _showSortBottomSheet,
                      onClear: _resetSort,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.borderColor.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategory,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down, color: context.textMuted, size: 20),
          style: TextStyle(
            color: context.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
          dropdownColor: context.surfaceColor,
          items: _categories.map((cat) {
            return DropdownMenuItem<String>(
              value: cat,
              child: Text(cat == 'Semua' ? 'Semua Kategori' : cat),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCategory = value);
              _applyFilters();
            }
          },
        ),
      ),
    );
  }

  Widget _buildSortButton() {
    return InkWell(
      onTap: () {
        _showSortBottomSheet();
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.borderColor.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              color: context.textMuted,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Sort',
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Urutkan Berdasarkan',
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSortOption('Nama (A-Z)', SortOption.nameAsc),
              _buildSortOption('Harga', SortOption.price),
              _buildSortOption('Stok', SortOption.stock),
              _buildSortOption('Margin', SortOption.margin),
            ],
          ),
        );
      },
    );
  }

  String get _currentSortLabel {
    switch (_sortOption) {
      case SortOption.nameAsc:
        return 'Nama (A-Z)';
      case SortOption.price:
        return 'Harga';
      case SortOption.stock:
        return 'Stok';
      case SortOption.margin:
        return 'Margin';
    }
  }

  void _resetSort() {
    setState(() => _sortOption = SortOption.nameAsc);
    _applyFilters();
  }

  Widget _buildSortOption(String label, SortOption option) {
    final isSelected = _sortOption == option;
    return InkWell(
      onTap: () {
        setState(() => _sortOption = option);
        _applyFilters();
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: isSelected ? AppColors.primary : context.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : context.textPrimary,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductList() {
    if (_filteredProducts.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: context.backgroundColor,
      child: RefreshIndicator(
        onRefresh: loadData,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: _filteredProducts.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final product = _filteredProducts[index];
            return ProductCard(
              product: product,
              averageMargin: _calculateAverageMargin(),
              onTap: () async {
                await navigateTo(context, AddProductScreen(product: product));
                loadData();
              },
              onEdit: () async {
                await navigateTo(context, AddProductScreen(product: product));
                loadData();
              },
              onDelete: () => _deleteProduct(product),
            );
          },
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatCurrencyCompact(double amount) {
    if (amount >= 1000000000) {
      return (amount / 1000000000).toStringAsFixed(1);
    } else if (amount >= 1000000) {
      return (amount / 1000000).toStringAsFixed(1);
    } else if (amount >= 1000) {
      return (amount / 1000).toStringAsFixed(0);
    }
    return amount.toStringAsFixed(0);
  }

  Widget _buildEmptyState() {
    final hasFilter =
        _searchQuery.isNotEmpty || _selectedCategory != 'Semua' || _showLowStockOnly;
    return EmptyState(
      icon: Icons.inventory_2_outlined,
      title: hasFilter ? 'Tidak ada produk ditemukan' : 'Belum ada produk',
      message: hasFilter
          ? 'Coba ubah filter atau kata kunci pencarian'
          : 'Tambah produk pertamamu untuk mulai kelola stok',
      actionLabel: hasFilter ? null : 'Tambah Produk',
      actionIcon: Icons.add,
      onAction: hasFilter
          ? null
          : () async {
              await navigateTo(context, const AddProductScreen());
              loadData();
            },
    );
  }

  double _calculateTotalStockValue() {
    return _products.fold(0.0, (sum, p) => sum + (p.sellPrice * p.stock));
  }

  double _calculateAverageMargin() {
    if (_products.isEmpty) return 0;
    final totalMargin = _products.fold(0, (sum, p) => sum + _calculateMarginPercentage(p));
    return (totalMargin / _products.length).round().toDouble();
  }

  int _calculateMarginPercentage(Product product) {
    if (product.buyPrice == 0) return 0;
    return (((product.sellPrice - product.buyPrice) / product.buyPrice) * 100).round();
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatCurrencyShort(double amount) {
    if (amount >= 1000000000) {
      return 'Rp ${(amount / 1000000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(0)}rb';
    }
    return 'Rp ${_formatCurrency(amount)}';
  }
}