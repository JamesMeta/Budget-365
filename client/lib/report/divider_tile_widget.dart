import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DividerTileWidget extends StatelessWidget {
  final String month;
  const DividerTileWidget({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 80, 80, 80),
        border: Border.all(color: const Color.fromARGB(255, 0, 0, 0), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                    "The Month of ${DateFormat.MMMM().format(DateTime(0, int.parse(month)))}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 0, 0, 0),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
