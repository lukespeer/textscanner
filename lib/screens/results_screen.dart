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
      body: ListView.builder(
        itemCount: widget.recognizedText.blocks.length,
        itemBuilder: (context, index) {
          final block = widget.recognizedText.blocks[index];
          return ListTile(
            title: Text(block.text),
          );
        },
      )
    );
  }
}