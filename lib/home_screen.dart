import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'settings_screen.dart'; // استيراد صفحة الإعدادات
import 'workout_summary_screen.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'workout_categories_screen.dart';
import 'meals_screen.dart';
// أضف استيراد streak.dart (عدل المسار لو ضروري)
import 'streak.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}//تبع التايم
// المتغيرات الرئيسية
late PageController _pageController;

int _currentPage = 0;
Timer? _sliderTimer;     // المؤقت الرئيسي للتمرير التلقائي
Timer? _resumeTimer;     // مؤقت استئناف التمرير بعد توقف المستخدم

final List<String> imagePaths = [
  'assets/exercises/image99.jpg',
  'assets/exercises/image2.jpg',
  'assets/exercises/image3.jpg',
  'assets/exercises/image4.jpg',
  'assets/exercises/image5.jpg',
  'assets/exercises/image6.jpg',
  'assets/exercises/image7.jpg',
  'assets/exercises/image8.jpg',
  'assets/exercises/image9.jpg',
];

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  String userName = '';
  String gender = '';
  double weight = 0.0;
  double height = 0.0;
  int age = 0;
  late DateTime selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> workoutData = {};
  bool isDarkMode = false;

  bool isExpanded = false; // هنا حالة توسيع التقويم

  final StreakManager streakManager = StreakManager();
  int currentStreak = 0;

  // تفعيل التمرير التلقائي كل 4 ثواني
  void startAutoScroll() {
    _sliderTimer?.cancel();
    _sliderTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_pageController.hasClients) {
        int nextPage = (_currentPage + 1) % imagePaths.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          _currentPage = nextPage;
        });
      }
    });
  }

  // إيقاف التمرير التلقائي مؤقتًا عند تدخل المستخدم، ثم استئنافه بعد 10 ثواني
  void pauseAutoScroll() {
    _sliderTimer?.cancel();
    _resumeTimer?.cancel();

    _resumeTimer = Timer(const Duration(seconds: 10), () {
      startAutoScroll();
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadUserInfo();
    selectedDay = DateTime.now();
    loadWorkoutData();
    loadTheme();
    _loadStreak();

    _pageController = PageController(initialPage: 0);
    startAutoScroll(); // ← بدأ التمرير التلقائي عند التشغيل
  }

  @override
  void dispose() {
    _pageController.dispose();
    _sliderTimer?.cancel();
    _resumeTimer?.cancel(); // ← مهم لإيقاف المؤقت عند إنهاء الصفحة

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ... باقي كود الصفحة ...


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkWorkoutSavedFlag();
    }
  }

  Future<void> _loadStreak() async {
    await streakManager.loadStreakData();
    setState(() {
      currentStreak = streakManager.currentStreak;
    });
  }

  Future<void> _checkWorkoutSavedFlag() async {
    final prefs = await SharedPreferences.getInstance();
    bool? saved = prefs.getBool('workout_saved_today');
    if (saved == true) {
      await _loadStreak(); // حدث الستريك
      await prefs.remove('workout_saved_today'); // نظف العلامة
    }
  }

  Future<void> loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? '';
      gender = prefs.getString('gender') ?? '';
      weight = prefs.getDouble('weight') ?? 0.0;
      height = prefs.getDouble('height') ?? 0.0;
      age = prefs.getInt('age') ?? 0;
    });
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    setState(() {});
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> loadWorkoutData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    Map<DateTime, List<Map<String, dynamic>>> tempData = {};

    for (var key in keys) {
      if (key.startsWith('workouts_')) {
        final dateString = key.replaceFirst('workouts_', '');
        try {
          final date = DateTime.parse(dateString);
          final value = prefs.getString(key);
          if (value != null) {
            final List<Map<String, dynamic>> workouts =
            List<Map<String, dynamic>>.from(jsonDecode(value));
            tempData[normalizeDate(date)] = workouts;
          }
        } catch (_) {
          continue;
        }
      }
    }

    setState(() {
      workoutData = tempData;
    });
  }

// بقية الكود في الهوم اسكرين حسب الحاجة...



  Future<void> handleDaySelected(DateTime day) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'workouts_${day.toIso8601String().substring(0, 10)}';
    final data = prefs.getString(key);

    List<Map<String, dynamic>> dayWorkouts = [];

    if (data != null) {
      try {
        dayWorkouts = List<Map<String, dynamic>>.from(jsonDecode(data));
      } catch (_) {}
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutSummaryScreen(
          workoutData: dayWorkouts,
          selectedDay: day,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final isDark = theme.brightness == Brightness.dark;
            final titleText = 'Gym Tracker';

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      // أيقونة القائمة (menu)
                      IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                                  SettingsScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final offsetAnimation = Tween<Offset>(
                                  begin: const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // Spacer لتوسيط العنوان
                      const SizedBox(width: 8),

                      // عنوان التطبيق في المنتصف
                      Expanded(
                        child: Center(
                          child: Text(
                            titleText,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      // كبسولة الستريك 🔥
                      InkWell(
                        onTap: () {
                          showAnimatedStreakDialog(context, currentStreak);
                        },
                        borderRadius: BorderRadius.circular(20),
                        splashColor: Colors.orange.withOpacity(0.2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: currentStreak > 0
                                ? Colors.orange.withOpacity(0.15)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.local_fire_department_outlined,
                                size: 20,
                                color: currentStreak > 0 ? Colors.orange : Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$currentStreak',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: currentStreak > 0 ? Colors.orange : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),



      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: Theme.of(context).brightness == Brightness.dark
                      ? const LinearGradient(
                    colors: [Color(0xFF2D2D3A), Color(0xFF3B3B4D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                      : const LinearGradient(
                    colors: [Color(0xFFF1F9FF), Color(0xFFE3F2FD)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.25)
                          : Colors.grey.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          '👋',
                          style: TextStyle(fontSize: 28),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Welcome back, $userName',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Inter',
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Age: $age | Weight: ${weight.toStringAsFixed(1)} kg | Height: ${height.toStringAsFixed(1)} cm | Gender: $gender',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Inter',
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[300]
                            : Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),





              const SizedBox(height: 20),
                    // ✅ مربعين للتمارين والوجبات

                    Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // زر إضافة وجبات
                            Expanded(
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => const MealsScreen(),
                                        transitionsBuilder: (_, animation, __, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/meals.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        // رفع النص قليلاً ليكون على نفس ارتفاع زر التمارين
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 80, // رفع النص بدل 60
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                            color: Colors.black.withOpacity(0.5),
                                            child: Text(
                                              'Add Meals',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 15,
                                          right: 15,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(width: 20),

                            // زر إضافة تمارين
                            Expanded(
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => const WorkoutCategoriesScreen(),
                                        transitionsBuilder: (_, animation, __, child) {
                                          return SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(1.0, 0.0),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * 0.3,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/cardio.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          left: 0,
                                          right: 0,
                                          bottom: 60,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                                            color: Colors.black.withOpacity(0.5),
                                            child: Text(
                                              'Add Workouts',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 15,
                                          right: 15,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                '+',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 30,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),




                    const SizedBox(height: 20), // ← إضافة مسافة قبل السلايدر

                    // ⬇️ Image Slider
                    // ⬇️ Workout Log و TableCalendar بدون كارد
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isExpanded = !isExpanded;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: LinearGradient(
                                  colors: Theme.of(context).brightness == Brightness.dark
                                      ? [Colors.grey.shade800, Colors.grey.shade900]
                                      : [Colors.white, Colors.grey.shade100],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                border: Border.all(
                                  color: Theme.of(context).primaryColor.withOpacity(0.85),
                                  width: 1.3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.12),
                                    blurRadius: 14,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                      Theme.of(context).brightness == Brightness.dark ? 0.05 : 0.6,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(-4, -4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    color: Theme.of(context).primaryColor,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Workout Calendar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodyLarge!.color,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  AnimatedRotation(
                                    turns: isExpanded ? 0.5 : 0,
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      Icons.keyboard_arrow_down,
                                      size: 28,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ],
                              ),

                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 400),
                            curve: Curves.easeInOut,
                            child: ClipRect(
                              child: Align(
                                heightFactor: isExpanded ? 1.0 : 0.0,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                                  child: TableCalendar(
                                    focusedDay: selectedDay,
                                    firstDay: DateTime.utc(2025, 1, 1),
                                    lastDay: DateTime.utc(2035, 12, 31),
                                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                                    onDaySelected: (day, focusedDay) {
                                      setState(() {
                                        selectedDay = day;
                                      });
                                      handleDaySelected(day);
                                    },
                                    daysOfWeekHeight: 36,
                                    rowHeight: 56,
                                    headerStyle: HeaderStyle(
                                      formatButtonVisible: false,
                                      titleCentered: true,
                                      headerPadding: const EdgeInsets.only(top: 0, bottom: 6),
                                      titleTextStyle: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                      ),
                                    ),
                                    calendarStyle: CalendarStyle(
                                      todayDecoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      selectedDecoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      selectedTextStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      defaultTextStyle: TextStyle(
                                        color: Theme.of(context).textTheme.bodyLarge!.color,
                                      ),
                                      weekendTextStyle: TextStyle(
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    calendarBuilders: CalendarBuilders(
                                      defaultBuilder: (context, day, _) {
                                        final normalizedDay = normalizeDate(day);
                                        final hasWorkout = workoutData.containsKey(normalizedDay) &&
                                            workoutData[normalizedDay]!.isNotEmpty;

                                        final fireColor = hasWorkout ? Colors.orange : Colors.grey.shade400;

                                        return Center(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Icon(
                                                Icons.local_fire_department,
                                                size: 38,
                                                color: fireColor,
                                              ),
                                              Positioned(
                                                top: 15,
                                                child: Transform.translate(
                                                  offset: const Offset(0, 0),
                                                  child: Container(
                                                    width: 19,
                                                    height: 19,
                                                    decoration: BoxDecoration(
                                                      color: fireColor,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    alignment: Alignment.center,
                                                    child: Text(
                                                      '${day.day}',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 13,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),



                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),




    );
  }
}

//نافدة منبثقة للاستريك

void showAnimatedStreakDialog(BuildContext context, int currentStreak) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'streakDialog',
    transitionDuration: const Duration(milliseconds: 400),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, __) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.85, end: 1.0)
              .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
          child: _FireDialog(currentStreak: currentStreak),
        ),
      );
    },
  );
}

class _FireDialog extends StatefulWidget {
  final int currentStreak;

  const _FireDialog({required this.currentStreak});

  @override
  State<_FireDialog> createState() => _FireDialogState();
}

class _FireDialogState extends State<_FireDialog> with TickerProviderStateMixin {
  late AnimationController _fireController;

  @override
  void initState() {
    super.initState();

    _fireController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _fireController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      },
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onTap: () {}, // منع الغلق عند الضغط داخل النافذة
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // كبسولة الشعلة والرقم
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ScaleTransition(
                            scale: Tween<double>(begin: 1, end: 1.3).animate(
                              CurvedAnimation(parent: _fireController, curve: Curves.easeInOut),
                            ),
                            child: Icon(
                              Icons.local_fire_department_outlined,
                              color: Colors.orange,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.currentStreak}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // داخل دالة showAnimatedStreakDialog أو داخل الويجت اللي بيعرض الديالوج

                    Text(
                      widget.currentStreak > 0
                          ? '🔥 أداء منتظم!'
                          : 'هل أنت مستعد؟ 🌟 لنبدأ الرحلة معًا! ابدأ التمرين من "Add Workouts" وزد استريكك يومًا بعد يوم 💪🔥',
                      // نص بديل لما يكون الاستريك صفر أو أقل
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      widget.currentStreak > 0
                          ? '🔥 سلسلة نجاح مستمرة!\nتمرين اليوم رقم ${widget.currentStreak} على التوالي!\nأنت بطل بحق 💪 استمر في التألق!'
                          : 'لا يوجد سجل حتى الآن.\nيمكنك البدء في التمرن الآن! 💪',
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: isDark
                            ? Colors.orange.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.15),
                        foregroundColor: Colors.orange.shade400, // لون واضح في الداكن
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 1,
                      ),
                      onPressed: () {
                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text(
                        'استمرار 🚀',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange, // لون واضح حتى في الدارك مود
                        ),
                      ),
                    ),


                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
