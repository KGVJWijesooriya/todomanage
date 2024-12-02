import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TaskCount extends StatefulWidget {
  final DateTimeRange selectedDateRange;

  const TaskCount({super.key, required this.selectedDateRange});

  @override
  State<TaskCount> createState() => _TaskCountState();
}

class _TaskCountState extends State<TaskCount> {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  int totalTasks = 0;
  int notStartedTasks = 0;
  int inProgressTasks = 0;
  int inReviewTasks = 0;
  int doneTasks = 0;

  List<TaskStatusData> taskStatusData = [];

  @override
  void initState() {
    super.initState();
    _fetchTaskData();
  }

  @override
  void didUpdateWidget(covariant TaskCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDateRange != widget.selectedDateRange) {
      _fetchTaskData();
    }
  }

  Future<void> _fetchTaskData() async {
    final DateTime startDate = widget.selectedDateRange.start;
    final DateTime endDate = widget.selectedDateRange.end;

    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance
        .collection('AppUser')
        .doc(userId)
        .collection('tasks')
        .where('createdAt', isGreaterThanOrEqualTo: startDate)
        .where('createdAt', isLessThanOrEqualTo: endDate)
        .get();

    int total = 0;
    int notStarted = 0;
    int inProgress = 0;
    int inReview = 0;
    int done = 0;

    for (var task in tasksSnapshot.docs) {
      total++;
      int progress = task['progress'] ?? 0;

      switch (progress) {
        case 0:
          notStarted++;
          break;
        case 1:
          inProgress++;
          break;
        case 2:
          inReview++;
          break;
        case 3:
          done++;
          break;
        default:
          notStarted++;
      }
    }

    setState(() {
      totalTasks = total;
      notStartedTasks = notStarted;
      inProgressTasks = inProgress;
      inReviewTasks = inReview;
      doneTasks = done;

      taskStatusData = [
        TaskStatusData('Pending', notStartedTasks, Colors.red),
        TaskStatusData('Ongoing', inProgressTasks, Colors.blue),
        TaskStatusData('Checking', inReviewTasks, Colors.yellow),
        TaskStatusData('Done', doneTasks, const Color(0xFF73FA92)),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          decoration: BoxDecoration(
            color: Color(0xFF24263a),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTaskCountBanner(
                upperText: '$totalTasks',
                lowerText: 'Total',
                upperTextColor: Colors.white,
                lowerTextColor: Colors.grey,
                containerColor: Colors.white,
              ),
              _buildTaskCountBanner(
                upperText: '$notStartedTasks',
                lowerText: 'Pending',
                upperTextColor: Colors.white,
                lowerTextColor: Colors.grey,
                containerColor: Colors.red,
              ),
              _buildTaskCountBanner(
                upperText: '$inProgressTasks',
                lowerText: 'Ongoing',
                upperTextColor: Colors.white,
                lowerTextColor: Colors.grey,
                containerColor: Colors.blue,
              ),
              _buildTaskCountBanner(
                upperText: '$inReviewTasks',
                lowerText: 'Checking',
                upperTextColor: Colors.white,
                lowerTextColor: Colors.grey,
                containerColor: Colors.yellow,
              ),
              _buildTaskCountBanner(
                upperText: '$doneTasks',
                lowerText: 'Done',
                upperTextColor: Colors.white,
                lowerTextColor: Colors.grey,
                containerColor: const Color(0xFF73FA92),
              ),
            ],
          ),
        ),
        SfCartesianChart(
          primaryXAxis: CategoryAxis(),
          title: ChartTitle(text: 'Task Status Overview'),
          legend: Legend(isVisible: true),
          tooltipBehavior: TooltipBehavior(enable: true),
          series: <ColumnSeries<TaskStatusData, String>>[
            ColumnSeries<TaskStatusData, String>(
              dataSource: taskStatusData,
              xValueMapper: (TaskStatusData data, _) => data.status,
              yValueMapper: (TaskStatusData data, _) => data.count,
              pointColorMapper: (TaskStatusData data, _) => data.color,
              name: 'Tasks',
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(5),
                topRight: Radius.circular(5),
              ),
              dataLabelSettings: DataLabelSettings(isVisible: true),
            )
          ],
        ),
      ],
    );
  }

  Widget _buildTaskCountBanner({
    required String upperText,
    required String lowerText,
    required Color upperTextColor,
    required Color lowerTextColor,
    required Color containerColor,
  }) {
    return Container(
      width: 70,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF14142B),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            upperText,
            style: TextStyle(color: containerColor, fontSize: 20),
          ),
          Text(
            lowerText,
            textAlign: TextAlign.center,
            style: TextStyle(color: lowerTextColor, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class TaskStatusData {
  final String status;
  final int count;
  final Color color;

  TaskStatusData(this.status, this.count, this.color);
}
