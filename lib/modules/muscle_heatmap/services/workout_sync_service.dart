import '../data/exercise_database.dart';
import '../models/muscle_group.dart';
import '../repositories/muscle_repository.dart';

class WorkoutSyncService {
  final MuscleRepository _repository = MuscleRepository();

  Future<void> syncWorkout(String exerciseName) async {
    final exercise =
    ExerciseDatabase.getExercise(exerciseName);

    if (exercise == null) {
      return;
    }

    final muscles = [
      exercise.primary,
      ...exercise.secondary,
    ];

    await _repository.updateMuscles(
      muscles,
      DateTime.now(),
    );
  }
}