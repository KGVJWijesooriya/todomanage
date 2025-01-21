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
    print(widget.task);
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
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context)
              .colorScheme
              .onSecondary, // Background color from theme
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            margin: EdgeInsets.all(20),
            height: 350,
            width: 350,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.single,
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                setState(() {
                  _selectedDate = args.value;
                });
                Navigator.of(context).pop(); // Close dialog on date selection
              },
              initialSelectedDate: _selectedDate,
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .onSecondary, // Use theme for background
              selectionColor: Theme.of(context)
                  .colorScheme
                  .surface, // Selection color from theme
              todayHighlightColor: Theme.of(context)
                  .colorScheme
                  .surface, // Today's highlight color
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // Header text color
                ),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .secondary, // Month cell text color
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context)
                      .colorScheme
                      .surface, // Today's date text color
                  fontWeight: FontWeight.w700, // Make today's text bold
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double TitleFontSize = MediaQuery.of(context).size.width / 28;
    return
        // AlertDialog(
        //   backgroundColor: Color(0xFF14142B),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.circular(10),
        //   ),
        //   content:
        //   SizedBox(
        //     height: MediaQuery.of(context).size.height * 0.45,
        //     width: MediaQuery.of(context).size.width,
        //     child:
        // SingleChildScrollView(
        //   scrollDirection: Axis.horizontal,
        //   physics: BouncingScrollPhysics(),
        //   child:
        //   Row(
        //     children: [

        SafeArea(
      child: Scaffold(
        body: Container(
          // padding: EdgeInsets.symmetric(
          //   horizontal: 20,
          // ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color: Theme.of(context).colorScheme.secondary,size: MediaQuery.of(context).size.width / 18,),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        Text(
                          'About Task',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: MediaQuery.of(context).size.width / 20,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.view_timeline_outlined,
                            color: Theme.of(context).colorScheme.secondary,
                            size: MediaQuery.of(context).size.width / 15,
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  // title: Text('Task Timeline'),
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  child: Container(
                                    // height: MediaQuery.of(context).size.width,
                                    child: TaskTimelineTile(
                                      userId: widget.userId,
                                      taskId: widget.task['id'],
                                    ),
                                  ),
                                  // actions: [
                                  //   TextButton(
                                  //     onPressed: () {
                                  //       Navigator.of(context)
                                  //           .pop(); // Close the dialog
                                  //     },
                                  //     child: Text('Close'),
                                  //   ),
                                  // ],
                                );
                              },
                            );
                          },
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context)
                                .colorScheme
                                .surface
                                .withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 22,
                            offset: Offset(0, 10),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Priority',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                              ),
                            ),
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
                                      width: 180,
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
                                              color:
                                                  _priorityTextColors[index]),
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
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: _selectedPriority != null
                                        ? _priorityColors[_priorityItems
                                            .indexOf(_selectedPriority!)]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  offset: Offset(0, -8),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: _priorityTextColors[_priorityItems
                                        .indexOf(_selectedPriority ??
                                            _priorityItems[0])],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task Progress',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Select Progress',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: List.generate(
                                  _progressItems.length,
                                  (index) => DropdownMenuItem<String>(
                                    value: _progressItems[index],
                                    child: Container(
                                      width: 180,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: _progressColors[index],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      margin: EdgeInsets.all(3),
                                      child: Center(
                                        child: Text(
                                          _progressItems[index],
                                          style: TextStyle(
                                              color:
                                                  _progressTextColors[index]),
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
                                buttonStyleData: ButtonStyleData(
                                  height: 40,
                                  width: 180,
                                  decoration: BoxDecoration(
                                    color: _selectedProgress != null
                                        ? _progressColors[_progressItems
                                            .indexOf(_selectedProgress!)]
                                        : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  offset: Offset(0, -8),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: _progressTextColors[_progressItems
                                        .indexOf(_selectedProgress ??
                                            _progressItems[0])],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task Amount:',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                              ),
                            ),
                            Text(
                              'LKR ${widget.task['amount']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    MediaQuery.of(context).size.width / 22,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 05),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Task Remaining \nBalance:',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    MediaQuery.of(context).size.width / 30,
                              ),
                            ),
                            Text(
                              'LKR ${widget.task['remaining']}',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                                color: (widget.task['remaining'] > 0)
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 10,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Title',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: TitleFontSize,
                          ),
                        ),
                        TextField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.onSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: TitleFontSize,
                          ),
                        ),
                        TextField(
                          controller: _descriptionController,
                          minLines: 3,
                          maxLines: null,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor:
                                Theme.of(context).colorScheme.onSecondary,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 0.5),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 1.0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w300),
                        ),
                        SizedBox(height: 5),
                        Text(
                          "Due Date",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w300,
                            fontSize: TitleFontSize,
                          ),
                        ),
                        GestureDetector(
                          onTap: _showDatePicker,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.onSecondary,
                              borderRadius: BorderRadius.circular(3),
                              border: Border.all(
                                  color: Theme.of(context).colorScheme.surface,
                                  width: 0.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd MMMM yyyy')
                                      .format(_selectedDate),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize: 18),
                                ),
                                Icon(
                                  Icons.event,
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Payment",
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.w300,
                                fontSize:
                                    MediaQuery.of(context).size.width / 25,
                              ),
                            ),
                            DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: Text(
                                  'Select Payment Type',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context).hintColor,
                                  ),
                                ),
                                items: List.generate(
                                  _paymentTyItems.length,
                                  (index) => DropdownMenuItem<String>(
                                    value: _paymentTyItems[index],
                                    child: Container(
                                      width: 200,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: _paymentTyColors[
                                            index], // Set the color based on the index
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                      margin: EdgeInsets.all(3),
                                      // padding: EdgeInsets.all(8),
                                      child: Center(
                                        child: Text(
                                          _paymentTyItems[index],
                                          style: TextStyle(
                                              color:
                                                  _paymentTyTextColors[index]),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                value: _selectedPaymentTy,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentTy = value;
                                    _paymentTy =
                                        _paymentTyItems.indexOf(value!);
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  height: 40,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: _selectedPaymentTy != null
                                        ? _paymentTyColors[_paymentTyItems.indexOf(
                                            _selectedPaymentTy!)] // Set the button color based on the selected item
                                        : Colors.grey[
                                            300], // Default color when no selection
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  offset: Offset(0, -8),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: _paymentTyTextColors[_paymentTyItems
                                        .indexOf(_selectedPaymentTy ??
                                            _paymentTyItems[
                                                0])], // Dynamically set icon color based on selection
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        if (_paymentTy == 1)
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // SizedBox(height: 10),
                              // Text(
                              //   "Advanced Amount",
                              //   style: TextStyle(
                              //     color: Colors.black,
                              //     fontSize: 16,
                              //     fontWeight: FontWeight.w300,
                              //   ),
                              // ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Advanced Amount",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      fontSize:
                                          MediaQuery.of(context).size.width /
                                              25,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Container(
                                    // width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondary,
                                      borderRadius: BorderRadius.circular(3),
                                      border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                          width: 0.5),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                            ],
                          ),
                        if (_paymentTy == 2)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // SizedBox(height: 10),
                              Text(
                                "Paid Amount",
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize:
                                      MediaQuery.of(context).size.width / 25,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Container(
                                // width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary,
                                  borderRadius: BorderRadius.circular(3),
                                  border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      width: 0.5),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Text('Paid Ammount'),
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
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 10),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Colors.red, width: 0.5)),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.020,
                                      color: Colors.red),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: _updateTaskInFirebase,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 50, vertical: 10),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        width: 0.5)),
                                child: Text(
                                  "Update",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.020,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .surface),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    // SingleChildScrollView(
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.center,
    //     children: [
    //       const Text(
    //         'Task Payment\nTimeline',
    //         textAlign: TextAlign.center,
    //         style: TextStyle(color: Colors.white, fontSize: 22),
    //       ),
    //       const SizedBox(height: 8),
    //       SizedBox(
    //         width: MediaQuery.of(context).size.width * 0.65,
    // child: TaskTimelineTile(
    //   userId: widget.userId,
    //   taskId: widget.task['id'],
    // ),
    //       )
    //     ],
    //   ),
    // ),
    //     ],
    //   ),
    // );
    // )
    // ),
  } // Method to update the task in Firebase

  Future<void> _updateTaskInFirebase() async {
    DateTime? advancePaidDate;
    DateTime? paidDate;

    try {
      advanceValue = double.tryParse(_advancedController.text) ?? 0.0;
      paidValue = double.tryParse(_remainingController.text) ?? 0.0;

      print(double.tryParse(_remainingController.text));
      Map<String, dynamic> updatedData = {};

      if (_titleController.text != widget.task['title']) {
        updatedData['title'] = _titleController.text;
      }
      if (_descriptionController.text != widget.task['description']) {
        updatedData['description'] = _descriptionController.text;
      }
      if (_selectedDate !=
          DateFormat('dd MMMM yyyy').parse(widget.task['dueDate'])) {
        updatedData['dueDate'] = Timestamp.fromDate(_selectedDate);
      }
      if (_progress != widget.task['progress']) {
        updatedData['progress'] = _progress;
      }
      if (_paymentTy != widget.task['paymentTy']) {
        updatedData['paymentTy'] = _paymentTy;
      }
      if (_priority != widget.task['priority']) {
        updatedData['priority'] = _priority;
      }
      if (advanceValue != widget.task['advance']) {
        updatedData['advance'] = advanceValue;
        advancePaidDate = DateTime.now();
        updatedData['advancePaidDate'] = advancePaidDate;
      }
      print(paidValue);
      if (paidValue > 0) {
        updatedData['paid'] = paidValue;
        updatedData['remaining'] = 0;
        paidDate = DateTime.now();
        updatedData['paidDate'] = paidDate;
      }
      if (remainingValue != widget.task['remaining']) {
        updatedData['remaining'] = remainingValue;
      }

      if (updatedData.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('AppUser')
            .doc(widget.userId)
            .collection('tasks')
            .doc(widget.task['id'])
            .update(updatedData);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error updating task: $e");
    }
  }
}
