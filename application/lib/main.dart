import 'package:can_scan/Pages/home.dart';
import 'package:flutter/material.dart';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/login.dart';
import 'package:can_scan/Pages/info.dart';
import 'package:can_scan/Pages/splash.dart';
import 'package:can_scan/Pages/stories.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:can_scan/Pages/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyAn6TSXQb1LBLj4DiEUgH_E8aKdfW32l54",
      appId: "1:92358301341:android:4466a7e344328b971f6674",
      projectId: "canscan-proj",
      storageBucket: "canscan-proj.firebasestorage.app",
      messagingSenderId: '',
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFFFE6E6),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF7469B6),
          elevation: 5,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Color(0xFFF2F0EF),
            fontSize: 32,
            fontFamily: 'BaskervvilleSC',
            shadows: [Shadow(offset: Offset(0, 3), blurRadius: 4, color: Color(0xFF000000).withOpacity(0.25))],
            fontWeight: FontWeight.bold,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
      ),
      title: 'CanScan',
      debugShowCheckedModeBanner: false,
      home: SplashScreenWrapper(),
    );
  }
}

class SplashScreenWrapper extends StatefulWidget {
  @override
  _SplashScreenWrapperState createState() => _SplashScreenWrapperState();
}

class _SplashScreenWrapperState extends State<SplashScreenWrapper> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(onSplashFinished: checkSession);
  }

  Future<Widget> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get user session data
      final String? userPhone = prefs.getString('user_phone');
      final String? userUid = prefs.getString('user_uid');
      final String? sessionExpiry = prefs.getString('session_expiry');

      // Check if session exists and is not expired
      if (userPhone != null && userUid != null && sessionExpiry != null) {
        final DateTime expiryDate = DateTime.parse(sessionExpiry);
        final DateTime now = DateTime.now();

        if (now.isBefore(expiryDate)) {
          // Session is valid, go to home page
          print('Valid session found for user: $userPhone');
          return MyHomePage();
        } else {
          // Session expired, clear it
          await prefs.remove('user_phone');
          await prefs.remove('user_uid');
          await prefs.remove('session_expiry');
          print('Session expired');
        }
      }

      // No valid session, go to login page
      return Login();
    } catch (e) {
      print('Error checking session: $e');
      // In case of any errors, default to login page
      return Login();
    }
  }
}