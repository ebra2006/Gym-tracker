import 'package:flutter/material.dart';

import '../models/muscle_info.dart';
import '../models/muscle_status.dart';
import '../utils/muscle_color.dart';

class MuscleStatusCard extends StatelessWidget {
  final String muscleName;
  final MuscleInfo info;

  const MuscleStatusCard({
    super.key,
    required this.muscleName,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final color = MuscleColor.fromInfo(info);

    String statusText;

    switch (info.status) {
      case MuscleStatus.ready:
        statusText = "Ready to train";
        break;
      case MuscleStatus.recovering:
        statusText = "${info.remainingRecovery.inHours} hours remaining";
        break;
      case MuscleStatus.inactive:
        statusText = "Not trained recently";
        break;
    }

    final fatiguePercent = (info.fatiguePercent * 100).round();
    final recoveryPercent = (info.recoveryPercent * 100).round();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 8,
                  backgroundColor: color,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    muscleName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ),
                Text(
                  "$recoveryPercent%",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: info.recoveryPercent,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              statusText,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Fatigue: $fatiguePercent%  |  Recovery Time: ${info.recoveryHours}h",
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            if (info.lastExerciseName != null) ...[
              const SizedBox(height: 6),
              Text(
                "Last: ${info.lastExerciseName} (${info.lastImpactPercent ?? 0}%)",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}