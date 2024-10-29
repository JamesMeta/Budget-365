import 'package:flutter/material.dart';
import 'package:budget_365/report/report_creation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ReportCreationWidget extends StatefulWidget {
  const ReportCreationWidget({
    super.key,
    /*required this.title*/
  });

  //final String title;

  @override
  State<ReportCreationWidget> createState() => _ReportWidgetState();
}

class _ReportWidgetState extends State<ReportCreationWidget> {
  final SupabaseClient supabase = Supabase.instance.client;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leadingWidth: 100,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Add',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                )),
            TextButton(
                onPressed: _addIncome,
                child: Text('Income',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ))),
            TextButton(
                onPressed: _addExpense,
                child: Text('Expense',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ))),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('    Amount:   ',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                    Expanded(
                      child: AmountInput(),
                    ),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '   Date:    ',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    Expanded(child: DateInput()),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Account:',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const DropdownMenuAccount(),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      'Category:',
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    const DropdownMenuCategory(),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: DescriptionInput()),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _goToHome() {}

  void _addIncome() async {
    // Capture values from input fields here
    final amount = double.parse(AmountInput()
        .amountController
        .text); // Update AmountInput to expose this controller
    final date =
        DateInput().dateController.text; // Expose date controller as well
    final account = _selectedAccount;
    final category = _selectedCategory;
    final description = DescriptionInput()
        .descriptionController
        .text; // Expose description controller

    // Insert into Supabase
    final response = await supabase.from('transactions').insert({
      'amount': amount,
      'date': date,
      'account': account,
      'category': category,
      'description': description,
      'type': 'income', // Explicitly specifying 'income'
    }).select();
  }

  void _addExpense() async {
    // Similar to _addIncome but set type as 'expense'
    final amount = double.parse(AmountInput().amountController.text);
    final date = DateInput().dateController.text;
    final account = _selectedAccount;
    final category = _selectedCategory;
    final description = DescriptionInput().descriptionController.text;

    final response = await supabase.from('transactions').insert({
      'amount': amount,
      'date': date,
      'account': account,
      'category': category,
      'description': description,
      'type': 'expense', // Explicitly specifying 'expense'
    }).select();
  }
}

class _selectedCategory {}

class _selectedAccount {}

class AmountInput extends StatelessWidget {
  AmountInput({Key? key}) : super(key: key);

  final TextEditingController amountController =
      TextEditingController(); // Expose controller

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Enter Amount',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(25.7),
        ),
      ),
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
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
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
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
        width: 200,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.white),
          dropdownColor: Colors.blue,
          menuWidth: 200,
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
        width: 200,
        child: DropdownButton<String>(
          style: const TextStyle(color: Colors.white),
          dropdownColor: Colors.blue,
          menuWidth: 200,
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

class DescriptionInput extends StatelessWidget {
  DescriptionInput({Key? key}) : super(key: key);

  final TextEditingController descriptionController =
      TextEditingController(); // Expose controller

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: descriptionController,
      keyboardType: TextInputType.multiline,
      decoration: InputDecoration(
        labelText: 'Description',
        hintText: 'Enter Description here',
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(25.7),
        ),
      ),
      style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }
}
