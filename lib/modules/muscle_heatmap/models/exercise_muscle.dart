import 'muscle_group.dart';

class ExerciseMuscle {
  final Map<MuscleGroup, int> impacts;
  final String movementType;
  final String mechanics;
  final String pattern;
  final String level;

  const ExerciseMuscle({
    required this.impacts,
    required this.movementType,
    required this.mechanics,
    required this.pattern,
    required this.level,
  });

  List<MuscleGroup> get primary => impacts.entries
      .where((entry) => entry.value >= 75)
      .map((entry) => entry.key)
      .toList();

  List<MuscleGroup> get secondary => impacts.entries
      .where((entry) => entry.value < 75)
      .map((entry) => entry.key)
      .toList();
}