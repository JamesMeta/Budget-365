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

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  static Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        password_hash TEXT NOT NULL,
        email TEXT NOT NULL,
        most_recent_login INTEGER NOT NULL CHECK (most_recent_login  IN (0, 1))
      );
    ''');
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
      await db.insert('account', row);
      setMostRecentLogin(row['id']);
      return row['id'];
    } catch (e) {
      print('Error creating account: $e');
      return -1;
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
