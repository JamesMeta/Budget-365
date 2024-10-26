import 'package:flutter/material.dart';

class DividerTileWidget extends StatelessWidget {
  final String week;
  const DividerTileWidget({super.key, required this.week});

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Container(
      padding: EdgeInsets.only(left: 10),
      child: Text(
        "Week of $week",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
        ),
      ),
    ));
  }
}
