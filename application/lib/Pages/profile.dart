import 'package:flutter/material.dart';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/stories.dart';
import 'package:can_scan/Pages/info.dart';


class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: TextStyle(fontFamily: 'BaskervvilleSC')),
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
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => CommunityStoriesPage()),
                );
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
              }),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
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
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Himanshi Agarwal",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Age: 20", style: TextStyle(fontSize: 19)),
                SizedBox(width: 20),
                Text("Gender: Female", style: TextStyle(fontSize: 19)),
              ],
            ),
            SizedBox(height: 15),

            _buildInfoTile(Icons.face, "Skin Tone", "Fair"),
            _buildInfoTile(Icons.medical_services, "Cancer History", "No"),
            _buildInfoTile(Icons.local_hospital, "Skin Cancer History", "None"),
            _buildInfoTile(Icons.local_bar, "Drinks", "Yes"),
            _buildInfoTile(Icons.smoking_rooms, "Smokes", "No"),
            _buildInfoTile(Icons.sunny, "Fitzpatrick", "0.6"),
            _buildInfoTile(Icons.spa, "Pesticide Exposure", "No"),
            _buildInfoTile(Icons.water_drop_rounded, "Piped Water", "No"),
            _buildInfoTile(Icons.water_outlined, "Sewage System", "No"),
            SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                // Log Out Action
              },
              icon: Icon(Icons.logout, color: Colors.white),
              label: Text("Log Out", style: TextStyle(fontSize: 16, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Color(0xFFF2F0EF),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF7469B6)),
          SizedBox(width: 20),
          Text(
            "$title: $value",
            style: TextStyle(fontSize: 16),
          ),
        ],
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
