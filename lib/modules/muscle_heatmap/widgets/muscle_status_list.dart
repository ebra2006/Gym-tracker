import 'package:flutter/material.dart';

import '../models/muscle_info.dart';
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

    entries.sort((a, b) => a.key.compareTo(b.key));

    return ListView.builder(
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];

        return MuscleStatusCard(
          muscleName: _formatName(entry.key),
          info: entry.value,
        );
      },
    );
  }

  String _formatName(String slug) {
    return slug
        .replaceAll('-', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : word[0].toUpperCase() + word.substring(1),
    )
        .join(' ');
  }
}