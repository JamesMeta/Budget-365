import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:flutter/material.dart';
import 'package:budget_365/design/app_gradient.dart';

class GroupCreationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final int userID;
  final bool edit;
  final Group? group;

  const GroupCreationWidget(
      {super.key,
      required this.cloudStorageManager,
      required this.userID,
      this.edit = false,
      this.group = null});

  @override
  State<GroupCreationWidget> createState() => _GroupCreationWidgetState();
}

class _GroupCreationWidgetState extends State<GroupCreationWidget> {
  String _groupCode = '';
  List<String> _users = [];
  List<String> _categoryExpense = [
    '🛒Groceries',
    '🪟Rent',
    '💡Utilities',
    '🏥Health',
    '📺Entertainment',
    '🚌Transportation',
    '*️⃣Miscellaneous'
  ];
  List<String> _categoryIncome = [
    '💵Salary',
    '🏦Investments',
    '🎁Gifts',
    '*️⃣Miscellaneous'
  ];

  TextEditingController _groupNameController = TextEditingController();
  TextEditingController _userEmailController = TextEditingController();
  TextEditingController _categoryController = TextEditingController();

  Color _textFieldFontColor = const Color.fromARGB(255, 255, 255, 255);
  Color _textFieldBorderColor = const Color.fromARGB(143, 0, 0, 0);

  double fontSizeInputs = 17;
  double fontSizeButtons = 25;

  @override
  void initState() {
    super.initState();
    if (widget.edit) {
      _groupNameController.text = widget.group?.name;
      //_users = widget.group?.users;
      //_categoryExpense = widget.group?.categoriesExpense;
      //_categoryIncome = widget.group?.categoriesIncome;
    }
    getUserEmail();
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
              padding: const EdgeInsets.fromLTRB(16.0, 80.0, 16.0, 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  LogoSection(),
                  SizedBox(height: 10),
                  Title(),
                  SizedBox(height: 30),
                  GroupCode(),
                  SizedBox(height: 140),
                  TextFieldGroupName(),
                  Row(
                    children: [
                      Expanded(child: AddUserButton()),
                      SizedBox(width: 10),
                      Expanded(child: AddCategoryButton()),
                    ],
                  ),
                  CreateGroupButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget LogoSection() {
    return Image.asset(
      'assets/images/logo1.png',
      scale: 2,
    );
  }

  Widget Title() {
    return Text(
      'Create Report Group',
      style: TextStyle(
        color: Colors.white,
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget GroupCode() {
    if (widget.edit) {
      _groupCode = widget.group?.code;
    }

    return Container(
      decoration: BoxDecoration(
          color: const Color.fromARGB(94, 0, 0, 0),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 2)),
      child: Column(
        children: [
          Container(
            height: 55,
            alignment: Alignment.center,
            child: _groupCode == ''
                ? FutureBuilder(
                    future: _getGroupCode(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Text('Group Code: $_groupCode',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold));
                      } else {
                        return CircularProgressIndicator();
                      }
                    })
                : Text('Group Code: $_groupCode',
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
        "Enter Group Name",
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
        keyboardType: TextInputType.number,
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
          // Set border for different states
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: _textFieldBorderColor,
                width: 2), // Border color when enabled
            borderRadius: BorderRadius.circular(25.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: _textFieldBorderColor,
                width: 2), // Border color when focused
            borderRadius: BorderRadius.circular(25.7),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: _textFieldFontColor,
                width: 2), // Border color in general
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
          int response = await _createGroup();
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
          "Submit",
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

  Future<void> _getGroupCode() async {
    final groupCode =
        await widget.cloudStorageManager.generateUniqueGroupCode();
    setState(() {
      _groupCode = groupCode;
    });
    return;
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
                            DataColumn(label: Text('Remove')),
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
                    setState(() {
                      dialogUsers.add(dialogUserEmailController.text);
                      dialogUserEmailController.clear();
                    });
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
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      dialogCategoryExpense.add(dialogCategoryController.text);
                      dialogCategoryController.clear();
                    });
                  },
                  child: Text("Add Expense"),
                ),
                TextButton(
                  onPressed: () {
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

  Future<void> getUserEmail() async {
    final email = await widget.cloudStorageManager.getEmail(widget.userID);
    setState(() {
      _users.add(email);
    });
  }

  Future<int> _createGroup() async {
    if (_groupNameController.text == '') {
      return 1;
    }
    await widget.cloudStorageManager
        .createGroup(_groupCode, _groupNameController.text, _users);

    return 0;
  }
}
