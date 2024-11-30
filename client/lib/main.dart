// ignore_for_file: non_constant_identifier_names, unused_element, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/home/budget_365_widget.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:budget_365/firebase_options.dart';
import 'notifications/firebase_api.dart';
import 'notifications/local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: "assets/keys/env");

  //associates loaded env variables with api variables
  DefaultFirebaseOptions.initialize(
    webApiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
    androidApiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
    iosApiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
    macosApiKey: dotenv.env['FIREBASE_MACOS_API_KEY'] ?? '',
    windowsApiKey: dotenv.env['FIREBASE_WINDOWS_API_KEY'] ?? '',
  );

  //initializes firebase connection
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await FirebaseApi().initNotifications();

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

  final localNotificationsManager = LocalNotificationsManager();
  final cloudStorageManager = CloudStorageManager(
    Supabase.instance.client,
    localNotificationsManager,
  );

  //wait for local storage to activate
  await LocalStorageManager.database;

  runApp(Budget365(cloudStorageManager));

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}
