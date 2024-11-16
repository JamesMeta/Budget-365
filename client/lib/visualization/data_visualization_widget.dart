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
  void initState() {
    super.initState();
    // Schedule the dialog to show after the current build phase is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ThisFeatureHasNotBeenImplemented();
        },
      );
    });
  }

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
    );
  }

  List<Widget> _widgetOptions() {
    return [LineChartScreen(), BarChartScreen(), PieChartScreen()];
  }

  Widget LineChartScreen() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 120, 10, 75),
      child: LineChart(LineChartData(
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

  List<FlSpot> _convertToSpots(List<double> data) {
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
