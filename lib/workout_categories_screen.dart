import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'workout_details_screen.dart'; // استيراد صفحة WorkoutDetailsScreen

class WorkoutCategoriesScreen extends StatefulWidget {
  const WorkoutCategoriesScreen({super.key});

  @override
  _WorkoutCategoriesScreenState createState() =>
      _WorkoutCategoriesScreenState();
}

class _WorkoutCategoriesScreenState extends State<WorkoutCategoriesScreen> {
  final List<Map<String, dynamic>> categories = const [
    {'name': 'Chest', 'icon': Icons.fitness_center},
    {'name': 'Abs', 'icon': Icons.accessibility},
    {'name': 'Biceps', 'icon': Icons.sports_mma},
    {'name': 'Cardio', 'icon': Icons.directions_run},
    {'name': 'Legs', 'icon': Icons.directions_walk},
    {'name': 'Shoulders', 'icon': Icons.accessibility_new},
    {'name': 'Triceps', 'icon': Icons.sports_kabaddi},
  ];

  List<String> customWorkouts = [];

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts(); // تحميل التمارين المخصصة عند بدء التطبيق
  }

  void _loadCustomWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts = prefs.getStringList('customWorkouts') ?? [];
    });
  }

  void _addCustomWorkout(String workout) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts.add(workout);
    });
    prefs.setStringList('customWorkouts', customWorkouts);
  }

  void _removeCustomWorkout(String workout) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Are you sure?"),
          content: const Text("Do you really want to delete this workout?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                setState(() {
                  customWorkouts.remove(workout);
                });
                prefs.setStringList('customWorkouts', customWorkouts);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('"$workout" deleted')),
                );
              },
            ),
          ],
        );
      },
    );
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
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        child: GridView.builder(
          itemCount: categories.length + customWorkouts.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            if (index < categories.length) {
              final category = categories[index];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WorkoutDetailsScreen(categoryName: category['name']);
                      },
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
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(category['icon'], size: 40),
                      const SizedBox(height: 10),
                      Text(
                        category['name'],
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            } else if (index < categories.length + customWorkouts.length) {
              final customWorkout = customWorkouts[index - categories.length];
              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WorkoutDetailsScreen(categoryName: customWorkout);
                      },
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
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fitness_center, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        customWorkout,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeCustomWorkout(customWorkout);
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // إضافة تمرين جديد
              return GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      String customWorkout = '';
                      return AlertDialog(
                        title: const Text('Add Custom Workout'),
                        content: TextField(
                          onChanged: (value) {
                            customWorkout = value;
                          },
                          decoration: const InputDecoration(
                              hintText: 'Enter workout name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (customWorkout.trim().isNotEmpty) {
                                _addCustomWorkout(customWorkout);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                      Text('"${customWorkout}" added')),
                                );
                              }
                            },
                            child: const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Card(
                  elevation: 4,
                  color: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.add, size: 40, color: Colors.black87),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
