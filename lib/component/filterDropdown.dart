import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class FilterDropdown extends StatefulWidget {
  @override
  _FilterDropdownState createState() => _FilterDropdownState();
}

class _FilterDropdownState extends State<FilterDropdown> {
  // Lists of values for the dropdown items
  final List<String> paidStatus = ['Paid', 'Not Paid', 'Advanced'];
  final List<String> progressStatus = ['Not Started', 'In Progress', 'In Review', 'Done'];

  // Selected items for checkboxes
  List<String> selectedPaidStatus = [];
  List<String> selectedProgressStatus = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF24263a),
      appBar: AppBar(title: Text('Dropdown with Checkboxes')),
      body: Center(
        child: DropdownButtonHideUnderline(
          child: DropdownButton2(
            isExpanded: true,
            hint: Text(
              'Select Filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            items: _buildDropdownItems(),
            value: null, // Use this to set the default selected value if needed
            onChanged: (value) {
              // Handle changes here
            },
            selectedItemBuilder: (context) {
              return _buildSelectedItems();
            },
            buttonStyleData: const ButtonStyleData(
              padding: EdgeInsets.only(left: 16, right: 8),
              height: 40,
              width: 200,
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.zero,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 250,
              decoration: BoxDecoration(
                color: Color(0xFF24263a),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Build the items with checkboxes for dropdown
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
                          setState(() {});
                          menuSetState(() {});
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
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
                      final isSelected = selectedProgressStatus.contains(status);
                      return InkWell(
                        onTap: () {
                          isSelected
                              ? selectedProgressStatus.remove(status)
                              : selectedProgressStatus.add(status);
                          setState(() {});
                          menuSetState(() {});
                        },
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.check_box_outlined
                                    : Icons.check_box_outline_blank,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 16),
                              Text(
                                status,
                                style: const TextStyle(
                                  color: Colors.white,
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

  // Build the selected items (this is optional, you can customize how the selected items appear)
  List<Widget> _buildSelectedItems() {
    return [
      Container(
        alignment: AlignmentDirectional.center,
        child: Text(
          '${selectedPaidStatus.join(', ')} ${selectedProgressStatus.join(', ')}',
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
