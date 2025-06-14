import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class WorkoutSummaryScreen extends StatefulWidget {
  final DateTime selectedDay;
  final List<Map<String, dynamic>> workoutData;

  const WorkoutSummaryScreen({
    super.key,
    required this.selectedDay,
    required this.workoutData,
  });


  @override
  State<WorkoutSummaryScreen> createState() => _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends State<WorkoutSummaryScreen> {
  late List<Map<String, dynamic>> workoutData;

  @override
  void initState() {
    super.initState();
    workoutData = widget.workoutData;

    for (var workout in workoutData) {
      debugPrint('📌 Workout note: ${workout['note']}');
    }


    _saveWorkoutData();
  }


  Future<void> _saveWorkoutData() async {
    final prefs = await SharedPreferences.getInstance();
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.selectedDay);
    final encodedData = jsonEncode(workoutData);
    await prefs.setString('workouts_$formattedDate', encodedData);
  }

  String formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date); // مثل Apr 23, 2025
  }

  Widget animatedWorkoutItem(Map<String, dynamic> workout, int index) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isCardio = workout['group']?.toString().toLowerCase() == 'cardio';

    bool hasValue(dynamic val) {
      if (val == null) return false;
      if (val is String && val.trim().isEmpty) return false;
      return true;
    }

    // اجمع الحقول المراد عرضها حسب النوع:
    List<Widget> infoFields = [];

    if (isCardio) {
      if (hasValue(workout['duration'])) {
        infoFields.add(_buildInfoField('Time', workout['duration'].toString()));
      }
    } else {
      if (hasValue(workout['reps'])) {
        infoFields.add(_buildInfoField('Reps', workout['reps'].toString()));
      }
      if (hasValue(workout['weight'])) {
        if (infoFields.isNotEmpty) infoFields.add(_verticalDivider());
        infoFields.add(_buildInfoField('Weight', '${workout['weight']} kg'));
      }
      if (hasValue(workout['duration'])) {
        if (infoFields.isNotEmpty) infoFields.add(_verticalDivider());
        infoFields.add(_buildInfoField('Time', workout['duration'].toString()));
      }
    }

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
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.symmetric(vertical: 10),
        shadowColor: primaryColor.withAlpha((0.3 * 255).round()),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${workout['group']} - ${workout['category']}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(children: infoFields),
              if (!isCardio &&
                  workout.containsKey('note') &&
                  workout['note'] != null &&
                  workout['note'].toString().trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 14),
                  child: Text(
                    'ملاحظة: ${workout['note']}',
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildInfoField(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              )),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: theme.iconTheme.color,
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        'Workout Summary',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Divider(height: 1, thickness: 1),
              ),
            ],
          ),
        ),
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
