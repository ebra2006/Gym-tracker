import '../models/muscle_group.dart';
import '../models/muscle_info.dart';
import '../models/muscle_status.dart';
import '../utils/recovery_rules.dart';

class RecoveryEngine {
  static const int inactiveDays = 14;

  static MuscleInfo calculate({
    required MuscleGroup muscle,
    DateTime? lastWorkout,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final definition = RecoveryRules.getDefinition(muscle);

    if (lastWorkout == null) {
      return MuscleInfo(
        muscle: muscle,
        lastWorkout: null,
        recoveryHours: definition.recoveryHours,
        status: MuscleStatus.inactive,
        remainingRecovery: Duration.zero,
        recoveryPercent: 0,
      );
    }

    final elapsed = currentTime.difference(lastWorkout);

    if (elapsed.inDays >= inactiveDays) {
      return MuscleInfo(
        muscle: muscle,
        lastWorkout: lastWorkout,
        recoveryHours: definition.recoveryHours,
        status: MuscleStatus.inactive,
        remainingRecovery: Duration.zero,
        recoveryPercent: 0,
      );
    }

    final recoveryDuration =
    Duration(hours: definition.recoveryHours);

    double recoveryPercent =
        elapsed.inMilliseconds / recoveryDuration.inMilliseconds;

    recoveryPercent = recoveryPercent.clamp(0.0, 1.0);

    if (elapsed >= recoveryDuration) {
      return MuscleInfo(
        muscle: muscle,
        lastWorkout: lastWorkout,
        recoveryHours: definition.recoveryHours,
        status: MuscleStatus.ready,
        remainingRecovery: Duration.zero,
        recoveryPercent: 1,
      );
    }

    return MuscleInfo(
      muscle: muscle,
      lastWorkout: lastWorkout,
      recoveryHours: definition.recoveryHours,
      status: MuscleStatus.recovering,
      remainingRecovery: recoveryDuration - elapsed,
      recoveryPercent: recoveryPercent,
    );
  }
}