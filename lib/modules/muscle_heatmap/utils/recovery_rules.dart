import '../models/muscle_category.dart';
import '../models/muscle_definition.dart';
import '../models/muscle_group.dart';

class RecoveryRules {
  static const List<MuscleDefinition> muscles = [
    MuscleDefinition(
      group: MuscleGroup.upperChest,
      category: MuscleCategory.chest,
      displayName: "Upper Chest",
      description: "Clavicular fibers of the pectoralis major, emphasized by incline pressing and incline fly patterns.",
      recoveryHours: 48,
      frontSvgId: "chest",
    ),
    MuscleDefinition(
      group: MuscleGroup.middleChest,
      category: MuscleCategory.chest,
      displayName: "Middle Chest",
      description: "Sternal pectoralis fibers, heavily loaded by flat presses and horizontal adduction.",
      recoveryHours: 48,
      frontSvgId: "chest",
    ),
    MuscleDefinition(
      group: MuscleGroup.lowerChest,
      category: MuscleCategory.chest,
      displayName: "Lower Chest",
      description: "Lower sternal pectoralis fibers, emphasized by dips and decline pressing angles.",
      recoveryHours: 48,
      frontSvgId: "chest",
    ),

    MuscleDefinition(
      group: MuscleGroup.frontDeltoid,
      category: MuscleCategory.shoulders,
      displayName: "Front Deltoid",
      description: "Anterior deltoid, strongly involved in pressing and shoulder flexion.",
      recoveryHours: 36,
      frontSvgId: "deltoids",
      backSvgId: "deltoids",
    ),
    MuscleDefinition(
      group: MuscleGroup.lateralDeltoid,
      category: MuscleCategory.shoulders,
      displayName: "Lateral Deltoid",
      description: "Middle deltoid, primary shoulder abductor and main target of lateral raises.",
      recoveryHours: 36,
      frontSvgId: "deltoids",
      backSvgId: "deltoids",
    ),
    MuscleDefinition(
      group: MuscleGroup.rearDeltoid,
      category: MuscleCategory.shoulders,
      displayName: "Rear Deltoid",
      description: "Posterior deltoid, active in horizontal abduction, rows, face pulls, and rear delt flys.",
      recoveryHours: 36,
      frontSvgId: "deltoids",
      backSvgId: "deltoids",
    ),

    MuscleDefinition(
      group: MuscleGroup.upperBack,
      category: MuscleCategory.back,
      displayName: "Upper Back",
      description: "General upper-back region including scapular retractors and thoracic back involvement.",
      recoveryHours: 48,
      backSvgId: "upper-back",
    ),
    MuscleDefinition(
      group: MuscleGroup.lats,
      category: MuscleCategory.back,
      displayName: "Lats",
      description: "Latissimus dorsi, emphasized by vertical pulls, pull-ups, pulldowns, and rows.",
      recoveryHours: 48,
      backSvgId: "upper-back",
    ),
    MuscleDefinition(
      group: MuscleGroup.rhomboids,
      category: MuscleCategory.back,
      displayName: "Rhomboids",
      description: "Scapular retractors, heavily involved in rows and face pulls.",
      recoveryHours: 48,
      backSvgId: "upper-back",
    ),
    MuscleDefinition(
      group: MuscleGroup.traps,
      category: MuscleCategory.back,
      displayName: "Traps",
      description: "Trapezius fibers involved in scapular elevation, retraction, and upper-back stability.",
      recoveryHours: 48,
      frontSvgId: "trapezius",
      backSvgId: "trapezius",
    ),
    MuscleDefinition(
      group: MuscleGroup.lowerBack,
      category: MuscleCategory.back,
      displayName: "Lower Back",
      description: "Spinal erector region, heavily taxed by deadlifts, hinges, and loaded spinal stabilization.",
      recoveryHours: 72,
      backSvgId: "lower-back",
    ),

    MuscleDefinition(
      group: MuscleGroup.longHeadBiceps,
      category: MuscleCategory.arms,
      displayName: "Long Head Biceps",
      description: "Outer biceps head, emphasized by shoulder-extended curls such as incline and Bayesian curls.",
      recoveryHours: 36,
      frontSvgId: "biceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.shortHeadBiceps,
      category: MuscleCategory.arms,
      displayName: "Short Head Biceps",
      description: "Inner biceps head, emphasized by preacher, concentration, and wider-grip curls.",
      recoveryHours: 36,
      frontSvgId: "biceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.brachialis,
      category: MuscleCategory.arms,
      displayName: "Brachialis",
      description: "Deep elbow flexor, strongly targeted by hammer and reverse curls.",
      recoveryHours: 36,
      frontSvgId: "biceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.tricepsLongHead,
      category: MuscleCategory.arms,
      displayName: "Triceps Long Head",
      description: "Two-joint triceps head, emphasized by overhead extensions and stretched triceps work.",
      recoveryHours: 48,
      frontSvgId: "triceps",
      backSvgId: "triceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.tricepsLateralHead,
      category: MuscleCategory.arms,
      displayName: "Triceps Lateral Head",
      description: "Outer triceps head, strongly involved in pushdowns and heavy pressing.",
      recoveryHours: 36,
      frontSvgId: "triceps",
      backSvgId: "triceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.tricepsMedialHead,
      category: MuscleCategory.arms,
      displayName: "Triceps Medial Head",
      description: "Deep triceps head active across most elbow extension patterns.",
      recoveryHours: 36,
      frontSvgId: "triceps",
      backSvgId: "triceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.forearms,
      category: MuscleCategory.arms,
      displayName: "Forearms",
      description: "Grip, wrist flexor, wrist extensor, and brachioradialis contribution.",
      recoveryHours: 24,
      frontSvgId: "forearm",
      backSvgId: "forearm",
    ),

    MuscleDefinition(
      group: MuscleGroup.upperAbs,
      category: MuscleCategory.core,
      displayName: "Upper Abs",
      description: "Upper rectus abdominis fibers, emphasized by crunching and spinal flexion.",
      recoveryHours: 24,
      frontSvgId: "abs",
    ),
    MuscleDefinition(
      group: MuscleGroup.lowerAbs,
      category: MuscleCategory.core,
      displayName: "Lower Abs",
      description: "Lower rectus abdominis region, emphasized by posterior pelvic tilt and leg raise patterns.",
      recoveryHours: 24,
      frontSvgId: "abs",
    ),
    MuscleDefinition(
      group: MuscleGroup.obliques,
      category: MuscleCategory.core,
      displayName: "Obliques",
      description: "Internal and external obliques, active in rotation, side bending, and anti-rotation.",
      recoveryHours: 24,
      frontSvgId: "obliques",
    ),
    MuscleDefinition(
      group: MuscleGroup.serratus,
      category: MuscleCategory.core,
      displayName: "Serratus",
      description: "Serratus anterior, active in scapular protraction, rollouts, push-up plus, and overhead control.",
      recoveryHours: 24,
      frontSvgId: "obliques",
    ),

    MuscleDefinition(
      group: MuscleGroup.rectusFemoris,
      category: MuscleCategory.legs,
      displayName: "Rectus Femoris",
      description: "Two-joint quadriceps muscle involved in knee extension and hip flexion.",
      recoveryHours: 48,
      frontSvgId: "quadriceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.vastusLateralis,
      category: MuscleCategory.legs,
      displayName: "Vastus Lateralis",
      description: "Outer quadriceps muscle, heavily loaded in squats, leg press, and extensions.",
      recoveryHours: 48,
      frontSvgId: "quadriceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.vastusMedialis,
      category: MuscleCategory.legs,
      displayName: "Vastus Medialis",
      description: "Inner quadriceps muscle involved in knee extension and knee tracking.",
      recoveryHours: 48,
      frontSvgId: "quadriceps",
    ),
    MuscleDefinition(
      group: MuscleGroup.vastusIntermedius,
      category: MuscleCategory.legs,
      displayName: "Vastus Intermedius",
      description: "Deep quadriceps muscle contributing strongly to knee extension.",
      recoveryHours: 48,
      frontSvgId: "quadriceps",
    ),

    MuscleDefinition(
      group: MuscleGroup.bicepsFemoris,
      category: MuscleCategory.legs,
      displayName: "Biceps Femoris",
      description: "Lateral hamstring muscle involved in hip extension and knee flexion.",
      recoveryHours: 48,
      backSvgId: "hamstring",
    ),
    MuscleDefinition(
      group: MuscleGroup.semitendinosus,
      category: MuscleCategory.legs,
      displayName: "Semitendinosus",
      description: "Medial hamstring muscle involved in hip extension and knee flexion.",
      recoveryHours: 48,
      backSvgId: "hamstring",
    ),
    MuscleDefinition(
      group: MuscleGroup.semimembranosus,
      category: MuscleCategory.legs,
      displayName: "Semimembranosus",
      description: "Medial hamstring muscle active in hinge and leg curl patterns.",
      recoveryHours: 48,
      backSvgId: "hamstring",
    ),

    MuscleDefinition(
      group: MuscleGroup.gluteMax,
      category: MuscleCategory.legs,
      displayName: "Glute Max",
      description: "Primary hip extensor, heavily loaded by hip thrusts, squats, lunges, and deadlifts.",
      recoveryHours: 48,
      backSvgId: "gluteal",
    ),
    MuscleDefinition(
      group: MuscleGroup.gluteMed,
      category: MuscleCategory.legs,
      displayName: "Glute Med",
      description: "Hip abductor and pelvic stabilizer, active in single-leg and abduction work.",
      recoveryHours: 36,
      backSvgId: "gluteal",
    ),
    MuscleDefinition(
      group: MuscleGroup.gluteMin,
      category: MuscleCategory.legs,
      displayName: "Glute Min",
      description: "Deep hip abductor and stabilizer assisting glute medius.",
      recoveryHours: 36,
      backSvgId: "gluteal",
    ),

    MuscleDefinition(
      group: MuscleGroup.gastrocnemius,
      category: MuscleCategory.legs,
      displayName: "Gastrocnemius",
      description: "Two-joint calf muscle emphasized by standing calf raises.",
      recoveryHours: 24,
      frontSvgId: "calves",
      backSvgId: "calves",
    ),
    MuscleDefinition(
      group: MuscleGroup.soleus,
      category: MuscleCategory.legs,
      displayName: "Soleus",
      description: "Deep calf muscle emphasized by seated calf raises and bent-knee plantar flexion.",
      recoveryHours: 24,
      frontSvgId: "calves",
      backSvgId: "calves",
    ),
    MuscleDefinition(
      group: MuscleGroup.hipFlexors,
      category: MuscleCategory.legs,
      displayName: "Hip Flexors",
      description: "Anterior hip flexor group active in leg raises, sit-ups, and sprint-like hip flexion.",
      recoveryHours: 36,
      frontSvgId: "adductors",
    ),
    MuscleDefinition(
      group: MuscleGroup.adductors,
      category: MuscleCategory.legs,
      displayName: "Adductors",
      description: "Inner thigh muscles involved in squats, lunges, sumo pulls, and hip adduction.",
      recoveryHours: 36,
      frontSvgId: "adductors",
      backSvgId: "adductors",
    ),
    MuscleDefinition(
      group: MuscleGroup.tibialisAnterior,
      category: MuscleCategory.legs,
      displayName: "Tibialis Anterior",
      description: "Front shin muscle responsible for dorsiflexion and ankle control.",
      recoveryHours: 24,
      frontSvgId: "tibialis",
    ),
  ];

  static MuscleDefinition getDefinition(MuscleGroup group) {
    return muscles.firstWhere((muscle) => muscle.group == group);
  }

  static List<MuscleDefinition> getByCategory(MuscleCategory category) {
    return muscles.where((muscle) => muscle.category == category).toList();
  }

  static List<MuscleDefinition> getByVisualSlug(String slug) {
    return muscles
        .where((muscle) => muscle.frontSvgId == slug || muscle.backSvgId == slug)
        .toList();
  }
}