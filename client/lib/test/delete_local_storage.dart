// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); //ensures that the flutter bindings are initialized
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'account_details.db');
  await deleteDatabase(path);
}
