import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/muscle_group.dart';

class MuscleRepository {
  static const String _storageKey = 'last_muscle_activity';

  Future<Map<MuscleGroup, DateTime>> getLastActivities() async {
    final prefs = await SharedPreferences.getInstance();

    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    final Map<MuscleGroup, DateTime> result = {};

    decoded.forEach((key, value) {
      final muscle = MuscleGroup.values.firstWhere(
            (e) => e.name == key,
      );

      result[muscle] = DateTime.parse(value);
    });

    return result;
  }

  Future<void> updateMuscle(
      MuscleGroup muscle,
      DateTime date,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final current = await getLastActivities();

    current[muscle] = date;

    final Map<String, String> data = {};

    current.forEach((key, value) {
      data[key.name] = value.toIso8601String();
    });

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  Future<void> updateMuscles(
      List<MuscleGroup> muscles,
      DateTime date,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final current = await getLastActivities();

    for (final muscle in muscles) {
      current[muscle] = date;
    }

    final Map<String, String> data = {};

    current.forEach((key, value) {
      data[key.name] = value.toIso8601String();
    });

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }
}