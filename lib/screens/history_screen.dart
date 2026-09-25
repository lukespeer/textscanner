import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:textscanner/api/text_api.dart';
import 'package:textscanner/screens/results_screen.dart';
import 'package:textscanner/storage/database.dart';
import 'package:image/image.dart' as img;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<ScanResult>> results;

  @override
  void initState() {
    super.initState();
    results = getResults();
  }

  void refresh() {
    setState(() {
      results = getResults();
    });
  }

  Future<void> deleteScan(ScanResult result) async {
    await deleteResult(result);
    refresh();
  }

  Future<void> viewScan(ScanResult result) async {
    _scanImage(result.imagePath);
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
          // clean up id
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: FutureBuilder<List<ScanResult>>(
        future: results,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final scans = snapshot.data ?? [];

          if (scans.isEmpty) {
            return const Center(
              child: Text('No saved scans yet.'),
            );
          }

          return ListView.builder(
            itemCount: scans.length,
            itemBuilder: (context, index) {
              final scan = scans[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(
                    scan.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (scan.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(scan.description),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        scan.date.toLocal().toString().split('.')[0],
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    borderRadius: BorderRadius.circular(20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'view',
                        child: Text('View'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          viewScan(scan);
                          break;
                        case 'edit':
                          print("edit info");
                          break;
                        case 'delete':
                          deleteScan(scan);
                          break;
                      }
                    },
                  )
                ),
              );
            },
          );
        },
      ),
    );
  }
}