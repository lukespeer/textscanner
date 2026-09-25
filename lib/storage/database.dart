import 'dart:async';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';

late Database database;

Future<void> databaseInit() async {
  database = await openDatabase(
    join(await getDatabasesPath(), 'history.db'),
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE results(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          text TEXT,
          imagePath TEXT,
          dateTime TEXT
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
      texts: List<String>.from(jsonDecode(map['texts'] as String)),
      createdAt: map['createdAt'] as int,
    );
  }

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(createdAt);
}

Future<void> saveResult(ScanResult result) async {
  await database.insert(
    'results',
    result.toMap()..remove('id'),
  );
}

Future<List<ScanResult>> getResults() async {
  final rows = await database.query(
    'results',
    orderBy: 'createdAt DESC',
  );

  return rows.map((row) => ScanResult.fromMap(row)).toList();
}

Future<void> deleteResult(ScanResult result) async {
  await database.delete(
    'results',
    where: 'id = ?',
    whereArgs: [result.id],
  );

  try {
    final file = File(result.imagePath);
    if (await file.exists())
    {
      file.delete();
    }
  } catch (e) {
    
  }
}