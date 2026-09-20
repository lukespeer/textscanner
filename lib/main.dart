import 'package:flutter/material.dart';
import 'package:textscanner/screens/camera_screen.dart';
import 'package:textscanner/api/camera_api.dart';

void main() async {
  await initCamera();

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
      home: const CameraScreen()
    );
  }
}