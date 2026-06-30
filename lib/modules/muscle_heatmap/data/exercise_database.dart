import '../models/exercise_muscle.dart';
import '../models/muscle_group.dart';

class ExerciseDatabase {
  static final Map<String, ExerciseMuscle> exercises = {
    // =========================
    // CHEST
    // =========================

    "bench bress": const ExerciseMuscle(
      primary: MuscleGroup.chest,
      secondary: [
        MuscleGroup.triceps,
        MuscleGroup.shoulders,
      ],
    ),

    "incline bench press": const ExerciseMuscle(
      primary: MuscleGroup.chest,
      secondary: [
        MuscleGroup.triceps,
        MuscleGroup.shoulders,
      ],
    ),

    "fly": const ExerciseMuscle(
      primary: MuscleGroup.chest,
    ),

    "incline chest fly": const ExerciseMuscle(
      primary: MuscleGroup.chest,
    ),

    "push-ups": const ExerciseMuscle(
      primary: MuscleGroup.chest,
      secondary: [
        MuscleGroup.triceps,
        MuscleGroup.shoulders,
      ],
    ),

    // =========================
    // BACK
    // =========================

    "lat pulldown": const ExerciseMuscle(
      primary: MuscleGroup.back,
      secondary: [
        MuscleGroup.biceps,
      ],
    ),

    "seated caple row": const ExerciseMuscle(
      primary: MuscleGroup.back,
      secondary: [
        MuscleGroup.biceps,
        MuscleGroup.rearShoulders,
      ],
    ),

    "barbell row": const ExerciseMuscle(
      primary: MuscleGroup.back,
      secondary: [
        MuscleGroup.biceps,
        MuscleGroup.rearShoulders,
      ],
    ),

    "dumbell row": const ExerciseMuscle(
      primary: MuscleGroup.back,
      secondary: [
        MuscleGroup.biceps,
        MuscleGroup.rearShoulders,
      ],
    ),

    "pull-ups": const ExerciseMuscle(
      primary: MuscleGroup.back,
      secondary: [
        MuscleGroup.biceps,
      ],
    ),

    "deadlift": const ExerciseMuscle(
      primary: MuscleGroup.back,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
        MuscleGroup.traps,
      ],
    ),



    // =========================
// LEGS
// =========================

    "barbell squat": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
      ],
    ),

    "front squat": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
      secondary: [
        MuscleGroup.glutes,
      ],
    ),

    "hack squat": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
      secondary: [
        MuscleGroup.glutes,
      ],
    ),

    "leg press": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
      ],
    ),

    "leg extension": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
    ),

    "walking lunges": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
      ],
    ),

    "bulgarian split squat": const ExerciseMuscle(
      primary: MuscleGroup.quadriceps,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.hamstrings,
      ],
    ),

    "romanian deadlift": const ExerciseMuscle(
      primary: MuscleGroup.hamstrings,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.back,
      ],
    ),

    "stiff leg deadlift": const ExerciseMuscle(
      primary: MuscleGroup.hamstrings,
      secondary: [
        MuscleGroup.glutes,
        MuscleGroup.back,
      ],
    ),

    "lying leg curl": const ExerciseMuscle(
      primary: MuscleGroup.hamstrings,
    ),

    "seated leg curl": const ExerciseMuscle(
      primary: MuscleGroup.hamstrings,
    ),

    "standing leg curl": const ExerciseMuscle(
      primary: MuscleGroup.hamstrings,
    ),

    "hip thrust": const ExerciseMuscle(
      primary: MuscleGroup.glutes,
      secondary: [
        MuscleGroup.hamstrings,
      ],
    ),

    "glute bridge": const ExerciseMuscle(
      primary: MuscleGroup.glutes,
      secondary: [
        MuscleGroup.hamstrings,
      ],
    ),

    "cable kickback": const ExerciseMuscle(
      primary: MuscleGroup.glutes,
    ),

    "standing calf raise": const ExerciseMuscle(
      primary: MuscleGroup.calves,
    ),

    "seated calf raise": const ExerciseMuscle(
      primary: MuscleGroup.calves,
    ),

    "donkey calf raise": const ExerciseMuscle(
      primary: MuscleGroup.calves,
    ),

    // =========================
// TRICEPS
// =========================

    "close grip bench press": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
      secondary: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
      ],
    ),

    "triceps pushdown": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "rope pushdown": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "overhead triceps extension": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "skull crushers": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "dips": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
      secondary: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
      ],
    ),

    "cable overhead extension": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "single arm pushdown": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "reverse grip pushdown": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "ez bar skull crusher": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "bench dips": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
      secondary: [
        MuscleGroup.chest,
      ],
    ),

    "kickbacks": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "machine triceps extension": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
    ),

    "diamond push-ups": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
      secondary: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
      ],
    ),

    "jm press": const ExerciseMuscle(
      primary: MuscleGroup.triceps,
      secondary: [
        MuscleGroup.chest,
        MuscleGroup.shoulders,
      ],
    ),

    // =========================
// ABS
// =========================

    "crunch": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "cable crunch": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "decline crunch": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "sit-up": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "hanging leg raise": const ExerciseMuscle(
      primary: MuscleGroup.abs,
      secondary: [
        MuscleGroup.obliques,
      ],
    ),

    "lying leg raise": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "reverse crunch": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "v-ups": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "toe touches": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "russian twist": const ExerciseMuscle(
      primary: MuscleGroup.obliques,
      secondary: [
        MuscleGroup.abs,
      ],
    ),

    "bicycle crunch": const ExerciseMuscle(
      primary: MuscleGroup.abs,
      secondary: [
        MuscleGroup.obliques,
      ],
    ),

    "mountain climbers": const ExerciseMuscle(
      primary: MuscleGroup.abs,
      secondary: [
        MuscleGroup.shoulders,
      ],
    ),

    "ab wheel rollout": const ExerciseMuscle(
      primary: MuscleGroup.abs,
      secondary: [
        MuscleGroup.shoulders,
      ],
    ),

    "plank": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "side plank": const ExerciseMuscle(
      primary: MuscleGroup.obliques,
      secondary: [
        MuscleGroup.abs,
      ],
    ),

    "woodchopper": const ExerciseMuscle(
      primary: MuscleGroup.obliques,
      secondary: [
        MuscleGroup.abs,
      ],
    ),

    "dragon flag": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    "flutter kicks": const ExerciseMuscle(
      primary: MuscleGroup.abs,
    ),

    // =========================
// SHOULDERS
// =========================

    "overhead press": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.triceps,
      ],
    ),

    "seated dumbbell press": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.triceps,
      ],
    ),

    "arnold press": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.triceps,
      ],
    ),

    "machine shoulder press": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.triceps,
      ],
    ),

    "military press": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.triceps,
      ],
    ),

    "lateral raise": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
    ),

    "cable lateral raise": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
    ),

    "front raise": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
    ),

    "cable front raise": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
    ),

    "rear delt fly": const ExerciseMuscle(
      primary: MuscleGroup.rearShoulders,
    ),

    "reverse pec deck": const ExerciseMuscle(
      primary: MuscleGroup.rearShoulders,
    ),

    "face pull": const ExerciseMuscle(
      primary: MuscleGroup.rearShoulders,
      secondary: [
        MuscleGroup.traps,
      ],
    ),

    "upright row": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.traps,
      ],
    ),

    "dumbbell shrugs": const ExerciseMuscle(
      primary: MuscleGroup.traps,
    ),

    "barbell shrugs": const ExerciseMuscle(
      primary: MuscleGroup.traps,
    ),

    "smith machine shoulder press": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
      secondary: [
        MuscleGroup.triceps,
      ],
    ),

    "single arm cable lateral raise": const ExerciseMuscle(
      primary: MuscleGroup.shoulders,
    ),

    "bent over lateral raise": const ExerciseMuscle(
      primary: MuscleGroup.rearShoulders,
    ),

    // =========================
    // BICEPS
    // =========================

    "barbell curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "dumbbell curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "hammer curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
      secondary: [
        MuscleGroup.forearms,
      ],
    ),

    "preacher curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "cable curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "concentration curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "ez bar curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "incline dumbbell curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "reverse curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
      secondary: [
        MuscleGroup.forearms,
      ],
    ),

    "spider curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "drag curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "machine curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "standing cable curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "bayesian cable curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
    ),

    "zottman curl": const ExerciseMuscle(
      primary: MuscleGroup.biceps,
      secondary: [
        MuscleGroup.forearms,
      ],
    ),
  };

  static ExerciseMuscle? getExercise(String name) {
    return exercises[name.trim().toLowerCase()];
  }
}