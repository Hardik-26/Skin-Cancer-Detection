import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:can_scan/Pages/cam.dart';
import 'package:can_scan/Pages/stories.dart';
import 'package:can_scan/Pages/profile.dart';
import 'package:can_scan/Pages/info.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> items = [];

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    final response = await http.get(Uri.parse('https://mocki.io/v1/8f6ea5f9-9f2e-4285-a3d2-c213456d31ad'));
    if (response.statusCode == 200) {
      setState(() {
        items = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load items');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CanScan', style: TextStyle(fontFamily: 'BaskervvilleSC')),
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
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CommunityStoriesPage()),
                  );
              }),
              _buildNavButton(Icons.info, () {
                  Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AboutPage()),
                  );
              }),
              SizedBox(width: 0),
              _buildNavButton(Icons.home, () {
                fetchItems();
              }),
              _buildNavButton(Icons.person, () {
                // Handel Profile Tap
                Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
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

      body: items.isEmpty ?
      Center(
        child: Text(
          "Lesson Analysis Will Appear Here",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(10),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _buildListItem(items[index]);
        },
      ),
    );
  }

  Widget _buildListItem(dynamic item) {
    return Card(
      elevation: 5,
      color: Color(0xFFF2F0EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(item['image'], width: 50, height: 50, fit: BoxFit.cover),
        ),
        title: Text(item['title'], style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(item['description'], maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black),
        onTap: () {
          // Handle item tap
        },
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
// Comment for commit.
