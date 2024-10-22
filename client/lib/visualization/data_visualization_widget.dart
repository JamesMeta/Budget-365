import 'package:flutter/material.dart';

class DataVisualizationWidget extends StatefulWidget {
  const DataVisualizationWidget({super.key});

  @override
  State<DataVisualizationWidget> createState() =>
      _DataVisualizationWidgetState();
}

class _DataVisualizationWidgetState extends State<DataVisualizationWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Visualization'),
      ),
    );
  }
}
