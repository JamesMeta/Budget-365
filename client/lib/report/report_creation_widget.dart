import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:budget_365/report/report.dart';

class ReportCreationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final String selectedGroup;
  final List<Group> groups;
  final int userID;

  const ReportCreationWidget({
    super.key,
    required this.cloudStorageManager,
    required this.selectedGroup,
    required this.groups,
    required this.userID,
  });

  @override
  State<ReportCreationWidget> createState() =>
      _ReportCreationWidgetState(selectedGroup, groups);
}

class _ReportCreationWidgetState extends State<ReportCreationWidget> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedGroup;
  String _selectedType = '';
  String _username = '';
  bool _needsRefresh = true;

  late final List<Group> _groups;

  Map<String, List<String>> _categories = {
    'income': [],
    'expense': [],
  };

  _ReportCreationWidgetState(selectedGroup, groups) {
    _selectedGroup = selectedGroup;
    _groups = groups;
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  final Color _textFieldFontColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _textFieldBorderColor = const Color.fromARGB(143, 0, 0, 0);

  late double _fontSizeButtons;
  late double _fontSizeInputs;
  late double _fullSizedTextFieldWidth;
  late double _fullSizedTextFieldHeight;
  late double _halfSizedTextFieldWidth;
  late double _halfSizedTextFieldHeight;
  late double _iconSize;
  late double _halfSizedButtonWidth;
  late double _halfSizedButtonHeight;
  late double _fullSizedButtonWidth;
  late double _fullSizedButtonHeight;
  late double _fontSizeTitle;
  late double _descriptionHeight;

  @override
  Widget build(BuildContext context) {
    _fontSizeButtons = MediaQuery.of(context).size.width * 0.05;
    _fontSizeInputs = MediaQuery.of(context).size.width * 0.035;
    _fullSizedTextFieldWidth = MediaQuery.of(context).size.width;
    _fullSizedTextFieldHeight = MediaQuery.of(context).size.height * 0.1;
    _halfSizedTextFieldWidth = MediaQuery.of(context).size.width * 0.45;
    _halfSizedTextFieldHeight = MediaQuery.of(context).size.height * 0.1;
    _iconSize = MediaQuery.of(context).size.width * 0.065;
    _halfSizedButtonWidth = MediaQuery.of(context).size.width * 0.40;
    _halfSizedButtonHeight = MediaQuery.of(context).size.height * 0.1;
    _fullSizedButtonWidth = MediaQuery.of(context).size.width;
    _fullSizedButtonHeight = MediaQuery.of(context).size.height * 0.1;
    _fontSizeTitle = MediaQuery.of(context).size.width * 0.08;
    _descriptionHeight = MediaQuery.of(context).size.height * 0.20;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 112, 213, 243),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBarSection(),
      body: Stack(
        children: [
          AppGradient(),
          Padding(
            padding:
                EdgeInsets.fromLTRB(10, _halfSizedButtonHeight * 1.4, 10, 10),
            child: SingleChildScrollView(
              // Wrap Column with SingleChildScrollView
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IncomeExpenseButton(),
                    SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            UsernameSection(),
                            SizedBox(width: 5),
                            GroupInput(),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            DateInputSelect(),
                            SizedBox(width: 5),
                            CategoryInput(),
                          ],
                        ),
                        SizedBox(height: 20),
                        AmountInput(),
                        SizedBox(height: 20),
                        DescriptionInput(),
                        SizedBox(height: 20),
                        BottomSubmitButton(),
                      ],
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // bottomNavigationBar: BottomAppBarSection(),
    );
  }

  PreferredSizeWidget AppBarSection() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "Create Report",
        style: TextStyle(
            color: Colors.white,
            fontSize: _fontSizeTitle,
            fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
    );
  }

  Widget IncomeExpenseButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          width: _halfSizedButtonWidth,
          height: _halfSizedButtonHeight,
          decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedType == 'income'
                      ? const Color.fromARGB(255, 107, 248, 112)
                      : Colors.transparent,
                  width: 2.5),
              borderRadius: BorderRadius.circular(10)),
          child: ElevatedButton(
            onPressed: _addIncome,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
              fixedSize: WidgetStatePropertyAll(Size(150, 60)),
            ),
            child: Text(
              "Income",
              style: TextStyle(
                  color: _selectedType == 'income'
                      ? const Color.fromARGB(255, 107, 248, 112)
                      : Colors.white,
                  fontSize: _fontSizeButtons,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          width: _halfSizedButtonWidth,
          height: _halfSizedButtonHeight,
          decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedType == 'expense'
                      ? const Color.fromARGB(255, 199, 0, 0)
                      : Colors.transparent,
                  width: 2.5),
              borderRadius: BorderRadius.circular(10)),
          child: ElevatedButton(
            onPressed: _addExpense,
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(Colors.transparent),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
              fixedSize: WidgetStatePropertyAll(Size(150, 60)),
            ),
            child: Text(
              "Expense",
              style: TextStyle(
                  color: _selectedType == 'expense'
                      ? const Color.fromARGB(255, 199, 0, 0)
                      : Colors.white,
                  fontSize: _fontSizeButtons,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget UsernameSection() {
    if (_username.isEmpty) {
      return FutureBuilder(
        future: getUsername(widget.userID),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MockTextField();
          } else if (snapshot.hasError) {
            return Text('Error');
          } else {
            return Container(
                width: _halfSizedTextFieldWidth,
                height: _halfSizedTextFieldHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(94, 117, 117, 117),
                  border: Border.all(color: _textFieldBorderColor, width: 2),
                  borderRadius: BorderRadius.circular(26.7),
                ),
                child: Text(
                  _username,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: _fontSizeInputs,
                      fontWeight: FontWeight.bold,
                      color: _textFieldFontColor),
                ));
          }
        },
      );
    } else {
      return Container(
          width: _halfSizedTextFieldWidth,
          height: _halfSizedTextFieldHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(94, 117, 117, 117),
            border: Border.all(color: _textFieldBorderColor, width: 2),
            borderRadius: BorderRadius.circular(26.7),
          ),
          child: Text(
            _username,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: _fontSizeInputs,
                fontWeight: FontWeight.bold,
                color: _textFieldFontColor),
          ));
    }
  }

  Widget CategoryInput() {
    if ((_categories['income']!.isEmpty && _categories['expense']!.isEmpty) ||
        _needsRefresh) {
      _needsRefresh = false;
      return FutureBuilder(
          future: _FetchCategories(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return MockTextField();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                alignment: Alignment.center,
                padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                width: _halfSizedTextFieldWidth,
                height: _halfSizedTextFieldHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: _textFieldBorderColor, width: 2),
                  borderRadius: BorderRadius.circular(26.7),
                ),
                child: DropdownButton<String>(
                  style: TextStyle(
                      color: _textFieldFontColor,
                      fontSize: _fontSizeInputs,
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.blue,
                  icon: Icon(Icons.arrow_drop_down, color: _textFieldFontColor),
                  isExpanded: true,
                  underline: Container(color: Colors.transparent),
                  value: _selectedCategory,
                  hint: Text('Select Category',
                      style: TextStyle(
                          color: _textFieldFontColor,
                          fontSize: _fontSizeInputs,
                          fontWeight: FontWeight.bold)), // Placeholder text
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: (() {
                    if (_selectedType.isNotEmpty) {
                      List<String> categoryList =
                          _categories[_selectedType] ?? [];
                      return categoryList.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList();
                    } else {
                      List<String> allCategories = [];
                      _categories.forEach((key, list) {
                        allCategories.addAll(list);
                      });
                      return allCategories.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList();
                    }
                  })(),
                ),
              );
            } else {
              return Text('Error: ${snapshot.error}');
            }
          });
    } else {
      return Container(
        padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
        width: _halfSizedTextFieldWidth,
        height: _halfSizedTextFieldHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _textFieldBorderColor, width: 2),
          borderRadius: BorderRadius.circular(26.7),
        ),
        child: DropdownButton<String>(
          style: TextStyle(
              color: _textFieldFontColor,
              fontSize: _fontSizeInputs,
              fontWeight: FontWeight.bold),
          dropdownColor: Colors.blue,
          icon: Icon(Icons.arrow_drop_down, color: _textFieldFontColor),
          isExpanded: true,
          underline: Container(color: Colors.transparent),
          value: _selectedCategory,
          hint: Text('Select Category',
              style: TextStyle(
                  color: _textFieldFontColor,
                  fontSize: _fontSizeInputs,
                  fontWeight: FontWeight.bold)), // Placeholder text
          onChanged: (String? value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          items: (() {
            if (_selectedType.isNotEmpty) {
              List<String> categoryList =
                  _categories[_selectedType.toLowerCase()] ?? [];
              return categoryList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList();
            } else {
              List<String> allCategories = [];
              _categories.forEach((key, list) {
                allCategories.addAll(list);
              });
              return allCategories.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList();
            }
          })(),
        ),
      );
    }
  }

  Widget GroupInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      width: _halfSizedTextFieldWidth,
      height: _halfSizedTextFieldHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: _textFieldBorderColor, width: 2),
        borderRadius: BorderRadius.circular(25.7),
      ),
      child: DropdownButton<String>(
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: _fontSizeInputs,
            fontWeight: FontWeight.bold),
        dropdownColor: Colors.blue,
        icon: Icon(Icons.arrow_drop_down, color: _textFieldFontColor),
        isExpanded: true,
        underline: Container(color: Colors.transparent),
        value: _selectedGroup,
        hint: Text('Select Group',
            style: TextStyle(
                color: _textFieldFontColor,
                fontSize: _fontSizeInputs,
                fontWeight: FontWeight.bold)), // Placeholder text
        onChanged: (String? value) {
          setState(() {
            _selectedGroup = value;
            _needsRefresh = true;
          });
        },
        items: _groups.map((Group value) {
          return DropdownMenuItem<String>(
            value: value.name,
            child: Text(value.name),
          );
        }).toList(),
      ),
    );
  }

  Widget DateInputSelect() {
    return GestureDetector(
      onTap: () {
        _selectDate(context);
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
        width: _halfSizedTextFieldWidth,
        height: _halfSizedTextFieldHeight,
        decoration: BoxDecoration(
          border: Border.all(color: _textFieldBorderColor, width: 2),
          borderRadius: BorderRadius.circular(25.7),
          color: Colors.transparent,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _dateController.text,
              style: TextStyle(
                color: _textFieldFontColor,
                fontSize: _fontSizeInputs,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              Icons.calendar_today,
              color: Colors.white,
              size: _iconSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget AmountInput() {
    return Container(
      width: _fullSizedTextFieldWidth, // Set width relative to screen
      height: _fullSizedTextFieldHeight, // Set height relative to screen
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        expands: true,
        maxLines: null,
        style: TextStyle(
          color: _textFieldFontColor,
          fontSize: _fontSizeInputs,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: "Enter Amount",
          labelStyle: TextStyle(
            color: _textFieldFontColor,
            fontSize: _fontSizeInputs,
            fontWeight: FontWeight.bold,
          ),
          contentPadding: EdgeInsets.only(left: 12, right: 12),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _textFieldBorderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _textFieldBorderColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25.7),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: _textFieldFontColor,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25.7),
          ),
          fillColor: Colors.transparent,
          filled: true,
        ),
      ),
    );
  }

  Widget DescriptionInput() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: _descriptionHeight,
      child: TextField(
        controller: _descriptionController,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: _fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "Enter description here...",
          hintStyle: TextStyle(color: _textFieldFontColor),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          // Set border for different states
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: _textFieldBorderColor,
                width: 2), // Border color when enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: _textFieldBorderColor,
                width: 2), // Border color when focused
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: _textFieldBorderColor,
                width: 2), // Border color in general
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget BottomSubmitButton() {
    return Container(
      height: _fullSizedButtonHeight,
      width: _fullSizedTextFieldWidth,
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () async {
          int response = await _createReport();
          if (response == 0) {
            Navigator.pop(context, response);
          } else if (response == -1) {
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
          } else if (response == -2) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Error"),
                    content: Text("Please enter a valid amount"),
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          fixedSize: WidgetStatePropertyAll(
              Size(_fullSizedButtonWidth, _fullSizedButtonHeight)),
        ),
        child: Text(
          "Submit",
          style: TextStyle(
            color: Colors.white,
            fontSize: _fontSizeButtons,
            fontFamily: 'Arial',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget MockTextField() {
    return Container(
        width: _halfSizedTextFieldWidth,
        height: _halfSizedTextFieldHeight,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _textFieldBorderColor, width: 2),
          borderRadius: BorderRadius.circular(26.7),
        ),
        child: Text(
          'Loading...',
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _textFieldFontColor),
        ));
  }

  void _addIncome() {
    setState(() {
      _selectedType = 'income';
      _selectedCategory = null;
    });
  }

  void _addExpense() {
    setState(() {
      _selectedType = 'expense';
      _selectedCategory = null;
    });
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> getUsername(int userID) async {
    _username = await widget.cloudStorageManager.getUsername(userID);
    return;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: _dateController.text.isEmpty
            ? DateTime.now()
            : DateTime.parse(_dateController.text),
        firstDate: DateTime(1800),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<Map<String, List<String>>> _FetchCategories() async {
    int groupID =
        _groups.firstWhere((group) => group.name == _selectedGroup).id;
    _categories = await widget.cloudStorageManager.getCategoryList(groupID);
    return _categories;
  }

  Future<int> _createReport() async {
    if (_selectedGroup == null ||
        _selectedType.isEmpty ||
        _amountController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _selectedCategory == null ||
        _dateController.text.isEmpty) {
      return -1;
    }

    // check if amount is a valid number
    try {
      double.parse(_amountController.text);
    } catch (e) {
      return -2;
    }

    int groupID =
        _groups.firstWhere((group) => group.name == _selectedGroup).id;
    int type = _selectedType == 'income' ? 0 : 1;
    double amount = double.parse(_amountController.text);
    String description = _descriptionController.text;
    String category = _selectedCategory!;
    DateTime date = DateTime.parse(_dateController.text);

    await widget.cloudStorageManager.createReport(
        amount: amount,
        description: description,
        Category: category,
        groupID: groupID,
        userID: widget.userID,
        date: date,
        type: type);

    return 0;
  }
}
