import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

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
  final GlobalKey _containerKey = GlobalKey();
  bool _showCarousel = false;
  int _currentCarouselIndex = 0;
  bool _showPinchAnimation = false;
  String? _screenshotUrl;

  // Hardcoded images for carousel
  final List<String> _carouselImages = [
    'assets/Instruction_2.png',
    'assets/Instruction_1.png',
  ];

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

  void _startPinchAnimation() {
    if (_image != null) {
      setState(() {
        _showPinchAnimation = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _showPinchAnimation = false;
        });

        // Restart the animation after some time
        Future.delayed(const Duration(seconds: 5), _startPinchAnimation);
      });
    }
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _showCarousel = true;  // Show carousel immediately after taking a picture
      });
    }
  }

  void _processImageAfterCarousel() {
    // Start pinch animation and zoom effect after carousel is closed
    setState(() {
      _showPinchAnimation = true;
    });

    // Start zoom animation
    Future.delayed(const Duration(milliseconds: 100), _animateZoom);

    // Hide pinch animation after a while
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _showPinchAnimation = false;
      });
    });
  }

  void _retakePhoto() {
    setState(() {
      _image = null;
      _transformationController.value = Matrix4.identity();
      _screenshotUrl = null;
    });
  }

  void _closeCarousel() {
    setState(() {
      _showCarousel = false;
    });
    _processImageAfterCarousel();
  }

  void _nextCarouselSlide() {
    setState(() {
      if (_currentCarouselIndex < _carouselImages.length - 1) {
        _currentCarouselIndex++;
      }
    });
  }

  void _prevCarouselSlide() {
    setState(() {
      if (_currentCarouselIndex > 0) {
        _currentCarouselIndex--;
      }
    });
  }

  Future<void> _captureScreenshot() async {
    try {
      RenderRepaintBoundary boundary = _containerKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // Save the file
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/screenshot_${DateTime.now().millisecondsSinceEpoch}.png');
        await file.writeAsBytes(pngBytes);

        setState(() {
          _screenshotUrl = file.path;
        });

        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Screenshot saved: ${file.path}')),
        // );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture screenshot: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If image is captured and carousel should be shown
    if (_image != null && _showCarousel) {
      return Scaffold(
        body: Stack(
          children: [
            // Full screen carousel
            GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity! > 0) {
                  _prevCarouselSlide();
                } else {
                  _nextCarouselSlide();
                }
              },
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Image.asset(
                  _carouselImages[_currentCarouselIndex],
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // Indicators
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _carouselImages.length,
                      (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index == _currentCarouselIndex
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 30),
                onPressed: _closeCarousel,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('CanScan', style: TextStyle(fontFamily: 'BaskervvilleSC')),
      ),
      body: Center(
        child: _image == null
            ? Text('Click the camera button to take a photo',
            style: TextStyle(fontSize: 16))
            : Stack(
          alignment: Alignment.center,
          children: [
            // Image container with screenshot boundary
            RepaintBoundary(
              key: _containerKey,
              child: Container(
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

            // Pinch animation overlay
            if (_showPinchAnimation)
              Container(
                width: 100,
                height: 100,
                child: AnimatedOpacity(
                  opacity: _showPinchAnimation ? 1.0 : 0.0,
                  duration: Duration(milliseconds: 500),
                  child: Icon(
                    Icons.pinch,
                    size: 80,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
          ],
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
              onPressed: _captureScreenshot,
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
// Comment for commit.