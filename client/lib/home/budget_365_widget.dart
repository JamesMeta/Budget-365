// ignore_for_file: non_constant_identifier_names, empty_catches

import 'package:flutter/material.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/report/report_tile_widget.dart';
import 'package:budget_365/report/report.dart';
import 'package:budget_365/report/report_creation_widget.dart';
import 'package:budget_365/utility/settings.dart';
import 'package:budget_365/visualization/data_visualization_widget.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/login/login_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:budget_365/group/group_ui_overview_widget.dart';
import 'package:budget_365/group/group_creation_widget.dart';
import 'package:budget_365/home/home_widget.dart';
import 'package:budget_365/design/app_gradient.dart';

class Budget365 extends StatelessWidget {
  final CloudStorageManager cloudStorageManager;

  const Budget365(this.cloudStorageManager, {super.key});

  //base widget for the app
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Budget365Widget(
          title: 'Budget365', cloudStorageManager: cloudStorageManager),
    );
  }
}

class Budget365Widget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;

  const Budget365Widget(
      {super.key, required this.title, required this.cloudStorageManager});

  final String title;

  @override
  State<Budget365Widget> createState() => _Budget365WidgetState();
}

class _Budget365WidgetState extends State<Budget365Widget> {
  int userLoggedIn = -1;
  int _selectedNavigationalIndex = 0;
  bool loginInProgress = false;

  late double _appBarHeight;

  late List<Widget> _widgetOptions = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _appBarHeight = MediaQuery.of(context).size.height * 0.1;

    return FutureBuilder(
      future: _initalizeApp(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Stack(
              children: [CircularProgressIndicator(), const AppGradient()]);
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBarSection(),
            bottomNavigationBar: BottomNavigationBarSection(),
            body: _widgetOptions.elementAt(_selectedNavigationalIndex),
          );
        }
      },
    );
  }

  void _onTapedNavigation(int index) {
    setState(() {
      _selectedNavigationalIndex = index;
    });
  }

  Future<void> _initalizeApp() async {
    await _initAccounts();
    await _initScreens();
    return;
  }

  Future<void> _initAccounts() async {
    final session = await widget.cloudStorageManager.isLoggedIn();
    if (session && userLoggedIn != -1) {
      return;
    } //bypasses the login process if the cloud storage manager reports that the user is already logged-in

    var value = await LocalStorageManager.fetchAccounts();

    if (value.isNotEmpty) {
      final mostRecentLogin = value.firstWhere(
        (account) => account['most_recent_login'] == 1,
        orElse: () => {},
      );

      if (mostRecentLogin.isNotEmpty) {
        final response = await widget.cloudStorageManager
            .login(mostRecentLogin['email'], mostRecentLogin['password']);
        if (int.tryParse(response!) != null) {
          userLoggedIn = int.parse(response);
          return;
        }
      }
    }

    // alert if no accounts or no recent login is found, show an alert dialog
    if (!loginInProgress) {
      loginInProgress = true;
      await _goToLogin();
      loginInProgress = false;
      return;
    }
  }

  Future<void> _initScreens() async {
    _widgetOptions = [
      HomeWidget(
          cloudStorageManager: widget.cloudStorageManager,
          userLoggedIn: userLoggedIn),
      DataVisualizationWidget(
        cloudStorageManager: widget.cloudStorageManager,
      ),
      GroupOverviewPage(
          cloudStorageManager: widget.cloudStorageManager,
          userLoggedIn: userLoggedIn),
    ];
  }

  PreferredSizeWidget AppBarSection() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Image.asset('assets/images/logo.png'),
      toolbarHeight: _appBarHeight,
      // title:
      //     Text(widget.title, style: const TextStyle(color: Colors.white)),
      actions: [
        IconButton(
            onPressed: _goToSettings,
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
              size: 30,
            )),
      ],
      leadingWidth: 100,
    );
  }

  Widget BottomNavigationBarSection() {
    //defines the lower snackbar
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: const Color.fromARGB(255, 80, 80, 80),
        unselectedItemColor: Colors.white,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        currentIndex: _selectedNavigationalIndex,
        onTap: _onTapedNavigation,
        iconSize: 40,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: '',
          ),
        ],
      ),
    );
  }

  Future<bool> _goToLogin() async {
    try {
      clearSession();
    } catch (e) {}

    //wait for the result of the navigation
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoginWidget(cloudStorageManager: widget.cloudStorageManager),
      ),
    );

    if (result != null) {
      if (!mounted) {
        return false; //esures the  widget is mounted before calling setState
      }
      setState(() {
        userLoggedIn = result;
      });

      return true; //logged-in
    } else {
      return false; //couldn't login
    }
  }

  Future<bool> _goToLoginSettings() async {
    try {
      await LocalStorageManager.logout(userLoggedIn);
    } catch (e) {}

    try {
      await widget.cloudStorageManager.logout();
    } catch (e) {}

    try {
      clearSession();
    } catch (e) {}

    return true;
  }

  void clearSession() {
    setState(() {
      userLoggedIn = -1;
      _selectedNavigationalIndex = 0;
    });
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SettingsWidget(
                cloudStorageManager: widget.cloudStorageManager,
                onLogout: _goToLoginSettings,
              )),
    );
  }
}
