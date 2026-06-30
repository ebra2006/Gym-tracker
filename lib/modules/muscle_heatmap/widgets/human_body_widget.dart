import 'package:flutter/material.dart';

import '../data/body_back.dart';
import '../data/body_front.dart';
import '../models/muscle_info.dart';
import 'body_painter.dart';
import 'muscle_status_list.dart';


//جدبد

import '../repositories/muscle_repository.dart';
import '../services/recovery_engine.dart';
import '../utils/muscle_slug_mapper.dart';





class HumanBodyWidget extends StatefulWidget {
  const HumanBodyWidget({super.key});

  @override
  State<HumanBodyWidget> createState() => _HumanBodyWidgetState();
}

class _HumanBodyWidgetState extends State<HumanBodyWidget> {
  bool showFront = true;

  // مؤقتًا لحد ما نربطه بالـ Repository
  final Map<String, MuscleInfo> muscleStates = {};

  final MuscleRepository repository = MuscleRepository();
  @override
  void initState() {
    super.initState();
    loadMuscles();
  }
  Future<void> loadMuscles() async {
    final activities = await repository.getLastActivities();

    muscleStates.clear();

    final bodyParts = [
      ...bodyFront,
      ...bodyBack,
    ];

    for (final part in bodyParts) {
      final group = MuscleSlugMapper.fromSlug(part.slug);

      if (group == null) continue;

      if (muscleStates.containsKey(part.slug)) continue;

      muscleStates[part.slug] = RecoveryEngine.calculate(
        muscle: group,
        lastWorkout: activities[group],
      );
    }

    if (mounted) {
      setState(() {});
    }
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),

        SegmentedButton<bool>(
          segments: const [
            ButtonSegment(
              value: true,
              label: Text("Front"),
            ),
            ButtonSegment(
              value: false,
              label: Text("Back"),
            ),
          ],
          selected: {showFront},
          onSelectionChanged: (value) {
            setState(() {
              showFront = value.first;
            });
          },
        ),

        Expanded(
          child: Center(
            child: FittedBox(
              child: SizedBox(
                width: 800,
                height: 1200,
                child: CustomPaint(
                  painter: BodyPainter(
                    showFront ? bodyFront : bodyBack,
                    muscleStates,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        Expanded(
          child: MuscleStatusList(
            muscleStates: muscleStates,
          ),
        ),
      ],
    );
  }
}