import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:textscanner/api/text_api.dart';

class ResultsScreen extends StatefulWidget {
  final InputImage image;
  final RecognizedText recognizedText;
  const ResultsScreen({super.key, required this.image, required this.recognizedText});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.recognizedText.blocks.length} Results'),
      ),
<<<<<<< Updated upstream
=======
      body: Stack(
        children: [
          Center(
            child: Image.memory(
              img.encodeJpg(widget.image),
              fit: BoxFit.contain,
            ),
          ),
          BottomSheet(
            builder:(context) => Container(
              color: Colors.black.withOpacity(0.7),
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Text(
                  widget.recognizedText.text,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            onClosing: () {
              
            },
          )
        ],
      )
>>>>>>> Stashed changes
    );
  }
} 