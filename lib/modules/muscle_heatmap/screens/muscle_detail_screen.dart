import 'package:flutter/material.dart';

import '../models/muscle_category.dart';
import '../models/muscle_definition.dart';
import '../models/muscle_info.dart';
import '../models/muscle_status.dart';
import '../utils/muscle_color.dart';

class MuscleDetailScreen extends StatelessWidget {
  final MuscleDefinition definition;
  final MuscleInfo info;

  const MuscleDetailScreen({
    super.key,
    required this.definition,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final color = MuscleColor.fromInfo(info);
    final recoveryPercent = (info.recoveryPercent * 100).round();
    final fatiguePercent = (info.fatiguePercent * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: Text(definition.displayName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  definition.displayName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            definition.category.displayName,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(definition.description),
          const SizedBox(height: 24),
          _DetailTile(
            title: "Status",
            value: _statusText(info.status),
          ),
          _DetailTile(
            title: "Recovery",
            value: "$recoveryPercent%",
          ),
          _DetailTile(
            title: "Fatigue",
            value: "$fatiguePercent%",
          ),
          _DetailTile(
            title: "Recovery Time",
            value: "${info.recoveryHours} hours",
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: info.recoveryPercent,
              minHeight: 10,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Last Targeted Exercise",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _DetailTile(
            title: "Exercise",
            value: info.lastExerciseName ?? "No recent exercise",
          ),
          _DetailTile(
            title: "Impact",
            value: info.lastImpactPercent == null
                ? "-"
                : "${info.lastImpactPercent}%",
          ),
          _DetailTile(
            title: "Last Time",
            value: info.lastWorkout == null
                ? "Not trained recently"
                : _formatDateTime(info.lastWorkout!),
          ),
          _DetailTile(
            title: "Remaining",
            value: _formatDuration(info.remainingRecovery),
          ),
        ],
      ),
    );
  }

  String _statusText(MuscleStatus status) {
    switch (status) {
      case MuscleStatus.ready:
        return "Ready to train";
      case MuscleStatus.recovering:
        return "Recovering";
      case MuscleStatus.inactive:
        return "Not trained recently";
    }
  }

  String _formatDateTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return "${date.year}-${_two(date.month)}-${_two(date.day)}  $hour:$minute";
  }

  String _formatDuration(Duration duration) {
    if (duration == Duration.zero) return "0 min";

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours <= 0) return "$minutes min";
    if (minutes == 0) return "$hours h";

    return "$hours h $minutes min";
  }

  String _two(int value) {
    return value.toString().padLeft(2, '0');
  }
}

class _DetailTile extends StatelessWidget {
  final String title;
  final String value;

  const _DetailTile({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}