import 'package:flutter/material.dart';
// call getCamera() to get the first available camera
import 'package:textscanner/api/camera_api.dart';
// call scanText(image) to scan text from an image
// must be an InputImage, but I think camera provides that.
import 'package:textscanner/api/text_api.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  void _onCapture() {
    // will actually take a photo 
    print('capture tapped');
  }

  void _onOpenLibrary() {
    // will open the history screen 
    print('library tapped');
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: Column(
        children: [
          // camera preview will go here
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              alignment: Alignment.center,
              child: const Text('camera preview goes here'),
            ),
          ),
          // buttons go here
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _onOpenLibrary,
                    icon: const Icon(Icons.photo_library, color: Colors.white),
                    iconSize: 32,
                  ),
                  FloatingActionButton(
                    onPressed: _onCapture,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.camera_alt, color: Colors.black),
                  ),
                  const SizedBox(width: 48),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}