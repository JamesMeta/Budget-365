import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';
import 'package:budget_365/group/group.dart';

class ReportCreationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;
  final String selectedGroup;
  final List<Group> groups;
  final int userID;

  ReportCreationWidget(
      {required this.cloudStorageManager,
      required this.selectedGroup,
      required this.groups,
      required this.userID});

  @override
  State<ReportCreationWidget> createState() =>
      _ReportCreationWidgetState(selectedGroup, groups);
}

class _ReportCreationWidgetState extends State<ReportCreationWidget> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedGroup;
  String _selectedType = '';
  bool _needsRefresh = true;

  late final List<Group> _groups;

  List<String> _categories = [];

  _ReportCreationWidgetState(selectedGroup, groups) {
    _selectedGroup = selectedGroup;
    _groups = groups;
    _dateController.text = DateTime.now().toString().split(' ')[0];
  }

  Color specialColor = const Color.fromARGB(143, 0, 0, 0);

  double fontSizeInputs = 17;
  double fontSizeButtons = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 112, 213, 243),
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: AppBarSection(),
      body: Stack(
        children: [
          Gradient(),
          Padding(
            padding: EdgeInsets.fromLTRB(10, 120, 10, 10),
            child: SingleChildScrollView(
              // Wrap Column with SingleChildScrollView
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
                          CategoryInput(),
                          SizedBox(width: 5),
                          GroupInput(),
                        ],
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          AmountInput(),
                          SizedBox(width: 5),
                          DateInputSelect(),
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
            color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
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

  Widget IncomeExpenseButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          decoration: BoxDecoration(
              border: Border.all(
                  color: _selectedType == 'Income'
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
                  color: _selectedType == 'Income'
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
                  color: _selectedType == 'Expense'
                      ? Colors.red
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
                  color: _selectedType == 'Expense' ? Colors.red : Colors.white,
                  fontSize: fontSizeButtons,
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget CategoryInput() {
    if (_categories.isEmpty || _needsRefresh) {
      _needsRefresh = false;
      return FutureBuilder(
          future: _FetchCategories(),
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Container(
                width: 190,
                height: 56,
                child: TextField(),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.connectionState == ConnectionState.done) {
              return Container(
                padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
                width: 190,
                height: 56,
                decoration: BoxDecoration(
                  border: Border.all(color: specialColor, width: 2),
                  borderRadius: BorderRadius.circular(26.7),
                ),
                child: DropdownButton<String>(
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSizeInputs,
                      fontWeight: FontWeight.bold),
                  dropdownColor: Colors.blue,
                  icon: Icon(Icons.arrow_drop_down, color: specialColor),
                  isExpanded: true,
                  underline: Container(color: Colors.transparent),
                  value: _selectedCategory,
                  hint: Text('Select Category',
                      style: TextStyle(
                          color: specialColor,
                          fontSize: fontSizeInputs,
                          fontWeight: FontWeight.bold)), // Placeholder text
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  items: _categories.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
          border: Border.all(color: specialColor, width: 2),
          borderRadius: BorderRadius.circular(26.7),
        ),
        child: DropdownButton<String>(
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSizeInputs,
              fontWeight: FontWeight.bold),
          dropdownColor: Colors.blue,
          icon: Icon(Icons.arrow_drop_down, color: specialColor),
          isExpanded: true,
          underline: Container(color: Colors.transparent),
          value: _selectedCategory,
          hint: Text('Select Category',
              style: TextStyle(
                  color: specialColor,
                  fontSize: fontSizeInputs,
                  fontWeight: FontWeight.bold)), // Placeholder text
          onChanged: (String? value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          items: _categories.map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      );
    }
  }

  Widget GroupInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      width: 190,
      height: 56,
      decoration: BoxDecoration(
        border: Border.all(color: specialColor, width: 2),
        borderRadius: BorderRadius.circular(25.7),
      ),
      child: DropdownButton<String>(
        style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        dropdownColor: Colors.blue,
        icon: Icon(Icons.arrow_drop_down, color: specialColor),
        isExpanded: true,
        underline: Container(color: Colors.transparent),
        value: _selectedGroup,
        hint: Text('Select Group',
            style: TextStyle(
                color: specialColor,
                fontSize: fontSizeInputs,
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
    return Container(
      width: 190,
      height: 56,
      child: TextField(
        controller: _dateController,
        readOnly: true,
        style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: 'Select Date',
          labelStyle: TextStyle(
              color: specialColor,
              fontSize: fontSizeInputs,
              fontWeight: FontWeight.bold),
          // Set border for different states
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color when enabled
            borderRadius: BorderRadius.circular(25.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color when focused
            borderRadius: BorderRadius.circular(25.7),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color in general
            borderRadius: BorderRadius.circular(25.7),
          ),
          suffixIcon: Icon(Icons.calendar_today, color: specialColor),
          fillColor: Colors.transparent,
          filled: true,
        ),
        onTap: () => _selectDate(context),
      ),
    );
  }

  Widget AmountInput() {
    return Container(
      width: 190,
      height: 56,
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          labelText: "Enter Amount",
          labelStyle: TextStyle(
              color: specialColor,
              fontSize: fontSizeInputs,
              fontWeight: FontWeight.bold),
          // Set border for different states
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color when enabled
            borderRadius: BorderRadius.circular(25.7),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color when focused
            borderRadius: BorderRadius.circular(25.7),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color in general
            borderRadius: BorderRadius.circular(25.7),
          ),
          fillColor: Colors.transparent,
          filled: true,
        ),
      ),
    );
  }

  Widget DescriptionInput() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 380,
      child: TextField(
        controller: _descriptionController,
        textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        style: TextStyle(
            color: Colors.white,
            fontSize: fontSizeInputs,
            fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: "Enter description here...",
          hintStyle: TextStyle(color: specialColor),
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          // Set border for different states
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color when enabled
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color when focused
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: specialColor, width: 2), // Border color in general
          ),
          filled: true,
          fillColor: Colors.transparent,
        ),
      ),
    );
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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
          fixedSize: WidgetStatePropertyAll(Size(400, 80)),
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

  _addIncome() {
    setState(() {
      _selectedType = 'Income';
    });
  }

  _addExpense() {
    setState(() {
      _selectedType = 'Expense';
    });
  }

  void dispose() {
    _dateController.dispose();
    super.dispose();
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

  Future<List<String>> _FetchCategories() async {
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

    int groupID =
        _groups.firstWhere((group) => group.name == _selectedGroup).id;
    int type = _selectedType == 'Income' ? 0 : 1;
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
