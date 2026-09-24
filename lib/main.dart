import 'package:flutter/material.dart';
import 'package:textscanner/screens/camera_screen.dart';
import 'package:textscanner/api/camera_api.dart';
import 'package:textscanner/screens/results_screen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'package:textscanner/api/text_api.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;
import 'package:textscanner/storage/database.dart';


late InputImage inputImage;
late img.Image asset;

void main() async {
  await initCamera();
  databaseInit();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Text Scanner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: CameraScreen()
    );
  }
}