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
  String workoutNote = ''; // النوتات

  Key _resetKey = UniqueKey(); // 🔹 أضفه هنا
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
      'note': workoutNote,  // ← أضف السطر ده الموتاتتتتتت65564545
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
      workoutNote = '';  // ← مسح نص الملاحظة بعد الحفظ
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
//النوتات 5456456456456
  Future<void> _showNoteBottomSheet(BuildContext context) async {
    final TextEditingController _noteController = TextEditingController(text: workoutNote);
    final RegExp validChars = RegExp(r'^[a-zA-Z0-9\u0600-\u06FF\s]*$'); // حروف عربي، إنجليزي، أرقام ومسافات

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _noteController,
                    autofocus: true,
                    maxLength: 100,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Enter your note',
                      border: OutlineInputBorder(),
                      counterText: '${_noteController.text.length}/100',
                    ),
                    onChanged: (value) {
                      setModalState(() {}); // فقط لتحديث العداد
                    },
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      String noteText = _noteController.text.trim();

                      if (!validChars.hasMatch(noteText)) {
                        // لو فيه رموز غير مسموحة، نعرض تحذير
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('تحذير'),
                            content: const Text('يرجى إدخال حروف أو أرقام فقط بدون رموز غريبة.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop(); // إغلاق التنبيه
                                },
                                child: const Text('حسناً'),
                              ),
                            ],
                          ),
                        );
                      } else {
                        Navigator.pop(context, noteText); // ترجع الملاحظة فقط لو صحيحة
                      }
                    },
                    child: const Text('Save Note'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );

    // حفظ النتيجة
    if (result != null) {
      setState(() {
        workoutNote = result;
      });
    }
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
    final theme = Theme.of(context);

    return Scaffold(
      //الاب باااااااااار
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final titleText = '${widget.categoryName} Workout';

            return Container(
              color: Colors.transparent,
              child: Stack(
                children: [
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.of(context).pop(),
                            color: theme.iconTheme.color,
                          ),
                          const Spacer(),

                          // هنا نستخدم شرط بسيط
                          if (widget.categoryName.length <= 13)
                            Text(
                              '${widget.categoryName} Workout',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: theme.primaryColor,
                              ),
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.categoryName.substring(0, 13) + '…',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                Text(
                                  'Workout',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryColor,
                                  ),
                                ),
                              ],
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
            );
          },
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
                color: theme.colorScheme.onBackground,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 25),

            _buildCounterCard(
              'Reps',
              reps,
                  () {
                if (reps > 0) setState(() => reps--);
              },
                  () {
                setState(() => reps++);
              },
              theme.primaryColor,
            ),

            const SizedBox(height: 15),

            _buildCounterCard(
              'Weight (kg)',
              weight.toStringAsFixed(1),
                  () {
                if (weight > 0) setState(() => weight -= 2.5);
              },
                  () {
                setState(() => weight += 2.5);
              },
              theme.primaryColor,
            ),

            const SizedBox(height: 20),

            Text(
              'Timer',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(110),
                  color: theme.colorScheme.surface,
                ),
                child: AnalogClock(stopwatch: _stopwatch),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              formattedTime,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onBackground,
                letterSpacing: 3,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _buildTimerIconButton(
                    isTimerRunning ? Icons.pause_circle_filled : Icons.play_circle_fill,
                        () {
                      if (isTimerRunning) {
                        stopTimer();
                      } else {
                        startTimer();
                      }
                    },
                    key: ValueKey<bool>(isTimerRunning),
                    size: 48,
                    padding: 16,
                    color: theme.primaryColor,
                  ),
                ),

                const SizedBox(width: 24),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _buildTimerIconButton(
                    Icons.refresh,
                        () {
                      setState(() {
                        resetTimer();
                        _resetKey = UniqueKey();
                      });
                    },
                    key: _resetKey,
                    size: 48,
                    padding: 16,
                    color: theme.primaryColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            Text(
              'Tasbeeh counter',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onBackground,
              ),
            ),

            const SizedBox(height: 30),

            OutlinedButton(
              onPressed: () => setState(() => tasbihCount++),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(70)),
                minimumSize: const Size(70, 70),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                '$tasbihCount',
                style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
            ),

            const SizedBox(height: 25),
//زر النوتات 846456456456
            OutlinedButton(
              onPressed: () => _showNoteBottomSheet(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              child: Text(
                'Add Note',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
            ),
            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: () {
                _saveWorkout(); // دالتك الأصلية لحفظ التمرين
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              child: Text(
                'Save Workout',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.primaryColor),
              ),
            ),

          ],
        ),
      ),
    );
  }

// تعديل الدالة _buildCounterCard لتكون الأزرار بإطار فقط بدون تعبئة
  Widget _buildCounterCard(
      String label,
      dynamic value,
      VoidCallback onDecrement,
      VoidCallback onIncrement,
      Color themeColor,
      ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 6,
      shadowColor: Colors.deepPurple.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SizedBox(
        width: 265,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: onDecrement,
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      side: BorderSide(color: themeColor, width: 2),
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.remove, size: 28, color: themeColor),
                  ),
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '$value',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: onIncrement,
                    style: OutlinedButton.styleFrom(
                      shape: const CircleBorder(),
                      side: BorderSide(color: themeColor, width: 2),
                      minimumSize: const Size(40, 40),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(Icons.add, size: 28, color: themeColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerIconButton(
      IconData icon,
      VoidCallback onPressed, {
        Key? key,
        double size = 28,
        double padding = 16,
        Color? color,
      }) {
    return OutlinedButton(
      key: key,
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        shape: const CircleBorder(),
        side: BorderSide(color: color ?? Colors.blue, width: 2),
        padding: EdgeInsets.all(padding),
        minimumSize: Size(size + padding * 2, size + padding * 2),
      ),
      child: Icon(icon, size: size, color: color),
    );
  }



}

class AnalogClock extends StatelessWidget {
  final Stopwatch stopwatch;

  const AnalogClock({super.key, required this.stopwatch});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomPaint(
      painter: _ClockPainter(stopwatch.elapsed, theme.brightness, theme.primaryColor),
      size: const Size(220, 220),
    );
  }
}


class _ClockPainter extends CustomPainter {
  final Duration elapsed;
  final Brightness brightness;
  final Color themeColor;

  _ClockPainter(this.elapsed, this.brightness, this.themeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // لون عكس الخلفية
    final oppositeColor = brightness == Brightness.dark ? Colors.white : Colors.black87;

    // رسم وجه الساعة (خلفية)
    final facePaint = Paint()
      ..color = brightness == Brightness.dark ? Colors.black : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, facePaint);

    // رسم الفريم الخارجي بخط رفيع وواضح
    final framePaint = Paint()
      ..color = oppositeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius - 1.5, framePaint);

    // رسم شرطات الدقائق (كل دقيقة، خط صغير جداً)
    final tickPaint = Paint()
      ..color = oppositeColor.withOpacity(0.5)
      ..strokeWidth = 1;

    for (int i = 0; i < 60; i++) {
      final angle = i * 6 * pi / 180;
      final tickLength = (i % 5 == 0) ? 8.0 : 4.0;
      final start = Offset(
        center.dx + (radius - tickLength - 10) * sin(angle),
        center.dy - (radius - tickLength - 10) * cos(angle),
      );
      final end = Offset(
        center.dx + (radius - 10) * sin(angle),
        center.dy - (radius - 10) * cos(angle),
      );
      canvas.drawLine(start, end, tickPaint);
    }

    // رسم أرقام الساعة من 5 إلى 60 كل 5 دقائق
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final textStyle = TextStyle(
      color: oppositeColor,
      fontSize: radius * 0.12,
      fontWeight: FontWeight.w600,
    );

    for (int i = 1; i <= 12; i++) {
      final number = (i * 5).toString();
      final angle = i * 30 * pi / 180;
      final position = Offset(
        center.dx + (radius - 30) * sin(angle),
        center.dy - (radius - 30) * cos(angle),
      );

      textPainter.text = TextSpan(text: number, style: textStyle);
      textPainter.layout();

      final offset = Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }

    // حساب الزوايا للعقارب
    final seconds = elapsed.inSeconds % 60;
    final milliseconds = (elapsed.inMilliseconds % 1000) / 1000;
    final secondsAngle = (seconds + milliseconds) * 6 * pi / 180;

    final minutes = elapsed.inMinutes % 60;
    final minutesAngle = minutes * 6 * pi / 180;

    final hours = (elapsed.inHours % 12).toDouble();
    final hoursAngle = (hours * 30 + minutes * 0.5) * pi / 180;

    // رسم عقرب الساعة (عكس لون الخلفية)
    final hourHandLength = radius * 0.5;
    final hourHandPaint = Paint()
      ..color = oppositeColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final hourHandEnd = Offset(
      center.dx + hourHandLength * sin(hoursAngle),
      center.dy - hourHandLength * cos(hoursAngle),
    );
    canvas.drawLine(center, hourHandEnd, hourHandPaint);

    // رسم عقرب الدقائق (عكس لون الخلفية)
    final minuteHandLength = radius * 0.7;
    final minuteHandPaint = Paint()
      ..color = oppositeColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    final minuteHandEnd = Offset(
      center.dx + minuteHandLength * sin(minutesAngle),
      center.dy - minuteHandLength * cos(minutesAngle),
    );
    canvas.drawLine(center, minuteHandEnd, minuteHandPaint);

    // رسم عقرب الثواني (لون الثيم)
    final secondHandLength = radius * 0.85;
    final secondHandPaint = Paint()
      ..color = themeColor
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final secondHandEnd = Offset(
      center.dx + secondHandLength * sin(secondsAngle),
      center.dy - secondHandLength * cos(secondsAngle),
    );
    canvas.drawLine(center, secondHandEnd, secondHandPaint);

    // نقطة مركز الساعة
    final centerDotPaint = Paint()
      ..color = themeColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, centerDotPaint);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.elapsed != elapsed ||
        oldDelegate.brightness != brightness ||
        oldDelegate.themeColor != themeColor;
  }
}
