// ignore_for_file: non_constant_identifier_names, unused_element, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/home/budget_365_widget.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //load environment variables

  await dotenv.load(fileName: "assets/keys/env");

  //as with the firebase options, the supabase env variables are loaded
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase URL or Anon Key is missing from .env');
  }

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  final cloudStorageManager = CloudStorageManager(
    //passes supabase and localnotifications manager to init cloud storage manager
    Supabase.instance.client,
  );

  //wait for local storage to activate
  await LocalStorageManager.database;

  runApp(Budget365(cloudStorageManager));
}
