import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'workout_categories_screen.dart';
import 'meals_screen.dart';
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
    const Placeholder(), // سيتم استبدالهم عند الضغط، عشان نحملهم عند الحاجة فقط
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

    // حدد الصفحة بناءً على الاختيار
    Widget page;
    switch (index) {
      case 1:
        page = const WorkoutCategoriesScreen();
        break;
      case 2:
        page = const MealsScreen();
        break;
      case 3:
        page =  ChatBotScreen();
        break;
      case 4:
        page = const CalorieCalculatorScreen();
        break;
      case 5:
        page =  FunBotScreen();
        break;
      case 6:
        page =  GemawyBotScreen();
        break;
      default:
        return;
    }

    // الانتقال مع انيميشن
    await Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        color: Theme.of(context).colorScheme.surface,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [

            IconButton(
              icon: const Icon(Icons.restaurant),
              color: Colors.orange,
              onPressed: () => _navigateTo(context, 2),
              tooltip: 'Meals',
            ),
            IconButton(
              icon: const Icon(Icons.face_retouching_natural),
              color: Colors.blue,
              onPressed: () => _navigateTo(context, 3),
              tooltip: 'ChatBot',
            ),
            IconButton(
              icon: const Icon(Icons.fitness_center),
              color: Colors.deepPurple,
              onPressed: () => _navigateTo(context, 1),
              tooltip: 'Workouts',
            ),
            IconButton(
              icon: const Icon(Icons.calculate),
              color: Colors.deepPurple,
              onPressed: () => _navigateTo(context, 4),
              tooltip: 'Calories',
            ),

            IconButton(
              icon: const Icon(Icons.face),
              color: Colors.indigo,
              onPressed: () => _navigateTo(context, 6),
              tooltip: 'Gemawy Bot',
            ),
          ],
        ),
      ),
    );
  }
}
