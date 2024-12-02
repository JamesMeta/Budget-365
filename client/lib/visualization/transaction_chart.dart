import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:budget_365/design/app_gradient.dart';

class TransactionChart extends StatefulWidget {
  final Future<List<Map<String, dynamic>>?> reportDataFuture;

  const TransactionChart({Key? key, required this.reportDataFuture})
      : super(key: key);

  @override
  _TransactionChartState createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  List<PieChartSectionData> _processDataForPieChart(
      List<Map<String, dynamic>> reportData) {
    final Map<String, double> spendingByCategory = {};

    for (final report in reportData) {
      final category = report['category'] ?? 'Uncategorized';
      final amount = report['amount'] ?? 0.0;
      spendingByCategory[category] =
          (spendingByCategory[category] ?? 0.0) + amount;
    }

    return spendingByCategory.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value.abs();

      return PieChartSectionData(
        value: amount,
        title: category,
        color: _getRandomColorForCategory(),
        radius: 50,
        titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
      );
    }).toList();
  }

  Color _getRandomColorForCategory() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const AppGradient(),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey, width: 1.5),
                  ),
                  child: FutureBuilder<List<Map<String, dynamic>>?>(
                    future: widget.reportDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(
                            child:
                                Text('Error fetching data: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('No data available.'));
                      }

                      final reportData = snapshot.data!;
                      final chartData = _processDataForPieChart(reportData);

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: PieChart(
                          PieChartData(
                            sections: chartData,
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            borderData: FlBorderData(show: false),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
