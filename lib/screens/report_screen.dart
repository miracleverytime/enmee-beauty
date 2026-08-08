import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/collapsible_stats.dart';
import '../widgets/page_header.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import '../widgets/staggered_item.dart';
import '../utils/haptics.dart';
import '../utils/formatters.dart';
import '../utils/app_toast.dart';
import '../main.dart';

class ReportScreen extends StatefulWidget {
  final bool initialStatsExpanded;

  const ReportScreen({
    super.key,
    this.initialStatsExpanded = false,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

enum ReportPeriod { hariIni, mingguIni, bulanIni, semua }

extension _ReportPeriodLabel on ReportPeriod {
  String get label {
    switch (this) {
      case ReportPeriod.hariIni:
        return 'Hari Ini';
      case ReportPeriod.mingguIni:
        return 'Minggu Ini';
      case ReportPeriod.bulanIni:
        return 'Bulan Ini';
      case ReportPeriod.semua:
        return 'Semua';
    }
  }
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  bool _isLoading = true;
  ReportPeriod _selectedPeriod = ReportPeriod.bulanIni;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<CollapsibleStatsState> _statsKey = GlobalKey<CollapsibleStatsState>();
  bool _isStatsExpanded = false;

  Map<String, dynamic> _summary = {};
  List<Map<String, dynamic>> _revenueByProduct = [];
  List<Map<String, dynamic>> _filteredByProduct = [];

  void _toggleStats() {
    Haptics.medium();
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
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final dates = _getDateRange();
      final summary = await _db.getRevenueSummary(
        startDate: dates.start,
        endDate: dates.end,
      );
      final byProduct = await _db.getRevenueByProduct(
        startDate: dates.start,
        endDate: dates.end,
      );

      setState(() {
        _summary = summary;
        _revenueByProduct = byProduct;
      });
      _applyFilters();
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          title: 'Gagal Memuat Laporan',
          description: '$e',
        );
      }
    }
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredByProduct = _revenueByProduct;
    } else {
      _filteredByProduct = _revenueByProduct.where((item) {
        final name = (item['name'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery.toLowerCase());
      }).toList();
    }
  }

  _DateRange _getDateRange() {
    final now = DateTime.now();
    DateTime? start;
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedPeriod) {
      case ReportPeriod.hariIni:
        start = DateTime(now.year, now.month, now.day);
        break;
      case ReportPeriod.mingguIni:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        break;
      case ReportPeriod.bulanIni:
        start = DateTime(now.year, now.month, 1);
        break;
      case ReportPeriod.semua:
        return const _DateRange();
    }

    return _DateRange(
      start: start.toIso8601String(),
      end: end.toIso8601String(),
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
                  title: 'Laporan Pendapatan',
                  showStatsToggle: true,
                  onStatsToggle: _toggleStats,
                  isStatsExpanded: _isStatsExpanded,
                ),
                CollapsibleStats(
                  key: _statsKey,
                  initialExpanded: _isStatsExpanded,
                  child: _buildSummaryStats(),
                ),
                const SizedBox(height: 12),
                _buildToolbar(),
                const SizedBox(height: 12),
                Expanded(child: _buildReportBody()),
              ],
            ),
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        children: [
          PageHeader(
            title: 'Laporan Pendapatan',
            showStatsToggle: true,
            onStatsToggle: _toggleStats,
            isStatsExpanded: _isStatsExpanded,
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
            itemBuilder: (_, __) => const _ReportItemSkeleton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStats() {
    final totalTransactions = _summary['total_transactions'] ?? 0;
    final totalItems = _summary['total_items'] ?? 0;
    final totalRevenue = (_summary['total_revenue'] ?? 0.0).toDouble();
    final totalProfit = (_summary['total_profit'] ?? 0.0).toDouble();
    final marginPercent =
        totalRevenue > 0 ? ((totalProfit / totalRevenue) * 100).round() : 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Total Pendapatan',
                value: Formatters.compact(totalRevenue).value,
                suffix: Formatters.compact(totalRevenue).unit,
                trend: '$marginPercent%',
                trendColor: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Total Profit',
                value: Formatters.compact(totalProfit).value,
                suffix: Formatters.compact(totalProfit).unit,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: 'Transaksi',
                value: Formatters.number(totalTransactions),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildStatCard(
                label: 'Item Terjual',
                value: Formatters.number(totalItems),
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
          SearchField(
            controller: _searchController,
            hintText: 'Cari produk terlaris...',
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _applyFilters();
            },
          ),
          const SizedBox(height: 10),
          _buildPeriodSelector(),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: ReportPeriod.values.map((period) {
        final isSelected = period == _selectedPeriod;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: period == ReportPeriod.values.last ? 0 : AppSpacing.sm,
            ),
            child: InkWell(
              onTap: () {
                if (isSelected) return;
                Haptics.selection();
                setState(() => _selectedPeriod = period);
                _loadData();
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : context.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : context.borderColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : context.textPrimary,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReportBody() {
    if (_filteredByProduct.isEmpty) {
      return _buildEmptyProductSection();
    }

    return Container(
      color: context.backgroundColor,
      child: RefreshIndicator(
        onRefresh: _loadData,
        child: StaggeredListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          itemCount: _filteredByProduct.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            return _buildProductItem(index, _filteredByProduct[index]);
          },
        ),
      ),
    );
  }

  Widget _buildProductItem(int index, Map<String, dynamic> item) {
    final name = item['name'] ?? 'Unknown';
    final sold = item['total_sold'] ?? 0;
    final revenue = (item['revenue'] ?? 0.0).toDouble();

    return Material(
      color: Colors.transparent,
      child: InkWell(
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
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.borderColor.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
                            color: AppColors.chipFacialBg,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'TERLARIS',
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
                    Text(
                      'Pendapatan',
                      style: TextStyle(
                        color: context.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.currencyRp(revenue),
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
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: context.backgroundColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.star,
                      color: AppColors.warning,
                      size: 12,
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
                          'TOP',
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
                    '$sold unit',
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

  Widget _buildEmptyProductSection() {
    final hasFilter = _searchQuery.isNotEmpty;
    return EmptyState(
      icon: Icons.bar_chart_outlined,
      title: hasFilter ? 'Tidak ada produk ditemukan' : 'Belum ada data produk',
      message: hasFilter
          ? 'Coba ubah kata kunci pencarian'
          : 'Mulai catat transaksi untuk melihat produk terlaris di sini',
    );
  }
}

class _DateRange {
  final String? start;
  final String? end;

  const _DateRange({this.start, this.end});
}

class _ReportItemSkeleton extends StatelessWidget {
  const _ReportItemSkeleton();

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
              SkeletonLoader(width: 20, height: 20, borderRadius: AppRadius.sm),
              SizedBox(height: AppSpacing.xs),
              SkeletonLoader(width: 40, height: 14, borderRadius: AppRadius.sm),
              SizedBox(height: AppSpacing.xs),
              SkeletonLoader(width: 60, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
