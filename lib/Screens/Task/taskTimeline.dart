import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeline_tile/timeline_tile.dart';

class TaskTimelineTile extends StatefulWidget {
  final String userId;
  final String taskId;

  const TaskTimelineTile({
    required this.userId,
    required this.taskId,
    super.key,
  });

  @override
  State<TaskTimelineTile> createState() => _TaskTimelineTileState();
}

class _TaskTimelineTileState extends State<TaskTimelineTile> {
  Map<String, dynamic>? taskData;

  @override
  void initState() {
    super.initState();
    fetchTaskData();
  }

  Future<void> fetchTaskData() async {
    // Fetch data from Firestore
    final DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
        .instance
        .collection('AppUser')
        .doc(widget.userId)
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    if (doc.exists) {
      setState(() {
        taskData = doc.data();
      });
    }
  }

  String formatDate(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('dd MMMM hh:mm a')
        .format(dateTime); // Format: 22 November 11:00 AM
  }

  @override
  Widget build(BuildContext context) {
    if (taskData == null) {
      return Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        // Timeline for Amount Paid, if exists
        if (taskData!['paid'] != null && taskData!['paidDate'] != null)
          TimelineTile(
            isFirst: true,
            alignment: TimelineAlign.start,
            indicatorStyle: IndicatorStyle(
              width: 40,
              color:  const Color(0xFF73FA92),
              padding: EdgeInsets.all(6),
              iconStyle: IconStyle(
                iconData: Icons.money,
                fontSize: 18,
              ),
            ),
            endChild: Container(
              color: const Color(0xFF24263A),
              margin: EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance Paid',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Amount: ${taskData!['paid']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    taskData!['paidDate'] != null
                        ? formatDate(taskData!['paidDate'] as Timestamp)
                        : 'Not Paid',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            beforeLineStyle: LineStyle(
              color:  const Color(0xFF73FA92),
              thickness: 4,
            ),
          ),
    
        // Timeline for Advance Paid, if exists
        if (taskData!['advance'] != null &&
            taskData!['advancePaidDate'] != null)
          TimelineTile(
            alignment: TimelineAlign.start,
            indicatorStyle: IndicatorStyle(
              width: 40,
              color:  const Color(0xFF9AC1EF),
              padding: EdgeInsets.all(6),
              iconStyle: IconStyle(
                iconData: Icons.attach_money,
                fontSize: 18,
              ),
            ),
            endChild: Container(
              color: const Color(0xFF24263A),
              margin: EdgeInsets.symmetric(vertical: 20),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Advance Paid: ${taskData!['advance']}',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                  SizedBox(height: 4),
                  Text(
                    formatDate(taskData!['advancePaidDate'] as Timestamp),
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            beforeLineStyle: LineStyle(
              color:  const Color(0xFF9AC1EF),
              thickness: 4,
            ),
          ),
        // Timeline for Task Creation Date
        TimelineTile(
          alignment: TimelineAlign.start,
          isLast: true,
          indicatorStyle: IndicatorStyle(
            width: 40,
            color:  const Color(0xFFA1E448),
            padding: EdgeInsets.all(6),
            iconStyle: IconStyle(
              iconData: Icons.calendar_today,
              fontSize: 18,
            ),
          ),
          endChild: Container(
            color: const Color(0xFF24263A),
            margin: EdgeInsets.symmetric(vertical: 20),
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Created',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ),
                SizedBox(height: 4),
                Text(
                  formatDate(taskData!['createdAt'] as Timestamp),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          beforeLineStyle: LineStyle(
            color:  const Color(0xFFA1E448),
            thickness: 4,
          ),
        ),
      ],
    );
  }
}
