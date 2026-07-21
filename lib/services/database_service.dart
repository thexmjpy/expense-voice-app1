import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../utils/default_categories.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_voice_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        icon TEXT NOT NULL,
        color_value INTEGER NOT NULL,
        keywords TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        raw_voice_text TEXT,
        date TEXT NOT NULL,
        is_income INTEGER NOT NULL DEFAULT 0
      )
    ''');

    for (final cat in defaultCategories()) {
      await db.insert('categories', cat.toMap()..remove('id'));
    }
  }

  Future<List<ExpenseCategory>> getAllCategories() async {
    final db = await database;
    final maps = await db.query('categories', orderBy: 'id ASC');
    return maps.map((m) => ExpenseCategory.fromMap(m)).toList();
  }

  Future<int> insertCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.insert('categories', category.toMap()..remove('id'));
  }

  Future<int> updateCategory(ExpenseCategory category) async {
    final db = await database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'id = ?',
      whereArgs: [category.id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertTransaction(ExpenseTransaction tx) async {
    final db = await database;
    return await db.insert('transactions', tx.toMap()..remove('id'));
  }

  Future<int> updateTransaction(ExpenseTransaction tx) async {
    final db = await database;
    return await db.update(
      'transactions',
      tx.toMap(),
      where: 'id = ?',
      whereArgs: [tx.id],
    );
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ExpenseTransaction>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC');
    return maps.map((m) => ExpenseTransaction.fromMap(m)).toList();
  }

  Future<List<ExpenseTransaction>> getTransactionsBetween(
      DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((m) => ExpenseTransaction.fromMap(m)).toList();
  }

  Future<Map<String, double>> getCategoryTotals(
      DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT category, SUM(amount) as total
      FROM transactions
      WHERE date >= ? AND date <= ? AND is_income = 0
      GROUP BY category
      ORDER BY total DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    return {
      for (final row in result)
        row['category'] as String: (row['total'] as num).toDouble()
    };
  }

  Future<double> getTotalByType(DateTime start, DateTime end, bool isIncome) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT SUM(amount) as total FROM transactions
      WHERE date >= ? AND date <= ? AND is_income = ?
    ''', [start.toIso8601String(), end.toIso8601String(), isIncome ? 1 : 0]);

    final total = result.first['total'];
    return total == null ? 0.0 : (total as num).toDouble();
  }
}
