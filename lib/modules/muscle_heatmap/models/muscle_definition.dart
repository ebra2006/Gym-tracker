import 'muscle_category.dart';
import 'muscle_group.dart';

class MuscleDefinition {
  final MuscleGroup group;
  final MuscleCategory category;
  final String displayName;
  final String description;
  final int recoveryHours;
  final String frontSvgId;
  final String backSvgId;

  const MuscleDefinition({
    required this.group,
    required this.category,
    required this.displayName,
    required this.description,
    required this.recoveryHours,
    this.frontSvgId = '',
    this.backSvgId = '',
  });

  String get visualSlug => frontSvgId.isNotEmpty ? frontSvgId : backSvgId;
}