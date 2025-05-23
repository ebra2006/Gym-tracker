import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'exercises_screen.dart';  // استيراد صفحة التمارين
import 'weight_tracker_page.dart'; // استيراد صفحة متتبع الوزن (تأكد من المسار الصحيح)

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final newThemeMode = !isDarkMode;
    setState(() {
      isDarkMode = newThemeMode;
    });
    prefs.setBool('isDarkMode', isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('Dark Mode', style: TextStyle(fontSize: 18)),
                trailing: Switch(
                  value: isDarkMode,
                  onChanged: (value) {
                    toggleTheme();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Restart Required'),
                          content: const Text(
                              'Please restart the app to apply the theme change.'),
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
                  },
                  activeColor: Colors.deepPurple,
                ),
                leading: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('مكتبة التمارين', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ExercisesScreen()),
                  );
                },
                leading: const Icon(Icons.fitness_center, color: Colors.deepPurple),
              ),
            ),

            // زر جديد لمتتبع الوزن
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: const Text('متتبع الوزن', style: TextStyle(fontSize: 18)),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WeightTrackerPage()),
                  );
                },
                leading: const Icon(Icons.monitor_weight, color: Colors.deepPurple),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
