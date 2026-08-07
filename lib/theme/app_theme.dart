import 'package:flutter/material.dart';

/// Design Tokens - Color Palette
class AppColors {
  // Primary & Accent Colors
  static const Color primary = Color(0xFF6D4AFF); // #6D4AFF - FAB, tab aktif, aksen ungu
  static const Color accent = Color(0xFF7F8AF5); // #7F8AF5 - indigo terang
  static const Color softAccentBg = Color(0xFFEFEBFF); // #EFEBFF - soft accent bg

  // Semantic Colors
  static const Color success = Color(0xFF34D896); // #34D896 - stok aman / margin positif
  static const Color warning = Color(0xFFF6BD36); // #F6BD36 - badge stok rendah
  static const Color destructive = Color(0xFFF14460); // #F14460 - stok habis / error

  // Category Chips (Light Theme)
  static const Color chipPrimerText = Color(0xFF2563EB); // #2563EB
  static const Color chipPrimerBg = Color(0xFFDBEAFE); // #DBEAFE
  static const Color chipFacialText = Color(0xFFEA6A28); // #EA6A28
  static const Color chipFacialBg = Color(0xFFFDE6D8); // #FDE6D8

  // Stock Badge (Light Theme)
  static const Color stockSafeText = Color(0xFF15803D); // #15803D
  static const Color stockSafeBg = Color(0xFFDCFCE7); // #DCFCE7
  static const Color stockSafeBorder = Color(0xFF86EFAC); // #86EFAC

  // Notification Badge
  static const Color notificationBadge = Color(0xFFEF4444); // #EF4444

  // Dark Mode Colors
  static const Color darkBackground = Color(0xFF0A0D15); // #0A0D15 - latar layar
  static const Color darkSurface = Color(0xFF161B24); // #161B24 - kartu metrik, produk, nav
  static const Color darkSecondary = Color(0xFF1F242E); // #1F242E - field search, tombol filter
  static const Color darkBorder = Color(0xFF232935); // #232935 - garis tepi
  static const Color darkForeground = Color(0xFFFAFAFA); // #FAFAFA - teks utama
  static const Color darkMutedForeground = Color(0xFF95A3B6); // #95A3B6 - teks sekunder / label

  // Light Mode Tokens
  static const Color lightBackground = Color(0xFFF4F5F7); // #F4F5F7 - latar layar
  static const Color lightSurface = Color(0xFFFFFFFF); // #FFFFFF - kartu / surface
  static const Color lightBorder = Color(0xFFE5E7EB); // #E5E7EB - garis tepi
  static const Color lightTextPrimary = Color(0xFF1A2233); // #1A2233 - teks utama
  static const Color lightTextSecondary = Color(0xFF6B7280); // #6B7280 - teks sekunder
  static const Color lightTextMuted = Color(0xFF9CA3AF); // #9CA3AF - teks muted
}

/// Design Tokens - Spacing & Sizing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
}

/// Design Tokens - Border Radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double pill = 100.0;
}

/// Design Tokens - Typography
class AppTextStyles {
  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.2,
    letterSpacing: -0.5,
  );
  
  // Headings
  static const TextStyle headingLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );
  
  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );
  
  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.5,
  );
  
  // Eyebrow (uppercase small text)
  static const TextStyle eyebrow = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0.8,
  );
}

/// Light Theme
ThemeData lightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.lightSurface,
      error: AppColors.destructive,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.lightSurface,
      foregroundColor: AppColors.lightTextPrimary,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      headlineLarge: AppTextStyles.headingLarge,
      headlineMedium: AppTextStyles.headingMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ).apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    ),
  );
}

/// Dark Theme
ThemeData darkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.darkSurface,
      error: AppColors.destructive,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkForeground,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
    ),
    textTheme: const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      headlineLarge: AppTextStyles.headingLarge,
      headlineMedium: AppTextStyles.headingMedium,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ).apply(
      bodyColor: AppColors.darkForeground,
      displayColor: AppColors.darkForeground,
    ),
  );
}

/// Theme Extension untuk akses mudah warna semantik
extension ThemeExtension on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  Color get surfaceColor => isDark ? AppColors.darkSurface : AppColors.lightSurface;
  Color get backgroundColor => isDark ? AppColors.darkBackground : AppColors.lightBackground;
  Color get secondaryColor => isDark ? AppColors.darkSecondary : AppColors.lightBackground;
  Color get borderColor => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get textPrimary => isDark ? AppColors.darkForeground : AppColors.lightTextPrimary;
  Color get textSecondary => isDark ? AppColors.darkMutedForeground : AppColors.lightTextSecondary;
  Color get textMuted => isDark ? AppColors.darkMutedForeground : AppColors.lightTextMuted;
  
  // Semantic colors
  Color get primaryColor => AppColors.primary;
  Color get accentColor => AppColors.accent;
  Color get successColor => AppColors.success;
  Color get warningColor => AppColors.warning;
  Color get destructiveColor => AppColors.destructive;
}
