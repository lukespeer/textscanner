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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Screen'),
      ),
      body: const Center(
        child: Text('Camera functionality will be implemented here.'),
      ),
    );
  }
}