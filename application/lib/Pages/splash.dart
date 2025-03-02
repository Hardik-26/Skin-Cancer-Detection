import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:can_scan/Pages/home.dart';
import 'package:can_scan/Pages/login.dart';// Import your home screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/SC.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        // Navigate to home screen when video ends
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => Login()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Keep background black to avoid flicker
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : CircularProgressIndicator(), // Show a loader until the video is ready
          ),
          // Black box at the bottom
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              height: 100, // Adjust height as needed
              width: double.infinity,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
