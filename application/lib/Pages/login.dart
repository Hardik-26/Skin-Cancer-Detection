import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/signUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class Login extends StatefulWidget  {
  const Login({super.key});
  @override
  _login createState() => _login();
}

class _login extends State<Login>  {
  // Variables to store input
  String phoneNumber = '';
  List<TextEditingController> otpControllers = List.generate(4, (index) => TextEditingController());
  List<FocusNode> otpFocusNodes = List.generate(4, (index) => FocusNode());
  bool showOtpFields = false;
  int generatedOTP = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80, // Increases the height of the AppBar
        titleSpacing: 20, // Adds spacing to the title
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10), // Adds space from top and bottom
          child: Text(
            'Login',
            style: TextStyle(fontFamily: 'BaskervvilleSC'),
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        shape: const CircularNotchedRectangle(),
        color: Color(0xFFAD88C6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => Signup()));
              },
              child: Text(
                "Don't Have An Account? Sign Up",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),

      body:
      Column(
        mainAxisAlignment: MainAxisAlignment.start ,
        children: [
          Padding(padding: const EdgeInsets.symmetric(vertical: 25)),
          Padding(
            padding: const EdgeInsets.only(bottom: 70),
            child: Image.asset('assets/floating_icon.png',height: 130,width: 130)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  phoneNumber = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter your Phone Number',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () {
                if (phoneNumber.isEmpty) {
                  showMessage("Enter your phone number!");
                  return;
                }
                if (phoneNumber.length != 10) {
                  showMessage("Phone number must be 10 digits!");
                  return;
                }
                performLogin(phoneNumber);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text('Get OTP'),
              ),
            ),
          ),
          if (showOtpFields)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: SizedBox(
                  width: 50,
                  child: TextField(
                    controller: otpControllers[index],
                    focusNode: otpFocusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 3) {
                        FocusScope.of(context).requestFocus(otpFocusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context).requestFocus(otpFocusNodes[index - 1]);
                      }
                    },
                  ),
                ),
              )),
            ),
          if (showOtpFields)
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  verifyOTP();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Text('Verify OTP'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Example login function
  void performLogin(String phoneNumber) async {
    try {
      bool exists = await userExists(phoneNumber);

      if (exists) {
        generatedOTP = generateOTP();
        setState(() {
          showOtpFields = true;
        });
        print('Phone Number: $phoneNumber');
        print('Generated OTP: $generatedOTP');
      } else {
        showMessage("Not a Registered User. Sign Up!!");
        return;
      }
    } catch (e) {
      print('Error during login: $e');
    }
  }

  int generateOTP() {
    Random random = Random();
    return 1000 + random.nextInt(9000); // Ensures a 4-digit number
  }

  // Function to verify OTP input
  void verifyOTP() {
    String enteredOTP = otpControllers.map((controller) => controller.text).join();

    if (enteredOTP.isEmpty || enteredOTP.length < 4) {
      showMessage("Enter the OTP!");
      return;
    }

    if (int.tryParse(enteredOTP) == generatedOTP) {
      showMessage("Login Successfully!");
      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } else {
      showMessage("Incorrect OTP,  try again!");
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black,  // Text color
            fontSize: 16,         // Increased text size
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFCCD2F2),  // Background color #ccd2f2
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Makes it appear above the bottom navbar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
      ),
    );
  }

  Future<bool> userExists(String phoneNumber) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('user');

      // Query Firestore to check if a document with the given phone number exists
      QuerySnapshot querySnapshot = await users.where('number', isEqualTo: int.parse(phoneNumber)).get();

      // If any document is found, the user already exists
      print(querySnapshot.docs);
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking user existence: $e");
      return false; // Assume user doesn't exist in case of error
    }
  }
}