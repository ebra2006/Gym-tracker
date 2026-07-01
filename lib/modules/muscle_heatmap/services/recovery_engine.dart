import 'dart:math';

import '../models/muscle_group.dart';
import '../models/muscle_info.dart';
import '../models/muscle_status.dart';
import '../utils/recovery_rules.dart';

class RecoveryEngine {
  static const int inactiveDays = 14;

  static MuscleInfo calculate({
    required MuscleGroup muscle,
    MuscleActivity? activity,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final definition = RecoveryRules.getDefinition(muscle);

    if (activity == null) {
      return MuscleInfo(
        muscle: muscle,
        lastWorkout: null,
        recoveryHours: definition.recoveryHours,
        fatiguePercent: 0,
        lastExerciseName: null,
        lastImpactPercent: null,
        status: MuscleStatus.inactive,
        remainingRecovery: Duration.zero,
        recoveryPercent: 0,
      );
    }

    final lastWorkout = activity.lastWorkout;
    final initialFatigue = activity.fatiguePercent.clamp(0.0, 1.0).toDouble();
    final elapsed = currentTime.difference(lastWorkout);

    if (elapsed.inDays >= inactiveDays) {
      return MuscleInfo(
        muscle: muscle,
        lastWorkout: lastWorkout,
        recoveryHours: definition.recoveryHours,
        fatiguePercent: 0,
        lastExerciseName: activity.lastExerciseName,
        lastImpactPercent: activity.lastImpactPercent,
        status: MuscleStatus.inactive,
        remainingRecovery: Duration.zero,
        recoveryPercent: 0,
      );
    }

    final recoveryDuration = Duration(
      minutes: max(
        1,
        (definition.recoveryHours * 60 * initialFatigue).round(),
      ),
    );

    double recoveryPercent =
        elapsed.inMilliseconds / recoveryDuration.inMilliseconds;

    recoveryPercent = recoveryPercent.clamp(0.0, 1.0).toDouble();

    final currentFatigue = initialFatigue * (1 - recoveryPercent);

    if (elapsed >= recoveryDuration) {
      return MuscleInfo(
        muscle: muscle,
        lastWorkout: lastWorkout,
        recoveryHours: definition.recoveryHours,
        fatiguePercent: 0,
        lastExerciseName: activity.lastExerciseName,
        lastImpactPercent: activity.lastImpactPercent,
        status: MuscleStatus.ready,
        remainingRecovery: Duration.zero,
        recoveryPercent: 1,
      );
    }

    return MuscleInfo(
      muscle: muscle,
      lastWorkout: lastWorkout,
      recoveryHours: definition.recoveryHours,
      fatiguePercent: currentFatigue,
      lastExerciseName: activity.lastExerciseName,
      lastImpactPercent: activity.lastImpactPercent,
      status: MuscleStatus.recovering,
      remainingRecovery: recoveryDuration - elapsed,
      recoveryPercent: recoveryPercent,
    );
  }
}