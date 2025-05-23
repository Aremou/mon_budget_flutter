import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// --- Database Service ---
class DBService {
  static Database? _db;

  static Future<Database> init() async {
    if (_db != null) return _db!;

    String path = join(await getDatabasesPath(), 'budget.db');
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE categories (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT
        )''');

        await db.execute('''CREATE TABLE budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          period TEXT,
          amount REAL,
          categoryId INTEGER
        )''');

        await db.execute('''CREATE TABLE expenses (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          categoryId INTEGER,
          amount REAL,
          label TEXT,
          note TEXT
        )''');

        await db.execute('''CREATE TABLE revenues (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          date TEXT,
          amount REAL,
          label TEXT,
          note TEXT
        )''');
      },
    );
    return _db!;
  }

  static Future<int> insert(String table, Map<String, dynamic> data) async {
    final db = await init();
    return await db.insert(table, data);
  }

  static Future<List<Map<String, dynamic>>> getAll(String table) async {
    final db = await init();
    return await db.query(table);
  }

  static Future<int> delete(String table, int id) async {
    final db = await init();
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(String table, Map<String, dynamic> data) async {
    final db = await init();
    return await db
        .update(table, data, where: 'id = ?', whereArgs: [data['id']]);
  }
}
