import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// Define a callback type for when splash screen finishes
typedef SplashFinishedCallback = Future<Widget> Function();

class SplashScreen extends StatefulWidget {
  final SplashFinishedCallback onSplashFinished;

  SplashScreen({required this.onSplashFinished});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _isVideoComplete = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset("assets/SC.mp4")
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration && !_isVideoComplete) {
        _isVideoComplete = true;
        _navigateToNextScreen();
      }
    });
  }

  Future<void> _navigateToNextScreen() async {
    // Call the callback function to determine where to navigate
    final nextScreen = await widget.onSplashFinished();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => nextScreen),
      );
    }
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