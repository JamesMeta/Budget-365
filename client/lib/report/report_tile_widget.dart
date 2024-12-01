import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/report/report.dart';

class ReportTileWidget extends StatefulWidget {
  final Report report;
  final CloudStorageManager cloudStorageManager;
  final void Function() onEdit;

  const ReportTileWidget(
      {super.key,
      required this.report,
      required this.cloudStorageManager,
      required this.onEdit});

  @override
  State<ReportTileWidget> createState() => _ReportTileWidgetState();
}

class _ReportTileWidgetState extends State<ReportTileWidget> {
  static const _fontSize = 19.0;
  static const _fontColor = Color.fromARGB(255, 255, 255, 255);
  static const _containerFillColor = Color.fromARGB(0, 255, 255, 255);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onEdit,
      child: Container(
        padding: const EdgeInsets.fromLTRB(5, 5, 0, 5),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
          color: _containerFillColor,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TypeSection(),
            Column(
              children: [
                CategorySection(),
                AmountSection(),
              ],
            ),
            UsersSection(),
            DateSection(),
          ],
        ),
      ),
    );
  }

  Widget TypeSection() {
    return Container(
      width: 55,
      alignment: Alignment.center,
      child: Column(
        children: [
          Text(widget.report.type == 1 ? '📉' : '📈',
              style: TextStyle(
                fontSize: 45,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget AmountSection() {
    return SingleChildScrollView(
      child: Container(
        width: 105,
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
    );
  }

  Widget CategorySection() {
    return SingleChildScrollView(
      child: Container(
        width: 160,
        alignment: Alignment.center,
        child: Column(
          children: [
            Text("${widget.report.category}:",
                style: const TextStyle(
                    fontSize: _fontSize,
                    fontWeight: FontWeight.bold,
                    color: _fontColor)),
          ],
        ),
      ),
    );
  }

  Widget UsersSection() {
    return Container(
      width: 35,
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
    );
  }

  Widget DateSection() {
    return Container(
      width: 55,
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
    );
  }

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

    Duration difference = DateTime.now().difference(dateTime);
    int daysDifference = difference.inDays;

    if (daysDifference == 0) {
      return 'Today';
    } else if (daysDifference == 1) {
      return 'Yest';
    } else if (daysDifference < 7) {
      switch (dateTime.weekday) {
        case 1:
          return 'Mon';
        case 2:
          return 'Tue';
        case 3:
          return 'Wed';
        case 4:
          return 'Thu';
        case 5:
          return 'Fri';
        case 6:
          return 'Sat';
        case 7:
          return 'Sun';
      }
    } else {
      switch (dateTime.day) {
        case 1:
        case 21:
        case 31:
          dayOfWeek = '${dateTime.day}st';
          break;
        case 2:
        case 22:
          dayOfWeek = '${dateTime.day}nd';
          break;
        case 3:
        case 23:
          dayOfWeek = '${dateTime.day}rd';
          break;
        default:
          dayOfWeek = '${dateTime.day}th';
          break;
      }
    }

    return dayOfWeek;
  }
}
