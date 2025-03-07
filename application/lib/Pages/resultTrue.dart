import 'package:flutter/material.dart';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/profile.dart';
import 'package:can_scan/Pages/stories.dart';
import 'package:can_scan/Pages/info.dart';

class ResultTrue extends StatelessWidget {
  const ResultTrue({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result', style: TextStyle(fontFamily: 'BaskervvilleSC')),
        backgroundColor: Color(0xFF7469B6),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  "Cancer Detected",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Steps to be Taken:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "1. Confirm diagnosis with an oncologist, biopsy, and imaging tests.\n\n"
                            "2. Determine the type and stage of cancer.\n\n"
                            "3. Explore treatment options like surgery, chemotherapy, radiation, or targeted therapy.\n\n"
                            "4. Maintain a healthy lifestyle with proper diet, exercise, and stress management.\n\n"
                            "5. Plan finances, check insurance coverage, and arrange caregiver support if needed.\n\n"
                            "6. Follow up regularly to monitor progress and prevent recurrence.",
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        shape: const CircularNotchedRectangle(),
        color: Color(0xFFAD88C6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavButton(Icons.auto_stories, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityStoriesPage()));
              }),
              _buildNavButton(Icons.info, () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AboutPage()));
              }),
              SizedBox(width: 0),
              _buildNavButton(Icons.home, () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyHomePage()));
              }),
              _buildNavButton(Icons.person, () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => ProfilePage()));
              }),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CameraApp()));
        },
        backgroundColor: Colors.transparent,
        shape: CircleBorder(),
        elevation: 5,
        child: Image.asset('assets/floating_icon.png'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onPressed) {
    return Material(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Color(0xFF7469B6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Icon(icon, size: 36, color: Colors.white),
        ),
      ),
    );
  }
}
