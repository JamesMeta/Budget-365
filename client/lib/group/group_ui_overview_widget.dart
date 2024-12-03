import 'dart:math';

import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/group/user_groups.dart';
import 'package:budget_365/group/group_creation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:budget_365/group/group_edit_widget.dart';

class GroupOverviewPage extends StatefulWidget {
  final CloudStorageManager
      cloudStorageManager; //instantiates the cloud management system
  final int userLoggedIn;

  const GroupOverviewPage({
    Key? key,
    required this.cloudStorageManager,
    required this.userLoggedIn,
  });

  @override
  _GroupOverviewPageState createState() => _GroupOverviewPageState();
}

class _GroupOverviewPageState extends State<GroupOverviewPage> {
  late List<Group>? _groups;

  static const _fontColor = Color.fromARGB(255, 255, 255, 255);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const AppGradient(),
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 110, 10, 75),
          child: Container(
            alignment: Alignment.topCenter,
            child: GroupTileSection(),
          ),
        ),
        PlusButtonSectionGroup(),
      ],
    );
  }

  Widget GroupTileSection() {
    return Container(
      alignment: Alignment.topCenter,
      child: FutureBuilder(
          future: widget.cloudStorageManager.getGroups(widget.userLoggedIn),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              _groups = snapshot.data;
              return ListView.builder(
                padding: const EdgeInsets.all(0),
                itemCount: _groups?.length ?? 0,
                itemBuilder: (context, index) {
                  final group = _groups?[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                      child: ListTile(
                        title: Text(group?.name ?? '',
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: _fontColor)),
                        subtitle: Text(group?.code ?? '',
                            style: const TextStyle(
                                fontSize: 18, color: _fontColor)),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: _fontColor),
                          onPressed: () =>
                              _goToGroupBuilderEdit(_groups?[index]),
                        ),
                        contentPadding: EdgeInsets.all(6),
                      ),
                    ),
                  );
                },
              );
            }
          }),
    );
  }

  Widget PlusButtonSectionGroup() {
    return Positioned(
        right: 20,
        bottom: 100,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.black,
              width: 1, // Border width
            ),
          ),
          child: IconButton(
            onPressed: _goToGroupBuilder,
            icon: const Icon(
              Icons.add, // Use a plus icon
              color: Color.fromARGB(255, 71, 162, 236),
              size: 55, // Adjust size to fit well
            ),
            padding: EdgeInsets.zero, // Remove padding
            constraints: const BoxConstraints(),
            splashColor: Colors.blue.withOpacity(0.4),
            highlightColor: Colors.white.withOpacity(0.3),
          ),
        ));
  }

  void _showSnackbar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _goToGroupBuilder() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupCreationWidget(
                cloudStorageManager: widget.cloudStorageManager,
                userID: widget.userLoggedIn,
              )),
    );
  }

  void _goToGroupBuilderEdit(Group? group) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupEditWidget(
                cloudStorageManager: widget.cloudStorageManager,
                group: group,
                userLoggedIn: widget.userLoggedIn,
              )),
    ).then((value) {
      if (value == 0) {
        _showSnackbar('Group edited successfully');
        setState(() {});
      } else if (value == 1) {
        _showSnackbar('Group deleted successfully');
        setState(() {});
      }
    });
  }
}
