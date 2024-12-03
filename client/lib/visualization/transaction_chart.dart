import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:budget_365/design/app_gradient.dart';
import 'package:flutter/services.dart';

class TransactionChart extends StatefulWidget {
  final Future<List<Map<String, dynamic>>?> reportDataFuture;
  final int? selectedGroupID;

  const TransactionChart({
    Key? key,
    required this.reportDataFuture,
    required this.selectedGroupID,
  }) : super(key: key);

  @override
  _TransactionChartState createState() => _TransactionChartState();
}

class _TransactionChartState extends State<TransactionChart> {
  final Map<String, Color> _categoryColors = {};

  List<PieChartSectionData> _processDataForPieChart(
      List<Map<String, dynamic>> reportData, int? selectedGroupID) {
    final Map<String, double> spendingByCategory = {};

    for (final report in reportData) {
      if (selectedGroupID == null || report['groupID'] == selectedGroupID) {
        final category = report['category'] ?? 'Uncategorized';
        final amount = report['amount'] ?? 0.0;
        spendingByCategory[category] =
            (spendingByCategory[category] ?? 0.0) + amount;
      }
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

  List<Widget> _buildLegend(Map<String, double> spendingByCategory) {
    final List<Widget> legendItems = [];
    spendingByCategory.forEach((category, amount) {
      legendItems.add(
        Row(
          children: [
            Container(
              width: 20,
              height: 20,
              color: _categoryColors[category],
            ),
            const SizedBox(width: 10),
            Text(
              '$category: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      );
    });
    return legendItems;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: widget.reportDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No data available.'));
        }

        final reportData = snapshot.data!;
        final Map<String, double> spendingByCategory = {};
        final chartData = _processDataForPieChart(
          reportData,
          widget.selectedGroupID,
        );

        // Generate spendingByCategory for legend
        for (final report in reportData) {
          if (widget.selectedGroupID == null ||
              report['groupID'] == widget.selectedGroupID) {
            final category = report['category'] ?? 'Uncategorized';
            final amount = report['amount'] ?? 0.0;
            spendingByCategory[category] =
                (spendingByCategory[category] ?? 0.0) + amount;
          }
        }

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
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildLegend(spendingByCategory),
            ),
          ],
        );
      },
    );
  }
}
