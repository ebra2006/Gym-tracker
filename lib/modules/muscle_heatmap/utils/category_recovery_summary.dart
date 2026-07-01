import '../models/muscle_category.dart';
import '../models/muscle_info.dart';
import 'recovery_rules.dart';

class CategoryRecoverySummary {
  final MuscleCategory category;
  final double fatiguePercent;
  final double recoveryPercent;
  final int recoveringCount;
  final int readyCount;
  final int inactiveCount;

  const CategoryRecoverySummary({
    required this.category,
    required this.fatiguePercent,
    required this.recoveryPercent,
    required this.recoveringCount,
    required this.readyCount,
    required this.inactiveCount,
  });

  static CategoryRecoverySummary fromStates({
    required MuscleCategory category,
    required Map<String, MuscleInfo> states,
  }) {
    final definitions = RecoveryRules.getByCategory(category);

    final infos = definitions
        .map((definition) => states[definition.group.name])
        .whereType<MuscleInfo>()
        .toList();

    if (infos.isEmpty) {
      return CategoryRecoverySummary(
        category: category,
        fatiguePercent: 0,
        recoveryPercent: 0,
        recoveringCount: 0,
        readyCount: 0,
        inactiveCount: 0,
      );
    }

    infos.sort(
          (a, b) => b.fatiguePercent.compareTo(a.fatiguePercent),
    );

    final worst = infos.first;

    return CategoryRecoverySummary(
      category: category,
      fatiguePercent: worst.fatiguePercent,
      recoveryPercent: worst.recoveryPercent,
      recoveringCount: infos.where((info) => info.isRecovering).length,
      readyCount: infos.where((info) => info.isReady).length,
      inactiveCount: infos.where((info) => info.isInactive).length,
    );
  }
}