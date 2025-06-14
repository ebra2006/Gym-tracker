import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'exercises_screen.dart';
import 'weight_tracker_page.dart';
import 'chatbotscreen.dart';
import 'calories_screen.dart';
import 'fun_bot_screen.dart';
import 'gemawybotscreen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Placeholder(), // سيتم استبدالهم عند الضغط، لتحميلهم عند الحاجة فقط
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  void _navigateTo(BuildContext context, int index) async {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    Widget page;
    PageRouteBuilder pageRoute;

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
      case 5:
        page = FunBotScreen();
        break;
      case 6:
        page = GemawyBotScreen();
        break;
      default:
        return;
    }

    pageRoute = PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );

    await Navigator.of(context).push(pageRoute);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildNavItem(
              context,
              icon: Icons.trending_up_outlined,
              label: 'Weight',
              index: 2,
            ),
            _buildNavItem(
              context,
              icon: Icons.smart_toy_outlined,
              label: 'Assistant',
              index: 3,
            ),
            _buildNavItem(
              context,
              icon: Icons.fitness_center_outlined,
              label: 'Workouts',
              index: 1,
            ),
            _buildNavItem(
              context,
              icon: Icons.local_fire_department_outlined,
              label: 'Calories',
              index: 4,
            ),
            _buildNavItem(
              context,
              icon: Icons.restaurant_menu_outlined,
              label: 'Food',
              index: 6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    final bool isSelected = _selectedIndex == index;
    final Color activeColor = Colors.deepPurple; // أو اختر blue
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color iconColor = isSelected
        ? activeColor
        : (isDark ? Colors.grey[400]! : Colors.grey[700]!);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(32),
        onTap: () => _navigateTo(context, index),
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: isSelected
              ? BoxDecoration(
            color: activeColor.withOpacity(0.1),
            shape: BoxShape.circle,
          )
              : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: iconColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
