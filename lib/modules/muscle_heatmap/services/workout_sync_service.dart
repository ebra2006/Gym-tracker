import 'package:flutter/foundation.dart';

import '../data/exercise_database.dart';
import '../models/muscle_group.dart';
import '../repositories/muscle_repository.dart';

class WorkoutSyncService {
  static final ValueNotifier<int> muscleHeatmapVersion = ValueNotifier<int>(0);
  /// نفترض أن 4 مجموعات فعالة تمثل الجرعة الكاملة للتمرين.
  /// هذه قيمة تصميمية وليست قيمة علمية ثابتة.
  static const double _perSetDose = 0.28;

  final MuscleRepository _repository = MuscleRepository();

  Future<void> syncWorkout(
      String exerciseName, {
        int? reps,
      }) async {
    final exercise = ExerciseDatabase.getExercise(exerciseName);

    if (exercise == null) {
      return;
    }

    final adjustedImpacts = _applySetDose(
      impacts: exercise.impacts,
      reps: reps,
    );

    await _repository.updateMuscleImpacts(
      impacts: adjustedImpacts,
      date: DateTime.now(),
      exerciseName: exerciseName,
    );

    muscleHeatmapVersion.value++;
  }

  Map<MuscleGroup, int> _applySetDose({
    required Map<MuscleGroup, int> impacts,
    int? reps,
  }) {
    final repFactor = _calculateRepFactor(reps ?? 0);

    return impacts.map((muscle, impact) {
      final adjustedImpact =
      (impact * _perSetDose * repFactor).round().clamp(0, 100);

      return MapEntry(muscle, adjustedImpact);
    });
  }

  double _calculateRepFactor(int reps) {
    if (reps <= 0) return 1.0;
    if (reps <= 5) return 0.85;
    if (reps <= 8) return 0.95;
    if (reps <= 12) return 1.00;
    if (reps <= 15) return 1.07;
    if (reps <= 20) return 1.12;

    return 1.15;
  }
}