import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../utils/page_transitions.dart';
import '../theme/app_theme.dart';
import 'product_list_screen.dart';
import 'transaction_list_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isLoading = true;
  String _selectedPeriod = 'Hari Ini';
  
  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _revenueByDate = [];
  List<Map<String, dynamic>> _revenueByProduct = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dates = _getDateRange();
      final summary = await _db.getRevenueSummary(startDate: dates['start'], endDate: dates['end']);
      final byDate = await _db.getRevenueByDate(startDate: dates['start'], endDate: dates['end']);
      final byProduct = await _db.getRevenueByProduct(startDate: dates['start'], endDate: dates['end']);
      
      setState(() {
        _summary = summary;
        _revenueByDate = byDate;
        _revenueByProduct = byProduct;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e'), backgroundColor: Colors.red),
        );
      }
    }
    setState(() => _isLoading = false);
  }

  Map<String, String> _getDateRange() {
    final now = DateTime.now();
    String? startDate;
    String? endDate = DateTime(now.year, now.month, now.day, 23, 59, 59).toIso8601String();

    switch (_selectedPeriod) {
      case 'Hari Ini':
        startDate = DateTime(now.year, now.month, now.day).toIso8601String();
        break;
      case 'Minggu Ini':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(weekStart.year, weekStart.month, weekStart.day).toIso8601String();
        break;
      case 'Bulan Ini':
        startDate = DateTime(now.year, now.month, 1).toIso8601String();
        break;
      case 'Semua':
        startDate = null;
        endDate = null;
        break;
    }

    return {'start': startDate ?? '', 'end': endDate ?? ''};
  }

  @override
  Widget build(BuildContext context) {
    final totalTransactions = _summary['total_transactions'] ?? 0;
    final totalItems = _summary['total_items'] ?? 0;
    final totalRevenue = (_summary['total_revenue'] ?? 0.0).toDouble();
    final totalProfit = (_summary['total_profit'] ?? 0.0).toDouble();
    final marginPercent = totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).round() : 0;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  _buildHeader(),
                  _buildPeriodSelector(),
                  const SizedBox(height: 12),
                  _buildSummaryStats(totalRevenue, totalProfit, marginPercent, totalTransactions, totalItems),
                  const SizedBox(height: 12),
                  _buildProductListSection(),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
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
            'Laporan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: context.textPrimary,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: context.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Export action
                  },
                  icon: Icon(
                    Icons.download_outlined,
                    color: context.textSecondary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    final periods = ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Semua'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: periods.map((period) {
            final isSelected = period == _selectedPeriod;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () {
                  setState(() => _selectedPeriod = period);
                  _loadData();
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : context.surfaceColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : context.borderColor,
                      width: 1,
                    ),
                  ),
                  child: Text(
                    period,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? Colors.white : context.textMuted,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSummaryStats(double revenue, double profit, int marginPercent, int transactions, int items) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Total Revenue',
                  value: _formatCurrencyCompact(revenue),
                  suffix: revenue >= 1000000 ? ' JT' : ' RB',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Total Profit',
                  value: _formatCurrencyCompact(profit),
                  suffix: profit >= 1000000 ? ' JT' : ' RB',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  label: 'Transaksi',
                  value: '$transactions',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  label: 'Margin',
                  value: '$marginPercent',
                  suffix: ' %',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    String? suffix,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
        children: [
          Text(
            label,
            style: TextStyle(
              color: context.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 6),
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
                ),
              ),
              if (suffix != null)
                Text(
                  suffix,
                  style: TextStyle(
                    color: context.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ],
      ),
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

  Widget _buildProductListSection() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        color: context.backgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _revenueByProduct.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada data produk',
                        style: TextStyle(color: Color(0xFF757575)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.separated(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _revenueByProduct.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) => _buildProductCard(_revenueByProduct[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> item) {
    final name = item['name'] ?? 'Unknown';
    final sold = item['total_sold'] ?? 0;
    final revenue = (item['revenue'] ?? 0.0).toDouble();
    final profit = (item['profit'] ?? 0.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$sold unit · Rp ${_formatCurrency(revenue)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '+Rp ${_formatCurrency(profit)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(child: _buildNavItem(Icons.inventory_2_outlined, 'Produk', false, () => navigateFade(context, const ProductListScreen()))),
            Expanded(child: _buildNavItem(Icons.receipt_long_outlined, 'Transaksi', false, () => navigateFade(context, const TransactionListScreen()))),
            Expanded(child: _buildNavItem(Icons.bar_chart, 'Laporan', true, () {})),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primary : context.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isActive ? AppColors.primary : context.textMuted,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
  }
}