import 'package:budget_365/visualization/transaction_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:flutter/services.dart';

class DataVisualizationWidget extends StatefulWidget {
  final CloudStorageManager
      cloudStorageManager; //requires connection to cloud manager instance for this service to get user data

  const DataVisualizationWidget({super.key, required this.cloudStorageManager});

  @override
  _DataVisualizationWidgetState createState() =>
      _DataVisualizationWidgetState();
}

class _DataVisualizationWidgetState extends State<DataVisualizationWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Activity by Category'),
        backgroundColor: const Color.fromARGB(255, 63, 158, 202),
        elevation: 4,
      ),
    );
  }
}
