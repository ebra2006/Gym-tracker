import 'muscle_group.dart';
import 'muscle_status.dart';

class MuscleInfo {
  final MuscleGroup muscle;
  final DateTime? lastWorkout;
  final int recoveryHours;
  final double fatiguePercent;
  final String? lastExerciseName;
  final int? lastImpactPercent;
  final MuscleStatus status;
  final Duration remainingRecovery;
  final double recoveryPercent;

  const MuscleInfo({
    required this.muscle,
    required this.lastWorkout,
    required this.recoveryHours,
    required this.fatiguePercent,
    required this.lastExerciseName,
    required this.lastImpactPercent,
    required this.status,
    required this.remainingRecovery,
    required this.recoveryPercent,
  });

  bool get isReady => status == MuscleStatus.ready;
  bool get isRecovering => status == MuscleStatus.recovering;
  bool get isInactive => status == MuscleStatus.inactive;
}

class MuscleActivity {
  final DateTime lastWorkout;
  final double fatiguePercent;
  final String lastExerciseName;
  final int lastImpactPercent;

  const MuscleActivity({
    required this.lastWorkout,
    required this.fatiguePercent,
    required this.lastExerciseName,
    required this.lastImpactPercent,
  });
}