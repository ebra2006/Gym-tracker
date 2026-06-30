import '../models/muscle_definition.dart';
import '../models/muscle_group.dart';

class RecoveryRules {
  static const List<MuscleDefinition> muscles = [

    MuscleDefinition(
      group: MuscleGroup.chest,
      displayName: "Chest",
      recoveryHours: 72,
      frontSvgId: "chest",
    ),

    MuscleDefinition(
      group: MuscleGroup.back,
      displayName: "Back",
      recoveryHours: 72,
      backSvgId: "back",
    ),

    MuscleDefinition(
      group: MuscleGroup.lats,
      displayName: "Lats",
      recoveryHours: 72,
      backSvgId: "lats",
    ),

    MuscleDefinition(
      group: MuscleGroup.traps,
      displayName: "Traps",
      recoveryHours: 48,
      backSvgId: "traps",
    ),

    MuscleDefinition(
      group: MuscleGroup.shoulders,
      displayName: "Shoulders",
      recoveryHours: 48,
      frontSvgId: "shoulders",
    ),

    MuscleDefinition(
      group: MuscleGroup.rearShoulders,
      displayName: "Rear Delts",
      recoveryHours: 48,
      backSvgId: "rear_shoulders",
    ),

    MuscleDefinition(
      group: MuscleGroup.biceps,
      displayName: "Biceps",
      recoveryHours: 48,
      frontSvgId: "biceps",
    ),

    MuscleDefinition(
      group: MuscleGroup.triceps,
      displayName: "Triceps",
      recoveryHours: 48,
      backSvgId: "triceps",
    ),

    MuscleDefinition(
      group: MuscleGroup.forearms,
      displayName: "Forearms",
      recoveryHours: 24,
      frontSvgId: "forearms",
    ),

    MuscleDefinition(
      group: MuscleGroup.abs,
      displayName: "Abs",
      recoveryHours: 24,
      frontSvgId: "abs",
    ),

    MuscleDefinition(
      group: MuscleGroup.obliques,
      displayName: "Obliques",
      recoveryHours: 24,
      frontSvgId: "obliques",
    ),

    MuscleDefinition(
      group: MuscleGroup.quadriceps,
      displayName: "Quadriceps",
      recoveryHours: 72,
      frontSvgId: "quads",
    ),

    MuscleDefinition(
      group: MuscleGroup.hamstrings,
      displayName: "Hamstrings",
      recoveryHours: 72,
      backSvgId: "hamstrings",
    ),

    MuscleDefinition(
      group: MuscleGroup.glutes,
      displayName: "Glutes",
      recoveryHours: 72,
      backSvgId: "glutes",
    ),

    MuscleDefinition(
      group: MuscleGroup.calves,
      displayName: "Calves",
      recoveryHours: 48,
      frontSvgId: "calves",
      backSvgId: "calves",
    ),
  ];

  static MuscleDefinition getDefinition(MuscleGroup group) {
    return muscles.firstWhere((muscle) => muscle.group == group);
  }
}