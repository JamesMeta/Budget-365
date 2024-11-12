// ignore_for_file: non_constant_identifier_names, unused_element, prefer_final_fields

import 'package:budget_365/group/group.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/report/report_tile_widget.dart';
import 'package:budget_365/report/report.dart';
import 'package:budget_365/report/report_creation_widget.dart';
import 'package:budget_365/utility/settings.dart';
import 'package:budget_365/visualization/data_visualization_widget.dart';
import 'package:budget_365/group/groups_overview_widget.dart';
import 'package:budget_365/utility/local_storage_manager.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/login/login_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
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

class Budget365 extends StatelessWidget {
  final CloudStorageManager cloudStorageManager;

  Budget365(this.cloudStorageManager);

  // This widget is the root of your application.
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

  Budget365Widget(
      {super.key, required this.title, required this.cloudStorageManager});

  final String title;

  @override
  State<Budget365Widget> createState() => _Budget365WidgetState();
}

class _Budget365WidgetState extends State<Budget365Widget> {
  List<Report> _reports = [];
  List<Group> _groups = [];
  late int userLoggedIn;
  int _selectedNavigationalIndex = 0;
  String? _selectedGroupItem = '';
  int _selectedGroupID = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initAccounts(), // The Future to wait for
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        // Check the connection state to handle loading, error, or data
        if (snapshot.hasError) {
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: false,
            appBar: AppBarSection(),
            body: Stack(children: [
              Gradient(),
              Center(child: Text('Error: ${snapshot.error}')),
            ]), // Show error message
            bottomNavigationBar: BottomNavigationBarSection(),
          );
        } else if (snapshot.connectionState == ConnectionState.done) {
          // Once the data is fetched, show the UI
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBarSection(),
            body: Stack(
              children: [
                Gradient(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 120, 10, 10),
                  child: Column(
                    children: [
                      DropDown_CalendarSection(),
                      const SizedBox(height: 5),
                      TableLabelsSection(),
                      TableRowsSection(),
                    ],
                  ),
                ),
                PlusButtonSection(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBarSection(),
          );
        } else {
          return Scaffold(
            extendBody: true,
            extendBodyBehindAppBar: true,
            appBar: AppBarSection(),
            body: Stack(
              children: [
                Gradient(),
                Center(child: CircularProgressIndicator()),
              ],
            ), // Show loading
            bottomNavigationBar: BottomNavigationBarSection(),
          );
        }
      },
    );
  }

  PreferredSizeWidget AppBarSection() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Image.asset('assets/images/logo.png'),
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

  Widget DropDown_CalendarSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        DropDownMenuGroupSection(),
        IconButton(
            onPressed: _goToCalendar,
            icon: const Icon(Icons.calendar_month,
                color: Colors.white, size: 30)),
      ],
    );
  }

  Widget DropDownMenuGroupSection() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(5),
        ),
        width: 200,
        height: 40,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.all(10),
          dropdownColor: Colors.blue,
          menuWidth: 200,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: Container(
            color: Colors.transparent,
          ),
          isExpanded: true,
          value: _selectedGroupItem,
          menuMaxHeight: 150,
          onChanged: (String? value) {
            setState(() {
              _selectedGroupItem = value;
              _selectedGroupID = _groups
                  .firstWhere((group) => group.name == value)
                  .id; // Get the ID of the selected group
            });
          },
          items: _groups.map((Group group) {
            return DropdownMenuItem<String>(
              value: group.name,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                ),
                child: Text(
                  group.name,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget TableLabelsSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Users",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(children: [
              Text("Type",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  )),
            ]),
          ),
          Container(
            width: 75,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  "Amount",
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 120,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("Category",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: 35,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text("Date",
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget TableRowsSection() {
    return Expanded(
      child: StreamBuilder<List<Report>>(
        stream: widget.cloudStorageManager.getReportsStream(_selectedGroupID),
        builder: (BuildContext context, AsyncSnapshot<List<Report>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reports available'));
          } else {
            final reports = snapshot.data!;
            return ListView.builder(
              itemCount: reports.length,
              itemBuilder: (BuildContext context, int index) {
                return ReportTileWidget(report: reports[index]);
              },
            );
          }
        },
      ),
    );
  }

  Widget PlusButtonSection() {
    return Positioned(
      right: 20,
      bottom: 100,
      child: Container(
        width: 70, // Set size of the container
        height: 70, // Set size of the container
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 71, 162, 236), // Background color
          shape: BoxShape.circle, // Circular shape Optional: add border
          border: Border.all(
            color: Colors.black, // Border color
            width: 1, // Border width
          ),
        ),
        child: IconButton(
          onPressed: _goToReportBuilder,
          icon: const Icon(
            Icons.add, // Use a plus icon
            color: Colors.white, // Icon color
            size: 55, // Adjust size to fit well
          ),
          padding: EdgeInsets.zero, // Remove padding
          constraints: const BoxConstraints(), // No constraints
          splashColor:
              Colors.blue.withOpacity(0.4), // Splash color for feedback
          highlightColor:
              Colors.white.withOpacity(0.3), // Highlight color for feedback
        ),
      ),
    );
  }

  Widget BottomNavigationBarSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.black, width: 1)),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        selectedItemColor: Colors.grey,
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

  Widget Gradient() {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 33, 81, 240),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 33, 81, 240),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )),
    );
  }

  Widget AlertNoLoginFound() {
    return AlertDialog(
      title: const Text('No user logged in'),
      content: const Text('Please log in to continue'),
      actions: <Widget>[
        TextButton(
          onPressed: () async {
            int result = await _goToLogin();
            if (result >= 0) {
              Navigator.of(context).pop(true); // Success, user logged in
            } else {
              Navigator.of(context).pop(false); // Failure, user did not log in
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  Future<void> _initAccounts() async {
    var value = await LocalStorageManager.fetchAccounts();
    if (value.isNotEmpty) {
      final mostRecentLogin = value.firstWhere(
        (account) => account['most_recent_login'] == 1,
        orElse: () => {},
      );
      if (mostRecentLogin.isNotEmpty) {
        int id = await widget.cloudStorageManager
            .login(mostRecentLogin['email'], mostRecentLogin['password']);
        if (id != -1) {
          // If login is successful, update the userLoggedIn state
          userLoggedIn = id;
          _groups = await widget.cloudStorageManager.getGroups(userLoggedIn);
          if (_groups.isNotEmpty && _selectedGroupItem == '') {
            _selectedGroupItem = _groups[0].name;
            _selectedGroupID = _groups[0].id;
          }
          return; // Finish the future successfully
        }
      }
    }
    // If no accounts or no recent login is found, show an alert dialog
    bool loginResult = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertNoLoginFound();
          },
        ) ??
        false;

    if (loginResult) {
      // Handle successful login, do any additional work here
      return;
    } else {
      // Handle unsuccessful login or dialog dismiss, prevent further execution
      return;
    }
  }

  Future<int> _goToLogin() async {
    try {
      await LocalStorageManager.logout(userLoggedIn);
    } catch (e) {
      print("No Login to Logout From: $e");
    }

    // Wait for the result of the navigation
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LoginWidget(cloudStorageManager: widget.cloudStorageManager),
      ),
    );

    if (result != null) {
      if (!mounted)
        return -1; // Ensure widget is mounted before calling setState
      setState(() {
        userLoggedIn = result;
      });
      return 0; // Login successful
    } else {
      return -1; // Login failed
    }
  }

  void _goToSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => SettingsWidget(
                cloudStorageManager: widget.cloudStorageManager,
                onLogout: _goToLogin,
              )),
    ).then((result) {
      if (result != null) {
        setState(() {
          userLoggedIn = result;
        });
      } else {
        print("Settings Popped with no login");
      }
    });
  }

  void _goToCalendar() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const CalendarPage()),
    // );
  }

  void _goToDataVisualization() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DataVisualizationWidget()),
    );
  }

  void _goToGroupsOverview() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GroupsOverviewWidget()),
    );
  }

  void _goToReportBuilder() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportCreationWidget(
                cloudStorageManager: widget.cloudStorageManager,
                selectedGroup: _selectedGroupItem!,
                groups: _groups,
                userID: userLoggedIn,
              )),
    );
  }

  void _onTapedNavigation(int index) {
    setState(() {
      _selectedNavigationalIndex = index;
    });
  }
}
