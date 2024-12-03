import 'package:budget_365/visualization/transaction_chart.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:flutter/services.dart';

class DataVisualizationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;

  const DataVisualizationWidget({Key? key, required this.cloudStorageManager})
      : super(key: key);

  @override
  _DataVisualizationWidgetState createState() =>
      _DataVisualizationWidgetState();
}

class _DataVisualizationWidgetState extends State<DataVisualizationWidget> {
  late Future<List<Map<String, dynamic>>?> _reportDataFuture;

  @override
  void initState() {
    super.initState();
    //uses the method in the active instance of the cloudstoragemanager to extract user reports
    _reportDataFuture = widget.cloudStorageManager.getReportsForGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //appbar in this case stores a title for the visualization - this can be adjusted based on the graph
        title: const Text(
          'Visualization',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 15.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 158, 202),
        elevation: 4,
        systemOverlayStyle: SystemUiOverlayStyle
            .light, //fixes issue where colours weren't updating
      ),
      extendBodyBehindAppBar: false,
      body: Stack(
        children: [
          const AppGradient(),
          Padding(
            padding: const EdgeInsets.all(19.0),
            child: SingleChildScrollView(
              //allows for vertical scrolling to avoid infinity render crashes
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 400,
                    child: TransactionChart(
                      reportDataFuture: _reportDataFuture,
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
