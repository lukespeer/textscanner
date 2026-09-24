import 'package:flutter/material.dart';
import 'package:textscanner/screens/camera_screen.dart';
import 'package:textscanner/api/camera_api.dart';
import 'package:textscanner/screens/results_screen.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:flutter/services.dart';
import 'package:textscanner/api/text_api.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;


late InputImage inputImage;
late img.Image asset;

void main() async {
  await initCamera();
  asset = await loadAssetImage("assets/images/sample.jpg");
  inputImage = await convertToInputImage(asset);

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
      home: FutureBuilder<RecognizedText>(
        // 1. Call your text scanning function here
        future: _scanImageText("assets/images/sample.jpg"), 
        builder: (context, snapshot) {
          // 2. While waiting for the await, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          
          // 3. Handle any errors during scanning
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Error scanning text: ${snapshot.error}')),
            );
          }

          // 4. Once complete, pass both the image and the awaited results
          if (snapshot.hasData) {
            return ResultsScreen(
              image: asset,
              recognizedText: snapshot.data!, // This is your awaited scanning output
            );
          }

          return const Scaffold(body: Center(child: Text('No data found')));
        },
      ),
    );
  }
}

Future<RecognizedText> _scanImageText(String assetPath) async {
  final RecognizedText recognizedText = await scanText(inputImage);
  return recognizedText;
}
Future<img.Image> loadAssetImage(String path) async {
  final data = await rootBundle.load(path);

  final image = img.decodeImage(
    data.buffer.asUint8List(),
  );

  if (image == null) {
    throw Exception('Could not decode image: $path');
  }

  return image;
}

Future<InputImage> convertToInputImage(img.Image image) async {
  // Convert package:image -> PNG bytes
  final png = Uint8List.fromList(img.encodePng(image));

  // Decode PNG using Flutter's image decoder
  final codec = await ui.instantiateImageCodec(png);
  final frame = await codec.getNextFrame();

  // Get raw RGBA pixels
  final data = await frame.image.toByteData(
    format: ui.ImageByteFormat.rawRgba,
  );

  if (data == null) {
    throw Exception('Could not convert image to raw RGBA');
  }

  return InputImage.fromBitmap(
    bitmap: data.buffer.asUint8List(),
    width: frame.image.width,
    height: frame.image.height,
    rotation: 0,
  );
}