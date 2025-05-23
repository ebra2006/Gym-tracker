import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'workout_summary_screen.dart';
import 'streak.dart';

class WorkoutDetailsScreen extends StatefulWidget {
  final String categoryName;

  const WorkoutDetailsScreen({super.key, required this.categoryName});

  @override
  _WorkoutDetailsScreenState createState() => _WorkoutDetailsScreenState();
}
// ال streal
class _WorkoutDetailsScreenState extends State<WorkoutDetailsScreen> {
  int reps = 0;
  double weight = 0.0;
  Stopwatch _stopwatch = Stopwatch();
  String formattedTime = "00.00.00";
  Timer? _timer;
  bool isTimerRunning = false;
  int _groupNumber = 1;
  int tasbihCount = 0;

  // <-- هنا بالضبط، بعد تعريف كل المتغيرات فوق، ضيف:
  final StreakManager streakManager = StreakManager();

  Future<void> _saveWorkout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('workout_saved_today', true);

    String currentDate = DateTime.now().toString().split(' ')[0];

    // استدعاء تحميل بيانات الاستريك وتحديثها
    await streakManager.loadStreakData();
    await streakManager.updateStreak();

    // جلب عدد التمارين المحفوظة لنفس اليوم
    List<Map<String, dynamic>> savedWorkouts = _loadSavedWorkouts(prefs, currentDate);

    // لو أول مرة تحفظ تمرين اليوم، عرض رسالة تهنئة
    if (savedWorkouts.isEmpty) {
      _showCongratulationDialog();
    }

    String groupName = "Group $_groupNumber";
    Map<String, dynamic> workout = {
      'category': widget.categoryName,
      'reps': reps,
      'weight': weight,
      'duration': formattedTime,
      'group': groupName,
      'date': currentDate,
      'tasbih': tasbihCount,
    };

    savedWorkouts.add(workout);
    prefs.setString('workouts_$currentDate', json.encode(savedWorkouts));

    setState(() {
      _groupNumber++;
    });

    _showSnackBar(currentDate);

    setState(() {
      reps = 0;
      weight = 0.0;
      formattedTime = "00.00.00";
      tasbihCount = 0;
      _stopwatch.reset();
    });
  }


  List<Map<String, dynamic>> _loadSavedWorkouts(SharedPreferences prefs, String date) {
    String? workoutsJson = prefs.getString('workouts_$date');
    if (workoutsJson != null) {
      List<dynamic> decodedData = json.decode(workoutsJson);
      return List<Map<String, dynamic>>.from(decodedData);
    }
    return [];
  }

  void _showSnackBar(String date) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Training saved. Tap to view'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            List<Map<String, dynamic>> workoutData = _loadSavedWorkouts(prefs, date);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => WorkoutSummaryScreen(
                  workoutData: workoutData,
                  selectedDay: DateTime.parse(date),

                ),
              ),
            );
          },
        ),
      ),
    );
  }
  // دالة التهنءة
// هنا تحط دالة التهنئة
  void _showCongratulationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🎉 مبروك!'),
        content: Text('أنت حافظ التمرين ليوم ${streakManager.currentStreak} على التوالي! استمر كده 💪'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('تمام'),
          ),
        ],
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
        title: Text('${widget.categoryName} Workout', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600)),
        centerTitle: true,
        elevation: 4,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.purpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter the details for ${widget.categoryName}',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? <Color>[Colors.deepPurple.shade200, Colors.purpleAccent.shade100]
                        : <Color>[Colors.deepPurple.shade700, Colors.purpleAccent.shade400],
                  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            _buildCounterCard('Reps', reps, () {
              if (reps > 0) setState(() => reps--);
            }, () {
              setState(() => reps++);
            }),

            const SizedBox(height: 15),

            _buildCounterCard('Weight (kg)', weight.toStringAsFixed(1), () {
              if (weight > 0) setState(() => weight -= 2.5);
            }, () {
              setState(() => weight += 2.5);
            }),

            const SizedBox(height: 20),
//الوان الكلمة
            Text(
              'Timer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepPurple.shade700,
                shadows: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                  Shadow(
                    blurRadius: 5,
                    color: Colors.deepPurple.shade200,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
//حجم الساعة
            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(110),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.deepPurple.shade100.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: AnalogClock(stopwatch: _stopwatch),
              ),
            ),

            const SizedBox(height: 20),
//الوان التيكست
            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepPurple.shade900,
                letterSpacing: 3,
                shadows: Theme.of(context).brightness == Brightness.dark
                    ? []
                    : [
                  Shadow(
                    blurRadius: 7,
                    color: Colors.deepPurple.shade200,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Wrap(
              spacing: 16,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                _buildTimerButton('Start', startTimer),
                _buildTimerButton('Stop', stopTimer),
                _buildTimerButton('Reset', resetTimer),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              'سبحة إلكترونية',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.deepPurple.shade700,
                shadows: Theme.of(context).brightness == Brightness.dark
                    ? [] // بدون ظل في الوضع الليلي
                    : [
                  Shadow(
                    blurRadius: 4,
                    color: Colors.deepPurple.shade200,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
            ),



            const SizedBox(height: 30),
//حجم السبحة في السايز
            ElevatedButton(
              onPressed: () => setState(() => tasbihCount++),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                minimumSize: const Size(70, 70),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
                shadowColor: Colors.deepPurpleAccent,
                elevation: 12,
              ),//حجم رقم السبحة
              child: Text(
                '$tasbihCount',
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton(
              onPressed: _saveWorkout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade800,
                padding:
                    // حجم الزرار
                const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 10,
              ),
              child: const Text(
                'Save Workout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterCard(
      String label,
      dynamic value,
      VoidCallback onDecrement,
      VoidCallback onIncrement,
      ) {
    return Card(
      elevation: 6,
      shadowColor: Colors.deepPurple.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        //عرض البطاقة
        width: 265, // عرض ثابت للبطاقة
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 12),
 //حجم المربعين بتوع العدات والكيلو جرامات
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: onDecrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade300,
                      minimumSize: const Size(40, 40),
                      shape: const CircleBorder(),
                      elevation: 6,
                    ),
                    child: const Icon(Icons.remove, size: 28, color: Colors.white),
                  ),

                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.deepPurple.shade900,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      )
                      ,
                    ),
                  ),

                  ElevatedButton(
                    onPressed: onIncrement,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple.shade400,
                      minimumSize: const Size(40, 40),
                      shape: const CircleBorder(),
                      elevation: 6,
                    ),
                    child: const Icon(Icons.add, size: 28, color: Colors.white),
                  ),
                ],
              ),

            ],
          ),
        ),
      ),
    );
  }




  Widget _buildTimerButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple.shade600,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 8,
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
    );
  }
}

class AnalogClock extends StatelessWidget {
  final Stopwatch stopwatch;

  const AnalogClock({super.key, required this.stopwatch});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ClockPainter(stopwatch.elapsed),
      size: const Size(220, 220),
    );
  }
}

class _ClockPainter extends CustomPainter {
  final Duration elapsed;

  _ClockPainter(this.elapsed);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final paint = Paint()
      ..color = Colors.deepPurple.shade100
      ..style = PaintingStyle.fill;
    // Draw clock face
    canvas.drawCircle(center, radius, paint);

// Draw outer circle border
    paint
      ..color = Colors.deepPurple.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawCircle(center, radius - 3, paint);

// Calculate angles
    final seconds = elapsed.inSeconds % 60;
    final milliseconds = (elapsed.inMilliseconds % 1000) / 1000;
    final secondsAngle = (seconds + milliseconds) * 6 * pi / 180;

    final minutes = elapsed.inMinutes % 60;
    final minutesAngle = minutes * 6 * pi / 180;

    final hours = (elapsed.inHours % 12).toDouble();
    final hoursAngle = (hours * 30 + minutes * 0.5) * pi / 180;

// Draw hour hand
    final hourHandLength = radius * 0.5;
    final hourHandPaint = Paint()
      ..color = Colors.deepPurple.shade900
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final hourHandEnd = Offset(center.dx + hourHandLength * sin(hoursAngle),
        center.dy - hourHandLength * cos(hoursAngle));
    canvas.drawLine(center, hourHandEnd, hourHandPaint);

// Draw minute hand
    final minuteHandLength = radius * 0.7;
    final minuteHandPaint = Paint()
      ..color = Colors.deepPurple.shade700
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final minuteHandEnd = Offset(center.dx + minuteHandLength * sin(minutesAngle),
        center.dy - minuteHandLength * cos(minutesAngle));
    canvas.drawLine(center, minuteHandEnd, minuteHandPaint);

// Draw second hand
    final secondHandLength = radius * 0.85;
    final secondHandPaint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final secondHandEnd = Offset(center.dx + secondHandLength * sin(secondsAngle),
        center.dy - secondHandLength * cos(secondsAngle));
    canvas.drawLine(center, secondHandEnd, secondHandPaint);

// Draw center circle
    paint
      ..color = Colors.deepPurple.shade800
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, paint);

// Draw ticks for every 5 seconds
    final tickPaint = Paint()
      ..color = Colors.deepPurple.shade600
      ..strokeWidth = 2;
    for (int i = 0; i < 60; i += 5) {
      final tickLength = (i % 15 == 0) ? 15.0 : 8.0;
      final angle = i * 6 * pi / 180;
      final start = Offset(center.dx + (radius - tickLength - 10) * sin(angle),
          center.dy - (radius - tickLength - 10) * cos(angle));
      final end = Offset(center.dx + (radius - 10) * sin(angle),
          center.dy - (radius - 10) * cos(angle));
      canvas.drawLine(start, end, tickPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.elapsed != elapsed;
  }
}


