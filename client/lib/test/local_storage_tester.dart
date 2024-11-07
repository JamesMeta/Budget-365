import 'package:sqflite/sqflite.dart';
import 'package:flutter/widgets.dart';

Future<bool> checkIfTableExists(Database db, String tableName) async {
  List<Map<String, dynamic>> result = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
    [tableName],
  );
  return result.isNotEmpty;
}

Future<List<String>> getColumnNames(Database db, String tableName) async {
  final List<Map<String, dynamic>> columnInfo =
      await db.rawQuery("PRAGMA table_info($tableName)");
  List<String> columnNames =
      columnInfo.map((column) => column['name'] as String).toList();
  return columnNames;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var db = await openDatabase('account_details.db');
  bool tableExists = await checkIfTableExists(db, 'account');
  print("Table exists: $tableExists");

  List<String> columnNames = await getColumnNames(db, 'account');
  print("Column names: $columnNames");
}
