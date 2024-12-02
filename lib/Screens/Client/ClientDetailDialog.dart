import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailDialog extends StatelessWidget {
  final String clientName;
  final String companyName;
  final double unpaidAmount;
  final bool isActive;
  final int remainingTasks;
  final String userId;
  final String email;
  final String MobileNo;

  ClientDetailDialog({
    Key? key,
    required this.clientName,
    required this.companyName,
    required this.unpaidAmount,
    required this.isActive,
    required this.remainingTasks,
    required this.userId,
    required this.email,
    required this.MobileNo,
  }) : super(key: key);
  Future<void> _launchPhone(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'wa.me',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    await launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Color(0xFF14142B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(3),
      ),
      title: Text(
        clientName,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: SizedBox(
        height: MediaQuery.of(context).size.height * 0.45,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 500,
                width: MediaQuery.of(context).size.width / 1.55,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Company',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            companyName,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Unpaid \nAmount',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w300),
                          ),
                          Text(
                            unpaidAmount.toStringAsFixed(2),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Container(
                            width: 100,
                            padding: EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Color(0xFF73FA92)
                                  : Color(0xFFE4602B),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            child: Text(
                              isActive ? 'Active' : 'Inactive',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: isActive
                                      ? Color(0xFF14142B)
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Remaining \nTasks',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 5, horizontal: 15),
                            decoration: BoxDecoration(
                              color: remainingTasks == 0
                                  ? Color(0xFFA1E448)
                                  : Color(0xFFE4602B),
                              borderRadius: BorderRadius.all(
                                Radius.circular(5),
                              ),
                            ),
                            child: Text(
                              '$remainingTasks',
                              style: TextStyle(
                                  color: remainingTasks == 0
                                      ? Color(0xFF14142B)
                                      : Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => _launchPhone(MobileNo),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Color(0xFF24263a),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.phone, size: 30),
                                  Text('Call')
                                ],
                              ),
                              Text(
                                MobileNo,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => _launchWhatsApp(MobileNo),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Color(0xFF24263a),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.chat, size: 30),
                                  Text(
                                    "WhatsApp",
                                    style: TextStyle(fontSize: 9),
                                  )
                                ],
                              ),
                              Text(
                                MobileNo,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: () => _launchEmail(email),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Color(0xFF24263a),
                          ),
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Icon(Icons.email, size: 30),
                                  Text("Email")
                                ],
                              ),
                              Text(
                                email,
                                style: TextStyle(fontSize: 15),
                              )
                            ],
                          ),
                        ),
                      )

                      // SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              // Add StreamBuilder to listen for tasks
              Column(
                children: [
                  Text(
                    'Task Timeline',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w600),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height/2.5,
                    width: 270,
                    margin: EdgeInsets.only(left: 20),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('AppUser')
                          .doc(userId)
                          .collection('tasks')
                          .where('client', isEqualTo: clientName)
                          // .orderBy('createdAt', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No tasks found'));
                        }
              
                        var tasks = snapshot.data!.docs;
                        return ListView.builder(
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            var task =
                                tasks[index].data() as Map<String, dynamic>;
                            // print(task);
                            return TimelineTile(
                              alignment: TimelineAlign.start,
                              isFirst: index == 0,
                              isLast: index == tasks.length - 1,
                              beforeLineStyle: LineStyle(
                                color: Color(0xFF24263a),
                                thickness: 4,
                              ),
                              indicatorStyle: IndicatorStyle(
                                width: 40,
                                color: task['progress'] == 0
                                    ? const Color(0xFFE4602B)
                                    : task['progress'] == 1
                                        ? const Color(0xFF9AC1EF)
                                        : const Color(0xFF73FA92),
                                iconStyle: IconStyle(
                                  iconData: task['progress'] == 0
                                      ? Icons.mood_bad
                                      : task['progress'] == 1
                                          ? Icons.handyman
                                          : Icons.check,
                                  fontSize: 25,
                                ),
                              ),
                              endChild: Container(
                                color: Color(0xFF24263a),
                                margin: EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 10),
                                padding: EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['title'] ?? 'No Title',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
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
                                        borderRadius:
                                            BorderRadius.circular(3),
                                      ),
                                      child: Text(
                                        task['progress'] == 0
                                            ? 'Not Started'
                                            : task['progress'] == 1
                                                ? 'In Progress'
                                                : task['progress'] == 2
                                                    ? 'In Review'
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
                                    SizedBox(height: 5),
                                    Text(
                                      'Created: ${formatDate((task['createdAt'] as Timestamp).toDate())}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    Text(
                                      'Due: ${formatDate((task['dueDate'] as Timestamp).toDate())}',
                                      style: TextStyle(color: Colors.white70),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      'Amount: ${task['amount'].toStringAsFixed(2)}',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Close',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  // Helper method to format the date
  String formatDate(DateTime date) {
    return '${date.day}-${date.month}-${date.year}';
  }
}
