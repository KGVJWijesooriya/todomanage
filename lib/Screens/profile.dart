import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../component/auth.dart';
import 'Auth/Loging.dart';

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
  bool isLoading = true;  // To show loading while data is being fetched

  @override
  void initState() {
    super.initState();
    user = _authService.getCurrentUser();
    _fetchUserData();  // Fetch user data on initialization
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('userDetails').doc(user!.uid).get();
      
      if (userDoc.exists) {
        setState(() {
          _firstNameController.text = userDoc['firstName'] ?? '';
          _lastNameController.text = userDoc['lastName'] ?? '';
          _phoneNumberController.text = userDoc['phoneNumber'] ?? '';
        });
      }
    }
    setState(() {
      isLoading = false;  // Set loading to false once data is fetched
    });
  }

  // Save updated user details to Firestore
  Future<void> _saveUserDetails() async {
    if (user != null) {
      CollectionReference users = FirebaseFirestore.instance.collection('userDetails');
      
      await users.doc(user!.uid).set({
        'email': user!.email,
        'firstName': _firstNameController.text,
        'lastName': _lastNameController.text,
        'phoneNumber': _phoneNumberController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details saved successfully!'))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator()) // Show loading indicator while fetching data
        : Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Logged in as: ${user?.email}',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 20),
          // First Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Your First Name",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w300)),
              TextFormField(
                controller: _firstNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your First Name",
                  hintStyle: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  filled: true,
                  fillColor: const Color(0xFF24263a),
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Color(0xFF73FA92), width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Color(0xFF73FA92), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Last Name Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Last Name",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextFormField(
                controller: _lastNameController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your Last Name",
                  hintStyle: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  filled: true,
                  fillColor: const Color(0xFF24263a),
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Color(0xFF73FA92), width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Color(0xFF73FA92), width: 2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          // Phone Number Field
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Phone Number",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w300,
                ),
              ),
              TextFormField(
                controller: _phoneNumberController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter your Phone Number",
                  hintStyle: const TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                  filled: true,
                  fillColor: const Color(0xFF24263a),
                  enabledBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Color(0xFF73FA92), width: 1),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderRadius: BorderRadius.circular(0),
                    borderSide: BorderSide(color: Color(0xFF73FA92), width: 2),
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
              minimumSize: const Size(double.infinity, 50), // Width and Height
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // Border radius
              ),
            ),
            child: const Text('Save Details'),
          ),
          const SizedBox(height: 20),
          // Log Out Button
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
              minimumSize: const Size(double.infinity, 50), // Width and Height
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5), // Border radius
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
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
