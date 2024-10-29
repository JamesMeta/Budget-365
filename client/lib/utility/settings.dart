import 'package:flutter/material.dart';
import 'package:budget_365/utility/delete_local_storage.dart';
import 'package:budget_365/utility/print_local_storage.dart';
import 'package:budget_365/utility/local_storage_manager.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: <Widget>[
          ElevatedButton(
            onPressed: () {
              deleteLocalStorage();
            },
            child: Text('Delete Local Storage'),
          ),
          ElevatedButton(
            onPressed: () {
              printLocalStorage();
            },
            child: Text('Print Local Storage'),
          ),
        ],
      ),
    );
  }

  void deleteLocalStorage() {
    WidgetsFlutterBinding
        .ensureInitialized(); // Ensure Flutter bindings are initialized
    LocalStorageManager.deleteAll();
    print('All data deleted');
  }

  void printLocalStorage() {
    WidgetsFlutterBinding
        .ensureInitialized(); // Ensure Flutter bindings are initialized
    LocalStorageManager.printAll();
  }
}
