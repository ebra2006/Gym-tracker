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
  String activityLevel = 'متوسط';
  String goal = 'الحفاظ';
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

  final List<String> activityLevels = ['خامل', 'خفيف', 'متوسط', 'عالي', 'مكثف', 'نشاط رياضي يومي'];
  final List<String> goals = ['خسارة الوزن', 'الحفاظ', 'زيادة العضلات', 'خسارة الدهون', 'تحسين اللياقة'];

  List<Map<String, dynamic>> savedResults = [];

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textDirection: TextDirection.rtl),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool validateInputs() {
    if (age == null || age! < 10 || age! > 100) {
      _showSnackBar('⚠️ العمر يجب أن يكون بين 10 و 100 سنة');
      return false;
    }
    if (weight == null || weight! < 30 || weight! > 200) {
      _showSnackBar('⚠️ الوزن يجب أن يكون بين 30 و 200 كجم');
      return false;
    }
    if (height == null || height! < 100 || height! > 250) {
      _showSnackBar('⚠️ الطول يجب أن يكون بين 100 و 250 سم');
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

    double bmr = 0;
    if (gender == 'Male') {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! + 5;
    } else {
      bmr = 10 * weight! + 6.25 * height! - 5 * age! - 161;
    }

    double activityFactor = {
      'خامل': 1.2,
      'خفيف': 1.375,
      'متوسط': 1.55,
      'عالي': 1.725,
      'مكثف': 1.9,
      'نشاط رياضي يومي': 2.0,
    }[activityLevel] ?? 1.55;

    double maintenanceCalories = bmr * activityFactor;

    switch (goal) {
      case 'خسارة الوزن':
        suggestion = '📉 اعتمد على نمط حياة نشط ونظام غذائي غني بالبروتين والخضروات للحفاظ على الشبع والتحكم بالوزن.';
        break;
      case 'زيادة العضلات':
        suggestion = '💪 ركّز على تمارين المقاومة المنتظمة ونوم كافٍ لدعم بناء العضلات وتحسين الأداء.';
        break;
      case 'خسارة الدهون':
        suggestion = '🔥 اجمع بين التمارين القلبية والقوة، وتناول وجبات متوازنة لدعم صحة الجسم وتقليل الدهون بشكل طبيعي.';
        break;
      case 'تحسين اللياقة':
        suggestion = '🏃‍♂️ دمج تمارين متنوعة، كالتمارين الهوائية والمقاومة، يعزز القدرة البدنية ويقوّي عضلة القلب.';
        break;
      default:
        suggestion = '✅ حافظ على نمط حياة متوازن يجمع بين التغذية السليمة والنشاط البدني الدوري لدعم صحتك العامة.';
        break;
    }


    return maintenanceCalories;
  }

  Map<String, List<String>> dietTips = {
    'خسارة الوزن': ['تناول البروتينات بكثرة.', 'قلل من السكريات والدهون المشبعة.', 'اشرب الماء بكثرة.'],
    'زيادة العضلات': ['زيادة البروتينات والكربوهيدرات.', 'كرر التمرين مع زيادة الأحمال تدريجياً.', 'تناول وجبات خفيفة بين الوجبات الرئيسية.'],
    'خسارة الدهون': ['مارس تمارين القلب بانتظام.', 'قلل السعرات الحرارية بشكل تدريجي.', 'اشرب شاي الأعشاب لتحفيز الحرق.'],
    'تحسين اللياقة': ['مارس التمارين الهوائية.', 'تناول أطعمة متوازنة غنية بالفيتامينات.', 'احصل على قسط كافٍ من النوم.'],
    'الحفاظ': ['حافظ على نمط حياة صحي ومتوازن.', 'مارس الرياضة بانتظام.', 'راقب وزنك بشكل دوري.'],
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
                        'Calories calcolator',
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
                  const Text("الجنس", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildCard(Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('ذكر'),
                          value: 'Male',
                          groupValue: gender,
                          onChanged: (val) => setState(() => gender = val!),
                          activeColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('أنثى'),
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
                      labelText: 'العمر',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => age = int.tryParse(val)),
                  )),
                  _buildCard(TextField(
                    controller: weightController,
                    focusNode: _weightFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'الوزن (كجم)',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => weight = double.tryParse(val)),
                  )),
                  _buildCard(TextField(
                    controller: heightController,
                    focusNode: _heightFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'الطول (سم)',
                      border: InputBorder.none,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) => setState(() => height = double.tryParse(val)),
                  )),
                  const SizedBox(height: 10),
                  const Text("مستوى النشاط البدني", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  _buildCard(DropdownButton<String>(
                    value: activityLevel,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: activityLevels.map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                    onChanged: (val) {
                      setState(() {
                        activityLevel = val!;
                        final calories = calculateCalories();
                        if (calories != null) {
                          result = '🍽️ السعرات اليومية اللازمة: ${calories.toStringAsFixed(0)} سعرة حرارية في اليوم';
                        }
                      });
                    },
                  )),
                  const SizedBox(height: 10),
                  const Text("الهدف", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
                            result = '🍽️ السعرات اليومية اللازمة: ${calories.toStringAsFixed(0)} سعرة حرارية في اليوم';
                          });
                        }
                      },
                      icon: Icon(Icons.calculate, color: Theme.of(context).primaryColor),
                      label: Text(
                        "احسب السعرات",
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
                    const Text("نصائح غذائية:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          activityLevel = 'متوسط';
                          goal = 'الحفاظ';
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
                      child: const Text("🔄 إعادة تعيين", style: TextStyle(fontSize: 16)),
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