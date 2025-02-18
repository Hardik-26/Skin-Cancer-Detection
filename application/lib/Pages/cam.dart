import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CameraApp extends StatefulWidget {
  const CameraApp({super.key});

  @override
  _CameraAppState createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> with SingleTickerProviderStateMixin {
  File? _image;
  late TransformationController _transformationController;
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;

  @override
  void initState() {
    super.initState();
    _transformationController = TransformationController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addListener(() {
      if (_animation != null) {
        _transformationController.value = _animation!.value;
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _animateZoom() {
    // Reset to identity matrix
    _transformationController.value = Matrix4.identity();

    // Create zoom animation
    final Matrix4 zoomed = Matrix4.identity()
      ..translate(-100.0, -100.0)  // Adjust these values based on your needs
      ..scale(1.5);  // Zoom level - adjust as needed

    _animation = Matrix4Tween(
      begin: Matrix4.identity(),
      end: zoomed,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward(from: 0);
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Start zoom animation after a short delay
      Future.delayed(const Duration(milliseconds: 100), _animateZoom);
    }
  }

  void _retakePhoto() {
    setState(() {
      _image = null;
      _transformationController.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CanScan', style: TextStyle(fontFamily: 'BaskervvilleSC')),
      ),
      body: Center(
        child: _image == null
            ? Text('Click the camera button to take a photo',
            style: TextStyle(fontSize: 16))
            : Container(
          margin: const EdgeInsets.all(5.0),
          padding: const EdgeInsets.all(3.0),
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 2)
          ),
          child: InteractiveViewer(
            transformationController: _transformationController,
            constrained: true,
            minScale: 0.5,
            maxScale: 2.5,
            child: Image.file(_image!),
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 5,
        shape: const CircularNotchedRectangle(),
        color: Color(0xFFAD88C6),
        child: _image != null
            ? Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.close, size: 40),
              onPressed: _retakePhoto,
            ),
            IconButton(
              icon: Icon(Icons.check, size: 40),
              onPressed: () {
                // Handle photo acceptance logic
              },
            ),
          ],
        )
            : SizedBox(height: 50),
      ),
      floatingActionButton: _image == null
          ? FloatingActionButton(
        onPressed: _takePicture,
        elevation: 0,
        backgroundColor: Colors.transparent,
        shape: CircleBorder(),
        child: Icon(Icons.camera_rounded, size: 55),
      )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}