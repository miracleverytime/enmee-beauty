import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bottom_nav_bar.dart';
import '../utils/page_transitions.dart';
import 'product_list_screen.dart';
import 'transaction_list_screen.dart';
import 'report_screen.dart';
import 'settings_screen.dart';
import 'add_product_screen.dart';
import 'add_transaction_screen.dart';

/// Shell route yang menjadi host untuk 4 tab utama aplikasi.
///
/// - `IndexedStack` menjaga state tiap tab (scroll, search, dsb)
///   ketika user berpindah tab, sehingga tidak rebuild dari awal.
/// - Bottom nav bar dan FAB diletakkan di sini (sekali saja),
///   sehingga setiap perubahan style cukup diedit di satu tempat.
class MainShell extends StatefulWidget {
  final int initialIndex;
  final bool statsInitiallyExpanded;

  const MainShell({
    super.key,
    this.initialIndex = 0,
    this.statsInitiallyExpanded = false,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  final GlobalKey<ProductListScreenState> _productsKey =
      GlobalKey<ProductListScreenState>();
  final GlobalKey<TransactionListScreenState> _transactionsKey =
      GlobalKey<TransactionListScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, 3);
  }

  void _onTabChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  Future<void> _onFabPressed() async {
    switch (_currentIndex) {
      case 0:
        await navigateTo(context, const AddProductScreen());
        _productsKey.currentState?.loadData();
        break;
      case 1:
        await navigateTo(context, const AddTransactionScreen());
        _transactionsKey.currentState?.loadData();
        break;
      default:
        break;
    }
  }

  bool get _showFab => _currentIndex == 0 || _currentIndex == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: Container(
        color: context.backgroundColor,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _AnimatedTab(
              isActive: _currentIndex == 0,
              child: ProductListScreen(
                key: _productsKey,
                initialStatsExpanded: widget.statsInitiallyExpanded,
              ),
            ),
            _AnimatedTab(
              isActive: _currentIndex == 1,
              child: TransactionListScreen(
                key: _transactionsKey,
                initialStatsExpanded: widget.statsInitiallyExpanded,
              ),
            ),
            _AnimatedTab(
              isActive: _currentIndex == 2,
              child: ReportScreen(
                initialStatsExpanded: widget.statsInitiallyExpanded,
              ),
            ),
            const _AnimatedTab(
              isActive: true,
              child: SettingsScreen(),
            ),
          ],
        ),
      ),
      floatingActionButton: AnimatedScale(
        scale: _showFab ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: _showFab ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          child: IgnorePointer(
            ignoring: !_showFab,
            child: Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onFabPressed,
                  customBorder: const CircleBorder(),
                  child: const Icon(Icons.add, color: Colors.white, size: 32),
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        showFab: _showFab,
      ),
    );
  }
}

/// Animated wrapper untuk konten tab. Fade + slide in saat tab pertama kali
/// diaktifkan; setelah aktif tetap pasif agar interaksi user (scroll, search)
/// tidak terganggu oleh animasi ulang.
class _AnimatedTab extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const _AnimatedTab({
    required this.isActive,
    required this.child,
  });

  @override
  State<_AnimatedTab> createState() => _AnimatedTabState();
}

class _AnimatedTabState extends State<_AnimatedTab>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
      value: widget.isActive ? 1.0 : 0.0,
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(_fade);
  }

  @override
  void didUpdateWidget(covariant _AnimatedTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

