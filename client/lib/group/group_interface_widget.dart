import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'group.dart'; // Your Group model

class GroupInterfaceWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final int userId;

  GroupInterfaceWidget(
      {required this.cloudStorageManager, required this.userId});

  @override
  _GroupInterfaceWidgetState createState() => _GroupInterfaceWidgetState();
}

class _GroupInterfaceWidgetState extends State<GroupInterfaceWidget> {
  late Future<List<Group>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  void _loadGroups() {
    _groupsFuture = widget.cloudStorageManager.getGroups(widget.userId);
  }

  Future<void> _editGroup(Group group) async {
    final newGroupName = await _showEditDialog(group.name);
    if (newGroupName != null) {
      await widget.cloudStorageManager
          .updateGroup(group.id, group.code, newGroupName);
      setState(() => _loadGroups());
    }
  }

  Future<String?> _showEditDialog(String currentName) async {
    final TextEditingController controller =
        TextEditingController(text: currentName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Group Name'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: 'New Group Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGroup(int groupId) async {
    await widget.cloudStorageManager.deleteGroup(groupId);
    setState(() => _loadGroups());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Failed to load groups'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No groups found'));
        }

        final groups = snapshot.data!;
        return ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final group = groups[index];
            return ListTile(
              title: Text(group.name),
              subtitle: Text('Code: ${group.code}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _editGroup(group),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteGroup(group.id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
