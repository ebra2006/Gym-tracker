import 'package:flutter/material.dart';

import '../models/muscle_category.dart';
import '../models/muscle_status.dart';
import '../repositories/muscle_repository.dart';
import '../services/recovery_engine.dart';
import '../utils/recovery_rules.dart';

class MuscleDebugScreen extends StatefulWidget {
  const MuscleDebugScreen({super.key});

  @override
  State<MuscleDebugScreen> createState() => _MuscleDebugScreenState();
}

class _MuscleDebugScreenState extends State<MuscleDebugScreen> {
  final repository = MuscleRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Muscle Debug"),
      ),
      body: FutureBuilder(
        future: repository.getLastActivities(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final activities = snapshot.data!;

          return ListView.builder(
            itemCount: RecoveryRules.muscles.length,
            itemBuilder: (context, index) {
              final definition = RecoveryRules.muscles[index];

              final info = RecoveryEngine.calculate(
                muscle: definition.group,
                activity: activities[definition.group],
              );

              IconData icon;

              switch (info.status) {
                case MuscleStatus.ready:
                  icon = Icons.check_circle;
                  break;
                case MuscleStatus.recovering:
                  icon = Icons.access_time;
                  break;
                case MuscleStatus.inactive:
                  icon = Icons.remove_circle;
                  break;
              }

              return ListTile(
                leading: Icon(icon),
                title: Text(definition.displayName),
                subtitle: Text(
                  "${definition.category.displayName} | ${info.status.name} | fatigue ${(info.fatiguePercent * 100).round()}%",
                ),
                trailing: Text(
                  "${info.remainingRecovery.inHours} h",
                ),
              );
            },
          );
        },
      ),
    );
  }
}