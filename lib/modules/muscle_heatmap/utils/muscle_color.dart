import 'package:flutter/material.dart';

import '../models/muscle_info.dart';
import '../models/muscle_status.dart';

class MuscleColor {
  static Color fromInfo(MuscleInfo info) {
    if (info.status == MuscleStatus.inactive) {
      return Colors.grey.shade400;
    }

    final fatigueScore = calculateFatigueScore(info);

    if (fatigueScore >= 0.75) {
      return Colors.red;
    }

    if (fatigueScore >= 0.50) {
      return Colors.orange;
    }

    if (fatigueScore >= 0.25) {
      return Colors.yellow.shade700;
    }

    return Colors.green;
  }

  static double calculateFatigueScore(MuscleInfo info) {
    return info.fatiguePercent.clamp(0.0, 1.0).toDouble();
  }
}