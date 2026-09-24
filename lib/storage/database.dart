import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

late Database database;

void databaseInit() async {
  database = await openDatabase(join(await getDatabasesPath(), 'history.db'));
}