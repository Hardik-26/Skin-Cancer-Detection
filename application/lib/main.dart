import 'package:can_scan/Pages/home.dart';
import 'package:flutter/material.dart';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/login.dart';

void main() {
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
      home: Login(),
    );
  }
}