import 'package:flutter/material.dart';

class AppGradient extends StatelessWidget {
  const AppGradient({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
        colors: [
          Color.fromARGB(255, 80, 117, 240),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 80, 117, 240),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      )),
    );
  }
}
