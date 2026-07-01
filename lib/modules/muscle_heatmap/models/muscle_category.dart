enum MuscleCategory {
  chest,
  back,
  shoulders,
  arms,
  core,
  legs,
}

extension MuscleCategoryInfo on MuscleCategory {
  String get displayName {
    switch (this) {
      case MuscleCategory.chest:
        return "Chest";
      case MuscleCategory.back:
        return "Back";
      case MuscleCategory.shoulders:
        return "Shoulders";
      case MuscleCategory.arms:
        return "Arms";
      case MuscleCategory.core:
        return "Core";
      case MuscleCategory.legs:
        return "Legs";
    }
  }
}