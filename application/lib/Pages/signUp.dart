import 'package:flutter/material.dart';
import 'package:can_scan/Pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:can_scan/Pages/profileQuestions.dart';

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
  TextEditingController phoneController = TextEditingController();
  TextEditingController otpController = TextEditingController();
  bool showOtpField = false;
  bool isLoading = false;
  String _verificationId = '';
  int? _resendToken;

  FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: 20,
        iconTheme: IconThemeData(color: Colors.white),
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
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

      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 10)),
              Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Image.asset('assets/floating_icon.png', height: 130, width: 130)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      firstName = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your First Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    setState(() {
                      phoneNumber = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter your Phone Number',
                    prefixText: '+91 ',  // Add country code prefix for India
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  ),
                ),
              ),
              if (!showOtpField)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => validateAndSendOTP(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Text('Get OTP'),
                    ),
                  ),
                ),
              if (showOtpField) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => verifyOTPAndRegister(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Text('Sign Up'),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: isLoading ? null : () => _resendOTP(),
                  child: Text('Resend OTP'),
                ),
              ],
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void validateAndSendOTP() async {
    if (firstName.isEmpty) {
      showMessage("Enter your First Name!");
      return;
    }
    if (lastName.isEmpty) {
      showMessage("Enter your Last Name!");
      return;
    }
    if (phoneNumber.isEmpty) {
      showMessage("Enter your phone number!");
      return;
    }
    if (phoneNumber.length != 10) {
      showMessage("Phone number must be 10 digits!");
      return;
    }

    // Check if user already exists
    bool exists = await userAlreadyExist(phoneNumber);
    if (exists) {
      showMessage("Phone Number Already Registered");
      return;
    }

    // Proceed with OTP sending
    _sendOTP();
  }

  Future<void> _sendOTP() async {
    try {
      setState(() {
        isLoading = true;
      });

      // Format phone number with country code for Firebase
      String formattedPhoneNumber = '+91' + phoneNumber;

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification on Android
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoading = false;
          });
          if (e.code == 'invalid-phone-number') {
            showMessage("Invalid phone number format");
          } else {
            showMessage("Verification failed: ${e.message}");
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            showOtpField = true;
            isLoading = false;
          });
          showMessage("OTP sent to your phone");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showMessage("Error sending OTP: $e");
    }
  }

  Future<void> _resendOTP() async {
    if (phoneNumber.isEmpty || phoneNumber.length != 10) {
      showMessage("Invalid phone number");
      return;
    }

    setState(() {
      isLoading = true;
    });

    String formattedPhoneNumber = '+91' + phoneNumber;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            isLoading = false;
          });
          showMessage("Verification failed: ${e.message}");
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            isLoading = false;
          });
          showMessage("OTP resent successfully");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        forceResendingToken: _resendToken,
        timeout: Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showMessage("Error resending OTP: $e");
    }
  }

  Future<void> verifyOTPAndRegister() async {
    String otp = otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      showMessage("Please enter valid 6-digit OTP");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _signInWithCredential(credential);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showMessage("Invalid OTP. Please try again.");
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Register user in Firestore
        await registerUser(user.uid);

        setState(() {
          isLoading = false;
        });

        showMessage("Account created! Let's complete your profile.");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => UserQuestionnaire(
                  firstName: firstName,
                  lastName: lastName,
                  phoneNumber: phoneNumber,
                  uid: user.uid,
                )
            )
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      if (e.code == 'invalid-verification-code') {
        showMessage("Invalid OTP code");
      } else {
        showMessage("Authentication failed: ${e.message}");
      }
    }
  }

  Future<void> registerUser([String? uid]) async {
    try {
      // Reference to Firestore collection
      CollectionReference users = FirebaseFirestore.instance.collection('user');

      // User data to be stored
      Map<String, dynamic> userData = {
        "name": firstName,
        "lastName": lastName,
        "number": int.parse(phoneNumber),
        "uid": uid ?? '',  // Store the Firebase Auth UID
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
      throw e;  // Re-throw to handle in calling function
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

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFFCCD2F2),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}