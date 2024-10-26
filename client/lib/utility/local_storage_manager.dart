import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('account_details.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        email TEXT NOT NULL,
        account_code TEXT NOT NULL
      );
    ''');
  }

  Future<int> createAccount(Map<String, dynamic> row) async {
    final db = await instance.database;

    return await db.insert('account', row);
  }

  Future<List<Map<String, dynamic>>> fetchAccounts() async {
    final db = await instance.database;

    return await db.query('account');
  }

  Future<int> updateAccount(Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];

    return await db.update(
      'account',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteGrade(int id) async {
    final db = await instance.database;

    return await db.delete(
      'account',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
