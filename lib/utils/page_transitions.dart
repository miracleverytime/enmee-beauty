import 'package:flutter/material.dart';

/// Custom page route dengan animasi fade & slide
class FadeSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final Offset beginOffset;

  FadeSlideRoute({
    required this.page,
    this.beginOffset = const Offset(1.0, 0.0), // slide dari kanan
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );
            
            final slideAnimation = Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            );

            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}

/// Transisi untuk navigasi maju (push) - slide dari kanan
Future<T?> navigateTo<T>(BuildContext context, Widget page) {
  return Navigator.push<T>(
    context,
    FadeSlideRoute(page: page),
  );
}

/// Transisi untuk navigasi berganti (pushReplacement) - fade saja
Future<T?> navigateReplace<T>(BuildContext context, Widget page) {
  return Navigator.pushReplacement<T, dynamic>(
    context,
    FadeSlideRoute(page: page, beginOffset: Offset.zero),
  );
}

/// Transisi untuk bottom navigation - fade halus
Future<T?> navigateFade<T>(BuildContext context, Widget page) {
  return Navigator.pushReplacement<T, dynamic>(
    context,
    PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 200),
    ),
  );
}
