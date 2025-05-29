import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';
import 'settings_screen.dart'; // استيراد صفحة الإعدادات
import 'workout_summary_screen.dart';
import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';

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
  'assets/exercises/image1.jpg',
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
        preferredSize: const Size.fromHeight(56),  // الطول الافتراضي
        child: Builder(
          builder: (context) {
            final theme = Theme.of(context);
            final titleText = 'Gym Tracker';

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
                            icon: const Icon(Icons.menu),
                            color: theme.iconTheme.color,
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

                          const Spacer(),

                          Text(
                            titleText,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: theme.primaryColor,
                            ),
                          ),

                          const Spacer(),

                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: InkWell(
                              onTap: () {
                                showAnimatedStreakDialog(context, currentStreak);
                              },
                              borderRadius: BorderRadius.circular(50),
                              splashColor: Colors.deepOrangeAccent.withOpacity(0.3),
                              child: Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade600,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 1,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.local_fire_department,
                                          color: Colors.white, size: 20),
                                      const SizedBox(width: 2),
                                      Text(
                                        '$currentStreak',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      color: Theme.of(context).cardColor,

                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),

                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Text(
                              'Welcome back, $userName 👋',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            const SizedBox(height: 8),
                            Text(
                              'Age: $age | Weight: ${weight.toStringAsFixed(1)} kg | Height: ${height.toStringAsFixed(1)} cm | Gender: $gender',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ⬇️ Image Slider
                    SizedBox(
                      height: 350,
                      child: Column(
                        children: [
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: imagePaths.length,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                                pauseAutoScroll(); // ← وقف التمرير التلقائي مؤقتًا
                              },
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.asset(
                                    imagePaths[index],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.fill,
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(imagePaths.length, (index) {
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                width: _currentPage == index ? 12 : 8,
                                height: _currentPage == index ? 12 : 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPage == index
                                      ? Theme.of(context).primaryColor

                                      : Colors.grey.shade400,
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    Card(
                      color: Theme.of(context).cardColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),

                      ),
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
                        calendarBuilders: CalendarBuilders(
                          defaultBuilder: (context, day, _) {
                            final normalizedDay = normalizeDate(day);
                            final hasWorkout = workoutData.containsKey(normalizedDay) &&
                                workoutData[normalizedDay]!.isNotEmpty;

                            if (hasWorkout) {
                              return Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${day.day}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              );
                            }

                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
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

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: isDark ? Colors.grey[900] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔥 النار المتحركة مع تقليل الحجم شويه
                ScaleTransition(
                  scale: Tween<double>(begin: 1, end: 1.3)
                      .animate(CurvedAnimation(parent: _fireController, curve: Curves.easeInOut)),    // حجم النار
                  child: Icon(Icons.local_fire_department, color: Colors.orange.shade600, size: 60),
                ),

                const SizedBox(height: 12), // قللت المسافة شوية

                Text(
                  '🔥 ممتاز يا بطل!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8), // قللت المسافة

                Text(
                  'أنت محافظ على تمرينك بقالك ${widget.currentStreak} يوم! 👏\n'
                      'الاستمرارية هي سر النجاح الحقيقي 💪 استمر كده وحقق كل أهدافك! 🚀',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'استمر 🚀',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


