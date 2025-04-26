import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  final List<Map<String, dynamic>> workoutData;

  const WorkoutSummaryScreen({
    Key? key,
    required this.selectedDay,
    required this.workoutData,
  }) : super(key: key);

  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  late List<Map<String, dynamic>> workoutData;

  @override
  void initState() {
    super.initState();
    workoutData = widget.workoutData;
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date); // مثل Apr 23, 2025
  }

  Widget animatedWorkoutItem(Map<String, dynamic> workout, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + index * 70),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 20),
          child: child,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 10),
        child: ListTile(
          title: Text('${workout['group']} - ${workout['category']}'),
          subtitle: Text(
            'Reps: ${workout['reps']}  •  Weight: ${workout['weight']} kg  •  Time: ${workout['duration']}',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Summary'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Workout Details for:',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              formatDate(widget.selectedDay),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            workoutData.isEmpty
                ? const Text(
              'No workouts found for this day.',
              style: TextStyle(fontSize: 18),
            )
                : Expanded(
              child: ListView.builder(
                itemCount: workoutData.length,
                itemBuilder: (context, index) {
                  final workout = workoutData[index];
                  return animatedWorkoutItem(workout, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
