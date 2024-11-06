// ignore_for_file: avoid_print

import 'package:flutter/widgets.dart'; // Import Flutter widgets library
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

Future<void> main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  final dbPath = await getDatabasesPath();
  final path = p.join(dbPath, 'account_details.db');
  await deleteDatabase(path);
}
