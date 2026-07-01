import '../data/exercise_database.dart';
import '../repositories/muscle_repository.dart';

class WorkoutSyncService {
  final MuscleRepository _repository = MuscleRepository();

  Future<void> syncWorkout(String exerciseName) async {
    final normalizedName = exerciseName.trim().toLowerCase();
    final exercise = ExerciseDatabase.getExercise(normalizedName);

    if (exercise == null) {
      return;
    }

    await _repository.updateMuscleImpacts(
      impacts: exercise.impacts,
      date: DateTime.now(),
      exerciseName: normalizedName,
    );
  }
}