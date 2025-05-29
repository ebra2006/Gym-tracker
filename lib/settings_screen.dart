import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // للوصول لل-notifiers
import 'exercises_screen.dart';
import 'weight_tracker_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isPurpleTheme = true;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isPurpleTheme = prefs.getBool('isPurpleTheme') ?? true;
    });
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = value);
    await prefs.setBool('isDarkMode', value);
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleColorTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isPurpleTheme = value);
    await prefs.setBool('isPurpleTheme', value);
    isPurpleThemeNotifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56), // ارتفاع appbar افتراضي
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
                        'Settings',
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
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDarkMode,
              activeColor: primaryColor,
              onChanged: toggleDarkMode,
            ),
            SwitchListTile(
              title: const Text('Use Purple Theme'),
              subtitle: const Text('Turn off to switch to Blue Theme'),
              value: isPurpleTheme,
              activeColor: primaryColor,
              onChanged: toggleColorTheme,
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.fitness_center, color: primaryColor),
              title: Text(
                'مكتبة التمارين',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: textColor.withOpacity(0.6)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExercisesScreen(),
                ),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
            ListTile(
              leading: Icon(Icons.monitor_weight, color: primaryColor),
              title: Text(
                'متتبع الوزن',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  size: 16, color: textColor.withOpacity(0.6)),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const WeightTrackerPage(),
                ),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            ),
          ],
        ),
      ),
    );
  }
}
