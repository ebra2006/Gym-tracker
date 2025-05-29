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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final labelColor = isDark ? Colors.white70 : const Color(0xFF5E35B1);
        final borderColor = isDark ? Colors.white54 : const Color(0xFF7E57C2);

        return AlertDialog(
          backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('إضافة وجبة', style: TextStyle(color: labelColor)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _customTextField('اسم الوجبة', (v) => name = v,
                    labelColor: labelColor, borderColor: borderColor),
                _customTextField('جرام', (v) => grams = v,
                    num: true, labelColor: labelColor, borderColor: borderColor),
                _customTextField('سعرات حرارية', (v) => calories = v,
                    num: true, labelColor: labelColor, borderColor: borderColor),
                _customTextField('بروتين (جم)', (v) => protein = v,
                    num: true, labelColor: labelColor, borderColor: borderColor),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF7E57C2), // بنفسجي متوسط
              ),
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
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5E35B1), // بنفسجي غامق
              ),
              child: const Text('إضافة'),
            ),
          ],
        );
      },
    );
  }

  Widget _customTextField(String label, Function(String) onChanged,
      {bool num = false, Color? labelColor, Color? borderColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: labelColor),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.purple),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: borderColor ?? Colors.deepPurple),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        style: TextStyle(color: labelColor),
        keyboardType: num ? TextInputType.number : TextInputType.text,
        onChanged: onChanged,
      ),
    );
  }

  void confirmDeleteMeal(int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        title: Text(
          'تأكيد الحذف',
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF5E35B1)),
        ),
        content: Text(
          'هل أنت متأكد من حذف هذه الوجبة؟',
          style: TextStyle(color: isDark ? Colors.white70 : Colors.black87),
        ),
        actions: [
          TextButton(
            child: Text('إلغاء',
                style: TextStyle(color: isDark ? Colors.white54 : const Color(0xFF7E57C2))),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('حذف'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleColor = isDark ? Colors.white : const Color(0xFF5E35B1);
    final subtitleColor = isDark ? Colors.white70 : Colors.black87;

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
        color: cardColor,
        elevation: 4,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          title: Text(
            meal['name'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
              fontSize: 18,
            ),
          ),
          subtitle: Text(
            'جرام: ${meal['grams']} | سعرات: ${meal['calories']} | بروتين: ${meal['protein']} جم',
            style: TextStyle(color: subtitleColor),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  meal['taken']
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: meal['taken'] ? Colors.green.shade400 : Colors.grey,
                  size: 28,
                ),
                onPressed: () => toggleMealTaken(index),
              ),
              IconButton(
                icon: Icon(Icons.delete,
                    color: Colors.red.shade400, size: 28),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFE3F2FD);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.transparent,  // خلي الخلفية شفافة عشان الـ theme يأثر عليها لو حبيت
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
                        color: Theme.of(context).iconTheme.color,  // لون الأيقونة حسب الثيم
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        'وجباتي',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).primaryColor,  // لون النص حسب الثيم
                        ),
                      ),
                      const Spacer(flex: 2),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: addMeal,
                        color: Theme.of(context).iconTheme.color,  // لون الأيقونة حسب الثيم
                        iconSize: 28,
                      ),
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

      body: meals.isEmpty
          ? Center(
        child: Text(
          'لا توجد وجبات بعد',
          style: TextStyle(
            fontSize: 18,
            color: isDark ? Colors.white70 : const Color(0xFF5E35B1),
            fontWeight: FontWeight.w500,
          ),
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
