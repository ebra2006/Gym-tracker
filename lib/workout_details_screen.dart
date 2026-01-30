import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_summary_screen.dart';
import 'streak.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  int _groupNumber = 1;
  int tasbihCount = 0;
  String workoutNote = ''; // النوتات

   // 🔹 أضفه هنا
  // <-- هنا بالضبط، بعد تعريف كل المتغيرات فوق، ضيف:
  final StreakManager streakManager = StreakManager();

// هنا الفاليديشن بتاع الوزن والعدات
  bool _validateInputs() {
    if (reps <= 0) {
      _showError("Please select reps");
      return false;
    }
    if (weight <= 0) {
      _showError("Please select weight");
      return false;
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(
            color: Colors.black, //  أسود دايمًا
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.yellow,
        duration: const Duration(seconds: 2),
      ),
    );
  }





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
//مسح قيم العدات والوزن بعد المستخدم ما يخلص
    setState(() {
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
                            title: const Text('Warning'),
                            content: const Text(
                              'Please enter only letters and numbers without special characters.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(ctx).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      }
                      else {
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

            if (!mounted) return;  // متأكد أن الـ widget موجودة
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: StatefulBuilder(
              builder: (context, setState) {
                final isDarkMode = Theme.of(context).brightness == Brightness.dark;

                return Container(
                  padding: const EdgeInsets.all(24),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.white,  // خلفية تناسب الوضع
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: -8.0, end: 8.0),
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOut,
                        builder: (context, value, child) {
                          double scale = 1 + (value.abs() / 40);
                          double rotation = value / 50;
                          return Transform.translate(
                            offset: Offset(value, 0),
                            child: Transform.rotate(
                              angle: rotation,
                              child: Transform.scale(
                                scale: scale,
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
                        onEnd: () {
                          Future.delayed(Duration.zero, () {
                            setState(() {});
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      Text(
                        '🚀 Awesome!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600, // لون ممتاز وجذاب
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '🔥 Keep the streak going!\n'
                            'Workout day ${streakManager.currentStreak} in a row!\n'
                            'You’re doing great 💪 Stay strong!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),



                      const SizedBox(height: 24),

                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Keep going'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );

  }



  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(100.r),
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.arrow_back,
                        color: isDark ? Colors.white : Colors.black87,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '${widget.categoryName} Workout',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 48.w), // للتوازن
                ],
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 50.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter the details for ${widget.categoryName}',
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 25.h),

            Row(
              children: [
                _buildScrollPickerCard(
                  label: 'Reps',
                  initialValue: reps,
                  minValue: 0,
                  maxValue: 100,
                  onSelectedItemChanged: (val) {
                    setState(() => reps = val);
                  },
                  themeColor: theme.primaryColor,
                ),
                SizedBox(width: 12.w),
                _buildScrollPickerCard(
                  label: 'Weight (kg)',
                  initialValue: (weight ~/ 2.5),
                  minValue: 0,
                  maxValue: 200,
                  onSelectedItemChanged: (val) {
                    setState(() => weight = val * 2.5);
                  },
                  themeColor: theme.primaryColor,
                  isWeight: true,
                ),
              ],
            ),


            SizedBox(height: 30.h),

            OutlinedButton(
              onPressed: () => _showNoteBottomSheet(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor, width: 2.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              ),
              child: Text(
                'Add Note',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
            SizedBox(height: 20.h),

// هنا الفاليديشن الل بيتاكد من الوزن والعدات
            OutlinedButton(
              onPressed: () {
                if (_validateInputs()) {
                  _saveWorkout();
                }
              },

              style: OutlinedButton.styleFrom(
                side: BorderSide(color: theme.primaryColor, width: 2.w),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              ),
              child: Text(
                'Save Workout',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// تبع الاسكرول
// تعديل الدالة _buildCounterCard لتكون الأزرار بإطار فقط بدون تعبئة
  Widget _buildScrollPickerCard({
    required String label,
    required int initialValue,
    required int minValue,
    required int maxValue,
    required ValueChanged<int> onSelectedItemChanged,
    required Color themeColor,
    bool isWeight = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final controller = FixedExtentScrollController(initialItem: initialValue - minValue);
//طول العمودين
    return Expanded(
      child: Card(
        elevation: 6,
        shadowColor: themeColor.withAlpha((0.3 * 255).round()),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SizedBox(
          height: 300,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListWheelScrollView.useDelegate(
                    itemExtent: 50,
                    diameterRatio: 1.2,
                    perspective: 0.002,
                    controller: controller,
                    physics: const FixedExtentScrollPhysics(),
                    onSelectedItemChanged: onSelectedItemChanged,
                    childDelegate: ListWheelChildBuilderDelegate(
                      builder: (context, index) {
                        final value = minValue + index;
                        final displayValue = isWeight
                            ? (value * 2.5).toStringAsFixed(1)
                            : value.toString();

                        final isSelected = (controller.selectedItem == index);

                        return Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected)
                                Icon(Icons.arrow_left, color: themeColor, size: 24),
                              Text(
                                displayValue,
                                style: TextStyle(
                                  fontSize: 28, //حجم الارقام
                                  fontWeight: FontWeight.bold,
                                  color: themeColor,
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.arrow_right, color: themeColor, size: 24),
                            ],
                          ),
                        );
                      },
                      childCount: maxValue - minValue + 1,
                    ),
                  ),
                ),
              ],
            ),
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

