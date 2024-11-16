import 'dart:math'; //used for current random groupid function (this is going to be replaced in the next version)

import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/group/user_groups.dart';

class GroupOverviewPage extends StatefulWidget {
  final CloudStorageManager
      cloudStorageManager; //instantiates the cloud management system
  final int userID;

  const GroupOverviewPage({
    Key? key,
    required this.cloudStorageManager,
    required this.userID,
  }) : super(key: key);

  @override
  _GroupOverviewPageState createState() => _GroupOverviewPageState();
}

class _GroupOverviewPageState extends State<GroupOverviewPage> {
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = widget.cloudStorageManager.getGroups(widget.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color.fromARGB(255, 112, 213, 243), //matching the ui standard
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildGradient(),
          FutureBuilder<List<Group>>(
            //list of user groups
            future: _groupsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No groups found.'));
              } else {
                final groups = snapshot.data!;
                return _buildGroupList(groups);
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        //button to open the popup to create a group
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: _showCreateGroupDialog,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    //app bar constructor
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: const Text(
        'User Groups',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildGradient() {
    //background gradient constructor
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
        ),
      ),
    );
  }

  Widget _buildGroupList(List<Group> groups) {
    //widget to list user groups
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              group.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            subtitle: Text(
              'Code: ${group.code}',
              style: const TextStyle(color: Colors.black54),
            ),
            trailing: const Icon(Icons.edit, color: Colors.blueAccent),
            onTap: () => _showEditGroupDialog(
                group), //when the user taps on a group, the edit popup opens for that group
          ),
        );
      },
    );
  }

  void _showCreateGroupDialog() {
    //popup to create a new group
    final TextEditingController groupCodeController = TextEditingController();
    final TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Create New Group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupCodeController,
                decoration: const InputDecoration(
                  labelText: 'Group Code',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                final groupCode = groupCodeController.text.trim();
                final groupName = groupNameController.text.trim();

                if (groupCode.isEmpty || groupName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please fill in all fields'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                  return;
                }

                final randomGroupId =
                    Random().nextInt(1000000); // Generate a random ID
                await widget.cloudStorageManager.createGroup(
                  randomGroupId,
                  groupCode,
                  groupName,
                );

                setState(() {
                  _groupsFuture =
                      widget.cloudStorageManager.getGroups(widget.userID);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Group created successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }

  void _showEditGroupDialog(Group group) {
    //popup to edit a group
    final TextEditingController groupCodeController =
        TextEditingController(text: group.code);
    final TextEditingController groupNameController =
        TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 245, 245, 245),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Edit Group',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black87,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupCodeController,
                decoration: const InputDecoration(
                  labelText: 'Group Code',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(color: Colors.blueAccent),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
              onPressed: () async {
                final newCode = groupCodeController.text;
                final newName = groupNameController.text;

                final success = await widget.cloudStorageManager.updateGroup(
                  group.id,
                  newCode,
                  newName,
                );

                if (success) {
                  setState(() {
                    _groupsFuture =
                        widget.cloudStorageManager.getGroups(widget.userID);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Group updated successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update group'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
