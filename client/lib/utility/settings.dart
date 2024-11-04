// ignore_for_file: unused_import, avoid_print

import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/utility/delete_local_storage.dart';
import 'package:budget_365/utility/print_local_storage.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/login/login_widget.dart';

class SettingsWidget extends StatefulWidget {
  final int id;
  final CloudStorageManager cloudStorageManager;

  const SettingsWidget(
      {super.key, required this.id, required this.cloudStorageManager});

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
          ElevatedButton(
            onPressed: () {
              logout();
            },
            child: Text('Logout'),
          )
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

  void logout() {
    WidgetsFlutterBinding
        .ensureInitialized(); // Ensure Flutter bindings are initialized
    LocalStorageManager.logout(widget.id);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => LoginWidget(
                cloudStorageManager: widget.cloudStorageManager,
              )),
    ).then((result) {
      if (result != null) {
        setState(() {
          Navigator.of(context).pop(result);
        });
      } else {
        setState(() {
          Navigator.of(context).pop();
        });
      }
    });
  }
}
