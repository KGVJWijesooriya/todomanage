import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/services.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

import 'taskTimeline.dart';

class AlertBox extends StatefulWidget {
  final Map<String, dynamic> task;
  final String userId; // Add userId for Firebase update

  AlertBox({required this.task, required this.userId});

  @override
  _AlertBoxState createState() => _AlertBoxState();
}

class _AlertBoxState extends State<AlertBox> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;

  int _progress = 0;
  int _paymentTy = 0;
  int _priority = 0;

  late TextEditingController _advancedController =
      TextEditingController(text: '00.00');
  late TextEditingController _paidController =
      TextEditingController(text: '00.00');
  late TextEditingController _remainingController =
      TextEditingController(text: '00.00');

  // Dropdown items
  final List<String> _progressItems = [
    'Not Started',
    'In Progress',
    'In Review',
    'Done',
  ];

  final List<Color> _progressColors = [
    const Color(0xFFE4602B),
    const Color(0xFF9AC1EF),
    const Color(0xFF73FA92),
    const Color(0xFFA1E448),
  ];
  final List<Color> _progressTextColors = [
    Colors.white,
    const Color(0xFF24263a),
    const Color(0xFF24263a),
    const Color(0xFF24263a),
  ];

  final List<String> _paymentTyItems = [
    'Not Paid',
    'Advanced',
    'Paid',
  ];

  final List<Color> _paymentTyColors = [
    const Color(0xFFE4602B),
    const Color(0xFF9AC1EF),
    const Color(0xFF73FA92),
  ];
  final List<Color> _paymentTyTextColors = [
    Colors.white,
    const Color(0xFF24263a),
    const Color(0xFF24263a),
  ];

  final List<String> _priorityItems = [
    'Urgent',
    'Normal',
  ];

  final List<Color> _priorityColors = [
    const Color(0xFFE4602B),
    const Color(0xFF9AC1EF),
  ];
  final List<Color> _priorityTextColors = [
    Colors.white,
    const Color(0xFF24263a),
  ];
  String? _selectedProgress;
  String? _selectedPaymentTy;
  String? _selectedPriority;

  late double advanceValue;
  late double paidValue;
  late double remainingValue;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with data
    _titleController = TextEditingController(text: widget.task['title']);
    _descriptionController =
        TextEditingController(text: widget.task['description']);

    // Parse the due date from the string format
    _selectedDate = DateFormat('dd MMMM yyyy')
        .parse(widget.task['dueDate']); // Adjust the format as needed

    // Initialize other fields
    _progress = widget.task['progress'];
    _paymentTy = widget.task['paymentTy'];
    _priority = widget.task['priority'];

    // Set the initial selected values based on the task data
    _selectedProgress = _progressItems[_progress];
    _selectedPaymentTy = _paymentTyItems[_paymentTy];
    _selectedPriority = _priorityItems[_priority];

    if (widget.task['advance'] != null) {
      advanceValue = double.tryParse(widget.task['advance'].toString()) ?? 0.0;
    } else {
      advanceValue = 0.0;
    }

    _advancedController = TextEditingController(text: advanceValue.toString());

    if (widget.task['paid'] != null) {
      paidValue = double.tryParse(widget.task['paid'].toString()) ?? 0.0;
    } else {
      paidValue = 0.0;
    }

    _paidController = TextEditingController(text: _paidController.toString());

    if (widget.task['remaining'] != null) {
      remainingValue =
          double.tryParse(widget.task['remaining'].toString()) ?? 0.0;
    } else {
      remainingValue = 0.0;
    }

    _remainingController =
        TextEditingController(text: remainingValue.toString());

    // print(remainingValue);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Method to show the date picker
  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Color(0xFF24263a),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            height: 400,
            child: SfDateRangePicker(
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  _selectedDate = args.value;
                });
                Navigator.of(context).pop(); // Close dialog on date selection
              },
              initialSelectedDate: _selectedDate,
              selectionMode: DateRangePickerSelectionMode.single,
            ),
          ),
          // actions: [
          //   TextButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     child: Text("Close"),
          //   ),
          // ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF14142B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Task Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 18,
                        ),
                      ),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Progress',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                          ),
                          items: List.generate(
                            _progressItems.length,
                            (index) => DropdownMenuItem<String>(
                              value: _progressItems[index],
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _progressColors[index],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                margin: EdgeInsets.all(3),
                                // padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    _progressItems[index],
                                    style: TextStyle(
                                        color: _progressTextColors[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          value: _selectedProgress,
                          onChanged: (value) {
                            setState(() {
                              _selectedProgress = value;
                              _progress = _progressItems.indexOf(value!);
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 240,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 250,
                            decoration: BoxDecoration(
                              color: Color(0xFF24263A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          iconStyleData: IconStyleData(
                            icon: SizedBox.shrink(),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF24263a),
                          labelText: 'Title',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF73FA92), width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF73FA92), width: 2),
                          ),
                        ),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: _descriptionController,
                        minLines: 2,
                        maxLines: null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color(0xFF24263a),
                          labelText: 'Description',
                          labelStyle: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF73FA92), width: 1),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide:
                                BorderSide(color: Color(0xFF73FA92), width: 2),
                          ),
                        ),
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300),
                      ),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: Container(
                          width: 280,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                              color: const Color(0xFF24263A),
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                  color: Color(0xFF73FA92), width: 1)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('dd MMMM yyyy')
                                    .format(_selectedDate),
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              Icon(
                                Icons.event,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF24263a),
                          border: Border(
                            bottom: BorderSide(
                              color: const Color(0xFF73FA92),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task Amount:',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${widget.task['amount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Payment Type',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                          ),
                          items: List.generate(
                            _paymentTyItems.length,
                            (index) => DropdownMenuItem<String>(
                              value: _paymentTyItems[index],
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _paymentTyColors[index],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                margin: EdgeInsets.all(3),
                                // color: _paymentTyColors[index],
                                padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    _paymentTyItems[index],
                                    style: TextStyle(
                                        color: _paymentTyTextColors[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          value: _selectedPaymentTy,
                          onChanged: (value) {
                            setState(() {
                              _selectedPaymentTy = value;
                              _paymentTy = _paymentTyItems.indexOf(value!);
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 240,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 250,
                            decoration: BoxDecoration(
                              color: Color(0xFF24263A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          iconStyleData: IconStyleData(
                            icon: SizedBox.shrink(), // Hides the dropdown arrow
                          ),
                        ),
                      ),
                      if (_paymentTy == 1)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "Advanced Amount",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF24263a),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Color(0xFF73FA92)),
                              ),
                              child: Container(
                                width: 100,
                                child: TextField(
                                  controller: _advancedController,
                                  keyboardType:
                                      TextInputType.numberWithOptions(
                                          decimal: true),
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}'),
                                    ),
                                  ],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.right,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      if (_paymentTy == 2)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 10),
                            Text(
                              "Paid Amount",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF24263a),
                                borderRadius: BorderRadius.circular(3),
                                border: Border.all(color: Color(0xFF73FA92)),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Paid Ammount'),
                                  Container(
                                    width: 100,
                                    child: TextField(
                                      controller: _remainingController,
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                              decimal: true),
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: Colors.white,
                                      ),
                                      textAlign: TextAlign.right,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 16),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: Text(
                            'Select Priority',
                            style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).hintColor),
                          ),
                          items: List.generate(
                            _priorityItems.length,
                            (index) => DropdownMenuItem<String>(
                              value: _priorityItems[index],
                              child: Container(
                                width: 200,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _priorityColors[index],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                margin: EdgeInsets.all(3),
                                // padding: EdgeInsets.all(8),
                                child: Center(
                                  child: Text(
                                    _priorityItems[index],
                                    style: TextStyle(
                                        color: _priorityTextColors[index]),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          value: _selectedPriority,
                          onChanged: (value) {
                            setState(() {
                              _selectedPriority = value;
                              _priority = _priorityItems.indexOf(value!);
                            });
                          },
                          buttonStyleData: const ButtonStyleData(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            height: 40,
                            width: 240,
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height: 40,
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 250,
                            decoration: BoxDecoration(
                              color: Color(0xFF24263A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          iconStyleData: IconStyleData(
                            icon: SizedBox.shrink(), // Hides the dropdown arrow
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Task Payment\nTimeline',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.65,
                      child: TaskTimelineTile(
                        userId: widget.userId,
                        taskId: widget.task['id'],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        // )
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "Cancel",
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        TextButton(
          onPressed: _updateTaskInFirebase,
          child: Container(
                  // height: MediaQuery.of(context).size.height * 0.05,
                  // margin: EdgeInsets.only(left: 20),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color(0xFF24263A),
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: Color(0xFF73FA92), width: 1)),
            child: Text(
              "Update",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: MediaQuery.of(context).size.height * 0.020,
                  color: const Color(0xFF73FA92)),
            ),
          ),
        ),
      ],
    );
  } // Method to update the task in Firebase

  Future<void> _updateTaskInFirebase() async {
    DateTime? advancePaidDate;
    DateTime? paidDate;

    try {
      // Convert input strings to double values
      advanceValue = double.tryParse(_advancedController.text) ?? 0.0;
      paidValue = double.tryParse(_remainingController.text) ?? 0.0;
      // Update remaining value if advance payment is made
      if (_paymentTy == 1 && advanceValue > 0) {
        remainingValue = widget.task['amount'] - advanceValue;
        advancePaidDate = DateTime.now();
        paidValue = 0.0;
      }

      // Update remaining and paid values if full payment is made
      if (_paymentTy == 2 && paidValue > 0) {
        remainingValue = 0.0; // Full payment made
        paidDate = DateTime.now();
        paidValue = paidValue; // Full amount is paid
      }

      // Updating the task in Firebase with the new values
      await FirebaseFirestore.instance
          .collection('AppUser')
          .doc(widget.userId)
          .collection('tasks')
          .doc(widget.task['id'])
          .update({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'dueDate': Timestamp.fromDate(_selectedDate),
        'progress': _progress,
        'paymentTy': _paymentTy,
        'priority': _priority,
        'advance': advanceValue,
        'remaining': remainingValue,
        'advancePaidDate': advancePaidDate,
        'paid': paidValue,
        'paidDate': paidDate,
      });

      // Close the dialog box after the update
      Navigator.pop(context);
    } catch (e) {
      print("Error updating task: $e");
    }
  }
}
