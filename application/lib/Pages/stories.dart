import 'package:flutter/material.dart';
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/profile.dart';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/info.dart';

class CommunityStoriesPage extends StatelessWidget {
  final List<Map<String, String>> stories = [
    {
      "name": "Emma Johnson",
      "age": "35",
      "year": "2020",
      "story":
      "I noticed a small mole that started changing. Early detection helped me get treatment in time. Never ignore your skin changes!"
    },
    {
      "name": "Michael Smith",
      "age": "42",
      "year": "2018",
      "story":
      "Regular skin checks saved my life. This app helped me recognize the early signs. Now, I'm cancer-free!"
    },
    {
      "name": "Sophia Davis",
      "age": "29",
      "year": "2021",
      "story":
      "A quick self-check using the app alerted me to an unusual spot. Early consultation with a dermatologist confirmed my concerns. Thank you!"
    },
    {
      "name": "Rahul Das",
      "age": "50",
      "year": "2017",
      "story":
      "Thanks to early detection, I underwent treatment quickly and made a full recovery."
    },
    {
      "name": "Isabella Carter",
      "age": "31",
      "year": "2019",
      "story":
      "I never paid much attention to a small dark spot on my arm. This app encouraged me to check it out, and I’m so grateful I did!"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Community Stories', style: TextStyle(fontFamily: 'BaskervvilleSC')),
        backgroundColor: Color(0xFF7469B6),
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
              }),
              _buildNavButton(Icons.info, () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
              }),
              SizedBox(width: 0),
              _buildNavButton(Icons.home, () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => MyHomePage()),
                  );
              }),
              _buildNavButton(Icons.person, () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              }),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => CameraApp()),
          );
        },
        backgroundColor: Colors.transparent,
        shape: CircleBorder(),
        elevation: 5,
        child: Image.asset('assets/floating_icon.png'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          children: stories.map((story) => _buildStoryCard(story)).toList(),
        ),
      ),
    );
  }

  Widget _buildStoryCard(Map<String, String> story) {
    return Card(
      elevation: 5,
      color: Color(0xFFF2F0EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              story["name"]!,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              "Age: ${story["age"]} | Recovered in: ${story["year"]}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              story["story"]!,
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
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
