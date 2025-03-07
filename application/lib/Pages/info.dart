import 'package:can_scan/Pages/home.dart';
import 'package:flutter/material.dart';
import 'package:can_scan/Pages/stories.dart';
import 'package:can_scan/Pages/profile.dart';
import 'package:can_scan/Pages/cam.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Information', style: TextStyle(fontFamily: 'BaskervvilleSC')),
        //backgroundColor: Color(0xFFAD88C6),
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
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Title
            const Text(
              "Learn About Skin Cancer!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Skin cancer is the abnormal growth of skin cells, often caused by prolonged exposure to ultraviolet (UV) radiation from the sun or artificial sources like tanning beds. It is one of the most common types of cancer but is also one of the most preventable and treatable when detected early.",
              style: TextStyle(fontSize: 16, color: Colors.black54),textAlign: TextAlign.justify
            ),
            const SizedBox(height: 20),

            // Types of Skin Cancer
            const Text(
              "Types of Skin Cancer",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),textAlign: TextAlign.justify
            ),
            const SizedBox(height: 10),
            _buildFeatureCard(
              "Basal Cell Carcinoma",
              "It appears as a flesh-colored, pearl-like bump or a pinkish patch of skin. It grows slowly and rarely spreads but can cause local tissue damage.",
              'assets/aboutAssets/BCC.jpeg',
            ),
            const SizedBox(height: 10),
            _buildFeatureCard(
              "Squamous Cell Carcinoma",
              "Often appearing as a firm, red bump or a scaly patch, it can grow deeper into the skin and spread if untreated.",
              'assets/aboutAssets/SCC.jpeg',
            ),
            const SizedBox(height: 10),
            _buildFeatureCard(
              "Melanoma",
              "The most dangerous form of skin cancer, melanoma can develop in an existing mole or appear as a new, unusual growth. Early detection is crucial, as it can spread rapidly.",
              'assets/aboutAssets/Melanoma.jpeg',
            ),
            const SizedBox(height: 30),

            // Signs and Symptoms
            const Text(
              "Signs and Symptoms",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "• A new or changing mole\n"
                  "• Sores that do not heal\n"
                  "• Scaly, red, or rough patches of skin\n"
                  "• Dark or multi-colored spots with irregular borders\n"
                  "• Itching, pain, or bleeding in a skin lesion",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Contact Us
            const Text(
              "Contact Us",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "For any inquiries, reach out to us:",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 5),
            const Text(
              "📍 Address: 123 Health Street, Bengaluru, India\n"
                  "📞 Phone: +91 9125555228\n"
                  "✉ Email: contact@canscan.com \n\n",
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // Feature Card Widget
  Widget _buildFeatureCard(String title, String description, String imagePath) {
    return Card(
      elevation: 5,
      color: Color(0xFFF2F0EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(imagePath, width: 50, height: 50, fit: BoxFit.cover),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87),textAlign: TextAlign.justify),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation Button Widget
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