import 'package:flutter/material.dart';

import '../widgets/human_body_widget.dart';

class MuscleHeatMapScreen extends StatelessWidget {
  const MuscleHeatMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Muscle Heat Map"),
      ),
      body: const HumanBodyWidget(),
    );
  }
}