import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_shell.dart';
import 'screens/add_product_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  // Load saved preferences synchronously so first frame is correct.
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? true; // Default to dark
  final isStatsExpanded = prefs.getBool('stats_expanded') ?? false;

  runApp(SkincareApp(
    isDarkMode: isDark,
    initialStatsExpanded: isStatsExpanded,
  ));
}

class SkincareApp extends StatefulWidget {
  final bool isDarkMode;
  final bool initialStatsExpanded;

  const SkincareApp({
    super.key,
    required this.isDarkMode,
    this.initialStatsExpanded = false,
  });

  @override
  State<SkincareApp> createState() => _SkincareAppState();

  static _SkincareAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SkincareAppState>();

  static bool getStatsExpanded(BuildContext context) {
    return of(context)?._isStatsExpanded ?? false;
  }
}

class _SkincareAppState extends State<SkincareApp> {
  late final ValueNotifier<ThemeMode> _themeMode;
  late bool _isStatsExpanded;

  @override
  void initState() {
    super.initState();
    _themeMode = ValueNotifier<ThemeMode>(
      widget.isDarkMode ? ThemeMode.dark : ThemeMode.light,
    );
    _isStatsExpanded = widget.initialStatsExpanded;
  }

  @override
  void dispose() {
    _themeMode.dispose();
    super.dispose();
  }

  Future<void> toggleTheme() async {
    final next = _themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    // Set theme mode tanpa animasi transisi.
    _themeMode.value = next;

    // Save theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', next == ThemeMode.dark);
  }

  Future<void> setStatsExpanded(bool value) async {
    if (_isStatsExpanded == value) return;
    setState(() {
      _isStatsExpanded = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('stats_expanded', value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          title: 'Skincare Stock',
          debugShowCheckedModeBanner: false,
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: mode,
          initialRoute: '/',
          routes: {
            '/': (context) => MainShell(
                  initialIndex: 0,
                  statsInitiallyExpanded: _isStatsExpanded,
                ),
            '/transactions': (context) => MainShell(
                  initialIndex: 1,
                  statsInitiallyExpanded: _isStatsExpanded,
                ),
            '/report': (context) => MainShell(
                  initialIndex: 2,
                  statsInitiallyExpanded: _isStatsExpanded,
                ),
            '/settings': (context) => MainShell(
                  initialIndex: 3,
                  statsInitiallyExpanded: _isStatsExpanded,
                ),
            '/add-product': (context) => const AddProductScreen(),
            '/add-transaction': (context) => const AddTransactionScreen(),
          },
        );
      },
    );
  }
}