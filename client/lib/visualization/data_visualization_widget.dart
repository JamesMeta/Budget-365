import 'package:budget_365/visualization/transaction_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:flutter/services.dart';

class DataVisualizationWidget extends StatefulWidget {
  final CloudStorageManager
      cloudStorageManager; //requires connection to cloud manager instance for this service to get user data

  const DataVisualizationWidget({Key? key, required this.cloudStorageManager})
      : super(key: key);

  @override
  _DataVisualizationWidgetState createState() =>
      _DataVisualizationWidgetState();
}

class _DataVisualizationWidgetState extends State<DataVisualizationWidget> {
  late Future<List<Map<String, dynamic>>?> _reportDataFuture;
  int? _selectedGroupID;
  Set<int> _groupIDs =
      {}; //_groupIDs will hold the unique GIDs to refine visualization

  @override
  void initState() {
    super.initState();
    _reportDataFuture = widget.cloudStorageManager
        .getReportsForGraph(); //stores the list of report data
    _loadGroupIDs();
  }

  Future<void> _loadGroupIDs() async {
    //maps the GIDs from report data, and then sets the unique GIDs
    final reportData = await _reportDataFuture;
    if (reportData != null) {
      final groupIDs = reportData
          .map((report) => report['groupID'] as int)
          .toSet(); //extracts the  unique groupIDs
      setState(() {
        _groupIDs = groupIDs;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Activity by Category'),
        backgroundColor: const Color.fromARGB(255, 63, 158, 202),
        elevation: 4,
      ),
      body: Stack(
        children: [
          const AppGradient(),
          Padding(
            padding: const EdgeInsets.all(19.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  DropdownButton<int>(
                    hint: const Text("Select Group ID"),
                    value: _selectedGroupID,
                    items: _groupIDs
                        .map((groupID) => DropdownMenuItem<int>(
                              value: groupID,
                              child: Text('Group $groupID'),
                            ))
                        .toList(),
                    onChanged: (groupID) {
                      setState(() {
                        _selectedGroupID = groupID;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 500,
                    child: TransactionChart(
                      reportDataFuture: _reportDataFuture,
                      selectedGroupID: _selectedGroupID,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
