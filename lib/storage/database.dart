import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database database;

Future<void> databaseInit() async {
  final path = join(await getDatabasesPath(), 'history.db');

  database = await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE results (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          texts TEXT NOT NULL,
          imagePath TEXT NOT NULL,
          createdAt INTEGER NOT NULL
        )
      ''');
    },
  );
}

class ScanResult {
  final int? id;
  final String imagePath;
  final List<String> texts;
  final int createdAt;

  const ScanResult({
    this.id,
    required this.imagePath,
    required this.texts,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'texts': jsonEncode(texts),
      'createdAt': createdAt,
    };
  }

  factory ScanResult.fromMap(Map<String, dynamic> map) {
    return ScanResult(
      id: map['id'] as int?,
      imagePath: map['imagePath'] as String,
      texts: List<String>.from(
        jsonDecode(map['texts'] as String),
      ),
      createdAt: map['createdAt'] as int,
    );
  }

  DateTime get date =>
      DateTime.fromMillisecondsSinceEpoch(createdAt);
}

// Save a scan to history
Future<void> saveResult(ScanResult result) async {
  await database.insert(
    'results',
    {
      'imagePath': result.imagePath,
      'texts': jsonEncode(result.texts),
      'createdAt': result.createdAt,
    },
  );
}

// Load all scans, newest first
Future<List<ScanResult>> getResults() async {
  final rows = await database.query(
    'results',
    orderBy: 'createdAt DESC',
  );

  return rows.map(ScanResult.fromMap).toList();
}

// Delete a scan and its associated image
Future<void> deleteResult(ScanResult result) async {
  if (result.id == null) return;

  try {
    final file = File(result.imagePath);

    if (await file.exists()) {
      await file.delete();
    }
  } catch (e) {
    debugPrint('Failed to delete image: $e');
    return;
  }

  await database.delete(
    'results',
    where: 'id = ?',
    whereArgs: [result.id],
  );
}