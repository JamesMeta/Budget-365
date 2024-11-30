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
  List<double> data = [];
  List<Group> _groups = [];
  List<Report> _reports = [];
  String? _selectedGroupItem;
  int? _selectedGroupID;
  int _selectedNavigationalIndex = 0;
  String? selectedGroup;
  final List<String> items = ['thing1','thing2','thing3'];
  final List<String> graphType = ['Line Graph','Bar Graph','Pie Chart'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Data Visualization',
          style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
      ),
      body: Stack(
        children: [
          const AppGradient(),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(8, 80, 8, 8),
                child: ScreenAspectRatio(),
              ),
              FutureBuilder(future: _getGroups(), 
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Stack(
                        children: [
                          CircularProgressIndicator(),
                          AppGradient(),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.connectionState == ConnectionState.done) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GroupInput(),
                          SizedBox(width: 5,),
                          GraphTypeMenu(),
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

  Widget ScreenAspectRatio(){
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
            spots: _convertToSpots(data),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
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


  List<FlSpot> _convertToSpots(List<double> data) {
    // _getReports();
    print(_groups);
    return List.generate(
      _reports.length,
      (index) => FlSpot(_reports[index].date.month.toDouble(), _reports[index].amount),
    );
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
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold),
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
        items: _groups.map<DropdownMenuItem<String>>((Group group){
          return DropdownMenuItem<String>(
            value: group.name,
            child: Text(group.name),
          );
        }).toList(),
      ),
    );
  }

  Widget GraphTypeMenu(){
    return Container(
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      width: 190,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(25.7),
      ),
      child: DropdownButton<int>(
        style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold),
        dropdownColor: Colors.blue,
        icon: Icon(Icons.arrow_drop_down, color: Colors.white),
        isExpanded: true,
        underline: Container(color: Colors.transparent),
        value: _selectedNavigationalIndex,
        hint: Text('Select Graph',
            style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold)), // Placeholder text
        onChanged: (int? value) {
          if(value != null){
            setState(() {
              _selectedNavigationalIndex = value;
            });
          }
        },
        items: List.generate(
          graphType.length, 
          (index) => DropdownMenuItem<int>(
            value: index,
            child: Text(graphType[index]),
          )),
      ),
    );
  }

  Future<void> _getGroups() async {
    _groups = await widget.cloudStorageManager.getGroups(widget.userLoggedIn);
    if (_groups.isNotEmpty && _selectedGroupItem == null) {
      _selectedGroupItem = _groups[0].name;
      _selectedGroupID = _groups[0].id;
    }
  }

  Future<void> _getReports(int groupID) async {
    _reports = await widget.cloudStorageManager.getReports(groupID);
  }

  int _dateToInt(DateTime date, String select){
    if(select == 'year'){
      return date.year;
    } else if(select == 'month'){
      return date.month;
    } else if(select == 'day'){
      return date.day;
    } else{
      return 0;
    }
  }

  void _onTapedNavigation(int index) {
    setState(() {
      _selectedNavigationalIndex = index;
    });
  }
}
