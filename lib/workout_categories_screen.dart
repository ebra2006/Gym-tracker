import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'exercise_screens/chest_exercises_screen.dart';
import 'exercise_screens/abs_exercises_screen.dart';
import 'exercise_screens/biceps_exercises_screen.dart';
import 'exercise_screens/cardio_exercises_screen.dart';
import 'exercise_screens/legs_exercises_screen.dart';
import 'exercise_screens/shoulders_exercises_screen.dart';
import 'exercise_screens/triceps_exercises_screen.dart';
import 'exercise_screens/back_exercises_screen.dart';
import 'workout_details_screen.dart';

class WorkoutCategoriesScreen extends StatefulWidget {
  const WorkoutCategoriesScreen({super.key});

  @override
  _WorkoutCategoriesScreenState createState() =>
      _WorkoutCategoriesScreenState();
}

class _WorkoutCategoriesScreenState extends State<WorkoutCategoriesScreen> {
  String? gender;
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadGenderAndSetCategories();
  }

  Future<void> _loadGenderAndSetCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gender = prefs.getString('gender') ?? 'Male'; // افتراضيًا ذكر

    if (gender == 'Male') {
      categories = [
        {'name': 'Chest', 'image': 'assets/images/chest.png'},
        {'name': 'Abs', 'image': 'assets/images/abs.png'},
        {'name': 'Biceps', 'image': 'assets/images/biceps.png'},
        {'name': 'Cardio', 'image': 'assets/images/cardio.png'},
        {'name': 'Legs', 'image': 'assets/images/legs.png'},
        {'name': 'Shoulders', 'image': 'assets/images/shoulders.png'},
        {'name': 'Triceps', 'image': 'assets/images/triceps.png'},
        {'name': 'Back', 'image': 'assets/images/back.png'},
      ];
    } else {
      // مثال: عضلات مختلفة أو ترتيب مختلف للإناث
      categories = [
        {'name': 'Back', 'image': 'assets/female/back.png'},
        {'name': 'Chest', 'image': 'assets/female/chest.png'},
        {'name': 'Legs', 'image': 'assets/female/legs.png'},
        {'name': 'Cardio', 'image': 'assets/female/cardio.png'},
        {'name': 'Abs', 'image': 'assets/female/abs.png'},
        {'name': 'Shoulders', 'image': 'assets/female/shoulders.png'},
        {'name': 'Biceps', 'image': 'assets/female/biceps.png'},
        {'name': 'Triceps', 'image': 'assets/female/triceps.png'},
      ];
    }

    setState(() {});
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        'Workout Categories',
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
        padding: const EdgeInsets.all(16),
        child: categories.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : GridView.builder(
          itemCount: categories.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: Colors.white.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.1),
                onTap: () {
                  Widget targetPage;

                  switch (category['name']) {
                    case 'Chest':
                      targetPage = const ChestExercisesScreen();
                      break;
                    case 'Abs':
                      targetPage = const AbsExercisesScreen();
                      break;
                    case 'Biceps':
                      targetPage = const BicepsExercisesScreen();
                      break;
                    case 'Cardio':
                      targetPage = const CardioExercisesScreen();
                      break;
                    case 'Legs':
                      targetPage = const LegsExercisesScreen();
                      break;
                    case 'Shoulders':
                      targetPage = const ShouldersExercisesScreen();
                      break;
                    case 'Triceps':
                      targetPage = const TricepsExercisesScreen();
                      break;
                    case 'Back':
                      targetPage = const BackExercisesScreen();
                      break;
                    default:
                      targetPage =
                          WorkoutDetailsScreen(categoryName: category['name']);
                  }

                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder:
                          (context, animation, secondaryAnimation) =>
                      targetPage,
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
                onLongPress: () {}, // لتفعيل تأثير الضغط
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        category['image'],
                        fit: BoxFit.cover,
                      ),
                      Container(
                        alignment: Alignment.bottomCenter,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.5),
                            ],
                          ),
                        ),
                        child: Text(
                          category['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
    );
  }
}
