import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:budget_365/design/app_gradient.dart';
import 'package:flutter/services.dart';

class TransactionChart extends StatefulWidget {
  final Future<List<Map<String, dynamic>>?> reportDataFuture;

  const TransactionChart({Key? key, required this.reportDataFuture})
      : super(key: key);

  @override
  _TransactionChartState createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  final Map<String, Color> _categoryColors = {}; //shared category-to-color map

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

      _categoryColors[category] ??= _getRandomColorForCategory();

      return PieChartSectionData(
        value: amount,
        color: _categoryColors[category],
        radius: 50,
      );
    }).toList();
  }

  Color _getRandomColorForCategory() {
    final random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  //legend for the piechart
  List<Widget> _buildLegend(Map<String, double> spendingByCategory) {
    final List<Widget> legendItems = [];
    spendingByCategory.forEach((category, amount) {
      legendItems.add(
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: _categoryColors[
                  category], //by accessing the colour map which is predefined, the legend and pie chart share the same RGB vals
            ),
            const SizedBox(width: 10),
            Text(category, style: const TextStyle(fontSize: 15)),
          ],
        ),
      );
    });
    return legendItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Activity by Category',
          style: TextStyle(
            color: Color.fromARGB(255, 255, 255, 255),
            fontSize: 19.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 158, 202),
        elevation: 4,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      extendBodyBehindAppBar: false,
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
                  SizedBox(
                    height: 400,
                    child: FutureBuilder<List<Map<String, dynamic>>?>(
                      future: widget.reportDataFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No data available.'));
                        }

                        final reportData = snapshot.data!;
                        final spendingByCategory = Map<String, double>();
                        for (final report in reportData) {
                          final category =
                              report['category'] ?? 'Uncategorized';
                          final amount = report['amount'] ?? 0.0;
                          spendingByCategory[category] =
                              (spendingByCategory[category] ?? 0.0) + amount;
                        }

                        final chartData = _processDataForPieChart(reportData);

                        return Column(
                          children: [
                            SizedBox(
                              height: 300,
                              child: PieChart(
                                PieChartData(
                                  sections: chartData,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Column(
                              children: _buildLegend(spendingByCategory),
                            ),
                          ],
                        );
                      },
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
