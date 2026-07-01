import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/muscle_group.dart';
import '../models/muscle_info.dart';
import '../utils/recovery_rules.dart';

class MuscleRepository {
  static const String _storageKey = 'last_muscle_activity_v3';

  Future<Map<MuscleGroup, MuscleActivity>> getLastActivities() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return {};

    final Map<String, dynamic> decoded = jsonDecode(jsonString);
    final Map<MuscleGroup, MuscleActivity> result = {};

    decoded.forEach((key, value) {
      final muscle = _tryParseMuscle(key);
      if (muscle == null) return;

      if (value is String) {
        result[muscle] = MuscleActivity(
          lastWorkout: DateTime.parse(value),
          fatiguePercent: 1,
          lastExerciseName: "Unknown exercise",
          lastImpactPercent: 100,
        );
        return;
      }

      if (value is Map<String, dynamic>) {
        result[muscle] = MuscleActivity(
          lastWorkout: DateTime.parse(value['lastWorkout']),
          fatiguePercent: (value['fatiguePercent'] as num).toDouble(),
          lastExerciseName: (value['lastExerciseName'] ?? "Unknown exercise").toString(),
          lastImpactPercent: (value['lastImpactPercent'] as num?)?.toInt() ?? 100,
        );
      }
    });

    return result;
  }

  Future<void> updateMuscleImpacts({
    required Map<MuscleGroup, int> impacts,
    required DateTime date,
    required String exerciseName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await getLastActivities();

    impacts.forEach((muscle, impactPercent) {
      final impact = (impactPercent / 100).clamp(0.0, 1.0).toDouble();
      final existing = current[muscle];

      final existingFatigue = existing == null
          ? 0.0
          : _getCurrentFatigue(
        muscle: muscle,
        activity: existing,
        now: date,
      );

      final combinedFatigue =
      (existingFatigue + impact * (1 - existingFatigue)).clamp(0.0, 1.0).toDouble();

      current[muscle] = MuscleActivity(
        lastWorkout: date,
        fatiguePercent: combinedFatigue,
        lastExerciseName: exerciseName,
        lastImpactPercent: impactPercent,
      );
    });

    final Map<String, dynamic> data = {};

    current.forEach((key, value) {
      data[key.name] = {
        'lastWorkout': value.lastWorkout.toIso8601String(),
        'fatiguePercent': value.fatiguePercent,
        'lastExerciseName': value.lastExerciseName,
        'lastImpactPercent': value.lastImpactPercent,
      };
    });

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  double _getCurrentFatigue({
    required MuscleGroup muscle,
    required MuscleActivity activity,
    required DateTime now,
  }) {
    final definition = RecoveryRules.getDefinition(muscle);
    final recoveryDuration = Duration(
      minutes: max(
        1,
        (definition.recoveryHours * 60 * activity.fatiguePercent).round(),
      ),
    );

    final elapsed = now.difference(activity.lastWorkout);

    final recoveryPercent =
        elapsed.inMilliseconds / recoveryDuration.inMilliseconds;

    return max(
      0,
      activity.fatiguePercent * (1 - recoveryPercent),
    );
  }

  MuscleGroup? _tryParseMuscle(String name) {
    for (final muscle in MuscleGroup.values) {
      if (muscle.name == name) return muscle;
    }

    return null;
  }
}