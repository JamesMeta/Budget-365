import 'package:flutter/material.dart';
import 'package:budget_365/report/report_tile_widget.dart';
import 'package:budget_365/report/report.dart';

void main() {
  runApp(const Budget365());
}

class Budget365 extends StatelessWidget {
  const Budget365({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const Budget365Widget(title: 'Budget365'),
    );
  }
}

class Budget365Widget extends StatefulWidget {
  const Budget365Widget({super.key, required this.title});

  final String title;

  @override
  State<Budget365Widget> createState() => _Budget365WidgetState();
}

class _Budget365WidgetState extends State<Budget365Widget> {
  List<Report> _reports = <Report>[
    Report(
      type: 0,
      reportCode: 'ABCD',
      amount: '2',
      description: 'Monthly salary',
      category: 'Salary',
      user: 'Johnathan Hanley',
      date: '2023-02-15',
    ),
    Report(
      type: 1,
      reportCode: 'EFGH',
      amount: '20',
      description: 'Groceries',
      category: 'Food',
      user: 'John Doe',
      date: '2023-02-18',
    ),
    Report(
      type: 0,
      reportCode: 'IJKL',
      amount: '500',
      description: '',
      category: 'Bonus',
      user: 'John Doe',
      date: '2023-03-01',
    ),
    Report(
      type: 1,
      reportCode: 'MNOP',
      amount: '15000',
      description: 'Dinner at restaurant',
      category: 'Food',
      user: 'John Doe',
      date: '2023-03-05',
    ),
    Report(
      type: 1,
      reportCode: 'QRST',
      amount: '300000',
      description: 'Utilities bill',
      category: 'Bills',
      user: 'John Doe',
      date: '2023-03-10',
    ),
    Report(
      type: 0,
      reportCode: 'UVWX',
      amount: '1000000',
      description: 'Freelance project',
      category: 'Freelance',
      user: 'John Doe',
      date: '2023-04-01',
    ),
    Report(
      type: 1,
      reportCode: 'YZ12',
      amount: '75',
      description: '',
      category: 'Entertainment',
      user: 'John Doe',
      date: '2023-04-15',
    ),
    Report(
      type: 0,
      reportCode: '3456',
      amount: '1200',
      description: '',
      category: 'Salary',
      user: 'John Doe',
      date: '2023-05-01',
    ),
    Report(
      type: 1,
      reportCode: '7890',
      amount: '450',
      description: 'Shopping',
      category: 'Clothing',
      user: 'John Doe',
      date: '2023-05-10',
    ),
    Report(
      type: 0,
      reportCode: 'ASDF',
      amount: '800',
      description: 'Side hustle',
      category: 'Freelance',
      user: 'John Doe',
      date: '2023-06-01',
    ),
    Report(
      type: 1,
      reportCode: 'QWER',
      amount: '120',
      description: 'Internet bill',
      category: 'Bills',
      user: 'John Doe',
      date: '2023-06-15',
    ),
    Report(
      type: 1,
      reportCode: 'ZXCV',
      amount: '55',
      description: '',
      category: 'Transportation',
      user: 'John Doe',
      date: '2023-06-20',
    ),
    Report(
      type: 0,
      reportCode: 'POIU',
      amount: '3000',
      description: 'Freelance web development',
      category: 'Freelance',
      user: 'John Doe',
      date: '2023-07-01',
    ),
    Report(
      type: 1,
      reportCode: 'LKJH',
      amount: '200',
      description: 'Vacation expenses',
      category: 'Travel',
      user: 'John Doe',
      date: '2023-07-05',
    ),
    Report(
      type: 0,
      reportCode: 'MNBV',
      amount: '3500',
      description: '',
      category: 'Salary',
      user: 'John Doe',
      date: '2023-07-15',
    ),
    Report(
      type: 1,
      reportCode: 'TYUI',
      amount: '175',
      description: 'Gym membership',
      category: 'Health',
      user: 'John Doe',
      date: '2023-07-20',
    ),
    Report(
      type: 0,
      reportCode: 'GHJK',
      amount: '4000',
      description: 'Consulting work',
      category: 'Consulting',
      user: 'John Doe',
      date: '2023-08-01',
    ),
    Report(
      type: 1,
      reportCode: 'BNML',
      amount: '250',
      description: 'Car maintenance',
      category: 'Transportation',
      user: 'John Doe',
      date: '2023-08-10',
    ),
    Report(
      type: 0,
      reportCode: 'VCXZ',
      amount: '5000',
      description: '',
      category: 'Salary',
      user: 'John Doe',
      date: '2023-09-01',
    ),
    Report(
      type: 1,
      reportCode: 'WERT',
      amount: '60',
      description: 'Movies and snacks',
      category: 'Entertainment',
      user: 'John Doe',
      date: '2023-09-05',
    ),
  ];

  void _goToSettings() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const SettingsPage()),
    // );
  }

  void _goToCalendar() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const CalendarPage()),
    // );
  }

  void _goToReportBuilder() {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => const ReportBuilderPage()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          backgroundColor: Colors.blue,
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
        ),
        body: Stack(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const DropdownMenuGroup(),
                    IconButton(
                        onPressed: _goToCalendar,
                        icon: const Icon(Icons.calendar_month,
                            color: Colors.white, size: 30)),
                  ],
                ),
                const SizedBox(height: 5),
                Container(
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
                ),
                Expanded(
                  child: Container(
                    child: ListView.builder(
                      itemCount: _reports.length,
                      itemBuilder: (BuildContext context, int index) {
                        return ReportTileWidget(report: _reports[index]);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 20,
            child: Container(
              width: 60, // Set size of the container
              height: 60, // Set size of the container
              decoration: BoxDecoration(
                color: Colors.white, // Background color
                shape: BoxShape.circle, // Circular shape Optional: add border
                border: Border.all(
                  color: Colors.black, // Border color
                  width: 2, // Border width
                ),
              ),
              child: IconButton(
                onPressed: () {
                  // Your action here
                  print('Button pressed!'); // Debugging output
                },
                icon: const Icon(
                  Icons.add, // Use a plus icon
                  color: Colors.blue, // Icon color
                  size: 55, // Adjust size to fit well
                ),
                padding: EdgeInsets.zero, // Remove padding
                constraints: const BoxConstraints(), // No constraints
                splashColor:
                    Colors.blue.withOpacity(0.4), // Splash color for feedback
                highlightColor: Colors.blue
                    .withOpacity(0.3), // Highlight color for feedback
              ),
            ),
          )
        ]),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 43, 118, 179),
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          iconSize: 40,
          items: const [
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
        ));
  }
}

class DropdownMenuGroup extends StatefulWidget {
  const DropdownMenuGroup({super.key});

  @override
  State<DropdownMenuGroup> createState() => _DropdownMenuGroupState();
}

class _DropdownMenuGroupState extends State<DropdownMenuGroup> {
  String? _selectedItem = 'Group1';

  List<String> _items = <String>['Group1', 'Group2', 'Group3'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.white),
          dropdownColor: Colors.blue,
          menuWidth: 200,
          isExpanded: true,
          value: _selectedItem,
          onChanged: (String? value) {
            setState(() {
              _selectedItem = value;
            });
          },
          items: _items.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
