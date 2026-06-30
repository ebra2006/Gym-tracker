import 'muscle_group.dart';

class ExerciseMuscle {
  final MuscleGroup primary;
  final List<MuscleGroup> secondary;

  const ExerciseMuscle({
    required this.primary,
    this.secondary = const [],
  });
}