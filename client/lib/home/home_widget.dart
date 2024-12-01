import 'package:flutter/material.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/report/report.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/report/report_tile_widget.dart';
import 'package:budget_365/report/report_creation_widget.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:budget_365/report/divider_tile_widget.dart';
import 'package:budget_365/report/report_edit_widget.dart';

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

  double _incomeTotal = 0;
  double _expenseTotal = 0;
  double _balance = 0;

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
                    TableTotalsSection(),
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
          borderRadius: BorderRadius.circular(10),
        ),
        width: 200,
        height: 50,
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

  Widget TableTotalsSection() {
    return FutureBuilder(
        future: _getTotals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: double.infinity,
                height: 75,
                decoration: BoxDecoration(
                  color: _containerFillColor,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: const Center(child: CircularProgressIndicator()));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                width: double.infinity,
                height: 75,
                decoration: BoxDecoration(
                  color: _containerFillColor,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Income',
                            style: TextStyle(
                                fontSize: _labelFontSize,
                                color: _labelFontColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$$_incomeTotal',
                            style: TextStyle(
                                fontSize: _labelFontSize,
                                color: const Color.fromARGB(255, 7, 236, 15),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Expense',
                            style: TextStyle(
                                fontSize: _labelFontSize,
                                color: _labelFontColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$$_expenseTotal',
                            style: TextStyle(
                                fontSize: _labelFontSize,
                                color: const Color.fromARGB(255, 194, 72, 72),
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(
                                fontSize: _labelFontSize,
                                color: _labelFontColor,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$$_balance',
                            style: TextStyle(
                                fontSize: _labelFontSize,
                                color: _labelFontColor,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ));
          }
        });
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

            // Ensure reports are sorted by date in descending order
            _reports!.sort((a, b) {
              DateTime dateA = DateTime.parse(a['date']);
              DateTime dateB = DateTime.parse(b['date']);
              return dateB.compareTo(dateA); // Descending order
            });

            return ListView.builder(
              padding: EdgeInsets.all(0),
              itemCount: _reports!.length,
              itemBuilder: (context, index) {
                final reportData = _reports![index] as Map<String, dynamic>;
                final report = Report(
                  id: reportData['id'] as int? ?? 0,
                  groupID: reportData['id_group'] as int? ?? 0,
                  userID: reportData['id_user'] as int? ?? 0,
                  type: reportData['type'] as int? ?? 0,
                  amount: (reportData['amount'] as num?)?.toDouble() ?? 0.0,
                  description:
                      reportData['description'] as String? ?? 'No description',
                  category:
                      reportData['category'] as String? ?? 'Uncategorized',
                  date: DateTime.parse(reportData['date']),
                );

                // Determine if a divider is needed
                bool showDivider = false;
                if (index == 0) {
                  showDivider = false; // Show divider for the first item
                } else {
                  DateTime currentReportDate = report.date;
                  DateTime previousReportDate =
                      DateTime.parse(_reports![index - 1]['date']);
                  if (currentReportDate.month != previousReportDate.month ||
                      currentReportDate.year != previousReportDate.year) {
                    showDivider = true; // Month has changed
                  }
                }

                // Build the list of widgets to display
                List<Widget> widgets = [];
                if (showDivider) {
                  widgets.add(DividerTileWidget(
                    month: report.date.month.toString(),
                  ));
                }

                widgets.add(ReportTileWidget(
                  onEdit: () => _goToReportEditor(report),
                  report: report,
                  cloudStorageManager: widget.cloudStorageManager,
                ));

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widgets,
                );
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

  void _goToReportEditor(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ReportEditWidget(
                cloudStorageManager: widget.cloudStorageManager,
                report: report,
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

  Future<void> _getTotals() async {
    final totals =
        await widget.cloudStorageManager.getReportTotals(_selectedGroupID ?? 0);
    _incomeTotal = totals['income']!;
    _expenseTotal = totals['expense']!;
    _balance = totals['balance']!;
  }
}
