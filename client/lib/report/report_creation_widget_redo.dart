import 'package:flutter/material.dart';
import 'package:budget_365/report/report_creation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportCreationWidgetRedo extends StatefulWidget {
  const ReportCreationWidgetRedo({super.key});

  @override
  State<ReportCreationWidgetRedo> createState() => ReportCreationWidgetRedoState();
}

class ReportCreationWidgetRedoState extends State<ReportCreationWidgetRedo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarSection(),
      body: Stack(children: [
        Padding(padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25,),
            AmountInput(),
            SizedBox(height: 25,),
            DateInputSelect(),
            SizedBox(height: 25,),
            AccountInput(),
            SizedBox(height: 25,),
            CategoryInput(),
            SizedBox(height: 25,),
            DescriptionInput(),],
        ),)
      ],),
      bottomNavigationBar: BottomAppBarSection(),
    );
  }

  PreferredSizeWidget AppBarSection(){
    return AppBar(
      centerTitle: true,
      // leadingWidth: 50,
      backgroundColor: Colors.blue,
      title: Text(
        "Income",
        style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),),
    );
  }

  Widget BottomAppBarSection(){
    return BottomAppBar(
      color: Colors.blue,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton(
              onPressed: _addIncome,
              child: Text(
                "Income",
                style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),)),
            TextButton(
              onPressed: _addExpense,
              child: Text(
                "Expense",
                style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),))],
        ),),);
  }

  Widget AmountInput(){
    return TextField(
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Enter Amount",
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(25.7)),
      ),
    );
  }
  Widget DateInputSelect(){
    return DateInput();
  }
  Widget AccountInput(){
    return DropdownMenuAccount();
  }
  Widget CategoryInput(){
    return DropdownMenuCategory();
  }
  Widget DescriptionInput(){
    return Expanded(child: TextField(
      textAlignVertical: TextAlignVertical.top,
        maxLines: null,
        expands: true,
        decoration: InputDecoration(
          hintText: "Enter description here...",
          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
      ),);
  }

  _addIncome(){}
  _addExpense(){}

}

class DateInput extends StatefulWidget {
  DateInput({Key? key}) : super(key: key);

  final TextEditingController dateController =
      TextEditingController(); // Expose controller

  @override
  State<DateInput> createState() => _DateInputState();
}

class _DateInputState extends State<DateInput> {
  TextEditingController _dateController = TextEditingController();
  @override
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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _dateController,
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Select Date',
        border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            borderRadius: BorderRadius.circular(25.7)),
        suffixIcon: Icon(Icons.calendar_today),
      ),
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      onTap: () => _selectDate(context),
    );
  }
}

class DropdownMenuAccount extends StatefulWidget {
  const DropdownMenuAccount({super.key});

  @override
  State<DropdownMenuAccount> createState() => _DropdownMenuAccountState();
}

class _DropdownMenuAccountState extends State<DropdownMenuAccount> {
  String? _selectedItem = 'Account1';

  List<String> _items = <String>['Account1', 'Account2', 'Account3'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          menuWidth: 350,
          isExpanded: true,
          value: _selectedItem,
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
      ),
    );
  }
}

class DropdownMenuCategory extends StatefulWidget {
  const DropdownMenuCategory({super.key});

  @override
  State<DropdownMenuCategory> createState() => _DropdownMenuCategoryState();
}

class _DropdownMenuCategoryState extends State<DropdownMenuCategory> {
  String? _selectedItem = 'Category1';

  List<String> _items = <String>['Category1', 'Category2', 'Category3'];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 350,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.black),
          dropdownColor: Colors.white,
          menuWidth: 350,
          isExpanded: true,
          value: _selectedItem,
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
      ),
    );
  }
}