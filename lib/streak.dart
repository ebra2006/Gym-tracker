import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StreakManager {
  int currentStreak = 0;
  String? lastWorkoutDate;

  Future<void> loadStreakData() async {
    final prefs = await SharedPreferences.getInstance();
    currentStreak = prefs.getInt('current_streak') ?? 0;
    lastWorkoutDate = prefs.getString('last_workout_date');
  }

  Future<void> updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    String currentDate = DateTime.now().toIso8601String().split('T')[0];

    if (lastWorkoutDate == null) {
      currentStreak = 1;
    } else {
      DateTime lastDate = DateTime.parse(lastWorkoutDate!);
      DateTime today = DateTime.parse(currentDate);
      int diffDays = today.difference(lastDate).inDays;

      if (diffDays == 1) {
        currentStreak++;
      } else if (diffDays > 1) {
        currentStreak = 1;
      }
    }

    lastWorkoutDate = currentDate;
    await prefs.setInt('current_streak', currentStreak);
    await prefs.setString('last_workout_date', lastWorkoutDate!);
  }

  Future<List<dynamic>> loadSavedWorkoutsForDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    String? workoutsJson = prefs.getString('workouts_$date');
    if (workoutsJson != null && workoutsJson.isNotEmpty) {
      try {
        return jsonDecode(workoutsJson);
      } catch (e) {
        return [];
      }
    }
    return [];
  }
}
