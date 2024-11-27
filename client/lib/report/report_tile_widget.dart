import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/report/report.dart';

class ReportTileWidget extends StatefulWidget {
  final Report report;
  final CloudStorageManager cloudStorageManager;

  const ReportTileWidget(
      {super.key, required this.report, required this.cloudStorageManager});

  @override
  State<ReportTileWidget> createState() => _ReportTileWidgetState();
}

class _ReportTileWidgetState extends State<ReportTileWidget> {
  static const _fontSize = 17.5;
  static const _fontColor = Color.fromARGB(255, 255, 255, 255);
  static const _containerFillColor = Color.fromARGB(0, 255, 255, 255);

  Future<String> getInitials(int userID) async {
    String name = await widget.cloudStorageManager.getUsername(userID);
    List<String> words = name.split(' '); // Split the name by spaces
    String initials = '';

    for (var word in words) {
      if (word.isNotEmpty) {
        initials +=
            word[0].toUpperCase(); // Take the first letter and capitalize it
        if (initials.length == 2) {
          break;
        }
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
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: _containerFillColor,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 55,
            alignment: Alignment.center,
            child: Column(
              children: [
                FutureBuilder<String>(
                  future: getInitials(widget.report.userID),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error');
                    } else {
                      return Text(
                        snapshot.data ?? '',
                        style: const TextStyle(
                            fontSize: _fontSize,
                            fontWeight: FontWeight.bold,
                            color: _fontColor),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          Container(
            width: 55,
            alignment: Alignment.center,
            child: Column(children: [
              Text(widget.report.type == 1 ? '📉' : '📈',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
            ]),
          ),
          SingleChildScrollView(
            child: Container(
              width: 70,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    widget.report.amount.toString(),
                    style: const TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.bold,
                        color: _fontColor),
                  ),
                ],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              width: 105,
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(widget.report.category,
                      style: const TextStyle(
                          fontSize: _fontSize,
                          fontWeight: FontWeight.bold,
                          color: _fontColor)),
                ],
              ),
            ),
          ),
          Container(
            width: 50,
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(getNameofDayofWeek(widget.report.date),
                    style: const TextStyle(
                        fontSize: _fontSize,
                        fontWeight: FontWeight.bold,
                        color: _fontColor)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
