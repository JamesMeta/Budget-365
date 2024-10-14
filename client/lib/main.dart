import 'package:flutter/material.dart';

void main() {
  runApp(const Budget365());
}

class Budget365 extends StatelessWidget {
  const Budget365({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        useMaterial3: true,
      ),
      home: const Budget365Widget(title: 'Budget365'),
    );
  }
}

class Budget365Widget extends StatefulWidget {
  const Budget365Widget({super.key, required this.title});

  final String title;

  @override
  State<Budget365Widget> createState() => _Budget365WidgetState();
}

class _Budget365WidgetState extends State<Budget365Widget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }
}
