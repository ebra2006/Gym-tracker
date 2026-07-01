import 'package:flutter/material.dart';

import '../models/muscle_info.dart';
import '../utils/recovery_rules.dart';
import 'muscle_status_card.dart';

class MuscleStatusList extends StatelessWidget {
  final Map<String, MuscleInfo> muscleStates;

  const MuscleStatusList({
    super.key,
    required this.muscleStates,
  });

  @override
  Widget build(BuildContext context) {
    final entries = muscleStates.entries.toList();

    entries.sort((a, b) {
      final aFatigue = a.value.fatiguePercent;
      final bFatigue = b.value.fatiguePercent;

      if (aFatigue != bFatigue) {
        return bFatigue.compareTo(aFatigue);
      }

      return a.key.compareTo(b.key);
    });

    return ListView.builder(
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final definition = RecoveryRules.getDefinition(entry.value.muscle);

        return MuscleStatusCard(
          muscleName: definition.displayName,
          info: entry.value,
        );
      },
    );
  }
}