import 'package:flutter/material.dart';

/// ListView dengan animasi stagger (fade + slide-up) saat pertama paint.
///
/// Menerima `itemCount` + `itemBuilder` + `separatorBuilder` seperti
/// `ListView.separated`. Hanya [maxStagger] item pertama yang di-stagger;
/// sisanya langsung muncul agar list panjang tidak terasa lambat. Scroll
/// dan interaksi lain tidak terpengaruh karena animasi hanya berjalan
/// sekali di awal.
class StaggeredListView extends StatefulWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final int delayStep;
  final int maxStagger;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const StaggeredListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.delayStep = 50,
    this.maxStagger = 8,
    this.padding,
    this.physics,
    this.controller,
  });

  @override
  State<StaggeredListView> createState() => _StaggeredListViewState();
}

class _StaggeredListViewState extends State<StaggeredListView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final int _totalMs;

  @override
  void initState() {
    super.initState();
    _totalMs = 320 + widget.maxStagger * widget.delayStep;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMs),
    );
    // Mulai setelah frame pertama agar list mounted dulu.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: widget.controller,
      physics: widget.physics,
      padding: widget.padding,
      itemCount: widget.itemCount,
      separatorBuilder: widget.separatorBuilder ??
          (_, __) => const SizedBox.shrink(),
      itemBuilder: (context, index) {
        final child = widget.itemBuilder(context, index);
        if (index >= widget.maxStagger) return child;
        return StaggeredItem(
          index: index,
          totalMs: _totalMs,
          delayStep: widget.delayStep,
          controller: _controller,
          child: child,
        );
      },
    );
  }
}

/// Item dengan animasi fade + slide-up berdasarkan interval di controller.
class StaggeredItem extends StatelessWidget {
  final int index;
  final int totalMs;
  final int delayStep;
  final AnimationController controller;
  final Widget child;

  const StaggeredItem({
    super.key,
    required this.index,
    required this.totalMs,
    required this.delayStep,
    required this.controller,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * delayStep) / totalMs;
    final end = ((index * delayStep) + 320) / totalMs;
    final opacity = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0.0, 1.0),
        end.clamp(0.0, 1.0),
        curve: Curves.easeOutCubic,
      ),
    );
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(opacity);

    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
