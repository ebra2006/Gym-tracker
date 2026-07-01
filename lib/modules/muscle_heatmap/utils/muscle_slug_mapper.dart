import '../models/muscle_group.dart';
import 'recovery_rules.dart';

class MuscleSlugMapper {
  static List<MuscleGroup> fromSlug(String slug) {
    return RecoveryRules.getByVisualSlug(slug)
        .map((definition) => definition.group)
        .toList();
  }
}