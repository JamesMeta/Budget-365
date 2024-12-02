import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';
import 'package:budget_365/design/app_gradient.dart';
import 'package:budget_365/report/report.dart';

class ReportEditWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final Report? report;

  const ReportEditWidget({
    super.key,
    required this.cloudStorageManager,
    required this.report,
  });

  @override
  State<ReportEditWidget> createState() => _ReportEditWidgetState();
}

class _ReportEditWidgetState extends State<ReportEditWidget> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Group _originalGroup;
  String? _selectedGroup;
  String? _selectedCategory;
  String _selectedType = '';
  String _username = '';
  bool _needsRefresh = true;

  Map<String, List<String>> _categories = {
    'income': [],
    'expense': [],
  };

  final Color _textFieldFontColor = const Color.fromARGB(255, 255, 255, 255);
  final Color _textFieldBorderColor = const Color.fromARGB(143, 0, 0, 0);

  double fontSizeInputs = 17;
  double fontSizeButtons = 25;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.report!.category;
    _selectedType = widget.report!.type == 0 ? 'income' : 'expense';
    _amountController.text = widget.report!.amount.toString();
    _descriptionController.text = widget.report!.description;
    _dateController.text =
        widget.report!.date.toIso8601String().split('T').first; //YYYY-MM-DD
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 112, 213, 243),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBarSection(),
      body: Stack(
        children: [
          AppGradient(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 120, 10, 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IncomeExpenseButton(),
                  SizedBox(height: 40),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AmountInput(),
                        ],
                      ),
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
        ],
      ),
    );
  }

  PreferredSizeWidget AppBarSection() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        "Report Editor",
        style: TextStyle(
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.delete, color: Colors.white, size: 30),
          onPressed: () {
            // open menu with delete option
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Delete Report"),
                    content:
                        Text("Are you sure you want to delete this report?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () async {
                          await widget.cloudStorageManager
                              .deleteReport(widget.report!.id);
                          Navigator.pop(context);
                          Navigator.pop(context, 0);
                        },
                        child: Text("Delete"),
                      ),
                    ],
                  );
                });
          },
        ),
      ],
    );
  }

  Widget IncomeExpenseButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
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
                  fontSize: fontSizeButtons,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedType == 'expense'
                      ? const Color.fromARGB(255, 0, 238, 255)
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
                      ? const Color.fromARGB(255, 0, 238, 255)
                      : Colors.white,
                  fontSize: fontSizeButtons,
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
        future: getUsername(widget.report!.userID),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return MockTextField();
          } else if (snapshot.hasError) {
            return Text('Error');
          } else {
            return Container(
                width: 190,
                height: 56,
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
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _textFieldFontColor),
                ));
          }
        },
      );
    } else {
      return Container(
          width: 190,
          height: 56,
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
                fontSize: 20,
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
                padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                width: 190,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: _textFieldBorderColor, width: 2),
                  borderRadius: BorderRadius.circular(26.7),
                ),
                child: DropdownButton<String>(
                  style: TextStyle(
                      color: _textFieldFontColor,
                      fontSize: fontSizeInputs,
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.blue,
                  icon: Icon(Icons.arrow_drop_down, color: _textFieldFontColor),
                  isExpanded: true,
                  underline: Container(color: Colors.transparent),
                  value: _selectedCategory,
                  hint: Text('Select Category',
                      style: TextStyle(
                          color: _textFieldFontColor,
                          fontSize: fontSizeInputs,
                          fontWeight: FontWeight.bold)),
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
        width: 190,
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(color: _textFieldBorderColor, width: 2),
          borderRadius: BorderRadius.circular(26.7),
        ),
        child: DropdownButton<String>(
          style: TextStyle(
              color: _textFieldFontColor,
              fontSize: fontSizeInputs,
              fontWeight: FontWeight.bold),
          dropdownColor: Colors.blue,
          icon: Icon(Icons.arrow_drop_down, color: _textFieldFontColor),
          isExpanded: true,
          underline: Container(color: Colors.transparent),
          value: _selectedCategory,
          hint: Text('Select Category',
              style: TextStyle(
                  color: _textFieldFontColor,
                  fontSize: fontSizeInputs,
                  fontWeight: FontWeight.bold)),
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
    if (_selectedGroup == null) {
      return FutureBuilder(
          future: _fetchGroup(widget.report!.groupID),
          builder: (BuildContext context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return MockTextField();
            } else if (snapshot.hasError) {
              return Text('Error');
            } else {
              return Container(
                  width: 190,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(94, 117, 117, 117),
                    border: Border.all(color: _textFieldBorderColor, width: 2),
                    borderRadius: BorderRadius.circular(26.7),
                  ),
                  child: Text(
                    _selectedGroup ?? "Unknown Group",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _textFieldFontColor),
                  ));
            }
          });
    } else {
      return Container(
          width: 190,
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color.fromARGB(94, 117, 117, 117),
            border: Border.all(color: _textFieldBorderColor, width: 2),
            borderRadius: BorderRadius.circular(26.7),
          ),
          child: Text(
            _selectedGroup ?? "Unknown Group",
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _textFieldFontColor),
          ));
    }
  }

  Widget DateInputSelect() {
    return SizedBox(
      width: 190,
      height: 56,
      child: TextField(
        controller: _dateController,
        readOnly: true,
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: 'Select Date',
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
            borderSide: BorderSide(color: _textFieldBorderColor, width: 2),
            borderRadius: BorderRadius.circular(25.7),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: _textFieldFontColor),
          fillColor: Colors.transparent,
          filled: true,
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget AmountInput() {
    return SizedBox(
      width: 390,
      height: 56,
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: "Enter Amount",
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

  Widget DescriptionInput() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 300,
      child: TextField(
        controller: _descriptionController,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        style: TextStyle(
            color: _textFieldFontColor,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "Enter description here...",
          hintStyle: TextStyle(color: _textFieldFontColor),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _textFieldBorderColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _textFieldBorderColor, width: 2),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: _textFieldBorderColor, width: 2),
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget MockTextField() {
    return Container(
        width: 190,
        height: 56,
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

  Widget BottomSubmitButton() {
    return Container(
      height: 100,
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
                    content: Text("Amount must be a number"),
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
          fixedSize: WidgetStatePropertyAll(Size(400, 80)),
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

  void _addIncome() {
    setState(() {
      _selectedType = 'income';
    });
  }

  void _addExpense() {
    setState(() {
      _selectedType = 'expense';
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
        initialDate: DateTime.now(),
        firstDate: DateTime(1800),
        lastDate: DateTime(2100));

    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  Future<Map<String, List<String>>> _FetchCategories() async {
    int groupID = widget.report!.groupID;
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

    // check if amount is a number
    try {
      double.parse(_amountController.text);
    } catch (e) {
      return -2;
    }

    int groupID = widget.report!.groupID;
    int type = _selectedType == 'income' ? 0 : 1;
    double amount = double.parse(_amountController.text);
    String description = _descriptionController.text;
    String category = _selectedCategory!;
    DateTime date = DateTime.parse(_dateController.text);

    await widget.cloudStorageManager.editReport(
        reportID: widget.report!.id,
        amount: amount,
        description: description,
        Category: category,
        groupID: groupID,
        userID: widget.report!.userID,
        date: date,
        type: type);

    return 0;
  }

  Future<void> _fetchGroup(int groupID) async {
    final response = await widget.cloudStorageManager.getGroup(groupID);
    if (response != null) {
      _originalGroup = response;
      _selectedGroup = _originalGroup.name;
    }
    return;
  }
}
