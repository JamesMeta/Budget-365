//user interface for groups
import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';

class GroupOverviewPage extends StatefulWidget {
  //instatiates the page
  final CloudStorageManager cloudStorageManager;
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
    //get the list of groups when the page is initialized
    _groupsFuture = widget.cloudStorageManager.getGroups(widget.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Groups'),
      ),
      body: FutureBuilder<List<Group>>(
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
            return ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return ListTile(
                  title: Text(group.name),
                  subtitle: Text('Code: ${group.code}'),
                  onTap: () => _showEditGroupDialog(group),
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showEditGroupDialog(Group group) {
    //shows the popup to edit the group object
    final TextEditingController groupCodeController =
        TextEditingController(text: group.code);
    final TextEditingController groupNameController =
        TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Group'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: groupCodeController,
                decoration: const InputDecoration(labelText: 'Group Code'),
              ),
              TextField(
                controller: groupNameController,
                decoration: const InputDecoration(labelText: 'Group Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
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
                    //updates the local state after a successful edit
                    _groupsFuture =
                        widget.cloudStorageManager.getGroups(widget.userID);
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Group updated successfully')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update group')),
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
