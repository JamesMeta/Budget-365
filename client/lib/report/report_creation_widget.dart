import 'package:flutter/material.dart';
import 'package:budget_365/report/report_creation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:budget_365/utility/cloud_storage_manager.dart';

class ReportCreationWidget extends StatefulWidget {
  final CloudStorageManager cloudStorageManager;

  ReportCreationWidget({required this.cloudStorageManager});

  @override
  State<ReportCreationWidget> createState() => _ReportCreationWidgetState();
}

class _ReportCreationWidgetState extends State<ReportCreationWidget> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  String? _selectedItem;
  String _selectedType = '';

  List<String> _items = <String>['Category1', 'Category2', 'Category3'];

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
                          SizedBox(width: 20),
                          DateInputSelect(),
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
          Color.fromARGB(255, 63, 19, 255),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 71, 162, 236),
          Color.fromARGB(255, 63, 19, 255),
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
    return Container(
      padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
      width: 180,
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
        value: _selectedItem,
        hint: Text('Select Category',
            style: TextStyle(
                color: specialColor,
                fontSize: fontSizeInputs,
                fontWeight: FontWeight.bold)), // Placeholder text
        onChanged: (String? value) {
          setState(() {
            _selectedItem = value;
          });
        },
        items: _items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget DateInputSelect() {
    return Container(
      width: 180,
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
      width: MediaQuery.of(context).size.width,
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
        onPressed: _doThing,
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

  _doThing() {}
}
