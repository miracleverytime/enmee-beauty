import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/transaction.dart' as model;
import '../theme/app_theme.dart';
import '../utils/page_transitions.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/collapsible_stats.dart';
import '../widgets/page_header.dart';
import '../main.dart';
import 'add_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  final bool initialStatsExpanded;

  const TransactionListScreen({
    super.key,
    this.initialStatsExpanded = false,
  });

  @override
  State<TransactionListScreen> createState() => TransactionListScreenState();
}

class TransactionListScreenState extends State<TransactionListScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<model.Transaction> _transactions = [];
  List<model.Transaction> _filteredTransactions = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedType = 'Semua';
  final List<String> _types = ['Semua', 'Hari Ini', 'Minggu Ini', 'Bulan Ini'];
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
      final data = await _db.getAllTransactions();
      setState(() => _transactions = data);
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
    List<model.Transaction> result = _transactions;

    if (_searchQuery.isNotEmpty) {
      result = result.where((t) =>
        (t.productName ?? '').toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    if (_selectedType != 'Semua') {
      final now = DateTime.now();
      result = result.where((t) {
        try {
          final date = DateTime.parse(t.date);
          switch (_selectedType) {
            case 'Hari Ini':
              return date.year == now.year &&
                  date.month == now.month &&
                  date.day == now.day;
            case 'Minggu Ini':
              final weekStart = now.subtract(Duration(days: now.weekday - 1));
              return date.isAfter(
                  DateTime(weekStart.year, weekStart.month, weekStart.day)
                      .subtract(const Duration(seconds: 1)));
            case 'Bulan Ini':
              return date.year == now.year && date.month == now.month;
          }
        } catch (_) {
          return true;
        }
        return true;
      }).toList();
    }

    setState(() => _filteredTransactions = result);
  }

  Future<void> _deleteTransaction(model.Transaction transaction) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text(
          'Hapus Transaksi',
          style: TextStyle(color: context.textPrimary),
        ),
        content: Text(
          'Hapus transaksi "${transaction.productName}" x${transaction.quantity}?',
          style: TextStyle(color: context.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: TextStyle(color: context.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _db.deleteTransaction(transaction.id!);
              final product = await _db.getProductById(transaction.productId);
              if (product != null) {
                await _db.updateProductStock(
                    product.id!, product.stock + transaction.quantity);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Transaksi berhasil dihapus'),
                    backgroundColor: context.successColor,
                  ),
                );
              }
              loadData();
            },
            style:
                TextButton.styleFrom(foregroundColor: context.destructiveColor),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                PageHeader(
                  title: 'Daftar Transaksi',
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
                Expanded(child: _buildTransactionList()),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader(
            title: 'Daftar Transaksi',
            showStatsToggle: true,
            onStatsToggle: _toggleStats,
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: const [
                Expanded(child: SummaryCardSkeleton()),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: SummaryCardSkeleton()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: const [
                Expanded(child: SummaryCardSkeleton()),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: SummaryCardSkeleton()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: const [
                Expanded(child: SummaryCardSkeleton()),
                SizedBox(width: AppSpacing.sm),
                Expanded(child: SummaryCardSkeleton()),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (_, __) => const _TransactionCardSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalRevenue = _transactions.fold(0.0, (sum, t) => sum + t.totalPrice);
    final totalProfit = _transactions.fold(0.0, (sum, t) {
      final margin = (t.sellPrice ?? 0) - (t.buyPrice ?? 0);
      return sum + (margin * t.quantity);
    });
    final marginPercent =
        totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).round() : 0;
    final totalTransactions = _transactions.length;
    final totalItems = _transactions.fold(0, (sum, t) => sum + t.quantity);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Total Penjualan',
                value: _formatCurrencyCompact(totalRevenue),
                suffix: ' JT',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Total Profit',
                value: _formatCurrencyCompact(totalProfit),
                suffix: ' JT',
                trend: '$marginPercent%',
                trendColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Jumlah Transaksi',
                value: _formatNumber(totalTransactions),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Item Terjual',
                value: _formatNumber(totalItems),
                suffix: ' unit',
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
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
          Container(
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
              onChanged: (value) {
                setState(() => _searchQuery = value);
                _applyFilters();
              },
              style: TextStyle(
                color: context.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Cari nama produk...',
                hintStyle: TextStyle(
                  color: context.textMuted,
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: context.textMuted,
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
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
                value: _selectedType,
                isExpanded: true,
                icon: Icon(Icons.keyboard_arrow_down, color: context.textMuted, size: 20),
                style: TextStyle(
                  color: context.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                dropdownColor: context.surfaceColor,
                items: _types.map((t) {
                  return DropdownMenuItem<String>(
                    value: t,
                    child: Text(t == 'Semua' ? 'Semua Periode' : t),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                    _applyFilters();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      color: context.backgroundColor,
      child: RefreshIndicator(
        onRefresh: loadData,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: _filteredTransactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final transaction = _filteredTransactions[index];
            return _buildTransactionCard(transaction);
          },
        ),
      ),
    );
  }

  Widget _buildTransactionCard(model.Transaction transaction) {
    final margin = (transaction.sellPrice ?? 0) - (transaction.buyPrice ?? 0);
    final profit = margin * transaction.quantity;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          await navigateTo(context, const AddTransactionScreen());
          loadData();
        },
        onLongPress: () => _deleteTransaction(transaction),
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
                    Icons.receipt_long_outlined,
                    color: context.textMuted,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.productName ??
                          'Produk #${transaction.productId}',
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
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
                            '${transaction.quantity} UNIT',
                            style: const TextStyle(
                              color: AppColors.chipPrimerText,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(transaction.date),
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Rp ${_formatCurrency(transaction.totalPrice)}',
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tahan lama untuk menghapus'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.delete_outline,
                        color: context.textMuted,
                        size: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
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
                          'LUNAS',
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
                  Text(
                    '+Rp ${_formatCurrency(profit)}',
                    style: TextStyle(
                      color: context.successColor,
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 80,
            color: context.textMuted,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            _searchQuery.isNotEmpty || _selectedType != 'Semua'
                ? 'Tidak ada transaksi ditemukan'
                : 'Belum ada transaksi',
            style: TextStyle(
              color: context.textSecondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            _searchQuery.isNotEmpty || _selectedType != 'Semua'
                ? 'Coba ubah filter atau pencarian'
                : 'Tap tombol + untuk menambah transaksi',
            style: TextStyle(
              color: context.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
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

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();

      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        final hour = date.hour.toString().padLeft(2, '0');
        final minute = date.minute.toString().padLeft(2, '0');
        return 'Hari ini · $hour.$minute';
      }

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des'
      ];
      final day = date.day.toString().padLeft(2, '0');
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$day ${months[date.month - 1]} · $hour.$minute';
    } catch (_) {
      return dateStr;
    }
  }
}

class _TransactionCardSkeleton extends StatelessWidget {
  const _TransactionCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonLoader(
            width: 44,
            height: 44,
            borderRadius: AppRadius.sm,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                SkeletonLoader(width: 150, height: 14),
                SizedBox(height: AppSpacing.sm),
                SkeletonLoader(width: 60, height: 10, borderRadius: AppRadius.sm),
                SizedBox(height: AppSpacing.sm),
                SkeletonLoader(width: 80, height: 9),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 100, height: 16),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: const [
              SkeletonLoader(width: 16, height: 16, borderRadius: AppRadius.sm),
              SizedBox(height: AppSpacing.xs),
              SkeletonLoader(width: 50, height: 14, borderRadius: AppRadius.sm),
              SizedBox(height: AppSpacing.xs),
              SkeletonLoader(width: 70, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
