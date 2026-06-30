import '../models/muscle_group.dart';

class CategoryMapper {
  static MuscleGroup? getPrimaryMuscle(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return MuscleGroup.chest;

      case 'back':
        return MuscleGroup.back;

      case 'legs':
        return MuscleGroup.quadriceps;

      case 'shoulders':
        return MuscleGroup.shoulders;

      case 'biceps':
        return MuscleGroup.biceps;

      case 'triceps':
        return MuscleGroup.triceps;

      case 'abs':
        return MuscleGroup.abs;

      default:
        return null;
    }
  }
}