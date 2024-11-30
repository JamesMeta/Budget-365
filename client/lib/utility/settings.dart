import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/utility/local_storage_manager.dart';

class SettingsWidget extends StatefulWidget {
  final CloudStorageManager
      cloudStorageManager; //connection with cloud storage manager
  final Future<bool> Function() onLogout;

  const SettingsWidget({
    super.key,
    required this.cloudStorageManager,
    required this.onLogout,
  });

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  bool receiveNotifications =
      false; //notifications reception defaults to false (to avoid spamming users)

  @override
  void initState() {
    super.initState();
    _loadNotificationSetting(); //retrieve the notification preference
  }

  //method connects to the local storage manager, which has a getter for notification prefs
  Future<void> _loadNotificationSetting() async {
    bool shouldReceive = await LocalStorageManager.getNotificationSetting();
    setState(() {
      receiveNotifications = shouldReceive;
    });
  }

  //method saves the selected notification value to local storage
  Future<void> _saveNotificationSetting(bool value) async {
    setState(() {
      receiveNotifications = value;
    });
    await LocalStorageManager.setNotificationSetting(value);
  }

  //method connects to the report export method in the cloud storage manager
  Future<void> _exportUserReports() async {
    try {
      await widget.cloudStorageManager.exportUserReports();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          //snackbars display either success or failure messages
          content: Text("Reports exported successfully!"),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Oops! Failed to export reports: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF123456), // Start color
              Color(0xFF654321), // End color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 100), // Space below the AppBar
              SwitchListTile(
                activeColor: Colors.lightBlueAccent,
                activeTrackColor: Colors.blueGrey,
                inactiveThumbColor: Colors.grey.shade700,
                inactiveTrackColor: Colors.grey.shade600,
                title: const Text(
                  'Receive Report Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                value: receiveNotifications,
                onChanged: (bool value) {
                  _saveNotificationSetting(value);
                },
              ),
              const SizedBox(height: 20), // Add some spacing
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF654321), // Button color
                  foregroundColor: Colors.white, // Text color
                  padding: const EdgeInsets.symmetric(
                      vertical: 12, horizontal: 20), // Button padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _exportUserReports,
                child: const Text(
                  'Export Reports',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF654321),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: logout,
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void logout() async {
    bool response = await widget.onLogout();
    if (response) {
      Navigator.pop(context, response);
    }
  }
}
