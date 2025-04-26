import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Map<String, dynamic>> meals = [];

  @override
  void initState() {
    super.initState();
    resetMealsIfNewDay();
    loadMeals();
  }

  Future<void> resetMealsIfNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T').first;
    final lastOpened = prefs.getString('last_opened_day');

    if (lastOpened != today) {
      final savedMeals = prefs.getString('meals_list');
      if (savedMeals != null) {
        List<Map<String, dynamic>> loadedMeals =
        List<Map<String, dynamic>>.from(json.decode(savedMeals));
        for (var meal in loadedMeals) {
          meal['taken'] = false;
        }
        prefs.setString('meals_list', json.encode(loadedMeals));
      }
      prefs.setString('last_opened_day', today);
    }
  }

  Future<void> loadMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMeals = prefs.getString('meals_list');
    if (savedMeals != null) {
      setState(() {
        meals = List<Map<String, dynamic>>.from(json.decode(savedMeals));
      });
    }
  }

  Future<void> saveMeals() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('meals_list', json.encode(meals));
  }

  void addMeal() {
    String name = '';
    String grams = '';
    String calories = '';
    String protein = '';

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة وجبة'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _customTextField('اسم الوجبة', (v) => name = v),
                _customTextField('جرام', (v) => grams = v, num: true),
                _customTextField('سعرات حرارية', (v) => calories = v, num: true),
                _customTextField('بروتين (جم)', (v) => protein = v, num: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (name.isNotEmpty) {
                  setState(() {
                    meals.add({
                      'name': name,
                      'grams': grams,
                      'calories': calories,
                      'protein': protein,
                      'taken': false,
                    });
                  });
                  saveMeals();
                  Navigator.pop(context);
                }
              },
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Widget _customTextField(String label, Function(String) onChanged, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        keyboardType: num ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  void confirmDeleteMeal(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: const Text('هل أنت متأكد من حذف هذه الوجبة؟'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('حذف'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              deleteMeal(index);
            },
          ),
        ],
      ),
    );
  }

  void deleteMeal(int index) {
    setState(() {
      meals.removeAt(index);
    });
    saveMeals();
  }

  void toggleMealTaken(int index) {
    setState(() {
      meals[index]['taken'] = !(meals[index]['taken'] ?? false);
    });
    saveMeals();

    if (meals[index]['taken']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('أحسنت! تم إنجاز هذه الوجبة 🎉'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget animatedMealItem(Map<String, dynamic> meal, int index) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + index * 50),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: child,
        ),
      ),
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(
            meal['name'],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            'جرام: ${meal['grams']} | سعرات: ${meal['calories']} | بروتين: ${meal['protein']} جم',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  meal['taken']
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: meal['taken'] ? Colors.green : Colors.grey,
                ),
                onPressed: () => toggleMealTaken(index),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => confirmDeleteMeal(index),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1F3F6),
      appBar: AppBar(
        title: const Text('وجباتي'),
        backgroundColor: Colors.green.shade400,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: addMeal,
          ),
        ],
      ),
      body: meals.isEmpty
          ? const Center(
        child: Text(
          'لا توجد وجبات بعد',
          style: TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) =>
            animatedMealItem(meals[index], index),
      ),
    );
  }
}
