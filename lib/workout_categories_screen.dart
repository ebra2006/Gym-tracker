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

  // تحميل التمارين من shared preferences
  void _loadCustomWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts = prefs.getStringList('customWorkouts') ?? [];
    });
  }

  // حفظ التمرين المخصص في shared preferences
  void _addCustomWorkout(String workout) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts.add(workout);
    });
    prefs.setStringList('customWorkouts', customWorkouts);
  }

  // حذف التمرين من shared preferences بعد التأكد
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
                  customWorkouts.remove(workout); // حذف التمرين
                });
                prefs.setStringList('customWorkouts', customWorkouts); // تحديث الذاكرة
                Navigator.of(context).pop(); // إغلاق الحوار
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Categories'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: categories.length + customWorkouts.length + 1, // نضيف واحدة لـ "إضافة تمرين"
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
                  // الانتقال إلى صفحة WorkoutDetailsScreen مع اسم الفئة
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailsScreen(categoryName: category['name']),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            } else if (index < categories.length + customWorkouts.length) {
              final customWorkout = customWorkouts[index - categories.length];
              return GestureDetector(
                onTap: () {
                  // الانتقال إلى صفحة WorkoutDetailsScreen مع اسم التمرين المخصص
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => WorkoutDetailsScreen(categoryName: customWorkout),
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
                      Icon(Icons.fitness_center, size: 40), // دمبل كأيقونة
                      const SizedBox(height: 10),
                      Text(
                        customWorkout,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red), // أيقونة الحذف الحمراء
                        onPressed: () {
                          _removeCustomWorkout(customWorkout); // استدعاء دالة الحذف
                        },
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // الكارد الخاص بإضافة تمرين جديد
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
                          decoration: const InputDecoration(hintText: 'Enter workout name'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (customWorkout.trim().isNotEmpty) {
                                _addCustomWorkout(customWorkout);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('"${customWorkout}" added')),
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
