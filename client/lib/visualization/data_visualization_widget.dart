import 'dart:ffi';

import 'package:budget_365/report/report.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';

class DataVisualizationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final int userLoggedIn;
  DataVisualizationWidget({
    required this.cloudStorageManager,
    required this.userLoggedIn,
  });

  @override
  State<DataVisualizationWidget> createState() =>
      _DataVisualizationWidgetState();
}

class _DataVisualizationWidgetState extends State<DataVisualizationWidget> {
  List<FlSpot> data = [];
  List<Group> _groups = [];
  List<Report> _reports = [];
  List<Map<String, dynamic>> _points = [];
  String? _selectedGroupItem;
  int? _selectedGroupID;
  int _selectedNavigationalIndex = 0;
  String? selectedGroup;
  final List<String> items = ['thing1', 'thing2', 'thing3'];
  final List<String> graphType = ['Line Graph', 'Bar Graph', 'Pie Chart'];

  Map<String, double> dataTotals = {};
  final List<int> _dateRangeNumerical = [1, 7, 30, 365, 2147483647];
  int _selectedDateRangeIndex = 3;

  @override
  void initState(){
    super.initState();
    _getReportDots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Padding(
                padding: EdgeInsets.fromLTRB(0, 25, 0, 8),
                child: GraphTypeNavigation()
              ),
      ),
      body: Stack(
        children: [
          const AppGradient(),
          Column(
            children: [
              Padding(
                      padding: EdgeInsets.fromLTRB(8, 140, 8, 8),
                      child: ScreenAspectRatio(),
                    ),
              FutureBuilder(
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
                    } else if (snapshot.connectionState ==
                        ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GroupInput(),
                          SizedBox(
                            width: 5,
                          ),
                        ],
                      );
                    }
                    return SizedBox();
                  }),
            ],
          )
        ],
      ),
    );
  }

  List<Widget> _widgetOptions() {
    return [LineChartScreen(), BarChartScreen(), PieChartScreen()];
  }

  Widget ScreenAspectRatio() {
    return AspectRatio(
      aspectRatio: 0.8,
      child: _widgetOptions().elementAt(_selectedNavigationalIndex),
    );
  }

  Widget LineChartScreen() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 60, 10, 20),
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: data,
            isCurved: true,
            barWidth: 4,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true),
          )
        ],
      )),
    );
  }

  Widget BarChartScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
      child: BarChart(BarChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
        ),
        borderData: FlBorderData(show: true),
      )),
    );
  }

  Widget PieChartScreen() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black,
          width: 2,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(10, 60, 10, 20),
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              borderSide: BorderSide(
                color: Colors.black,
                width: 2),
              radius: 185,
              value: dataTotals['income'],
              color: const Color.fromARGB(255, 18, 233, 25),
              title: 'Income',
              titleStyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              borderSide: BorderSide(
                color: Colors.black,
                width: 2,
              ),
              radius: 150,
              value: dataTotals['expenses'],
              titlePositionPercentageOffset: 0.7,
              color: Colors.red,
              title: 'Expenses',
              titleStyle: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold),
            )
          ],
          sectionsSpace: 2,
          centerSpaceRadius: 0,
        )
      ),
    );
  }

  Widget ThisFeatureHasNotBeenImplemented() {
    return AlertDialog(
      title: const Text('Feature Not Fully Implemented'),
      content: const Text(
          'This feature has not been fully implemented yet so this is a simple demo of what will be here'),
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

  List<FlSpot> _convertToSpots(List<Map<String, dynamic>> data) {
    return data.asMap().entries.map((report) {
      final date = report.value['date'] as DateTime;
      final amount = (report.value['amount'] as num).toDouble();

      final xVal = date.difference(data.first['date']).inDays.toDouble();

      return FlSpot(xVal, amount);
    }).toList();
  }

  Widget GroupInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      width: 190,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(25.7),
      ),
      child: DropdownButton<String>(
        style: TextStyle(
            color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
        dropdownColor: Colors.blue,
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        underline: Container(color: Colors.transparent),
        value: _selectedGroupItem,
        hint: Text('Select Group',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)), // Placeholder text
        onChanged: (String? value) {
          final newGroupID = _groups
              .firstWhere((group) => group.name == value)
              .id; // Get the ID of the selected group
          setState(() {
            _selectedGroupItem = value;
            _selectedGroupID = newGroupID;
          });
        },
        items: _groups.map<DropdownMenuItem<String>>((Group group) {
          return DropdownMenuItem<String>(
            value: group.name,
            child: Text(group.name),
          );
        }).toList(),
      ),
    );
  }

  Widget GraphTypeNavigation(){
    return NavigationBar(
        onDestinationSelected: (int index){
          setState(() {
            _selectedNavigationalIndex = index;
          });
        },
        selectedIndex: _selectedNavigationalIndex,
        indicatorColor: Colors.transparent,
        indicatorShape: BeveledRectangleBorder(
          borderRadius: BorderRadius.zero
        ),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.area_chart,
              color: Colors.white,
              size: 50,),
            label: '',
            tooltip: 'Line Chart',
            selectedIcon: Icon(
              Icons.area_chart,
              color: Colors.grey,
              size: 50,
            ),),
          NavigationDestination(
            icon: Icon(
              Icons.bar_chart,
              color: Colors.white,
              size: 50,),
            label: '',
            tooltip: 'Bar Chart',
            selectedIcon: Icon(
              Icons.bar_chart,
              color: Colors.grey,
              size: 50,
            ),),
          NavigationDestination(
            icon: Icon(
              Icons.pie_chart,
              color: Colors.white,
              size: 50,),
            label: '',
            tooltip: 'Pie Chart',
            selectedIcon: Icon(
              Icons.pie_chart,
              color: Colors.grey,
              size: 50,
            ),)
        ],
        backgroundColor: Colors.transparent,
      );
  }

  List<Map<String, dynamic>> _positiveNegative(List<Map<String, dynamic>> data) {
    return data.map((entry) {
      final isIncome = entry['type'] == 0;
      return {
        'date': entry['date'],
        'amount': isIncome ? entry['amount'] : -entry['amount'],
      };
    }).toList();
  }

  Map<String, double> _incomeExpense(List<Map<String, dynamic>> data){
    double totalIncome = 0.0;
    double totalExpenses = 0.0;

    for(var entry in data) {
      if (entry['amount'] >= 0) {
        totalIncome += entry['amount'];
      } else {
        totalExpenses += entry['amount'].abs();
      }
    }

    return {
      'income' : totalIncome,
      'expenses': totalExpenses,
    };
  }

  Future<void> _getGroups() async {
    _groups = await widget.cloudStorageManager.getGroups(widget.userLoggedIn);
    if (_groups.isNotEmpty && _selectedGroupItem == null) {
      _selectedGroupItem = _groups[0].name;
      _selectedGroupID = _groups[0].id;
    }
  }

  Future<void> _getReports() async {
    _reports = await widget.cloudStorageManager.getReports(widget.userLoggedIn);
  }

  Future<void> _getReportDots() async {
    try {
      _points = await widget.cloudStorageManager.getReportDots(1); //hard Coded, change.
      setState(() {
        data = _convertToSpots(_positiveNegative(_points));
        dataTotals = _incomeExpense(_positiveNegative(_points));
      });
    } catch(e) {
      print('Error fetching data: $e');
    }
  }
}
