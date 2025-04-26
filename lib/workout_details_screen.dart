import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_summary_screen.dart'; // تأكد من أن لديك هذه الشاشة

class WorkoutDetailsScreen extends StatefulWidget {
  final String categoryName;

  const WorkoutDetailsScreen({super.key, required this.categoryName});

  @override
  _WorkoutDetailsScreenState createState() => _WorkoutDetailsScreenState();
}

class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  int reps = 0;
  double weight = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  String formattedTime = "00.00.00";
  Timer? _timer;
  bool isTimerRunning = false;
  int _groupNumber = 1;
  int tasbihCount = 0; // متغير لحفظ عدد التسبيحات

  // لحفظ التمرين في SharedPreferences
  Future<void> _saveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    String groupName = "Group $_groupNumber"; // تسمية المجموعة بتزايد
    String currentDate = DateTime.now().toString().split(' ')[0]; // الحصول على التاريخ الحالي بتنسيق yyyy-mm-dd
    Map<String, dynamic> workout = {
      'category': widget.categoryName,
      'reps': reps,
      'weight': weight,
      'duration': formattedTime,
      'group': groupName,
      'date': currentDate, // إضافة التاريخ للمفتاح 'date'
      'tasbih': tasbihCount, // إضافة عدد التسبيحات
    };

    // حفظ التمرين في SharedPreferences
    List<Map<String, dynamic>> savedWorkouts = _loadSavedWorkouts(prefs, currentDate);
    savedWorkouts.add(workout);
    prefs.setString('workouts_$currentDate', json.encode(savedWorkouts)); // حفظ البيانات تحت التاريخ المحدد

    // زيادة رقم المجموعة للتسمية في المرة القادمة
    setState(() {
      _groupNumber++;
    });

    // عرض SnackBar بعد الحفظ
    _showSnackBar(currentDate);

    // تصفير العدادات
    setState(() {
      reps = 0;
      weight = 0.0;
      formattedTime = "00.00.00";
      tasbihCount = 0; // إعادة تعيين عدد التسبيحات
      _stopwatch.reset(); // إعادة تعيين الـ Stopwatch
    });
  }

  // لتحميل التمرين المحفوظ من SharedPreferences
  List<Map<String, dynamic>> _loadSavedWorkouts(SharedPreferences prefs, String date) {
    String? workoutsJson = prefs.getString('workouts_$date');
    if (workoutsJson != null) {
      List<dynamic> decodedData = json.decode(workoutsJson);
      return List<Map<String, dynamic>>.from(decodedData);
    }
    return [];
  }

  // لعرض SnackBar بعد حفظ التمرين
  void _showSnackBar(String date) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Training saved. Tap to view'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () async {
            // الانتقال إلى صفحة WorkoutSummaryScreen مع التاريخ المحدد
            final prefs = await SharedPreferences.getInstance();
            List<Map<String, dynamic>> workoutData = _loadSavedWorkouts(prefs, date);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutSummaryScreen(
                  workoutData: workoutData, // تمرير workoutData
                  selectedDay: DateTime.parse(date), // إرسال التاريخ الحالي
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _stopwatch.stop();
    _timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    if (!isTimerRunning) {
      _stopwatch.start();
      isTimerRunning = true;
      _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
        setState(() {
          int minutes = _stopwatch.elapsed.inMinutes;
          int seconds = _stopwatch.elapsed.inSeconds % 60;
          int milliseconds = (_stopwatch.elapsed.inMilliseconds % 1000) ~/ 10;

          formattedTime =
          "${minutes.toString().padLeft(2, '0')}.${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}";
        });
      });
    }
  }

  void stopTimer() {
    if (isTimerRunning) {
      _stopwatch.stop();
      _timer?.cancel();
      setState(() {
        isTimerRunning = false;
      });
    }
  }

  void resetTimer() {
    _stopwatch.reset();
    setState(() {
      formattedTime = "00.00.00";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryName} Workout', style: TextStyle(fontSize: 24)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Enter the details for ${widget.categoryName}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            // Reps
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Reps: $reps', style: const TextStyle(fontSize: 24)),
                IconButton(
                  icon: const Icon(Icons.remove, size: 30),
                  onPressed: () => setState(() {
                    if (reps > 0) reps--;
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 30),
                  onPressed: () => setState(() {
                    reps++;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Weight
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Weight: ${weight.toStringAsFixed(1)} kg', style: const TextStyle(fontSize: 24)),
                IconButton(
                  icon: const Icon(Icons.remove, size: 30),
                  onPressed: () => setState(() {
                    if (weight > 0) weight -= 2.5;
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.add, size: 30),
                  onPressed: () => setState(() {
                    weight += 2.5;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Timer
            Text(
              'Timer: $formattedTime',
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Timer buttons using Wrap to prevent overflow
            Wrap(
              spacing: 10,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: startTimer,
                  child: const Text('Start Timer', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: stopTimer,
                  child: const Text('Stop Timer', style: TextStyle(fontSize: 20)),
                ),
                ElevatedButton(
                  onPressed: resetTimer,
                  child: const Text('Reset Timer', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Tasbih (سبحة)
            Column(
              children: [
                Text(
                  'سبحة إلكترونية في وقت الراحة',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => setState(() {
                    tasbihCount++;
                  }),
                  style: ElevatedButton.styleFrom(

                  ),
                  child: Text(
                    '$tasbihCount',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveWorkout, // حفظ التمرين بما في ذلك التسبيح
                  child: const Text('Save Workout', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

