import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

late List<CameraDescription> cameras;

Future<void> initCamera() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
}

CameraDescription getCamera() {
  if (cameras.isEmpty) {
    throw Exception('No cameras available');
  }
  return cameras.first;
}