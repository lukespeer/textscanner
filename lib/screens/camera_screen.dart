import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
import 'package:textscanner/screens/results_screen.dart';

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
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

@override
  void initState() {
    super.initState();
    // set up the camera when the screen opens
    _controller = CameraController(
      getCamera(),
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }
  
  @override
  void dispose() {
    // turn off the camera when leaving the screen
    _controller.dispose();
    super.dispose();
  }
  Future<void> _onCapture() async {
    try {
      await _initializeControllerFuture;

      final image = await _controller.takePicture();

      await _scanImage(image.path);

    } catch (e) {
      print('error taking photo: $e');
    }
  }

  Future<void> _onOpenLibrary() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      // user closed the picker without choosing a photo
      return;
    }

    await _scanImage(image.path);
  }

  Future<void> _scanImage(String imagePath) async {
    final bytes = await File(imagePath).readAsBytes();
    final decodedPhoto = img.decodeImage(bytes);
    if (decodedPhoto == null) {
      throw StateError('Could not decode captured image');
    }

    final photo = img.bakeOrientation(decodedPhoto);
    final tempDirectory = await Directory.systemTemp.createTemp(
      'textscanner_',
    );
    final normalizedFile = File('${tempDirectory.path}/normalized.jpg');

    try {
      await normalizedFile.writeAsBytes(img.encodeJpg(photo));
      final recognizedText = await scanText(
        InputImage.fromFilePath(normalizedFile.path),
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            image: photo,
            recognizedText: recognizedText,
          ),
        ),
      );
    } finally {
        try {
          await normalizedFile.delete();
          await tempDirectory.delete();
        } on FileSystemException {

        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  // permission was denied
                  return const Center(child: Text('could not start camera'));
                } else if (snapshot.connectionState == ConnectionState.done) {
                  // camera is ready, show the live feed
                  return CameraPreview(_controller);
                } else {
                  // camera is still starting up
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
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