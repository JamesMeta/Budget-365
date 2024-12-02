import 'package:flutter/widgets.dart';
import 'package:budget_365/utility/local_storage_manager.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocalStorageManager.printAll();
}
