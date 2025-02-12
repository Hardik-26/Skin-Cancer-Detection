import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    final response = await http.get(Uri.parse('https://mocki.io/v1/b8529de5-9803-4ff4-9647-010c0196f9b6'));
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
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
              _buildNavButton(Icons.settings, () {
                // Handel Settings Tap
              }),
              _buildNavButton(Icons.info, () {
                // Handel Info Tap
              }),
              SizedBox(width: 0),
              _buildNavButton(Icons.home, () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyHomePage()
                    )
                );
              }),
              _buildNavButton(Icons.person, () {
                // Handel Profile Tap
              }),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
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
