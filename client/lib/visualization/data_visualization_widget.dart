import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DataVisualizationWidget extends StatefulWidget {
  const DataVisualizationWidget({super.key});

  @override
  State<DataVisualizationWidget> createState() =>
      _DataVisualizationWidgetState();
}

class _DataVisualizationWidgetState extends State<DataVisualizationWidget> {
  final List<double> data = [1000, 1200, 80, -1200, -75, -213, -12];
  int _selectedNavigationalIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Data Visualization'),
      ),
      body: Stack(
        children: [
          Gradient(),
          _widgetOptions().elementAt(_selectedNavigationalIndex),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarSection(),
    );
  }

  List<Widget> _widgetOptions(){
    return [LineChartScreen(),BarChartScreen(),PieChartScreen()];
  }

  Widget LineChartScreen(){
    return Padding(
            padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
            child: LineChart(
              LineChartData(
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
                lineBarsData: [
                  LineChartBarData(
                    spots: _convertToSpots(data),
                    isCurved: true,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(show: true),
                  )
                ],
              )
            ),
          );
  }

  Widget BarChartScreen(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
      child: BarChart(
        BarChartData(
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
        )
      ),
    );
  }

  Widget PieChartScreen(){
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
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
            icon: Icon(Icons.area_chart_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_rounded),
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
          Color.fromARGB(255, 80, 117, 240),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 80, 117, 240),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )),
    );
  }
  
  List<FlSpot> _convertToSpots(List<double> data){
    return List.generate(
      data.length,
      (index) => FlSpot(index.toDouble(), data[index]),
    );
  }

  void _onTapedNavigation(int index) {
    setState(() {
      _selectedNavigationalIndex = index;
    });
  }
  
}
