import 'package:flutter/material.dart';

import '../data/body_back.dart';
import '../data/body_front.dart';
import '../models/muscle_category.dart';
import '../models/muscle_definition.dart';
import '../models/muscle_info.dart';
import '../repositories/muscle_repository.dart';
import '../screens/muscle_detail_screen.dart';
import '../services/recovery_engine.dart';
import '../utils/muscle_color.dart';
import '../utils/muscle_slug_mapper.dart';
import '../utils/recovery_rules.dart';
import 'body_painter.dart';
import '../utils/category_recovery_summary.dart';

class HumanBodyWidget extends StatefulWidget {
  const HumanBodyWidget({super.key});

  @override
  State<HumanBodyWidget> createState() => _HumanBodyWidgetState();
}

class _HumanBodyWidgetState extends State<HumanBodyWidget> {
  bool showFront = true;
  MuscleCategory selectedCategory = MuscleCategory.chest;

  final Map<String, MuscleInfo> visualMuscleStates = {};
  final Map<String, MuscleInfo> detailedMuscleStates = {};

  final MuscleRepository repository = MuscleRepository();

  @override
  void initState() {
    super.initState();
    loadMuscles();
  }

  Future<void> loadMuscles() async {
    final activities = await repository.getLastActivities();

    visualMuscleStates.clear();
    detailedMuscleStates.clear();

    for (final definition in RecoveryRules.muscles) {
      final info = RecoveryEngine.calculate(
        muscle: definition.group,
        activity: activities[definition.group],
      );

      detailedMuscleStates[definition.group.name] = info;
    }

    final bodyParts = [
      ...bodyFront,
      ...bodyBack,
    ];

    for (final part in bodyParts) {
      if (visualMuscleStates.containsKey(part.slug)) continue;

      final groups = MuscleSlugMapper.fromSlug(part.slug);

      if (groups.isEmpty) continue;

      final infos = groups
          .map((group) => detailedMuscleStates[group.name])
          .whereType<MuscleInfo>()
          .toList();

      if (infos.isEmpty) continue;

      infos.sort(
            (a, b) => b.fatiguePercent.compareTo(a.fatiguePercent),
      );

      visualMuscleStates[part.slug] = infos.first;
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDefinitions =
    RecoveryRules.getByCategory(selectedCategory);

    return Column(
      children: [
        const SizedBox(height: 12),

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
          flex: 4,
          child: Center(
            child: FittedBox(
              child: SizedBox(
                width: 800,
                height: 1200,
                child: CustomPaint(
                  painter: BodyPainter(
                    showFront ? bodyFront : bodyBack,
                    visualMuscleStates,
                  ),
                ),
              ),
            ),
          ),
        ),

        SizedBox(
          height: 52,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: MuscleCategory.values.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = MuscleCategory.values[index];
              final selected = category == selectedCategory;

              final summary = CategoryRecoverySummary.fromStates(
                category: category,
                states: detailedMuscleStates,
              );

              final fatigue = (summary.fatiguePercent * 100).round();

              return ChoiceChip(
                label: Text("${category.displayName} $fatigue%"),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    selectedCategory = category;
                  });
                },
              );
            },
          ),
        ),

        Expanded(
          flex: 3,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 12),
            itemCount: selectedDefinitions.length,
            itemBuilder: (context, index) {
              final definition = selectedDefinitions[index];
              final info = detailedMuscleStates[definition.group.name];

              if (info == null) {
                return const SizedBox.shrink();
              }

              return _MuscleSubItem(
                definition: definition,
                info: info,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MuscleDetailScreen(
                        definition: definition,
                        info: info,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MuscleSubItem extends StatelessWidget {
  final MuscleDefinition definition;
  final MuscleInfo info;
  final VoidCallback onTap;

  const _MuscleSubItem({
    required this.definition,
    required this.info,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = MuscleColor.fromInfo(info);
    final recovery = (info.recoveryPercent * 100).round();
    final fatigue = (info.fatiguePercent * 100).round();

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 10,
          backgroundColor: color,
        ),
        title: Text(
          definition.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          "Recovery $recovery% | Fatigue $fatigue%",
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}