import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/group/user_groups.dart';
import 'package:budget_365/group/group_creation_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/design/app_gradient.dart';

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
          padding: const EdgeInsets.all(8.0),
          child: GroupTileSection(),
        ),
        PlusButtonSectionGroup(),
      ],
    );
  }

  Widget GroupTileSection() {
    return Container(
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
        width: 70, // Set size of the container
        height: 70, // Set size of the container
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          shape: BoxShape.circle, // Circular shape Optional: add border
          border: Border.all(
            color: Colors.black, // Border color
            width: 1, // Border width
          ),
        ),
        child: IconButton(
          onPressed: _goToGroupBuilder,
          icon: const Icon(
            Icons.add, // Use a plus icon
            color: Color.fromARGB(255, 71, 162, 236), // Icon color
            size: 55, // Adjust size to fit well
          ),
          padding: EdgeInsets.zero, // Remove padding
          constraints: const BoxConstraints(), // No constraints
          splashColor:
              Colors.blue.withOpacity(0.4), // Splash color for feedback
          highlightColor:
              Colors.white.withOpacity(0.3), // Highlight color for feedback
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('Report successfully created'),
      duration: Duration(seconds: 2),
    );

    // Display the snackbar
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
    ).then((value) {
      if (value == 0) {
        _showSnackbar(context);
        setState(() {
          // You can update any state variables here, even if you don't actually change anything.
        });
      }
    });
  }

  void _goToGroupBuilderEdit(Group? group) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GroupCreationWidget(
                cloudStorageManager: widget.cloudStorageManager,
                userID: widget.userLoggedIn,
                group: group,
                edit: true,
              )),
    ).then((value) {
      if (value == 0) {
        _showSnackbar(context);
        setState(() {
          // You can update any state variables here, even if you don't actually change anything.
        });
      }
    });
  }
}
