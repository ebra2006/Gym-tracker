import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'home_screen.dart';
import 'exercises_screen.dart';
import 'weight_tracker_page.dart';
import 'chatbotscreen.dart';
import 'calories_screen.dart';
import 'gemawybotscreen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  int currentStep = 0;
  bool tutorialCompleted = false;
  List<TargetFocus> targets = [];

  final GlobalKey _weightKey = GlobalKey();
  final GlobalKey _assistantKey = GlobalKey();
  final GlobalKey _workoutsKey = GlobalKey();
  final GlobalKey _caloriesKey = GlobalKey();
  final GlobalKey _foodKey = GlobalKey();

  late AnimationController _pulseController;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _checkIfTutorialCompleted();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkIfTutorialCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tutorialCompleted = prefs.getBool('tutorialCompleted') ?? false;

    if (!tutorialCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initTargets();
        _showCurrentStep();
      });
    }
  }

  void _initTargets() {
    targets = [
      _buildTarget(_workoutsKey, "اهلا بيك في برنامج Gym tracker ! دي صفحة التمارين هتلاقي فيها صور للتمرين وشرح لكل تمرينة بيعلمك تلعب التمرين صح "),
      _buildTarget(_weightKey, "دي صفحة متابعة الوزن برسم بياني عشان تتابع تقدمك في خسارة الوزن او زيادته ."),
      _buildTarget(_assistantKey, "دي صفحة المساعد الذكي بيقدملك نصايح وخطط تمرينية ."),
      _buildTarget(_caloriesKey, "دي صفحة حساب السعرات اللازمة ليك ."),
      _buildTarget(_foodKey, "ده بوت بحث عن الاكلات تنويه بسيط البوت مش مخصص للشات وطريقة استعماله هو كتابة اسم الاكلة فقط ثم سيظهرلك بياناتها ."),
    ];
  }

  TargetFocus _buildTarget(GlobalKey key, String text) {
    return TargetFocus(
      keyTarget: key,
      shape: ShapeLightFocus.Circle,
      radius: 50.w, // ⬅️ Responsive Circle Radius (تجرب القيم لحد ما تظبط)
      enableOverlayTab: false,
      contents: [
        TargetContent(
          align: ContentAlign.top,
          builder: (context, controller) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                 SizedBox(height: 50.h),
                 Text(
                  "أهلا بك في برنامج Gym Tracker",
                  style: TextStyle(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                 SizedBox(height: 16.h),
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: 1 + (_pulseController.value * 0.05),
                      child: child,
                    );
                  },
                  child: Container(
                    margin:  EdgeInsets.symmetric(horizontal: 16.w),
                    padding:  EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style:  TextStyle(color: Colors.white, fontSize: 14.sp, height: 1.6),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  void _showCurrentStep() {
    if (currentStep >= targets.length) {
      return;
    }

    TutorialCoachMark(
      targets: [targets[currentStep]],
      colorShadow: Colors.black.withOpacity(0.8),
      onClickTarget: (_) {
        _navigateTo(_getIndexForStep(currentStep));
      },
      onFinish: () {
        _completeTutorial();
        return true;
      },
      onSkip: () {
        _completeTutorial();
        return true;
      },
    ).show(context: context);
  }

  Future<void> _completeTutorial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorialCompleted', true);
    setState(() {
      tutorialCompleted = true;
    });
  }

  int _getIndexForStep(int step) {
    switch (step) {
      case 0:
        return 1;
      case 1:
        return 2;
      case 2:
        return 3;
      case 3:
        return 4;
      case 4:
        return 6;
      default:
        return 0;
    }
  }

  Future<void> _navigateTo(int index) async {
    Widget page;

    switch (index) {
      case 1:
        page = const ExercisesScreen();
        break;
      case 2:
        page = const WeightTrackerPage();
        break;
      case 3:
        page = ChatBotScreen();
        break;
      case 4:
        page = const CalorieCalculatorScreen();
        break;
      case 6:
        page = GemawyBotScreen();
        break;
      default:
        return;
    }

    setState(() {
      currentStep++;
    });

    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

    if (currentStep < targets.length) {
      _showCurrentStep();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, -2)),
          ],
        ),
        padding:  EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(context, icon: Icons.trending_up_outlined, label: 'Weight', index: 2, key: _weightKey),
            _buildNavItem(context, icon: Icons.smart_toy_outlined, label: 'Assistant', index: 3, key: _assistantKey),
            _buildNavItem(context, icon: Icons.fitness_center_outlined, label: 'Workouts', index: 1, key: _workoutsKey),
            _buildNavItem(context, icon: Icons.local_fire_department_outlined, label: 'Calories', index: 4, key: _caloriesKey),
            _buildNavItem(context, icon: Icons.restaurant_menu_outlined, label: 'Food', index: 6, key: _foodKey),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, required int index, required GlobalKey key}) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = Colors.deepPurple;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color iconColor = isSelected ? activeColor : (isDark ? Colors.grey[400]! : Colors.grey[700]!);

    return Expanded(
      child: InkWell(
        key: key,
        borderRadius: BorderRadius.circular(32),
        onTap: () => _navigateTo(index),
        child: Container(
          height: 64.h,
          alignment: Alignment.center,
          decoration: isSelected ? BoxDecoration(color: activeColor.withOpacity(0.1), shape: BoxShape.circle) : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24.sp),
               SizedBox(height: 4.h),
              Text(label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w400, color: iconColor)),
            ],
          ),
        ),
      ),
    );
  }
}
