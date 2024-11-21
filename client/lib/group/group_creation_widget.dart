import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:flutter/material.dart';

class GroupCreationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final int userID;

  const GroupCreationWidget(
      {super.key, required this.cloudStorageManager, required this.userID});

  @override
  State<GroupCreationWidget> createState() => _GroupCreationWidgetState();
}

class _GroupCreationWidgetState extends State<GroupCreationWidget> {
  String _groupCode = '';
  List<String> _users = [];

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Create Group',
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Gradient(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 120.0, 8.0, 20.0),
              child: Column(
                children: [
                  TextFieldGroupName(),
                  GroupCode(),
                  AddUsersTextField(),
                  AddUserButton(),
                  UsersDataTable(),
                  CreateGroupButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget Gradient() {
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

  Widget GroupCode() {
    return Container(
      child: Column(
        children: [
          Text('Group Code',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          Container(
            child: _groupCode == ''
                ? FutureBuilder(
                    future: _getGroupCode(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text('$_groupCode',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold));
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
                : Text('$_groupCode',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget TextFieldGroupName() {
    return Container(
      child: Column(
        children: [
          Text('Group Name',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          TextField(
            controller: _groupNameController,
            decoration: InputDecoration(
              hintText: 'Enter Group Name',
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget AddUsersTextField() {
    return Container(
      child: Column(
        children: [
          Text('Add Users',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold)),
          TextField(
            controller: _userEmailController,
            decoration: InputDecoration(
              hintText: 'Enter User Email',
              hintStyle: TextStyle(color: Colors.white),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget AddUserButton() {
    return ElevatedButton(
      onPressed: _addUser,
      child: Text('Add User'),
    );
  }

  Widget UsersDataTable() {
    return DataTable(
      columns: [
        DataColumn(label: Text('User Email')),
        DataColumn(label: Text('Remove')),
      ],
      rows: _users
          .map((user) => DataRow(
                cells: [
                  DataCell(Text(user)),
                  DataCell(IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      setState(() {
                        _users.remove(user);
                      });
                    },
                  )),
                ],
              ))
          .toList(),
    );
  }

  Widget CreateGroupButton() {
    return ElevatedButton(
      onPressed: _createGroup,
      child: Text('Create Group'),
    );
  }

  Future<void> _getGroupCode() async {
    final groupCode =
        await widget.cloudStorageManager.generateUniqueGroupCode();
    setState(() {
      _groupCode = groupCode;
    });
    return;
  }

  void _addUser() {
    setState(() {
      _users.add(_userEmailController.text);
    });
  }

  void _createGroup() {
    widget.cloudStorageManager.createGroup(
        _groupCode, _groupNameController.text, _users, widget.userID);
  }
}
