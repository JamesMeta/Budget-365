import 'package:flutter/material.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/report/report.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/report/report_tile_widget.dart';
import 'package:budget_365/report/report_creation_widget.dart';
import 'package:budget_365/design/app_gradient.dart';

class HomeWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final int userLoggedIn;

  const HomeWidget(
      {super.key,
      required this.cloudStorageManager,
      required this.userLoggedIn});

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  List<dynamic>? _reports = [];
  List<Group> _groups = [];

  String? _selectedGroupItem;
  int? _selectedGroupID;

  static const _labelFontSize = 17.5;
  static const _labelFontColor = Color.fromARGB(255, 255, 255, 255);
  static const _containerFillColor = Color.fromARGB(0, 255, 255, 255);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppGradient(),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
          child: FutureBuilder(
            future: _getGroups(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Stack(
                  children: [
                    CircularProgressIndicator(),
                    AppGradient(),
                  ],
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    DropDown_CalendarSection(),
                    const SizedBox(height: 5),
                    TableLabelsSection(),
                    TableRowsSection(),
                  ],
                );
              }
              return const SizedBox();
            },
          ),
        ),
        PlusButtonSectionBody(),
      ],
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
          border: Border.all(color: Colors.black, width: 2),
          borderRadius: BorderRadius.circular(5),
        ),
        width: 200,
        height: 40,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.white),
          padding: const EdgeInsets.all(10),
          dropdownColor: const Color.fromARGB(255, 84, 136, 182),
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.black,
          borderRadius: BorderRadius.circular(20),
          menuWidth: 200,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
          underline: Container(
            color: Colors.transparent,
          ),
          isExpanded: true,
          value: _selectedGroupItem,
          menuMaxHeight: 150,
          onChanged: (
            String? value,
          ) {
            final newGroupID = _groups
                .firstWhere((group) => group.name == value)
                .id; // Get the ID of the selected group
            setState(() {
              _selectedGroupItem = value;
              _selectedGroupID = newGroupID;
            });
          },
          items: _groups.map((Group group) {
            return DropdownMenuItem<String>(
              value: group.name,
              child: Container(
                alignment: Alignment.center,
                height: 40,
                width: 180,
                decoration: BoxDecoration(),
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
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        color: _containerFillColor,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SingleChildScrollView(
            child: Container(
              width: 55,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Users",
                    style: const TextStyle(
                        fontSize: _labelFontSize,
                        fontWeight: FontWeight.bold,
                        color: _labelFontColor),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: 55,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("Type",
                        style: TextStyle(
                          fontSize: _labelFontSize,
                          fontWeight: FontWeight.bold,
                          color: _labelFontColor,
                        )),
                  ]),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: 70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Amount",
                    style: const TextStyle(
                        fontSize: _labelFontSize,
                        fontWeight: FontWeight.bold,
                        color: _labelFontColor),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: 105,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Category",
                      style: const TextStyle(
                          fontSize: _labelFontSize,
                          fontWeight: FontWeight.bold,
                          color: _labelFontColor)),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: 50,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("Date",
                      style: const TextStyle(
                          fontSize: _labelFontSize,
                          fontWeight: FontWeight.bold,
                          color: _labelFontColor)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget TableRowsSection() {
    return Expanded(
      child: StreamBuilder(
        key: ValueKey(_selectedGroupID),
        stream:
            widget.cloudStorageManager.getReportsStream(_selectedGroupID ?? 0),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Center(child: Text('No reports found.'));
          } else {
            _reports =
                snapshot.data as List<dynamic>?; // Cast `snapshot.data` safely.
            return ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount:
                  _reports?.length ?? 0, // Default to 0 if `reports` is null.
              itemBuilder: (context, index) {
                final reportData = _reports?[index]
                    as Map<String, dynamic>?; // Handle potential null.
                if (reportData == null) {
                  return const SizedBox.shrink(); // Skip if the data is null.
                }

                final report = Report(
                  id: reportData['id'] as int? ??
                      0, // Provide default values if null.
                  groupID: reportData['id_group'] as int? ?? 0,
                  userID: reportData['id_user'] as int? ?? 0,
                  type: reportData['type'] as int? ?? 0,
                  amount: reportData['amount'].toDouble() ?? 0.0,
                  description:
                      reportData['description'] as String? ?? 'No description',
                  category:
                      reportData['category'] as String? ?? 'Uncategorized',
                  date: (DateTime.parse(reportData['date'])),
                );

                return ReportTileWidget(
                    report: report,
                    cloudStorageManager: widget.cloudStorageManager);
              },
            );
          }
        },
      ),
    );
  }

  Widget PlusButtonSectionBody() {
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

  Widget ThisFeatureHasNotBeenImplemented() {
    return AlertDialog(
      title: const Text('Feature Not Implemented'),
      content: const Text(
          'This feature has not been implemented yet check back in the full release of Budget365'),
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

  Future<void> _getGroups() async {
    _groups = await widget.cloudStorageManager.getGroups(widget.userLoggedIn);
    if (_groups.isNotEmpty && _selectedGroupItem == null) {
      _selectedGroupItem = _groups[0].name;
      _selectedGroupID = _groups[0].id;
    }
  }

  void _goToCalendar() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const CalendarPage()),
    // );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ThisFeatureHasNotBeenImplemented();
      },
    );
  }

  void _showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Report successfully created'),
      duration: Duration(seconds: 2),
    );

    // Display the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _goToReportBuilder() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportCreationWidget(
                cloudStorageManager: widget.cloudStorageManager,
                selectedGroup: _selectedGroupItem ?? '',
                groups: _groups,
                userID: widget.userLoggedIn,
              )),
    ).then((value) {
      if (value == 0) {
        _showSnackbar(context);
        setState(() {
          // You can update any state variables here, even if you don't actually change anything.
        });
      }
    });
  }
}
