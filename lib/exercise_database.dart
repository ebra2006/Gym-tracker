import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ExerciseDatabase {
  static Database? _database;

  // إنشاء أو فتح قاعدة البيانات
  static Future<Database> getDatabase() async {
    if (_database != null) return _database!;

    // تحديد مسار قاعدة البيانات
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'exercises.db');

    _database = await openDatabase(
      path,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE exercises(id INTEGER PRIMARY KEY, name TEXT, description TEXT, image TEXT)',
        );
        await _loadInitialData(db);
      },
      version: 1,
    );

    return _database!;
  }

  // تحميل البيانات الأولية من ملف JSON
  static Future<void> _loadInitialData(Database db) async {
    final String jsonString = await rootBundle.loadString('assets/exercises.json');
    final List<dynamic> exercises = jsonDecode(jsonString);

    // إدخال البيانات في القاعدة
    for (var exercise in exercises) {
      await db.insert(
        'exercises',
        exercise,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // جلب التمارين من قاعدة البيانات
  static Future<List<Map<String, dynamic>>> getExercises() async {
    final db = await getDatabase();
    return await db.query('exercises');
  }

  // مسح قاعدة البيانات وإعادة تحميل البيانات
  static Future<void> resetDatabase() async {
    final db = await getDatabase();
    await db.delete('exercises'); // مسح البيانات القديمة
    await _loadInitialData(db);    // تحميل البيانات الجديدة
  }
}
