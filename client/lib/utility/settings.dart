// ignore_for_file: unused_import, avoid_print

import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/test/delete_local_storage.dart';
import 'package:budget_365/test/print_local_storage.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/login/login_widget.dart';

class SettingsWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  Future<int> Function() onLogout;

  SettingsWidget(
      {super.key, required this.cloudStorageManager, required this.onLogout});

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
              logout();
            },
            child: Text('Logout'),
          ),
          ThisFeatureHasNotBeenImplemented(),
        ],
      ),
    );
  }

  Widget ThisFeatureHasNotBeenImplemented() {
    return AlertDialog(
      title: const Text('Features Not Implemented'),
      content: const Text(
          'The settings page has yet to be implemented other than the logout button.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
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

  void logout() async {
    int response = await widget.onLogout();
    if (response != -1) {
      Navigator.pop(context);
    }
  }
}
