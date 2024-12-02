// ignore_for_file: avoid_print

import 'package:shared_preferences/shared_preferences.dart';
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
      version: 2, //increment this when you change the schema
      onCreate: _createDB, //this will create the table if it does not exist
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
    return result.isNotEmpty; //returns true if the table exists
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

  static Future<String> getAccountUsername(int id) async {
    final db = await database;

    final response = await db.query(
      'account',
      columns: ['username'],
      where: 'id = ?',
      whereArgs: [id],
    );

    return response[0]['username'] as String;
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
    try {
      final db = await database;

      await db.rawUpdate('''
      UPDATE account
      SET most_recent_login = 0
      WHERE id = ?
    ''', [id]);
    } catch (e) {
      print('Error logging out: $e');
    }
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

  //method retrieves the notification preference stored locally for the user
  static Future<bool> getNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('receive_notifications') ?? false;
  }

  //method uses shared preferences to store the boolean storage preference value
  static Future<void> setNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('receive_notifications', value);
  }

  static Future<bool> getLoginSetting() async {
    final loginPref = await SharedPreferences.getInstance();
    return loginPref.getBool('receive_logon') ?? true;
  }

  static Future<void> setLoginSetting(bool value) async {
    final loginPref = await SharedPreferences.getInstance();
    loginPref.setBool('receive_logon', value);
  }

  static Future<bool> getLogoffSetting() async {
    final logoffPref = await SharedPreferences.getInstance();
    return logoffPref.getBool('receive_logoff') ?? true;
  }

  static Future<void> setLogoffSetting(bool value) async {
    final logoffPref = await SharedPreferences.getInstance();
    logoffPref.setBool('receive_logoff', value);
  }

  //method retrieves the ID of the user logged-in with the local session
  static Future<int?> getCurrentUserID() async {
    final db = await database; //connects to the local storage

    try {
      final response = await db.query(
        'account',
        columns: ['id'],
        where: 'most_recent_login = ?',
        whereArgs: [1], //the most recent login is the logged-in user
      );

      if (response.isNotEmpty) {
        return response.first['id'] as int;
      }
    } catch (e) {
      print('Error fetching current user ID: $e');
    }

    return null; // Return null if no user is logged in
  }
}
