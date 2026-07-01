import '../data/exercise_database.dart';
import '../repositories/muscle_repository.dart';

class WorkoutSyncService {
  final MuscleRepository _repository = MuscleRepository();

  Future<void> syncWorkout(String exerciseName) async {
    final exercise = ExerciseDatabase.getExercise(exerciseName);

    if (exercise == null) {
      return;
    }

    await _repository.updateMuscleImpacts(
      impacts: exercise.impacts,
      date: DateTime.now(),
      exerciseName: exerciseName,
    );
  }
}