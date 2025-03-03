import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/signUp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  _login createState() => _login();
}

class _login extends State<Login> {
  // Variables to store input
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
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
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 80,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
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

      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.symmetric(vertical: 25)),
              Padding(
                  padding: const EdgeInsets.only(bottom: 70),
                  child: Image.asset('assets/floating_icon.png', height: 130, width: 130)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
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
                    onPressed: isLoading ? null : () => _sendOTP(),
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
                    controller: _otpController,
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
                    onPressed: isLoading ? null : () => _verifyOTP(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      child: Text('Verify OTP'),
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

  Future<void> _sendOTP() async {
    String phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isEmpty) {
      showMessage("Enter your phone number!");
      return;
    }

    if (phoneNumber.length != 10) {
      showMessage("Phone number must be 10 digits!");
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      // Check if user exists in Firestore
      bool exists = await userExists(phoneNumber);

      if (!exists) {
        showMessage("Not a Registered User. Sign Up!!");
        setState(() {
          isLoading = false;
        });
        return;
      }

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
    String phoneNumber = _phoneController.text.trim();
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

  Future<void> _verifyOTP() async {
    String otp = _otpController.text.trim();

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
        // Create user session
        await createUserSession(_phoneController.text.trim());

        setState(() {
          isLoading = false;
        });

        showMessage("Login Successful!");
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
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

  // Creates a user session that lasts for 10 days
  Future<void> createUserSession(String phoneNumber) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save the login time and phone number
      final DateTime now = DateTime.now();
      final DateTime expiryDate = now.add(Duration(days: 10));

      await prefs.setString('user_phone', phoneNumber);
      await prefs.setString('user_uid', _auth.currentUser?.uid ?? '');
      await prefs.setString('session_expiry', expiryDate.toIso8601String());

      print('Session created successfully until: $expiryDate');
    } catch (e) {
      print('Error creating session: $e');
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

  Future<bool> userExists(String phoneNumber) async {
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