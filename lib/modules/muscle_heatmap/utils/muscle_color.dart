import 'package:flutter/material.dart';

import '../models/muscle_info.dart';
import '../models/muscle_status.dart';

class MuscleColor {
  static Color fromInfo(MuscleInfo info) {
    switch (info.status) {
      case MuscleStatus.inactive:
        return Colors.grey.shade400;

      case MuscleStatus.ready:
        return Colors.green;

      case MuscleStatus.recovering:
        return Color.lerp(
          Colors.red,
          Colors.green,
          info.recoveryPercent,
        )!;
    }
  }
}