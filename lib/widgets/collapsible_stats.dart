import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Widget untuk menampilkan statistik yang bisa di-collapse/expand
class CollapsibleStats extends StatefulWidget {
  final Widget child;
  final VoidCallback? onToggle;
  final Function(BuildContext, VoidCallback, Animation<double>)? buildToggleButton;
  final bool initialExpanded;

  const CollapsibleStats({
    super.key,
    required this.child,
    this.onToggle,
    this.buildToggleButton,
    this.initialExpanded = false,
  });

  @override
  State<CollapsibleStats> createState() => CollapsibleStatsState();
}

class CollapsibleStatsState extends State<CollapsibleStats>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  Animation<double> get iconRotation => Tween<double>(
        begin: 0.0,
        end: 0.5,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ));

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initialExpanded;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: _isExpanded ? 1.0 : 0.0,
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void didUpdateWidget(covariant CollapsibleStats oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialExpanded != widget.initialExpanded &&
        _isExpanded != widget.initialExpanded) {
      _isExpanded = widget.initialExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
    widget.onToggle?.call();
  }

  void setExpanded(bool value) {
    if (_isExpanded == value) {
      if ((value && _controller.value != 1.0) ||
          (!value && _controller.value != 0.0)) {
        if (value) {
          _controller.forward();
        } else {
          _controller.reverse();
        }
      }
      return;
    }
    setState(() {
      _isExpanded = value;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Widget buildToggleButton(BuildContext context) {
    return GestureDetector(
      onTap: toggleExpanded,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: context.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(
            color: context.borderColor.withOpacity(0.6),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: RotationTransition(
            turns: iconRotation,
            child: Icon(
              Icons.keyboard_arrow_down,
              color: context.textSecondary,
              size: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _expandAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _expandAnimation,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: widget.child,
        ),
      ),
    );
  }
}
