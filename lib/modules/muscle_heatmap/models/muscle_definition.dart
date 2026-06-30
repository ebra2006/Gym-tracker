import 'muscle_group.dart';

class MuscleDefinition {
  final MuscleGroup group;

  final String displayName;

  final int recoveryHours;

  final String frontSvgId;

  final String backSvgId;

  const MuscleDefinition({
    required this.group,
    required this.displayName,
    required this.recoveryHours,
    this.frontSvgId = '',
    this.backSvgId = '',
  });
}