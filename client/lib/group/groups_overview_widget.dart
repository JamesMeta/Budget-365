import 'package:flutter/material.dart';

class GroupsOverviewWidget extends StatefulWidget {
  const GroupsOverviewWidget({super.key});

  @override
  State<GroupsOverviewWidget> createState() => _GroupsOverviewWidgetState();
}

class _GroupsOverviewWidgetState extends State<GroupsOverviewWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups Overview'),
      ),
    );
  }
}
