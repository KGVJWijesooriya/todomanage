import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../component/shimer.dart';
import 'ClientDetailDialog.dart';

class clients extends StatefulWidget {
  final Function(int) onIconPressed;
  const clients({
    super.key,
    required this.onIconPressed,
  });

  @override
  State<clients> createState() => _clientsState();
}

class _clientsState extends State<clients> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> calculateClientStats(
      String clientName, String userId) async {
    // Reference to the tasks collection
    CollectionReference tasksRef = FirebaseFirestore.instance
        .collection('AppUser')
        .doc(userId)
        .collection('tasks');

    // Query for tasks related to the specific client
    QuerySnapshot taskSnapshot =
        await tasksRef.where('client', isEqualTo: clientName).get();

    int remaTasks = 0;
    double unPaidAmount = 0.0;

    // Loop through the tasks and calculate unpaid amount and remaining tasks
    taskSnapshot.docs.forEach((doc) {
      Map<String, dynamic> taskData = doc.data() as Map<String, dynamic>;

      // Check the progress value for remaining tasks (progress less than 2)
      if (taskData['progress'] == 0 ||
          taskData['progress'] == 1 ||
          taskData['progress'] == 2) {
        remaTasks += 1;
      }

      // Calculate unpaid amount (amount - paid)
      double amount = taskData['amount'] ?? 0.0;
      double paid = taskData['paid'] ?? 0.0;
      unPaidAmount += (amount - paid);
    });

    return {
      'remaTasks': remaTasks,
      'unPaidAmount': unPaidAmount,
    };
  }

  @override
  Widget build(BuildContext context) {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the Firestore collection
    CollectionReference clientsRef = FirebaseFirestore.instance
        .collection('AppUser')
        .doc(userId)
        .collection('client');

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Search clients...',
              hintStyle: TextStyle(color: Colors.white),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Color(0xFF24263a),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 2.0),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),

        SizedBox(height: 20),
        GestureDetector(
          onTap: () {
            widget.onIconPressed(5);
            print('Create Client button tapped');
          },
          child: Container(
            padding: EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Color(0xFFF6C445),
              borderRadius: BorderRadius.all(Radius.circular(3)),
            ),
            child: Text(
              ' + Create Client',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                color: const Color(0xFF24263a),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(height: 20),

        Container(
          width: double.infinity,
          height: 700,
          child: StreamBuilder<QuerySnapshot>(
            stream: clientsRef.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Container(
                  padding: EdgeInsets.only(top: 200),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        Icon(
                          Icons.cloud_off,
                          color: Colors.white,
                          size: 32,
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: Shimer.buildShimmerLoading());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Text('No clients found',
                    style: TextStyle(color: Colors.white));
              }

              // Filter clients based on search query
              String searchText = _searchController.text.toLowerCase();
              List<DocumentSnapshot> filteredClients =
                  snapshot.data!.docs.where((doc) {
                Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
                String clientName = (data['clientName'] ?? '').toLowerCase();
                String companyName = (data['companyName'] ?? '').toLowerCase();

                return clientName.contains(searchText) ||
                    companyName.contains(searchText);
              }).toList();

              if (filteredClients.isEmpty) {
                return Text('No clients match your search',
                    style: TextStyle(color: Colors.white));
              }

              return ListView(
                children: filteredClients.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;

                  // Fetch the client statistics (remaTasks and unPaidAmount)
                  return FutureBuilder<Map<String, dynamic>>(
                    future: calculateClientStats(data['clientName'], userId),
                    builder: (context,
                        AsyncSnapshot<Map<String, dynamic>> statsSnapshot) {
                      if (!statsSnapshot.hasData) {
                        return Center(
                            child:
                                Shimer.buildShimmerLoadingforClients(context));
                      }

                      // Extract the calculated values
                      int remaTasks = statsSnapshot.data!['remaTasks'];
                      double unPaidAmount = statsSnapshot.data!['unPaidAmount'];

                      return GestureDetector(
                        onTap: () {
                          // Extract the relevant data fields from 'data'
                          String clientName =
                              data['clientName'] ?? 'Unknown Client';
                          String companyName =
                              data['companyName'] ?? 'Unknown Company';
                          // double unPaidAmount =
                          //     data['unpaidAmount']?.toDouble() ?? 0.0;
                          bool isActive = data['isActive'] ?? false;
                          // int remaTasks = remaTasks;
                          String Email = data['email'];
                          String phoneNo = data['mobileNumber'];

                          // Show the detail dialog when the container is tapped
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ClientDetailDialog(
                                clientName: clientName,
                                companyName: companyName,
                                unpaidAmount: unPaidAmount.toDouble(),
                                isActive: isActive,
                                remainingTasks: remaTasks, userId: userId,
                                email: Email, MobileNo: phoneNo,
                                // tasks: statsSnapshot.data, // Pass the task list here
                              );
                            },
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFF24263a),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(5),
                                  topRight: Radius.circular(5),
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF24263a).withOpacity(0.0),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        data['clientName'] ?? 'Unknown Client',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        data['companyName'] ??
                                            'Unknown Company',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Divider(
                                        color: Colors.white54,
                                        thickness: 1,
                                      ),
                                      SizedBox(height: 8),
                                      Container(
                                        width: 100,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: data['isActive'] == true
                                              ? Color(0xFF73FA92)
                                              : Color(0xFFE4602B),
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        child: Text(
                                          data['isActive'] == true
                                              ? 'Active'
                                              : 'Inactive',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: data['isActive'] == true
                                                ? Colors.black
                                                : Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: Container(
                                height: 60,
                                width: 150,
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'Unpaid Amount',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    Text(
                                      '${unPaidAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 22,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 0,
                              child: Container(
                                padding: EdgeInsets.only(
                                    top: 10, bottom: 5, left: 5, right: 5),
                                decoration: BoxDecoration(
                                  color: remaTasks == 0
                                      ? const Color(0xFFA1E448)
                                      : const Color(0xFFE4602B),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(5),
                                    topRight: Radius.circular(5),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '$remaTasks',
                                      style: TextStyle(
                                        height: 0.8,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: remaTasks == 0
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Task',
                                      style: TextStyle(
                                        fontSize: 19,
                                        fontWeight: FontWeight.bold,
                                        color: remaTasks == 0
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                    Text(
                                      'Remaining',
                                      style: TextStyle(
                                        height: 0.8,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: remaTasks == 0
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              );
            },
          ),
        ),
      ],
    );
  }
}
