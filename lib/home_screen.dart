import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:convert';

import 'workout_categories_screen.dart';
import 'workout_summary_screen.dart';
import 'calories_screen.dart';
import 'meals_screen.dart';
import 'ChatBotScreen.dart';
import 'fun_bot_screen.dart'; // ✅ استيراد شاشة البوت الترفيهي
import 'GemawyBotScreen.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = '';
  String gender = '';
  double weight = 0.0;
  double height = 0.0;
  int age = 0;
  late DateTime selectedDay;
  Map<DateTime, List<Map<String, dynamic>>> workoutData = {};
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadUserInfo();
    selectedDay = DateTime.now();
    loadWorkoutData();
    loadTheme();
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

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode = isDarkMode ? ThemeMode.light : ThemeMode.dark;
    themeNotifier.value = newThemeMode;
    setState(() {
      isDarkMode = !isDarkMode;
    });
    prefs.setBool('isDarkMode', isDarkMode);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Restart Required'),
          content: const Text('To apply the theme change, please close the app and reopen it.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ThemeData(
            primaryColor: Colors.blue,
            scaffoldBackgroundColor: Colors.white, // جعل الخلفية بيضاء
            cardColor: Colors.white, // لون الكارت الأبيض في الوضع العادي
            buttonTheme: ButtonThemeData(buttonColor: Colors.blueAccent),
          ),
          darkTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black, // خلفية داكنة
            cardColor: Colors.black, // كارت أسود في الوضع الداكن
            textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.white)), // استخدام bodyMedium بدلاً من bodyText2
          ),

          home: Scaffold(
            appBar: AppBar(
              title: const Text('Gym Tracker'),
              centerTitle: true,
              backgroundColor: Colors.deepPurple, // تغيير اللون في الشريط العلوي
              actions: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GemawyBotScreen()),
                    );
                  },
                  splashColor: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(color: Colors.purpleAccent, width: 3),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.search_off),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
                  onPressed: toggleTheme,
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Card(
                      color: isDarkMode ? Colors.black : Colors.white, // تغيير اللون حسب الوضع
                      elevation: 0, // إزالة الظل
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.deepPurple, width: 2), // إطار بنفسجي حول الكارت
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
                                color: isDarkMode ? Colors.white : Colors.black, // تغيير اللون بناءً على الوضع
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

                    const SizedBox(height: 30),
                    Card(
                      color: Colors.transparent, // جعل البطاقة شفافة
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: Colors.deepPurple, width: 2), // إطار حول التقويم
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
                                        color: Colors.black, fontWeight: FontWeight.bold),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: workoutData[normalizeDate(selectedDay)]?.length ?? 0,
                      itemBuilder: (context, index) {
                        final workout = workoutData[normalizeDate(selectedDay)]?[index];
                        return ListTile(
                          title: Text(workout?['name'] ?? ''),
                          subtitle: Text(
                            'Reps: ${workout?['reps']} - Weight: ${workout?['weight']} - Time: ${workout?['time'] != null ? "${workout!['time']} sec" : "N/A"}',
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WorkoutSummaryScreen(
                                  workoutData: workoutData[normalizeDate(selectedDay)] ?? [],
                                  selectedDay: selectedDay,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: Padding(
              padding: const EdgeInsets.only(bottom: 0.0),
              child: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: 0,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WorkoutCategoriesScreen()),
                    );
                  } else if (index == 1) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MealsScreen()),
                    );
                  } else if (index == 2) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatBotScreen()),
                    );
                  } else if (index == 3) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => FunBotScreen()),
                    );
                  } else if (index == 4) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CalorieCalculatorScreen()),
                    );
                  } else if (index == 5) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GemawyBotScreen()),
                    );
                  }
                },
                items: [
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => WorkoutCategoriesScreen()),
                        );
                      },
                      splashColor: Colors.orange,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.orange, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.fitness_center),
                      ),
                    ),
                    label: 'Workouts',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MealsScreen()),
                        );
                      },
                      splashColor: Colors.orange,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.orange, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.restaurant),
                      ),
                    ),
                    label: 'Meals',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ChatBotScreen()),
                        );
                      },
                      splashColor: Colors.blue,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.blue, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.chat),
                      ),
                    ),
                    label: 'Bot',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => FunBotScreen()),
                        );
                      },
                      splashColor: Colors.green,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.green, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.face),
                      ),
                    ),
                    label: 'Fun Bot',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CalorieCalculatorScreen()),
                        );
                      },
                      splashColor: Colors.purple,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.purple, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.calculate),
                      ),
                    ),
                    label: 'Calories',
                  ),
                  BottomNavigationBarItem(
                    icon: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GemawyBotScreen()),
                        );
                      },
                      splashColor: Colors.purpleAccent,
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(color: Colors.purpleAccent, width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.search_off),
                      ),
                    ),
                    label: 'Bot',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
