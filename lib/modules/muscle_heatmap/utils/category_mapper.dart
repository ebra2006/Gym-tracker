import '../models/muscle_group.dart';

class CategoryMapper {
  static MuscleGroup? getPrimaryMuscle(String category) {
    switch (category.toLowerCase()) {
      case 'chest':
        return MuscleGroup.middleChest;

      case 'back':
        return MuscleGroup.upperBack;

      case 'legs':
        return MuscleGroup.vastusLateralis;

      case 'shoulders':
        return MuscleGroup.frontDeltoid;

      case 'biceps':
        return MuscleGroup.longHeadBiceps;

      case 'triceps':
        return MuscleGroup.tricepsLateralHead;

      case 'abs':
      case 'core':
        return MuscleGroup.upperAbs;

      default:
        return null;
    }
  }
}