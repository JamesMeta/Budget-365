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

  // Extract Firebase keys from .env
  DefaultFirebaseOptions.initialize(
    webApiKey: dotenv.env['FIREBASE_WEB_API_KEY'] ?? '',
    androidApiKey: dotenv.env['FIREBASE_ANDROID_API_KEY'] ?? '',
    iosApiKey: dotenv.env['FIREBASE_IOS_API_KEY'] ?? '',
    macosApiKey: dotenv.env['FIREBASE_MACOS_API_KEY'] ?? '',
    windowsApiKey: dotenv.env['FIREBASE_WINDOWS_API_KEY'] ?? '',
  );

  // Initialize Firebase
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  // Initialize Firebase messaging
  await FirebaseApi().initNotifications();

  // Extract Supabase credentials from .env
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception('Supabase URL or Anon Key is missing from .env');
  }

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Rename the variable to avoid conflict with the class name
  final localNotificationsManager = LocalNotificationsManager();
  final cloudStorageManager = CloudStorageManager(
    Supabase.instance.client,
    localNotificationsManager,
  );

  // Ensure LocalStorageManager is ready
  await LocalStorageManager.database;

  // Run your app
  runApp(Budget365(cloudStorageManager));

  // Handle background messages for Firebase Messaging
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}
