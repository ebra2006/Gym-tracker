import 'package:flutter/material.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalorieCalculatorScreen> createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
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

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
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
    }[activityLevel]!;

    double maintenanceCalories = bmr * activityFactor;

    switch (goal) {
      case 'خسارة الوزن':
        suggestion = '💡 قلل حوالي 300 - 500 سعرة حرارية يوميًا للوصول إلى هدفك.';
        break;
      case 'زيادة العضلات':
        suggestion = '💪 أضف حوالي 300 - 500 سعرة حرارية يوميًا لبناء العضلات.';
        break;
      default:
        suggestion = '✅ حافظ على هذا المعدل من السعرات للحفاظ على وزنك الحالي.';
        break;
    }

    return maintenanceCalories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🔥 حساب السعرات الحرارية'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("الجنس", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('ذكر'),
                    value: 'Male',
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('أنثى'),
                    value: 'Female',
                    groupValue: gender,
                    onChanged: (val) => setState(() => gender = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Card(
              child: TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'العمر'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = int.tryParse(val);
                  setState(() {
                    age = parsed;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'الوزن (كجم)'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  setState(() {
                    weight = parsed;
                  });
                },
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: 'الطول (سم)'),
                keyboardType: TextInputType.number,
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  setState(() {
                    height = parsed;
                  });
                },
              ),
            ),
            const SizedBox(height: 15),
            const Text("مستوى النشاط البدني", style: TextStyle(fontWeight: FontWeight.bold)),
            Card(
              child: DropdownButton<String>(
                value: activityLevel,
                isExpanded: true,
                items: ['خامل', 'خفيف', 'متوسط', 'عالي']
                    .map((level) => DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (val) => setState(() => activityLevel = val!),
              ),
            ),
            const SizedBox(height: 15),
            const Text("الهدف", style: TextStyle(fontWeight: FontWeight.bold)),
            Card(
              child: DropdownButton<String>(
                value: goal,
                isExpanded: true,
                items: ['خسارة الوزن', 'الحفاظ', 'زيادة العضلات']
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (val) => setState(() => goal = val!),
              ),
            ),
            const SizedBox(height: 25),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  final calories = calculateCalories();
                  if (calories != null) {
                    setState(() {
                      result = '🍽️ السعرات اليومية اللازمة: ${calories.toStringAsFixed(0)} سعرة حرارية في اليوم';
                    });
                  } else {
                    setState(() {
                      result = '⚠️ من فضلك أدخل كل القيم المطلوبة';
                      suggestion = '';
                    });
                  }
                },
                icon: const Icon(Icons.calculate),
                label: const Text("احسب السعرات"),
              ),
            ),
            const SizedBox(height: 30),
            if (result.isNotEmpty) ...[
              Text(result,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              if (suggestion.isNotEmpty)
                Text(suggestion,
                    style: const TextStyle(fontSize: 16, color: Colors.grey)),
            ],
            const SizedBox(height: 30),
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
                  });
                },
                child: const Text("إعادة تعيين"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
