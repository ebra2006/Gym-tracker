import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalorieCalculatorScreen> createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> with TickerProviderStateMixin {
  String gender = 'Male';
  int? age;
  double? weight;
  double? height;
  String activityLevel = 'Moderate';
  String goal = 'Maintain';
  String result = '';
  String suggestion = '';

  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _opacityAnimation;

  final FocusNode _ageFocusNode = FocusNode();
  final FocusNode _weightFocusNode = FocusNode();
  final FocusNode _heightFocusNode = FocusNode();

  final List<String> activityLevels = [
    'Sedentary',
    'Light',
    'Moderate',
    'High',
    'Intense',
    'Daily Exercise'
  ];
  final List<String> goals = [
    'Weight Loss',
    'Maintain',
    'Muscle Gain',
    'Fat Loss',
    'Fitness Improvement'
  ];

  List<Map<String, dynamic>> savedResults = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.ltr),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool validateInputs() {
    if (age == null || age! < 10 || age! > 100) {
      _showSnackBar('⚠️ Age must be between 10 and 100 years');
      return false;
    }
    if (weight == null || weight! < 30 || weight! > 200) {
      _showSnackBar('⚠️ Weight must be between 30 and 200 kg');
      return false;
    }
    if (height == null || height! < 100 || height! > 250) {
      _showSnackBar('⚠️ Height must be between 100 and 250 cm');
      return false;
    }
    return true;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
    loadSavedResults();
  }

  @override
  void dispose() {
    _controller.dispose();
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    _ageFocusNode.dispose();
    _weightFocusNode.dispose();
    _heightFocusNode.dispose();
    super.dispose();
  }

  Future<void> loadSavedResults() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString('calorie_results');
    if (jsonString != null) {
      final List<dynamic> jsonData = json.decode(jsonString);
      setState(() {
        savedResults = jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
      });
    }
  }

  Future<void> saveResult(double calories) async {
    final prefs = await SharedPreferences.getInstance();
    final newEntry = {
      'date': DateTime.now().toIso8601String(),
      'calories': calories,
      'weight': weight ?? 0,
      'goal': goal,
    };
    savedResults.add(newEntry);
    await prefs.setString('calorie_results', json.encode(savedResults));
  }

  double? calculateCalories() {
    if (age == null || weight == null || height == null) return null;

    // 1. Calculate BMR
    double bmr = 0;
    if (gender == 'Male') {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }

    // 2. Activity Factor
    double activityFactor = {
      'Sedentary': 1.2,
      'Light': 1.375,
      'Moderate': 1.55,
      'High': 1.725,
      'Intense': 1.9,
      'Daily Exercise': 1.9,
    }[activityLevel] ?? 1.55;

    // 3. Maintenance Calories
    double maintenanceCalories = bmr * activityFactor;

    // 4. Adjust based on Goal
    switch (goal) {
      case 'Weight Loss':
        maintenanceCalories -= 500;
        suggestion =
        '📉 Focus on an active lifestyle and a protein-rich diet with vegetables to stay full and manage weight.';
        break;
      case 'Muscle Gain':
        maintenanceCalories += 400;
        suggestion =
        '💪 Focus on regular resistance training and sufficient sleep to support muscle growth and performance.';
        break;
      case 'Fat Loss':
        maintenanceCalories -= 250;
        suggestion =
        '🔥 Combine cardio and strength training, and eat balanced meals to naturally support fat loss.';
        break;
      case 'Fitness Improvement':
        maintenanceCalories += 100;
        suggestion =
        '🏃‍♂️ Combine aerobic and resistance training to enhance physical fitness and strengthen your heart.';
        break;
      default: // Maintain
        suggestion =
        '✅ Maintain a balanced lifestyle combining healthy nutrition and regular physical activity to support overall health.';
        break;
    }

    if (gender == 'Male' && maintenanceCalories < 1500) maintenanceCalories = 1500;
    if (gender == 'Female' && maintenanceCalories < 1200) maintenanceCalories = 1200;

    return maintenanceCalories;
  }

  Map<String, List<String>> dietTips = {
    'Weight Loss': [
      'Eat plenty of protein.',
      'Reduce sugars and saturated fats.',
      'Drink plenty of water.'
    ],
    'Muscle Gain': [
      'Increase protein and carbohydrates.',
      'Progressively increase workout loads.',
      'Have snacks between main meals.'
    ],
    'Fat Loss': [
      'Do cardio regularly.',
      'Reduce calories gradually.',
      'Drink herbal tea to boost fat burning.'
    ],
    'Fitness Improvement': [
      'Do aerobic exercises.',
      'Eat balanced, vitamin-rich foods.',
      'Get enough sleep.'
    ],
    'Maintain': [
      'Maintain a healthy, balanced lifestyle.',
      'Exercise regularly.',
      'Monitor your weight regularly.'
    ],
  };

  Widget _buildCard(Widget child) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                        color: Theme.of(context).iconTheme.color,
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        'Calories Calculator',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: DefaultTextStyle(
              style: TextStyle(color: textColor),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Gender", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildCard(Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Male'),
                          value: 'Male',
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Female'),
                          value: 'Female',
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  )),
                  _buildCard(TextField(
                    controller: ageController,
                    focusNode: _ageFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => age = int.tryParse(val)),
                  )),
                  _buildCard(TextField(
                    controller: weightController,
                    focusNode: _weightFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => weight = double.tryParse(val)),
                  )),
                  _buildCard(TextField(
                    controller: heightController,
                    focusNode: _heightFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm)',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => height = double.tryParse(val)),
                  )),
                  const SizedBox(height: 10),
                  const Text("Activity Level", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildCard(DropdownButton<String>(
                    value: activityLevel,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: activityLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                    onChanged: (val) {
                      setState(() {
                        activityLevel = val!;
                      });
                    },

                  )),
                  const SizedBox(height: 10),
                  const Text("Goal", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildCard(DropdownButton<String>(
                    value: goal,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: goals.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                    onChanged: (val) {
                      setState(() {
                        goal = val!;
                        calculateCalories();
                      });
                    },
                  )),
                  const SizedBox(height: 20),
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      ),
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        if (!validateInputs()) return;

                        final calories = calculateCalories();
                        if (calories != null) {
                          saveResult(calories);
                          setState(() {
                            result = '🍽️ Daily required calories: ${calories.toStringAsFixed(0)} kcal/day';
                          });
                        }
                      },
                      icon: Icon(Icons.calculate, color: Theme.of(context).primaryColor),
                      label: Text(
                        "Calculate Calories",
                        style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),
                  if (result.isNotEmpty) ...[
                    Text(result, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor)),
                    const SizedBox(height: 10),
                    if (suggestion.isNotEmpty)
                      Text(suggestion, style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.7))),
                    const SizedBox(height: 10),
                    const Text("Diet Tips:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ...?dietTips[goal]?.map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text("• $tip", style: TextStyle(fontSize: 16, color: textColor.withOpacity(0.8))),
                    )),
                  ],
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          gender = 'Male';
                          age = null;
                          weight = null;
                          height = null;
                          activityLevel = 'Moderate';
                          goal = 'Maintain';
                          result = '';
                          suggestion = '';
                          ageController.clear();
                          weightController.clear();
                          heightController.clear();

                          _ageFocusNode.unfocus();
                          _weightFocusNode.unfocus();
                          _heightFocusNode.unfocus();
                        });
                      },
                      child: const Text("🔄 Reset", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
