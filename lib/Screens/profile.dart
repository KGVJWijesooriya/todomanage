import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:todomanage/component/theme_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../component/auth.dart';
import 'Auth/Loging.dart';
import 'package:todomanage/component/theme_provider.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final Authservice _authService = Authservice();
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  User? user;
  bool isLoading = true; // To show loading while data is being fetched

  @override
  void initState() {
    super.initState();
    user = _authService.getCurrentUser();
    _fetchUserData(); // Fetch user data on initialization
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('userDetails')
          .doc(user!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _firstNameController.text = userDoc['firstName'] ?? '';
          _lastNameController.text = userDoc['lastName'] ?? '';
          _phoneNumberController.text = userDoc['phoneNumber'] ?? '';
        });
      }
    }
    setState(() {
      isLoading = false; // Set loading to false once data is fetched
    });
  }

  // Save updated user details to Firestore
  Future<void> _saveUserDetails() async {
    if (user != null) {
      CollectionReference users =
          FirebaseFirestore.instance.collection('userDetails');

      await users.doc(user!.uid).set({
        'email': user!.email,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneNumberController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User details saved successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consume ThemeProvider to apply the theme dynamically
    final themeProvider = Provider.of<ThemeProvider>(context);

    // Update the status bar style based on the current theme
    final isDarkMode = themeProvider.themeData.brightness == Brightness.dark;
    return isLoading
        ? Center(
            child:
                CircularProgressIndicator()) // Show loading indicator while fetching data
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(20),
                    padding: EdgeInsets.all(20),
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
                            offset: Offset(0, 6),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Logged in',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.width / 22,
                          ),
                        ),
                        Text(
                          '${user?.email}',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: MediaQuery.of(context).size.width / 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  // First Name Field
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your First Name",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 17,
                            fontWeight: FontWeight.w300),
                      ),
                      TextFormField(
                        controller: _firstNameController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          hintText: "Enter your First Name",
                          hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w300),
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
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Last Name Field
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Last Name",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextFormField(
                        controller: _lastNameController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          hintText: "Enter your Last Name",
                          hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w300),
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
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Phone Number Field
                  Column(
                    spacing: 5,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Phone Number",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 17,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      TextFormField(
                        controller: _phoneNumberController,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary),
                        decoration: InputDecoration(
                          hintText: "Enter your Phone Number",
                          hintStyle: TextStyle(
                              fontSize: 16.0,
                              color: Theme.of(context).colorScheme.secondary,
                              fontWeight: FontWeight.w300),
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
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Save Details Button
                  ElevatedButton(
                    onPressed: () async {
                      await _saveUserDetails();
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, // Text color
                      backgroundColor: Colors.blue, // Button background color
                      minimumSize:
                          const Size(double.infinity, 50), // Width and Height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Border radius
                      ),
                    ),
                    child: const Text('Save Details'),
                  ),
                  const SizedBox(height: 50), Divider(),
                  const SizedBox(height: 50),
                  // Log Out Button
                  // Save Details Button

                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 00, vertical: 10),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          width: 0.2,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),

                      // borderRadius: BorderRadius.circular(8)
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Theme',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 17,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        ToggleSwitch(
                          minWidth: 90.0,
                          cornerRadius: 20.0,
                          activeBgColors: [
                            [Colors.yellowAccent],
                            [Theme.of(context).colorScheme.onSecondary]
                          ],
                          activeFgColor:
                              Theme.of(context).colorScheme.secondary,
                          inactiveBgColor: Colors.grey[300],
                          inactiveFgColor:
                              Theme.of(context).colorScheme.primary,
                          initialLabelIndex: isDarkMode ? 1 : 0,
                          totalSwitches: 2,
                          labels: ['Light', 'Dark'],
                          icons: [Icons.wb_sunny, Icons.nightlight_round],
                          onToggle: (index) {
                            // Toggle the theme mode based on the selected switch
                            Provider.of<ThemeProvider>(context, listen: false)
                                .toggleTheme();
                          },
                          animate: true,
                          curve: Curves.easeInOut,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      await _authService.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const Loging(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, // Text color
                      backgroundColor: Colors.red, // Button background color
                      minimumSize:
                          const Size(double.infinity, 50), // Width and Height
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5), // Border radius
                      ),
                    ),
                    child: const Text('Log Out'),
                  ),
                  const SizedBox(height: 80),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     Provider.of<ThemeProvider>(context, listen: false)
                  //         .toggleTheme();
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     foregroundColor: Colors.white, // Text color
                  //     backgroundColor: Colors.blue, // Button background color
                  //     minimumSize:
                  //         const Size(double.infinity, 50), // Width and Height
                  //     shape: RoundedRectangleBorder(
                  //       borderRadius: BorderRadius.circular(5), // Border radius
                  //     ),
                  //   ),
                  //   child: const Text('Tap'),
                  // ),
                ],
              ),
            ),
          );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }
}
