// ignore_for_file: avoid_print

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

class LocalStorageManager {
  static final LocalStorageManager instance = LocalStorageManager._init();

  static Database? _database;

  LocalStorageManager._init();

  static Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('account_details.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2, // Increment this when you change the schema
      onCreate: _createDB, // This will create the table if it does not exist
    );
  }

  static Future _createDB(Database db, int version) async {
    try {
      await db.execute('''
      CREATE TABLE account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL,
        most_recent_login INTEGER NOT NULL CHECK (most_recent_login IN (0, 1))
      );
    ''');
      print("Table 'account' created successfully.");
    } catch (e) {
      print("Error creating table: $e");
    }
  }

  static Future<bool> isTableExists() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT name FROM sqlite_master WHERE type='table' AND name='account';
  ''');
    return result.isNotEmpty; // Returns true if the table exists
  }

  static Future<int> setMostRecentLogin(int id) async {
    final db = await database;

    await db.rawUpdate('''
      UPDATE account
      SET most_recent_login = 0
      WHERE id != ?
    ''', [id]);

    return await db.rawUpdate('''
      UPDATE account
      SET most_recent_login = 1
      WHERE id = ?
    ''', [id]);
  }

  static Future<bool> isAccountCashed(String email) async {
    final db = await database;

    final response = await db.query(
      'account',
      where: 'email = ?',
      whereArgs: [email],
    );

    return response.isNotEmpty;
  }

  static Future<int> createAccount(Map<String, dynamic> row) async {
    try {
      final db = await database;
      final id = await db.insert('account', row);

      return id;
    } catch (e) {
      print('Error creating account: $e');
      return -1; // Or consider throwing an exception
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAccounts() async {
    final db = await database;

    return await db.query('account');
  }

  static Future<int> updateAccount(Map<String, dynamic> row) async {
    final db = await database;
    final id = row['id'];

    return await db.update(
      'account',
      row,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> logout(int id) async {
    final db = await database;

    await db.rawUpdate('''
      UPDATE account
      SET most_recent_login = 0
      WHERE id = ?
    ''', [id]);
  }

  static Future<int> deleteAccount(int id) async {
    final db = await database;

    return await db.delete(
      'account',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future close() async {
    final db = await database;

    db.close();
  }

  static Future deleteAll() async {
    final db = await database;

    return await db.delete('account');
  }

  static Future printAll() async {
    final db = await database;

    final accounts = await db.query('account');

    print(accounts);
  }
}
