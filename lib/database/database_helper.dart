import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/transaction.dart' as model;

class DatabaseHelper {
  static Database? _database;
  static final DatabaseHelper instance = DatabaseHelper._init();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('skincare.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    Directory dbPath;
    try {
      dbPath = await getApplicationDocumentsDirectory();
    } catch (e) {
      final String defaultPath = await getDatabasesPath();
      dbPath = Directory(defaultPath);
    }
    
    if (!await dbPath.exists()) {
      await dbPath.create(recursive: true);
    }
    
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      readOnly: false,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        stock INTEGER NOT NULL DEFAULT 0,
        buy_price REAL NOT NULL DEFAULT 0,
        sell_price REAL NOT NULL DEFAULT 0,
        image_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        total_price REAL NOT NULL,
        date TEXT NOT NULL,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');
  }

  // PRODUCT CRUD

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProductById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> updateProductStock(int id, int newStock) async {
    final db = await database;
    return await db.update(
      'products',
      {'stock': newStock},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<String>> getAllCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM products ORDER BY category',
    );
    return maps.map((m) => m['category'] as String).toList();
  }

  Future<int> getTotalProducts() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM products');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getLowStockProducts() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM products WHERE stock <= 5',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // TRANSACTION CRUD

  Future<int> insertTransaction(model.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<model.Transaction>> getAllTransactions({String? startDate, String? endDate}) async {
    final db = await database;
    String sql = '''
      SELECT t.*, p.name as product_name, p.buy_price, p.sell_price
      FROM transactions t
      INNER JOIN products p ON t.product_id = p.id
    ''';
    List<dynamic> args = [];

    if (startDate != null && endDate != null) {
      sql += ' WHERE t.date BETWEEN ? AND ?';
      args = [startDate, endDate];
    } else if (startDate != null) {
      sql += ' WHERE t.date >= ?';
      args = [startDate];
    } else if (endDate != null) {
      sql += ' WHERE t.date <= ?';
      args = [endDate];
    }

    sql += ' ORDER BY t.date DESC, t.id DESC';

    final List<Map<String, dynamic>> maps = await db.rawQuery(sql, args);
    return List.generate(maps.length, (i) => model.Transaction.fromMap(maps[i]));
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  // REPORT QUERIES

  Future<Map<String, dynamic>> getRevenueSummary({String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE t.date BETWEEN ? AND ?';
      whereArgs = [startDate, endDate];
    } else if (startDate != null) {
      whereClause = 'WHERE t.date >= ?';
      whereArgs = [startDate];
    } else if (endDate != null) {
      whereClause = 'WHERE t.date <= ?';
      whereArgs = [endDate];
    }

    final result = await db.rawQuery('''
      SELECT
        COUNT(*) as total_transactions,
        COALESCE(SUM(t.total_price), 0) as total_revenue,
        COALESCE(SUM(t.quantity), 0) as total_items,
        COALESCE(SUM(t.total_price - (p.buy_price * t.quantity)), 0) as total_profit
      FROM transactions t
      INNER JOIN products p ON t.product_id = p.id
      $whereClause
    ''', whereArgs);

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getRevenueByDate({String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE t.date BETWEEN ? AND ?';
      whereArgs = [startDate, endDate];
    } else if (startDate != null) {
      whereClause = 'WHERE t.date >= ?';
      whereArgs = [startDate];
    } else if (endDate != null) {
      whereClause = 'WHERE t.date <= ?';
      whereArgs = [endDate];
    }

    return await db.rawQuery('''
      SELECT
        t.date,
        COUNT(*) as transaction_count,
        SUM(t.total_price) as revenue,
        SUM(t.quantity) as items_sold,
        SUM(t.total_price - (p.buy_price * t.quantity)) as profit
      FROM transactions t
      INNER JOIN products p ON t.product_id = p.id
      $whereClause
      GROUP BY t.date
      ORDER BY t.date DESC
    ''', whereArgs);
  }

  Future<List<Map<String, dynamic>>> getRevenueByProduct({String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE t.date BETWEEN ? AND ?';
      whereArgs = [startDate, endDate];
    } else if (startDate != null) {
      whereClause = 'WHERE t.date >= ?';
      whereArgs = [startDate];
    } else if (endDate != null) {
      whereClause = 'WHERE t.date <= ?';
      whereArgs = [endDate];
    }

    return await db.rawQuery('''
      SELECT
        p.name,
        SUM(t.quantity) as total_sold,
        SUM(t.total_price) as revenue,
        SUM(t.total_price - (p.buy_price * t.quantity)) as profit
      FROM transactions t
      INNER JOIN products p ON t.product_id = p.id
      $whereClause
      GROUP BY p.id
      ORDER BY revenue DESC
    ''', whereArgs);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}