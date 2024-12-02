import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/notifications/email_sender.dart';

class SettingsWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
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
      false; //default setting - when the value is false, the user won't get a push notification (prevents spam)

  bool receiveLogin = true;
  bool receiveLogoff = true;
  @override
  void initState() {
    super.initState();
    _loadNotificationSetting();
    _loadLogoffSetting();
    _loadLogonSetting();
  }

  Future<void> _loadNotificationSetting() async {
    //retrieves the user's notification preference from local database
    bool shouldReceive = await LocalStorageManager.getNotificationSetting();
    setState(() {
      receiveNotifications = shouldReceive;
    });
  }

  Future<void> _loadLogonSetting() async {
    bool logonNotificationEnabled = await LocalStorageManager.getLoginSetting();
    setState(() {
      receiveLogin = logonNotificationEnabled;
    });
  }

  Future<void> _loadLogoffSetting() async {
    bool logoffNotificationEnabled =
        await LocalStorageManager.getLogoffSetting();
    setState(() {
      receiveLogoff = logoffNotificationEnabled;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    //when the user sets the notification preference, that value is stored using localstoragemanager
    setState(() {
      receiveNotifications = value;
    });
    await LocalStorageManager.setNotificationSetting(value);
  }

  Future<void> _saveLogonSetting(bool value) async {
    setState(() {
      receiveLogin = value;
    });
    await LocalStorageManager.setLoginSetting(value);
  }

  Future<void> _saveLogoffSetting(bool value) async {
    setState(() {
      receiveLogoff = value;
    });
    await LocalStorageManager.setLogoffSetting(value);
  }

  Future<void> _exportUserReports() async {
    //defines the response to the user pressing the export reports button
    try {
      await widget.cloudStorageManager
          .exportUserReports(); //main functionality - cloudstoragemanager handles the actual export process
      ScaffoldMessenger.of(context).showSnackBar(
        //snackbar carries the response message
        const SnackBar(content: Text("Reports exported successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Oops! Failed to export reports: $e")),
      );
    }
  }

  // New function to send balance email
  Future<void> _sendBalanceEmail() async {
    try {
      await widget.cloudStorageManager.sendBalanceEmail();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Balance email sent successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Oops! Failed to send balance email: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    //settings construction
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
      body: Stack(
        children: [
          const AppGradient(), //app theme gradient from app_gradient.dart is invoked
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50),
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
                  onChanged: _saveNotificationSetting,
                ),
                const SizedBox(height: 50),
                SwitchListTile(
                  activeColor: Colors.lightBlueAccent,
                  activeTrackColor: Colors.blueGrey,
                  inactiveThumbColor: Colors.grey.shade700,
                  inactiveTrackColor: Colors.grey.shade600,
                  title: const Text(
                    'Receive Login Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: receiveLogin,
                  onChanged: _saveLogonSetting,
                ),
                const SizedBox(height: 50),
                SwitchListTile(
                  activeColor: Colors.lightBlueAccent,
                  activeTrackColor: Colors.blueGrey,
                  inactiveThumbColor: Colors.grey.shade700,
                  inactiveTrackColor: Colors.grey.shade600,
                  title: const Text(
                    'Receive Logoff Notifications',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: receiveLogoff,
                  onChanged: _saveLogoffSetting,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 40, 176, 218),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
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
                    backgroundColor: const Color.fromARGB(255, 40, 176, 218),
                    foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _sendBalanceEmail, // Trigger sendBalanceEmail
                  child: const Text(
                    'Send Balance Email',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 40, 176, 218),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 20),
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
        ],
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
