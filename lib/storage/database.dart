import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database database;

//call this once at startup, before saving or loading any results
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

