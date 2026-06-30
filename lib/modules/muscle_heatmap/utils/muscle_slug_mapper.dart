import '../models/muscle_group.dart';

class MuscleSlugMapper {
  static MuscleGroup? fromSlug(String slug) {
    switch (slug) {
      case 'chest':
        return MuscleGroup.chest;

      case 'upper-back':
        return MuscleGroup.back;

      case 'lower-back':
        return MuscleGroup.back;

      case 'lats':
        return MuscleGroup.lats;

      case 'trapezius':
        return MuscleGroup.traps;

      case 'deltoids':
        return MuscleGroup.shoulders;

      case 'rear-deltoids':
        return MuscleGroup.rearShoulders;

      case 'biceps':
        return MuscleGroup.biceps;

      case 'triceps':
        return MuscleGroup.triceps;

      case 'forearm':
      case 'forearms':
        return MuscleGroup.forearms;

      case 'abs':
        return MuscleGroup.abs;

      case 'obliques':
        return MuscleGroup.obliques;

      case 'quadriceps':
        return MuscleGroup.quadriceps;

      case 'hamstrings':
        return MuscleGroup.hamstrings;

      case 'glutes':
        return MuscleGroup.glutes;

      case 'calves':
        return MuscleGroup.calves;

      default:
        return null;
    }
  }
}