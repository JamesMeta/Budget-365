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
  static const _fontColor = Color.fromARGB(255, 255, 255, 255);
  static const _containerFillColor = Color.fromARGB(0, 255, 255, 255);

  late double _fontSize;
  late double _rowHeight;
  late double _iconSize;
  late double _iconWidth;
  late double _CategoryWidth;
  late double _AmountWidth;
  late double _UsersWidth;
  late double _DateWidth;

  @override
  Widget build(BuildContext context) {
    _fontSize = MediaQuery.of(context).size.width * 0.035;
    _rowHeight = MediaQuery.of(context).size.width * 0.15;
    _iconSize = MediaQuery.of(context).size.width * 0.065;
    _iconWidth = MediaQuery.of(context).size.width * 0.065;
    _CategoryWidth = MediaQuery.of(context).size.width * 0.4;
    _AmountWidth = MediaQuery.of(context).size.width * 0.4;
    _UsersWidth = MediaQuery.of(context).size.width * 0.1;
    _DateWidth = MediaQuery.of(context).size.width * 0.15;

    return SingleChildScrollView(
      child: GestureDetector(
        onTap: widget.onEdit,
        child: Container(
          width: double.infinity,
          height: _rowHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
            color: _containerFillColor,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TypeSection(),
              Column(
                mainAxisSize: MainAxisSize.min,
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
      ),
    );
  }

  Widget TypeSection() {
    return Container(
      width: _iconWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.report.type == 1 ? '📉' : '📈',
              style: TextStyle(
                fontSize: _iconSize,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }

  Widget AmountSection() {
    return Container(
      width: _AmountWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.report.amount.toString(),
            style: TextStyle(
                fontSize: _fontSize,
                fontWeight: FontWeight.bold,
                color: _fontColor),
          ),
        ],
      ),
    );
  }

  Widget CategorySection() {
    return Container(
      width: _CategoryWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text("${widget.report.category}:",
              style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                  color: _fontColor)),
        ],
      ),
    );
  }

  Widget UsersSection() {
    return Container(
      width: _UsersWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  style: TextStyle(
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
      width: _DateWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(getNameofDayofWeek(widget.report.date),
              style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.bold,
                  color: _fontColor)),
        ],
      ),
    );
  }

  Future<String> getInitials(int userID) async {
    String name = await widget.cloudStorageManager.getUsername(userID);
    List<String> words = name.split(' '); //splits the name by spaces
    String initials = '';

    for (var word in words) {
      if (word.isNotEmpty) {
        initials += word[0].toUpperCase();
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
