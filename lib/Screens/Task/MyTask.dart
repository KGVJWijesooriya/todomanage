import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'TaskDetailDialog.dart';

class myTask extends StatefulWidget {
  const myTask({super.key});

  @override
  State<myTask> createState() => _myTaskState();
}

class _myTaskState extends State<myTask> {
  final TextEditingController _searchController = TextEditingController();
  String userId = FirebaseAuth.instance.currentUser!.uid;
  List<Map<String, dynamic>> taskList = [];
  List<Map<String, dynamic>> filteredTaskList = [];
  String selectedSorting = 'Ascending';
  final List<String> paidStatus = ['Paid', 'Not Paid', 'Advanced'];
  final List<String> progressStatus = [
    'Not Started',
    'In Progress',
    'In Review',
    'Done'
  ];

  List<String> selectedPaidStatus = ['Paid', 'Not Paid', 'Advanced'];
  List<String> selectedProgressStatus = [
    'Not Started',
    'In Progress',
    'In Review',
    // 'Done'
  ];

  @override
  void initState() {
    super.initState();
    _fetchTasks();

    _searchController.addListener(() {
      // _filterTasks();
    });
  }

  void _fetchTasks() {
    bool isDescending = selectedSorting == 'Descending';
    FirebaseFirestore.instance
        .collection('AppUser')
        .doc(userId)
        .collection('tasks')
        .orderBy('dueDate', descending: isDescending)
        .snapshots()
        .listen((snapshot) {
      taskList = snapshot.docs.map((doc) {
        DateTime dueDateTime = (doc['dueDate'] as Timestamp).toDate();
        int remainingDays = dueDateTime.difference(DateTime.now()).inDays;

        return {
          'id': doc.id,
          'title': doc['title'],
          'client': doc['client'],
          'dueDate':
              (DateFormat('dd MMMM yyyy').format(dueDateTime)).toString(),
          'remainingDays': remainingDays,
          'description': doc['description'],
          'progress': doc['progress'],
          'paymentTy': doc['paymentTy'],
          'priority': doc['priority'],
          'advance': doc['advance'],
          'amount': doc['amount'],
          'remaining': doc['remaining'],
        };
      }).toList();

      // Apply the filters to the fetched data
      _applyFilters();
    });
  }

  void _applyFilters() {
    setState(() {
      final searchQuery = _searchController.text
          .toLowerCase(); // Convert to lowercase for case-insensitive search

      // Filter tasks based on both selected paid status, progress status, and search query
      filteredTaskList = taskList.where((task) {
        // Convert payment and progress to string labels
        String paymentStatus = task['paymentTy'] == 0
            ? 'Not Paid'
            : task['paymentTy'] == 1
                ? 'Advanced'
                : 'Paid';

        String progressStatus = task['progress'] == 0
            ? 'Not Started'
            : task['progress'] == 1
                ? 'In Progress'
                : task['progress'] == 2
                    ? 'In Review'
                    : 'Done';

        // Check if the task matches the selected filters and search query
        bool matchesFilters = selectedPaidStatus.contains(paymentStatus) &&
            selectedProgressStatus.contains(progressStatus);

        // Check if the task title matches the search query
        bool matchesSearch = task['title'].toLowerCase().contains(searchQuery);

        return matchesFilters && matchesSearch;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: _searchController,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
            decoration: InputDecoration(
              hintText: 'Search Tasks...',
              hintStyle: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Icon(
                  Icons.search,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _applyFilters(); // Reapply filters when search is cleared
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.surface, width: 1.0),
                borderRadius: BorderRadius.circular(16),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary, width: 2.0),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onChanged: (value) {
              _applyFilters(); // Update filters when typing in the search box
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 43,
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface,
                border: Border(
                  bottom: BorderSide(
                    color: Theme.of(context).colorScheme.surface,
                    width: 2.0,
                  ),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  value: selectedSorting,
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                    ),
                  ),
                  buttonStyleData: ButtonStyleData(
                    height: 43,
                    // padding: EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: SizedBox.shrink(), // Hides the dropdown arrow
                  ),
                  style: TextStyle(color: Colors.white),
                  items: ['Ascending', 'Descending'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.sort, // Sort icon on the left
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          SizedBox(width: 8), // Space between icon and text
                          Text(
                            value,
                            style: TextStyle(
                              color: value == selectedSorting
                                  ? Theme.of(context).colorScheme.surface
                                  : Theme.of(context)
                                      .colorScheme
                                      .surface, // Default color for other items
                              fontWeight: value == selectedSorting
                                  ? FontWeight
                                      .bold // Make the selected item bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedSorting = newValue!;
                      _fetchTasks(); // Update task list based on sorting
                    });
                  },
                ),
              ),
            ),
            DropdownButtonHideUnderline(
              child: DropdownButton2(
                isExpanded: true,
                hint: Text(
                  'Filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                iconStyleData: IconStyleData(
                  icon: Icon(Icons.filter_alt),
                  iconEnabledColor: Theme.of(context).colorScheme.secondary,
                ),
                items: _buildDropdownItems(),
                value: null,
                onChanged: (value) {
                  // Apply filters when dropdown value changes
                  _applyFilters();
                },
                selectedItemBuilder: (context) {
                  return _buildSelectedItems();
                },
                buttonStyleData: ButtonStyleData(
                  padding: EdgeInsets.only(left: 16, right: 8),
                  height: 43,
                  width: 100,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).colorScheme.surface,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 180,
                  padding: EdgeInsets.zero,
                ),
                dropdownStyleData: DropdownStyleData(
                  maxHeight: 250,
                  width: 380,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        SingleChildScrollView(
          child: Column(
            children: [
              ...filteredTaskList.map((task) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _buildTaskCard(task, context, userId),
                );
              }).toList(),
              SizedBox(height: 100), // Add 100px space at the end
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(
      Map<String, dynamic> task, BuildContext context, String userId) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                AlertBox(task: task, userId: userId), // Pass userId here
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurface,
              borderRadius: BorderRadius.all(Radius.circular(16)
                  // topLeft: Radius.circular(16),
                  // topRight: Radius.circular(16),
                  ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.0),
                    Color(0xFF73FA92).withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFF73FA92),
                    width: 2.0,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task['title'],
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Task due date: ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          task['dueDate'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Client: ',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          task['client'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Divider(
                      color: Theme.of(context).colorScheme.secondary,
                      thickness: 1,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Task Progress',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: task['progress'] == 0
                                    ? const Color(0xFFE4602B)
                                    : task['progress'] == 1
                                        ? const Color(0xFF9AC1EF)
                                        : task['progress'] == 2
                                            ? const Color(0xFF73FA92)
                                            : const Color(0xFFA1E448),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Text(
                                task['progress'] == 0
                                    ? 'Pending'
                                    : task['progress'] == 1
                                        ? 'Ongoing'
                                        : task['progress'] == 2
                                            ? 'Checking'
                                            : 'Done',
                                style: TextStyle(
                                  color: task['progress'] == 0
                                      ? Colors.white
                                      : task['progress'] == 1
                                          ? Colors.black
                                          : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Payment\nProgress',
                          style: TextStyle(
                            height: 1,
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task['paymentTy'] == 0
                                ? const Color(0xFFE4602B)
                                : task['paymentTy'] == 1
                                    ? const Color(0xFF9AC1EF)
                                    : const Color(0xFF73FA92),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            task['paymentTy'] == 0
                                ? 'Not Paid'
                                : task['paymentTy'] == 1
                                    ? 'Advanced'
                                    : 'Paid',
                            style: TextStyle(
                              color: task['paymentTy'] == 0
                                  ? Colors.white
                                  : task['paymentTy'] == 1
                                      ? Colors.black
                                      : Colors.black,
                              fontWeight: FontWeight.w600,
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
          Positioned(
            bottom: 15,
            right: 10,
            child: Container(
              height: 50,
              width: 100,
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: task['priority'] == 0
                    ? const Color(0xFFFF0000)
                    : const Color(0xFF9AC1EF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Center(
                child: Text(
                  task['priority'] == 0 ? 'Urgent' : 'Normal',
                  style: TextStyle(
                    fontSize: 20,
                    color: task['priority'] == 0 ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          if (task['remainingDays'] > 0)
            Positioned(
              top: 05,
              right: 00,
              child: Container(
                padding: EdgeInsets.only(top: 10, bottom: 5, left: 5, right: 5),
                decoration: BoxDecoration(
                  color: task['remainingDays'] >= 0
                      ? const Color(0xFF73FA92)
                      : const Color(0xFFE4602B),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getRemainingTime(task['remainingDays']),
                      style: TextStyle(
                        height: 0.8,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: task['remainingDays'] >= 0
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    Text(
                      _getRemainingTimeText(task['remainingDays']),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Remaining',
                      style: TextStyle(
                        height: 0.8,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (task['remainingDays'] <= 0)
            Positioned(
              top: 05,
              right: 00,
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE4602B),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      _getRemainingTime(task['remainingDays']),
                      style: TextStyle(
                        height: 0.8,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: task['remainingDays'] > 0
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    Text(
                      _getRemainingTimeText(task['remainingDays']),
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: task['remainingDays'] > 0
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                    Text(
                      'Overdue',
                      style: TextStyle(
                        height: 0.8,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: task['remainingDays'] > 0
                            ? Colors.black
                            : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  String _getRemainingTime(int remainingDays) {
    if (remainingDays >= 0) {
      if (remainingDays == 1) {
        return '1';
      } else if (remainingDays <= 10) {
        return '$remainingDays';
      } else if (remainingDays > 10 && remainingDays <= 30) {
        int remainingWeeks = (remainingDays / 7).ceil();
        return '$remainingWeeks';
      } else if (remainingDays > 30 && remainingDays <= 365) {
        int remainingMonths = (remainingDays / 30).ceil();
        return '$remainingMonths';
      } else {
        int remainingYears = (remainingDays / 365).ceil();
        return '$remainingYears';
      }
    } else {
      int overdueDays = remainingDays.abs();
      if (overdueDays == 1) {
        return '1';
      } else if (overdueDays <= 10) {
        print('overdueDays + $overdueDays');
        return '$overdueDays';
      } else if (overdueDays > 10 && overdueDays <= 30) {
        int overdueWeeks = (overdueDays / 7).ceil();
        print(overdueWeeks);
        print('overdueDays + $overdueDays');

        return '$overdueWeeks';
      } else if (overdueDays > 30 && overdueDays <= 365) {
        int overdueMonths = (overdueDays / 30).ceil();
        return '$overdueMonths';
      } else {
        int overdueYears = (overdueDays / 365).ceil();
        return '$overdueYears';
      }
    }
  }

  String _getRemainingTimeText(int remainingDays) {
    if (remainingDays >= 0) {
      if (remainingDays == 1) {
        return 'Day';
      } else if (remainingDays <= 10) {
        return 'Days';
      } else if (remainingDays > 10 && remainingDays <= 30) {
        int remainingWeeks = (remainingDays / 7).ceil();
        return remainingWeeks == 1 ? 'week' : 'weeks';
      } else if (remainingDays > 30 && remainingDays <= 365) {
        int remainingMonths = (remainingDays / 30).ceil();
        return remainingMonths == 1 ? 'month' : 'months';
      } else {
        int remainingYears = (remainingDays / 365).ceil();
        return remainingYears == 1 ? 'Year' : 'years';
      }
    } else {
      int overdueDays = remainingDays.abs();
      if (overdueDays == 1) {
        return 'Day';
      } else if (overdueDays <= 10) {
        return 'Days';
      } else if (overdueDays > 10 && overdueDays <= 30) {
        int overdueWeeks = (overdueDays / 7).ceil();
        return overdueWeeks == 1 ? 'week' : 'weeks';
      } else if (overdueDays > 30 && overdueDays <= 365) {
        int overdueMonths = (overdueDays / 30).ceil();
        return overdueMonths == 1 ? 'month' : 'months';
      } else {
        int overdueYears = (overdueDays / 365).ceil();
        return overdueYears == 1 ? 'Year' : 'years';
      }
    }
  }

  List<DropdownMenuItem<String>> _buildDropdownItems() {
    return [
      DropdownMenuItem<String>(
        enabled: false,
        child: StatefulBuilder(
          builder: (context, menuSetState) {
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: paidStatus.map((status) {
                      final isSelected = selectedPaidStatus.contains(status);
                      return InkWell(
                        onTap: () {
                          isSelected
                              ? selectedPaidStatus.remove(status)
                              : selectedPaidStatus.add(status);
                          setState(() {}); // Update UI for main widget
                          menuSetState(() {}); // Update UI for dropdown menu
                          _applyFilters(); // Apply filters after selection
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                status,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: progressStatus.map((status) {
                      final isSelected =
                          selectedProgressStatus.contains(status);
                      return InkWell(
                        onTap: () {
                          isSelected
                              ? selectedProgressStatus.remove(status)
                              : selectedProgressStatus.add(status);
                          setState(() {});
                          menuSetState(() {});
                          _applyFilters(); // Apply filters after selection
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box
                                    : Icons.check_box_outline_blank,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                status,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _buildSelectedItems() {
    return [
      Container(
        alignment: AlignmentDirectional.center,
        child: Text(
          'Paid: ${selectedPaidStatus.join(', ')} | Progress: ${selectedProgressStatus.join(', ')}',
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
            overflow: TextOverflow.ellipsis,
          ),
          maxLines: 1,
        ),
      ),
    ];
  }
}
