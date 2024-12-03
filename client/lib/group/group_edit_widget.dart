// ignore_for_file: prefer_final_fields, sized_box_for_whitespace, non_constant_identifier_names

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/design/app_gradient.dart';

class GroupEditWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final Group? group;
  final int userLoggedIn;

  const GroupEditWidget({
    super.key,
    required this.cloudStorageManager,
    required this.group,
    required this.userLoggedIn,
  });

  @override
  State<GroupEditWidget> createState() => _GroupEditWidgetState();
}

class _GroupEditWidgetState extends State<GroupEditWidget> {
  String _groupCode = '';
  List<String> _users = [];
  List<String> _categoryExpense = [];
  List<String> _categoryIncome = [];

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _groupCodeController = TextEditingController();

  Color _textFieldFontColor = const Color.fromARGB(255, 255, 255, 255);
  Color _textFieldBorderColor = const Color.fromARGB(143, 0, 0, 0);

  double fontSizeInputs = 17;
  double fontSizeButtons = 25;

  @override
  void initState() {
    super.initState();
    _groupCodeController.text = widget.group!.code;
    _groupNameController.text = widget.group!.name;
    _groupCode = widget.group!.code;
    _getUsers();
    _getIncomeCategories();
    _getExpenseCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          AppGradient(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LogoSection(),
                  SizedBox(height: 10),
                  Title(),
                  SizedBox(height: 30),
                  GroupCode(),
                  SizedBox(height: 20),
                  TextFieldGroupName(),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: AddUserButton()),
                      SizedBox(width: 10),
                      Expanded(child: AddCategoryButton()),
                    ],
                  ),
                  SizedBox(height: 5),
                  CreateGroupButton(),
                  SizedBox(height: 40),
                  RemoveSelfFromGroupElevatedButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget LogoSection() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.65,
      height: MediaQuery.of(context).size.height * 0.3,
      child: Image.asset(
        'assets/images/logo1.png',
        fit: BoxFit.contain,
      ),
    );
  }

  Widget Title() {
    return Text(
      'Edit Report Group',
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget GroupCode() {
    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(60, 0, 0, 0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2)),
      child: Column(
        children: [
          Container(
            height: 55,
            alignment: Alignment.center,
            child: Text('Group Code: $_groupCode',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget TitleOfTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      child: Text(
        "Group Name:",
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: fontSizeButtons,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget TextFieldGroupName() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _groupNameController,
        keyboardType: TextInputType.text,
        maxLength: 25,
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: "Enter Group Name",
          labelStyle: TextStyle(
              color: _textFieldFontColor,
              fontSize: fontSizeInputs,
              fontWeight: FontWeight.bold),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _textFieldBorderColor, width: 2),
            borderRadius: BorderRadius.circular(25.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _textFieldBorderColor, width: 2),
            borderRadius: BorderRadius.circular(25.7),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: _textFieldFontColor, width: 2),
            borderRadius: BorderRadius.circular(25.7),
          ),
          fillColor: Colors.transparent,
          filled: true,
        ),
      ),
    );
  }

  Widget AddUserButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: _addUser,
        child: Text(
          'Add User',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget AddCategoryButton() {
    return Container(
      height: 60,
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        onPressed: _addCategory,
        child: Text(
          'Add Category',
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget UsersDataTable() {
    return Container(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 10,
          columns: [
            DataColumn(label: Text('User Email')),
            DataColumn(label: Text('Remove')),
          ],
          rows: _users
              .map((user) => DataRow(
                    cells: [
                      DataCell(Text(user)),
                      DataCell(IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            _users.remove(user);
                          });
                        },
                      )),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget CategoryDataTable() {
    return Container(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          columnSpacing: 20,
          columns: [
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Type')),
            DataColumn(label: Text('Remove')),
          ],
          rows: _categoryExpense
                  .map((category) => DataRow(
                        cells: [
                          DataCell(Text(category)),
                          DataCell(Text('Expense')),
                          DataCell(IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _categoryExpense.remove(category);
                              });
                            },
                          )),
                        ],
                      ))
                  .toList() +
              _categoryIncome
                  .map((category) => DataRow(
                        cells: [
                          DataCell(Text(category)),
                          DataCell(Text('Income')),
                          DataCell(IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _categoryIncome.remove(category);
                              });
                            },
                          )),
                        ],
                      ))
                  .toList(),
        ),
      ),
    );
  }

  Widget CreateGroupButton() {
    return Container(
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () async {
          int response = await _editGroup();
          if (response == 0) {
            Navigator.pop(context, response);
          } else {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Please fill out all fields"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("OK"),
                      ),
                    ],
                  );
                });
          }
        },
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        child: Text(
          "Submit Changes",
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeButtons,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget RemoveSelfFromGroupElevatedButton() {
    return Container(
      width: double.infinity,
      height: 80,
      margin: EdgeInsets.only(top: 20),
      child: ElevatedButton(
        onPressed: () async {
          await _confirmLeaveGroup();
        },
        style: ButtonStyle(
          backgroundColor: WidgetStatePropertyAll(Colors.transparent),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        child: Text(
          "Leave Group",
          style: TextStyle(
            color: const Color.fromARGB(255, 148, 18, 18),
            fontSize: fontSizeButtons,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: Duration(seconds: 2),
    );

    // Display the snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _addUser() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> dialogUsers = List.from(_users);
        TextEditingController dialogUserEmailController =
            TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Add User"),
              content: Container(
                height: 200,
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 10,
                          columns: [
                            DataColumn(label: Text('User Email')),
                            DataColumn(label: Text('')),
                          ],
                          rows: dialogUsers
                              .map((user) => DataRow(
                                    cells: [
                                      DataCell(Text(user)),
                                      DataCell(IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          setState(() {
                                            dialogUsers.remove(user);
                                          });
                                          _showSnackbar(
                                              context, "User Removed");
                                        },
                                      )),
                                    ],
                                  ))
                              .toList(),
                        ),
                      ),
                    ),
                    TextField(
                      controller: dialogUserEmailController,
                      decoration: InputDecoration(hintText: "Enter User Email"),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (dialogUserEmailController.text == '') {
                      return;
                    }
                    setState(() {
                      dialogUsers.add(dialogUserEmailController.text);
                      dialogUserEmailController.clear();
                    });
                    _showSnackbar(context, "User Added");
                  },
                  child: Text("Add"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _users = List.from(dialogUsers);
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addCategory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<String> dialogCategoryExpense = List.from(_categoryExpense);
        List<String> dialogCategoryIncome = List.from(_categoryIncome);
        TextEditingController dialogCategoryController =
            TextEditingController();

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              scrollable: true,
              title: Text("Add Category"),
              content: Container(
                height: 300,
                child: Column(
                  children: [
                    Container(
                      height: 200,
                      child: SingleChildScrollView(
                        child: DataTable(
                          columnSpacing: 20,
                          columns: [
                            DataColumn(label: Text('Category')),
                            DataColumn(label: Text('Type')),
                            DataColumn(label: Text('')),
                          ],
                          rows: dialogCategoryExpense
                                  .map((category) => DataRow(
                                        cells: [
                                          DataCell(Text(category)),
                                          DataCell(Text('Expense')),
                                          DataCell(IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                dialogCategoryExpense
                                                    .remove(category);
                                              });
                                            },
                                          )),
                                        ],
                                      ))
                                  .toList() +
                              dialogCategoryIncome
                                  .map((category) => DataRow(
                                        cells: [
                                          DataCell(Text(category)),
                                          DataCell(Text('Income')),
                                          DataCell(IconButton(
                                            icon: Icon(Icons.delete),
                                            onPressed: () {
                                              setState(() {
                                                dialogCategoryIncome
                                                    .remove(category);
                                              });
                                            },
                                          )),
                                        ],
                                      ))
                                  .toList(),
                        ),
                      ),
                    ),
                    TextField(
                      controller: dialogCategoryController,
                      decoration: InputDecoration(hintText: "Enter Category"),
                      maxLength: 15,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (dialogCategoryController.text == '') {
                      return;
                    }
                    setState(() {
                      dialogCategoryExpense.add(dialogCategoryController.text);
                      dialogCategoryController.clear();
                    });
                  },
                  child: Text("Add Expense"),
                ),
                TextButton(
                  onPressed: () {
                    if (dialogCategoryController.text == '') {
                      return;
                    }
                    setState(() {
                      dialogCategoryIncome.add(dialogCategoryController.text);
                      dialogCategoryController.clear();
                    });
                  },
                  child: Text("Add Income"),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _categoryExpense = List.from(dialogCategoryExpense);
                      _categoryIncome = List.from(dialogCategoryIncome);
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Done"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _getUsers() async {
    _users = await widget.cloudStorageManager.getGroupUsers(widget.group!.id);
  }

  Future<void> _getIncomeCategories() async {
    _categoryIncome = await widget.cloudStorageManager
        .getGroupIncomeCategories(widget.group!.id);
  }

  Future<void> _getExpenseCategories() async {
    _categoryExpense = await widget.cloudStorageManager
        .getGroupExpenseCategories(widget.group!.id);
  }

  Future<void> _leaveGroup() async {
    await widget.cloudStorageManager
        .leaveGroup(widget.group!.id, widget.userLoggedIn);
  }

  Future<void> _confirmLeaveGroup() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Leave Group"),
          content: Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await _leaveGroup();
                Navigator.pop(context);
                Navigator.pop(context, 1);
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<int> _editGroup() async {
    if (_groupNameController.text == '') {
      return -1;
    }

    if (_users.isEmpty) {
      return -1;
    }

    if (_categoryExpense.isEmpty && _categoryIncome.isEmpty) {
      return -1;
    }

    _showSnackbar(context, "loading...");

    await widget.cloudStorageManager.UpdateExistingGroup(
      widget.group!.id,
      _groupCodeController.text,
      _groupNameController.text,
      _users,
      _categoryIncome,
      _categoryExpense,
    );

    return 0;
  }
}
