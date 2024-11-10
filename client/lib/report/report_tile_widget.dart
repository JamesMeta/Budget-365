import 'package:flutter/material.dart';
import 'package:budget_365/report/report.dart';

class ReportTileWidget extends StatefulWidget {
  final Report report;

  const ReportTileWidget({super.key, required this.report});

  @override
  State<ReportTileWidget> createState() => _ReportTileWidgetState();
}

class _ReportTileWidgetState extends State<ReportTileWidget> {
  String getInitials(String name) {
    List<String> words = name.split(' '); // Split the name by spaces
    String initials = '';

    for (var word in words) {
      if (word.isNotEmpty) {
        initials +=
            word[0].toUpperCase(); // Take the first letter and capitalize it
      }
    }

    return initials;
  }

  String getNameofDayofWeek(DateTime date) {
    DateTime dateTime = date;
    String dayOfWeek = '';

    switch (dateTime.weekday) {
      case 1:
        dayOfWeek = 'Mon';
        break;
      case 2:
        dayOfWeek = 'Tue';
        break;
      case 3:
        dayOfWeek = 'Wed';
        break;
      case 4:
        dayOfWeek = 'Thu';
        break;
      case 5:
        dayOfWeek = 'Fri';
        break;
      case 6:
        dayOfWeek = 'Sat';
        break;
      case 7:
        dayOfWeek = 'Sun';
        break;
    }

    return dayOfWeek;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  getInitials(widget.report.username),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(children: [
              Text(widget.report.type == 1 ? '📉' : '📈',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  )),
            ]),
          ),
          Container(
            width: 75,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  widget.report.amount.toString(),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
          ),
          Container(
            width: 120,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(widget.report.category,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: 35,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(getNameofDayofWeek(widget.report.date),
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
