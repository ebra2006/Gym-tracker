import 'muscle_group.dart';
import 'muscle_status.dart';

class MuscleInfo {
  final MuscleGroup muscle;
  final DateTime? lastWorkout;
  final int recoveryHours;
  final MuscleStatus status;
  final Duration remainingRecovery;
  final double recoveryPercent;

  const MuscleInfo({
    required this.muscle,
    required this.lastWorkout,
    required this.recoveryHours,
    required this.status,
    required this.remainingRecovery,
    required this.recoveryPercent,
  });

  bool get isReady => status == MuscleStatus.ready;

  bool get isRecovering => status == MuscleStatus.recovering;

  bool get isInactive => status == MuscleStatus.inactive;
}