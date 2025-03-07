import 'package:flutter/material.dart';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/profile.dart';
import 'package:can_scan/Pages/stories.dart';
import 'package:can_scan/Pages/info.dart';

class ResultFalse extends StatelessWidget {
  const ResultFalse({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnosis Result', style: TextStyle(fontFamily: 'BaskervvilleSC')),
        backgroundColor: Color(0xFF7469B6),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  "No Cancer Detected",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
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
                        "Steps that can be Taken:",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          children: [
                            TextSpan(
                              text: "Based on our analysis, there are no signs of cancer, but keep monitoring, and consult a doctor if you notice any changes.\n\n",
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54 ),
                            ),
                            TextSpan(
                              text: "1. Maintain regular health check-ups to monitor any future risks.\n\n"
                                  "2. Protect skin from excessive sun exposure using sunscreen and protective clothing.\n\n"
                                  "3. Follow a healthy lifestyle with a balanced diet and regular exercise.\n\n"
                                  "4. Avoid smoking, excessive alcohol, and other risk factors that may lead to future health issues.\n\n"
                                  "5. Stay informed about early signs and symptoms of cancer for proactive detection.\n\n"
                                  "6. Manage stress through meditation, yoga, or engaging in relaxing activities.",
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40)
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
