import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:can_scan/Pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});
  @override
  _signUp createState() => _signUp();
}

class _signUp extends State<Signup> {
  // Variables to store input
  String firstName = '';
  String lastName = '';
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
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10), // Adds space from top and bottom
          child: Text(
            'Sign Up',
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
                Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
              },
              child: Text(
                "Already Have An Account? Login",
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
              padding: const EdgeInsets.only(bottom: 50),
              child: Image.asset('assets/floating_icon.png',height: 130,width: 130)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  firstName = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter your First Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  lastName = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Enter your Last Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
            ),
          ),
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
                if (firstName.isEmpty && lastName.isEmpty  && phoneNumber.isEmpty ) {
                  showMessage("Enter all fields!");
                  return;
                }
                if (firstName.isEmpty) {
                  showMessage(" Enter your First Name!");
                  return;
                }
                if (lastName.isEmpty) {
                  showMessage(" Enter your Last Name!");
                  return;
                }
                if (phoneNumber.isEmpty) {
                  showMessage(" Enter your phone number!");
                  return;
                }
                if (phoneNumber.length != 10) {
                  showMessage("Phone number must be 10 digits!");
                  return;
                }
                performSignUp(firstName, lastName, phoneNumber);
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
                  registerUser();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  child: Text('Sign Up'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Example signup function
  void performSignUp(String firstName, String lastName, String phoneNumber) async {
    try {
      bool exists = await userAlreadyExist(phoneNumber);

      if (exists) {
        showMessage("Phone Number Already Registered");
        return;
      } else {
        setState(() {
          showOtpFields = true;
        });
        generatedOTP = generateOTP();
        print('First: $firstName');
        print('Last: $lastName');
        print('Phone Number: $phoneNumber');
        print('Generated OTP: $generatedOTP');
      }
    } catch (e) {
      print('Error during Sign Up: $e');
    }
  }

  int generateOTP() {
    Random random = Random();
    return 1000 + random.nextInt(9000); // Ensures a 4-digit number
  }

  // Function to verify OTP input
  Future<void> verifyOTP() async {
    String enteredOTP = otpControllers.map((controller) => controller.text).join();

    if (enteredOTP.isEmpty || enteredOTP.length < 4) {
      showMessage("Enter the OTP!");
      return;
    }

    if (int.tryParse(enteredOTP) == generatedOTP) {
      showMessage("Signed Up Successfully!");
    } else {
      showMessage("Incorrect OTP, try again!");
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

  Future<void> registerUser() async {
    try {
      // Reference to Firestore collection
      CollectionReference users = FirebaseFirestore.instance.collection('user');

      // User data to be stored
      Map<String, dynamic> userData = {
        "name": firstName,
        "lastName": lastName,
        "number": phoneNumber,
        "age": null,
        "cancer_history": null,
        "drinks": null,
        "fitzpatrick": null,
        "gender": null,
        "has_piped_water": null,
        "has_sewage_system": null,
        "pesticide_exposore": null,
        "skin_cancer_history": null,
        "smokes": null
      };

      // Add user data to Firestore
      await users.add(userData);

      print("User registered successfully!");
    } catch (e) {
      print("Error registering user: $e");
    }
  }

  Future<bool> userAlreadyExist(String phoneNumber) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('user');

      // Query Firestore to check if a document with the given phone number exists
      QuerySnapshot querySnapshot = await users.where('number', isEqualTo: int.parse(phoneNumber)).get();

      // If any document is found, the user already exists
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print("Error checking user existence: $e");
      return false; // Assume user doesn't exist in case of error
    }
  }
}