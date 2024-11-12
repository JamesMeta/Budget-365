import 'package:flutter/material.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';

class GroupCreationScreen extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;

  GroupCreationScreen({required this.cloudStorageManager});

  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _groupCodeController = TextEditingController();
  final TextEditingController _groupNameController = TextEditingController();

  Future<void> _createGroup() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Replace `1` with the actual user ID if needed
        await widget.cloudStorageManager.createGroup(
          1, // Replace with the actual user ID
          _groupCodeController.text.trim(),
          _groupNameController.text.trim(),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Group created successfully!')),
        );

        Navigator.pop(context); // Go back to previous screen
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create group: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _groupCodeController,
                decoration: InputDecoration(labelText: 'Group Code'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group code';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _groupNameController,
                decoration: InputDecoration(labelText: 'Group Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createGroup,
                child: Text('Create Group'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
