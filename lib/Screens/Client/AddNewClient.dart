import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class addNewClients extends StatefulWidget {
  const addNewClients({
    super.key,
  });

  @override
  State<addNewClients> createState() => _addNewClientsState();
}

class _addNewClientsState extends State<addNewClients> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController companyController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController countryCodeController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  String? emailError;
  String? clientNameError;
  String? companyError;
  String? mobileError;
  String? countryCodeError;

  // Regular expression for basic email validation
  final emailRegex = RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  void validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        emailError = "Email cannot be empty";
      } else if (!emailRegex.hasMatch(value)) {
        emailError = "Please enter a valid email address";
      } else {
        emailError = null;
      }
    });
  }

  bool validateInputs() {
    bool isValid = true;

    setState(() {
      clientNameError = titleController.text.trim().isEmpty
          ? "Client name is required"
          : null;
      companyError = companyController.text.trim().isEmpty
          ? "Company name is required"
          : null;
      countryCodeError = countryCodeController.text.trim().isEmpty
          ? "Contry Code is required"
          : null;
      mobileError = mobileController.text.trim().isEmpty
          ? "Mobile number is required"
          : null;
      validateEmail(emailController.text.trim());

      // If any error exists, return false
      isValid = clientNameError == null &&
          companyError == null &&
          mobileError == null &&
          emailError == null;
    });

    return isValid;
  }

  void saveClientData() async {
    if (!validateInputs()) {
      print('Validation failed. Please check your input.');
      return;
    }
    try {
      // Get the logged-in user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Get the country code and mobile number values
      String countryCode = countryCodeController.text.trim();
      String mobileNumber = mobileController.text.trim();

      // Ensure the country code starts with '+' and concatenate with the mobile number
      String fullPhoneNumber = '$countryCode$mobileNumber';

      // Basic validation: Ensure both fields are not empty
      if (countryCode.isEmpty || mobileNumber.isEmpty) {
        print('Please enter a valid country code and mobile number.');
        return; // Stop execution if inputs are invalid
      }

      // Create the client data map
      Map<String, dynamic> clientData = {
        'clientName': titleController.text.trim(),
        'companyName': companyController.text.trim(),
        'mobileNumber': fullPhoneNumber, // Properly formatted number
        'email': emailController.text.trim(),
        'isActive': true,
        'createdAt': Timestamp.now(),
      };

      // Reference to the Firestore collection
      CollectionReference clientsRef = FirebaseFirestore.instance
          .collection('AppUser')
          .doc(userId)
          .collection('client');

      // Save the client data to Firestore
      await clientsRef.add(clientData);

      // Clear fields after saving
      titleController.clear();
      companyController.clear();
      mobileController.clear();
      countryCodeController.clear();
      emailController.clear();

      print('Client data saved successfully!');
    } catch (e) {
      print('Failed to save client data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Client Name",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextField(
            controller: titleController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Add Your Client Name Here',
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              errorText: clientNameError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFF24263a),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Client's Company or Brand Name",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextField(
            controller: companyController,
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Add Your Client's Company or Brand Here",
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              errorText: companyError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFF24263a),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 1.0),
                borderRadius: BorderRadius.circular(3),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 15),
          Text(
            "Client's Mobile Number",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          Row(
            children: [
              // Country Code Input
              Container(
                width:
                    80, // Set the desired width for the country code input
                child: TextField(
                  controller:
                      countryCodeController, // Separate controller for the country code
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(
                        4), // Limit the number of characters
                    FilteringTextInputFormatter.allow(
                        RegExp(r'[\d+]')), // Allow digits and plus symbol
                  ],
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    // Ensure the value starts with '+'
                    if (!value.startsWith('+')) {
                      countryCodeController.text = '+$value';
                      // Move the cursor to the end of the text
                      countryCodeController.selection =
                          TextSelection.fromPosition(
                        TextPosition(
                            offset: countryCodeController.text.length),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "+1",
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    errorText: countryCodeError,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFF24263a),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF73FA92), width: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF73FA92), width: 1.0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8), // Add spacing between fields
              // Mobile Number Input
              Expanded(
                child: TextField(
                  controller: mobileController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Client's Mobile Number",
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    errorText: mobileError,
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Color(0xFF24263a),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF73FA92), width: 0.5),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: const Color(0xFF73FA92), width: 1.0),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.red,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            "Client's Email Address",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
          TextField(
            controller: emailController,
            style: TextStyle(color: Colors.white),
            onChanged: validateEmail, // Real-time validation
            decoration: InputDecoration(
              hintText: "Add Your Client's Email Address Here",
              hintStyle: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              errorText: emailError, // Display error message
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Color(0xFF24263a),
              enabledBorder: OutlineInputBorder(
                borderSide:
                    BorderSide(color: const Color(0xFF73FA92), width: 0.5),
                borderRadius: BorderRadius.circular(3),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.red,
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: emailError != null
                      ? Colors.red
                      : const Color(0xFF73FA92),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: emailError != null
                      ? Colors.red
                      : const Color(0xFF73FA92),
                  width: 2.0,
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          SizedBox(height: 100),
          GestureDetector(
            onTap: () {
              setState(() {
                titleController.clear();
                companyController.clear();
                mobileController.clear();
                emailController.clear();
              });
              print('Clear button tapped');
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF24263a),
                border: Border.all(color: Colors.red, width: 1),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Clear',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ),
          SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              saveClientData();
              print('Save button tapped');
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF73FA92),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                'Create This Client',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF14142B), fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
