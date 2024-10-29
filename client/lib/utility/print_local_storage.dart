import 'package:flutter/widgets.dart'; // Import Flutter widgets library
import 'package:budget_365/utility/local_storage_manager.dart';

void main() {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter bindings are initialized
  LocalStorageManager.printAll();
}