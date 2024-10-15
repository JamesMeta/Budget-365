import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          leading: Image.asset('assets/images/logo.png'),
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
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
        body: Padding(
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
              const SizedBox(height: 20),
              ListView(
                children: const [
                  ListTile(
                    title: Text('Item 1'),
                  ),
                  ListTile(
                    title: Text('Item 2'),
                  ),
                  ListTile(
                    title: Text('Item 3'),
                  ),
                  ListTile(
                    title: Text('Item 4'),
                  ),
                  ListTile(
                    title: Text('Item 5'),
                  ),
                  ListTile(
                    title: Text('Item 6'),
                  ),
                  ListTile(
                    title: Text('Item 7'),
                  ),
                  ListTile(
                    title: Text('Item 8'),
                  ),
                  ListTile(
                    title: Text('Item 9'),
                  ),
                  ListTile(
                    title: Text('Item 10'),
                  ),
                  ListTile(
                    title: Text('Item 11'),
                  ),
                  ListTile(
                    title: Text('Item 12'),
                  ),
                  ListTile(
                    title: Text('Item 13'),
                  ),
                  ListTile(
                    title: Text('Item 14'),
                  ),
                  ListTile(
                    title: Text('Item 15'),
                  ),
                  ListTile(
                    title: Text('Item 16'),
                  ),
                  ListTile(
                    title: Text('Item 17'),
                  ),
                  ListTile(
                    title: Text('Item 18'),
                  ),
                  ListTile(
                    title: Text('Item 19'),
                  ),
                  ListTile(
                    title: Text('Item 20'),
                  ),
                ],
              ),
            ],
          ),
        ),
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
