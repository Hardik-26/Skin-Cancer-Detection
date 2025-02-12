import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          backgroundColor: Color(0xFFFFE6E6),
          appBar: AppBar(
              title: Text("Home"),
              backgroundColor: Color(0xFF7469B6),
              elevation: 5,
              centerTitle: true,
              titleTextStyle: TextStyle(
                  color: Color(0xFFF2F0EF),
                  fontSize: 32,
                  shadows: [Shadow(offset: Offset(0, 3), blurRadius: 4, color: Color(0xFF000000).withOpacity(0.25))],
                  fontWeight: FontWeight.bold
              )
          )
      );
  }
}
