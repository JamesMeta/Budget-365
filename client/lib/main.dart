// ignore_for_file: non_constant_identifier_names, unused_element, prefer_final_fields
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/home/budget_365_widget.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:budget_365/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //Initialize Supabase
  await Supabase.initialize(
    url: 'https://wywwdptapooirphafrqa.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind5d3dkcHRhcG9vaXJwaGFmcnFhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mjg5MzY4MzQsImV4cCI6MjA0NDUxMjgzNH0.6lBEAj2gUaO2ZbZB6RDZQQ9zaOiNT1EbUt9Bu18mHk8',
  );

  final cloudStorageManager = CloudStorageManager(Supabase.instance.client);
  WidgetsFlutterBinding.ensureInitialized(); // Required for async operations
  await LocalStorageManager.database;

  runApp(Budget365(cloudStorageManager));
}
