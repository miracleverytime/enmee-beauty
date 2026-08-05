import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'screens/product_list_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/transaction_list_screen.dart';
import 'screens/add_transaction_screen.dart';
import 'screens/report_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const SkincareApp());
}

class SkincareApp extends StatefulWidget {
  const SkincareApp({super.key});

  @override
  State<SkincareApp> createState() => _SkincareAppState();

  static _SkincareAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_SkincareAppState>();
}

class _SkincareAppState extends State<SkincareApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Skincare Stock',
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      darkTheme: darkTheme(),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const ProductListScreen(),
        '/add-product': (context) => const AddProductScreen(),
        '/transactions': (context) => const TransactionListScreen(),
        '/add-transaction': (context) => const AddTransactionScreen(),
        '/report': (context) => const ReportScreen(),
      },
    );
  }
}