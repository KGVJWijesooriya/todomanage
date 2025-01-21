import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:popover/popover.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:dropdown_button2/dropdown_button2.dart';

class addNewTask extends StatefulWidget {
  const addNewTask({super.key});

  @override
  State<addNewTask> createState() => _addNewTaskState();
}

class _addNewTaskState extends State<addNewTask> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController _amountController =
      TextEditingController(text: '00.00');
  final TextEditingController _advancedController =
      TextEditingController(text: '00.00');
  final TextEditingController _paidController =
      TextEditingController(text: '00.00');

  String userId = FirebaseAuth.instance.currentUser!.uid;
  int selectedPay = 0;
  int priority = 1;
  List<Map<String, String>> clients = [];
  String? selectedValue;
  TextEditingController textEditingController = TextEditingController();

  DateTime? _selectedDate;
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _speechAvailable = false;
  String _selectedLanguage = "en-US";
  final Map<String, String> _languageOptions = {
    "English": "en-US",
    "Sinhala": "si-LK",
  };
  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeechToText();
    fetchClientNames();
  }

  Future<void> fetchClientNames() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('AppUser')
          .doc(userId)
          .collection('client')
          .get();

      List<Map<String, String>> clientList = querySnapshot.docs.map((doc) {
        String clientName = doc['clientName'];
        String companyName = doc['companyName'];
        return {
          'clientName': clientName,
          'companyName': companyName,
        };
      }).toList();

      setState(() {
        clients = clientList;
      });
    } catch (e) {
      print('Error fetching client names: $e');
    }
  }

  Future<void> _initSpeechToText() async {
    var status = await Permission.microphone.request();

    if (status.isGranted) {
      bool available = await _speech.initialize(
        onStatus: (status) {
          if (status == "notListening") {
            setState(() {
              _isListening = false;
            });
          }
        },
        onError: (error) {
          print('Speech recognition error: ${error.errorMsg}');
          setState(() {
            _isListening = false;
          });
        },
      );

      print('Speech-to-Text available: $available');
      setState(() {
        _speechAvailable = available;
      });
    } else if (status.isPermanentlyDenied) {
      openAppSettings(); // Open app settings for manual permission.
    } else {
      print('Microphone permission denied');
      setState(() {
        _speechAvailable = false;
      });
    }
  }

  void _startListening(TextEditingController controller) async {
    if (_speechAvailable && !_isListening) {
      try {
        setState(() {
          _isListening = true;
        });
        await _speech.listen(
          onResult: (val) {
            setState(() {
              controller.text += val.recognizedWords; // Appends text.
            });
          },
          localeId: _selectedLanguage, // Specify locale if needed.
        );
      } catch (e) {
        print('Error while starting listening: $e');
        setState(() {
          _isListening = false;
        });
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() {
        _isListening = false;
      });
      _speech.stop();
    }
  }

  void _onDateSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      _selectedDate = args.value;
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('d MMMM y').format(date);
  }

  void _openDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(3),
          ),
          child: Container(
            margin: EdgeInsets.all(20),
            height: 350,
            width: 350,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.single,
              onSelectionChanged: _onDateSelectionChanged,
              initialSelectedDate: _selectedDate,
              backgroundColor: Theme.of(context).colorScheme.onSecondary,
              selectionColor: Theme.of(context).colorScheme.surface,
              todayHighlightColor: Theme.of(context).colorScheme.surface,
              headerStyle: DateRangePickerHeaderStyle(
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                todayTextStyle: TextStyle(
                    color: Theme.of(context).colorScheme.surface,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Task Title",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextField(
            controller: titleController,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            decoration: InputDecoration(
              hintText: 'Add Your Task Title Here',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w300,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  // Handle the mic tap action (start/stop listening)
                  if (_isListening) {
                    _stopListening();
                  } else {
                    _startListening(titleController);
                  }
                },
                onLongPress: () async {
                  // Get the width of the screen to position the menu at the right corner
                  final RenderBox renderBox =
                      context.findRenderObject() as RenderBox;
                  final position = renderBox.localToGlobal(Offset.zero);
                  final screenWidth = MediaQuery.of(context).size.width;

                  // Show the PopupMenuButton manually at the right corner
                  await showMenu<String>(
                    color: Theme.of(context).colorScheme.primary,
                    context: context,
                    position: RelativeRect.fromLTRB(
                      screenWidth -
                          50, // Right corner, adjust based on padding or size of the icon
                      position.dy + 40, // Below the mic icon
                      0,
                      0,
                    ),
                    items: _languageOptions.entries.map((entry) {
                      return PopupMenuItem<String>(
                        value: entry.value,
                        child: ListTile(
                          title: Text(
                            entry.key,
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          onTap: () {
                            setState(() {
                              _selectedLanguage = entry.value;
                            });
                            Navigator.pop(context); // Close the popover
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
                child: Icon(
                  _isListening ? Icons.mic_off : Icons.mic,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface, width: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface, width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),

          SizedBox(height: 10),
          Text(
            "Task Description",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          Stack(
            children: [
              TextField(
                controller: descriptionController,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.secondary),
                minLines: 3,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Add Your Task Description here',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w300,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.onSecondary,
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
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () {
                    // Handle the mic tap action (start/stop listening)
                    if (_isListening) {
                      _stopListening();
                    } else {
                      _startListening(descriptionController);
                    }
                  },
                  onLongPress: () async {
                    // Get the width of the screen to position the menu at the right corner
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final position = renderBox.localToGlobal(Offset.zero);
                    final screenWidth = MediaQuery.of(context).size.width;

                    // Show the PopupMenuButton manually at the right corner
                    await showMenu<String>(
                      color: Theme.of(context).colorScheme.primary,
                      context: context,
                      position: RelativeRect.fromLTRB(
                        screenWidth -
                            50, // Right corner, adjust based on padding or size of the icon
                        position.dy + 40, // Below the mic icon
                        0,
                        0,
                      ),
                      items: _languageOptions.entries.map((entry) {
                        return PopupMenuItem<String>(
                          value: entry.value,
                          child: ListTile(
                            title: Text(
                              entry.key,
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedLanguage = entry.value;
                              });
                              Navigator.pop(context); // Close the popover
                            },
                          ),
                        );
                      }).toList(),
                    );
                  },
                  child: Icon(
                    _isListening ? Icons.mic_off : Icons.mic,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                // IconButton(
                //   icon: Icon(
                //     _isListening ? Icons.mic_off : Icons.mic,
                //     color: Theme.of(context).colorScheme.secondary,
                //   ),
                //   onPressed: () {
                //     if (_isListening) {
                //       _stopListening();
                //     } else {
                //       _startListening(descriptionController);
                //     }
                //   },
                // ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Priority',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        priority = 0;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding: EdgeInsets.symmetric(
                        horizontal: priority == 0
                            ? MediaQuery.of(context).size.width / 6
                            : MediaQuery.of(context).size.width / 9,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: priority == 0
                            ? const Color(0xFFE4602B)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Urgent',
                        style: TextStyle(
                            color: priority == 0
                                ? Theme.of(context).colorScheme.secondary
                                : Colors.black,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        priority = 1;
                      });
                    },
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 500),
                      padding: EdgeInsets.symmetric(
                        horizontal: priority == 1
                            ? MediaQuery.of(context).size.width / 6
                            : MediaQuery.of(context).size.width / 9,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: priority == 1
                            ? const Color(0xFF9AC1EF)
                            : Colors.grey,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        'Normal',
                        style: TextStyle(
                            color: priority == 0
                                ? Colors.black
                                : Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            "Due Date",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          // SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              _openDatePicker(context);
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                    color: Theme.of(context).colorScheme.surface, width: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? '${_formatDate(_selectedDate!)}'
                        : 'No Date Selected',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16),
                  ),
                  Icon(
                    Icons.event,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Task Amount",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                  color: Theme.of(context).colorScheme.surface, width: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add Your Task Ammount'),
                Container(
                  width: 100,
                  child: TextField(
                    controller: _amountController,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
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
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSecondary,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 0.5,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2<String>(
                isExpanded: true,
                hint: Text(
                  'Select Client',
                  style: TextStyle(
                    fontSize: 17,
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                items: clients
                    .map((client) => DropdownMenuItem<String>(
                          value: client['clientName'],
                          child: Text(
                            '${client['clientName']} (${client['companyName']})',
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary, // Updated text color
                            ),
                          ),
                        ))
                    .toList(),
                value: selectedValue,
                onChanged: (value) {
                  setState(() {
                    selectedValue = value;
                  });
                },
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  height: 40,
                  width: 200,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                menuItemStyleData: MenuItemStyleData(
                  height: 40,
                  // textStyle: TextStyle(
                  //   fontSize: 14,
                  //   color: Theme.of(context).colorScheme.secondary, // Updated text color
                  // ),
                ),
                dropdownSearchData: DropdownSearchData(
                  searchController: textEditingController,
                  searchInnerWidgetHeight: 50,
                  searchInnerWidget: Container(
                    height: 50,
                    padding: const EdgeInsets.only(
                      top: 8,
                      bottom: 4,
                      right: 8,
                      left: 8,
                    ),
                    child: TextFormField(
                      expands: true,
                      maxLines: null,
                      controller: textEditingController,
                      style: TextStyle(
                        color: Theme.of(context)
                            .colorScheme
                            .secondary, // Updated text color
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        hintText: 'Search Client...',
                        hintStyle: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .secondary, // Updated text color
                        ),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.primary,
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.surface,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  searchMatchFn: (item, searchValue) {
                    return item.value
                        .toString()
                        .toLowerCase()
                        .contains(searchValue.toLowerCase());
                  },
                ),
                onMenuStateChange: (isOpen) {
                  if (!isOpen) {
                    textEditingController.clear();
                  }
                },
              ),
            ),
          ),

          SizedBox(height: 10),
          Text(
            'Payment',
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPay = 0;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 14,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPay == 0
                        ? const Color(0xFFE4602B)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Not Recived'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPay = 1;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 14,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPay == 1
                        ? const Color(0xFF9AC1EF)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Advance'),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedPay = 2;
                  });
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width / 14,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: selectedPay == 2
                        ? const Color(0xFF73FA92)
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text('Paid'),
                ),
              ),
            ],
          ),
          if (selectedPay == 1)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  "Advanced Amount",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSecondary,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Color(0xFF73FA92)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Task Advanced Ammount'),
                      Container(
                        width: 100,
                        child: TextField(
                          controller: _advancedController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
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
          if (selectedPay == 2)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  "Paid Amount",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSecondary,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: Color(0xFF73FA92)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Task Paid Ammount'),
                      Container(
                        width: 100,
                        child: TextField(
                          controller: _paidController,
                          keyboardType:
                              TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.allow(
                              RegExp(r'^\d+\.?\d{0,2}'),
                            ),
                          ],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
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
          SizedBox(height: 40),
          GestureDetector(
            onTap: () {
              setState(() {
                titleController.clear();
                descriptionController.clear();
                _amountController.clear();
                _advancedController.clear();
                _paidController.clear();
                selectedPay = 0;
              });
              print('Clear button tapped');
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSecondary,
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Clear',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              String title = titleController.text.trim();
              String description = descriptionController.text.trim();
              String? client = selectedValue;
              DateTime? dueDate = _selectedDate;
              String amount = _amountController.text.trim();
              String advance = _advancedController.text.trim();
              String paid = _paidController.text.trim();

              if (title.isEmpty ||
                  description.isEmpty ||
                  client == null ||
                  dueDate == null ||
                  amount.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Please fill all the fields")),
                );
                return;
              }

              // Parse the numeric values
              double parsedAmount = double.tryParse(amount) ?? 0.0;
              double parsedAdvance = double.tryParse(advance) ?? 0.0;
              double parsedPaid = double.tryParse(paid) ?? 0.0;

              // Check if amount, advance, and paid are greater than 0, and capture their respective timestamps
              DateTime? amountPaidDate;
              DateTime? advancePaidDate;
              DateTime? paidDate;

              if (parsedAmount > 0) {
                amountPaidDate = DateTime.now();
              }
              if (parsedAdvance > 0) {
                advancePaidDate = DateTime.now();
              }
              if (parsedPaid > 0) {
                paidDate = DateTime.now();
              }

              Map<String, dynamic> taskData = {
                'title': title,
                'description': description,
                'priority': priority,
                'progress': 0,
                'client': client,
                'dueDate': dueDate,
                'paymentTy': selectedPay,
                'amount': parsedAmount,
                'advance': parsedAdvance,
                'paid': parsedPaid,
                'remaining': parsedAmount - (parsedAdvance + parsedPaid),
                'createdAt': FieldValue.serverTimestamp(),
                'amountPaidDate': amountPaidDate,
                'advancePaidDate': advancePaidDate,
                'paidDate': paidDate,
              };

              try {
                await FirebaseFirestore.instance
                    .collection('AppUser')
                    .doc(userId)
                    .collection('tasks')
                    .add(taskData);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Task created successfully")),
                );

                titleController.clear();
                descriptionController.clear();
                _amountController.text = '00.00';
                setState(() {
                  selectedValue = null;
                  _selectedDate = null;
                });
              } catch (e) {
                print('Error creating task: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Failed to create task")),
                );
              }
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF73FA92),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Create This Task',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF14142B), fontSize: 18),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom > 0 ? 100 : 10,
          ),
        ],
      ),
    );
  }
}
