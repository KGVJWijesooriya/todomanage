import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'TaskCount.dart';

class Mainanalize extends StatefulWidget {
  const Mainanalize({super.key});

  @override
  State<Mainanalize> createState() => _MainanalizeState();
}

class _MainanalizeState extends State<Mainanalize> {
  DateTimeRange? selectedDateRange;
  String selectedWeek = 'Last Week';
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  int selectedYear = DateTime.now().year;

  DateTimeRange? customDateRange;

  String formatDateRange(DateTimeRange range) {
    return '${DateFormat('d MMMM yyyy').format(range.start)} To ${DateFormat('d MMMM yyyy').format(range.end)}';
  }

  final List<String> weekOptions = ['Last Week', '2 Weeks', '3 Weeks'];

  final List<String> monthOptions = List.generate(12, (index) {
    return DateFormat('MMMM')
        .format(DateTime(DateTime.now().year, index + 1, 1));
  });

  final List<int> yearOptions = List.generate(10, (index) {
    return DateTime.now().year - index;
  });

  DateTimeRange getWeekRange(String selectedWeek) {
    final today = DateTime.now();
    int daysBack;
    switch (selectedWeek) {
      case '2 Weeks':
        daysBack = 14;
        break;
      case '3 Weeks':
        daysBack = 21;
        break;
      case 'Last Week':
      default:
        daysBack = 7;
    }
    return DateTimeRange(
        start: today.subtract(Duration(days: daysBack)), end: today);
  }

  DateTimeRange getMonthRange(String selectedMonth) {
    final currentYear = DateTime.now().year;
    final monthIndex = monthOptions.indexOf(selectedMonth) + 1;
    final firstDay = DateTime(currentYear, monthIndex, 1);
    final lastDay = DateTime(currentYear, monthIndex + 1, 0);
    return DateTimeRange(start: firstDay, end: lastDay);
  }

  DateTimeRange getYearRange(int selectedYear) {
    final firstDay = DateTime(selectedYear, 1, 1);
    final lastDay = DateTime(selectedYear, 12, 31);
    return DateTimeRange(start: firstDay, end: lastDay);
  }

  DateTimeRange getInitialDateRange() {
    final today = DateTime.now();
    return DateTimeRange(
        start: today.subtract(const Duration(days: 30)), end: today);
  }

  @override
  void initState() {
    super.initState();

    selectedDateRange = getInitialDateRange();
  }

  void openCustomDateRangePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.onSurface,
          title: const Text('Select Custom Date Range'),
          content: SizedBox(
            height: 400,
            width: 300,
            child: SfDateRangePicker(
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                customDateRange?.start ?? selectedDateRange!.start,
                customDateRange?.end ?? selectedDateRange!.end,
              ),
              backgroundColor: Theme.of(context).colorScheme.background,
              selectionColor: Theme.of(context).colorScheme.secondary,
              startRangeSelectionColor: Theme.of(context).colorScheme.secondary,
              endRangeSelectionColor: Theme.of(context).colorScheme.secondary,
              rangeSelectionColor:
                  Theme.of(context).colorScheme.secondary.withOpacity(0.3),
              todayHighlightColor: Theme.of(context).colorScheme.primary,
              headerStyle: DateRangePickerHeaderStyle(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
              monthCellStyle: DateRangePickerMonthCellStyle(
                textStyle: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                todayTextStyle: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                if (args.value is PickerDateRange) {
                  customDateRange = DateTimeRange(
                    start: args.value.startDate,
                    end: args.value.endDate ?? args.value.startDate,
                  );
                }
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                foregroundColor: Theme.of(context).colorScheme.secondary,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                ),
              ),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (customDateRange != null) {
                    selectedDateRange = customDateRange;
                  }
                });
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                foregroundColor: Theme.of(context).colorScheme.surface,
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  hint: Text(
                    'Select Week',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Set hint text color
                    ),
                  ),
                  value: selectedWeek,
                  items: weekOptions
                      .map((week) => DropdownMenuItem<String>(
                            value: week,
                            child: Center(
                              child: Text(
                                week,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary, // Set item text color
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  buttonStyleData: ButtonStyleData(
                    height: 43,
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
                  iconStyleData: const IconStyleData(
                    icon: SizedBox.shrink(),
                  ),
                  alignment: Alignment.center,
                  onChanged: (value) {
                    setState(() {
                      selectedWeek = value!;
                      selectedDateRange = getWeekRange(selectedWeek);
                    });
                  },
                ),
              ),
              DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  hint: Text(
                    'Select Month',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .secondary, // Set hint text color
                    ),
                  ),
                  value: selectedMonth,
                  items: monthOptions
                      .map((month) => DropdownMenuItem<String>(
                            value: month,
                            child: Center(
                              child: Text(
                                month,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .secondary, // Set item text color
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  buttonStyleData: ButtonStyleData(
                    height: 43,
                    width: 150,
                    padding: EdgeInsets.only(left: 10),
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
                  iconStyleData: const IconStyleData(
                    icon: SizedBox.shrink(),
                  ),
                  alignment: Alignment.center,
                  onChanged: (value) {
                    setState(() {
                      selectedMonth = value!;
                      selectedDateRange = getMonthRange(selectedMonth);
                    });
                  },
                ),
              ),
              // DropdownButtonHideUnderline(
              //   child: DropdownButton2<int>(
              //     hint: const Text('Select Year', textAlign: TextAlign.center),
              //     value: selectedYear,
              //     items: yearOptions
              //         .map((year) => DropdownMenuItem<int>(
              //               value: year,
              //               child: Center(child: Text(year.toString())),
              //             ))
              //         .toList(),
              //     dropdownStyleData: DropdownStyleData(
              //       decoration: BoxDecoration(
              //         color: Color(0xFF24263a),
              //         borderRadius: BorderRadius.circular(8),
              //       ),
              //     ),
              //     buttonStyleData: const ButtonStyleData(
              //       height: 43,
              //       width: 85,
              //       decoration: BoxDecoration(
              //         color: Color(0xFF24263a),
              //         border: Border(
              //           bottom: BorderSide(
              //             color: Color(0xFF73FA92),
              //             width: 2.0,
              //           ),
              //         ),
              //       ),
              //     ),
              //     iconStyleData: const IconStyleData(
              //       icon: SizedBox.shrink(),
              //     ),
              //     alignment: Alignment.center,
              //     onChanged: (value) {
              //       setState(() {
              //         selectedYear = value!;
              //         selectedDateRange = getYearRange(selectedYear);
              //       });
              //     },
              //   ),
              // ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            openCustomDateRangePicker(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            minimumSize: const Size(double.infinity, 50),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(3),
              side: BorderSide(
                color: Theme.of(context).colorScheme.surface,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Custom Range',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.date_range,
                size: 24,
                color: Theme.of(context).colorScheme.surface,
              ),
            ],
          ),
        ),
        if (selectedDateRange != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Text(
              '${formatDateRange(selectedDateRange!)}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
            ),
          ),
        TaskCount(
          selectedDateRange: selectedDateRange!,
        )
      ],
    );
  }
}
