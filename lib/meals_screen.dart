import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flutter/services.dart';


class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen> {
  List<Map<String, dynamic>> meals = [];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

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
    nameController.clear();
    caloriesController.clear();
    noteController.clear();

    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Add Meal',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
              )),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                maxLength: 20,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zأ-ي0-9 ]')),
                ],
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : textColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Meal name',
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: caloriesController,
                keyboardType: TextInputType.number,
                maxLength: 3,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : textColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Calories (optional)',
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ),
              TextField(
                controller: noteController,
                maxLength: 50,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Zأ-ي0-9 ]')),
                ],
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark ? Colors.white : textColor,
                ),
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  labelStyle: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ),
            ],

          ),
          actions: [
            TextButton(
              child: Text('Cancel', style: TextStyle(color: primaryColor)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Add'),
              //المدخلات5455665
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  // اسم الوجبة مطلوب فقط
                  return;
                }
                setState(() {
                  meals.add({
                    'name': nameController.text.trim(),
                    'calories': caloriesController.text.trim(), // ممكن تكون فاضية
                    'note': noteController.text.trim(),
                    'taken': false,
                  });
                });
                saveMeals();
                Navigator.of(context).pop();
              },

            ),
          ],
        );
      },
    );
  }

  void confirmDeleteMeal(int index) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final colorSecondary = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm deletion',
          style: TextStyle(
              color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to delete this meal?',
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: colorSecondary)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
      final theme = Theme.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Great job! Meal completed 🎉'),
          backgroundColor: Colors.green.shade600,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          elevation: 5,
        ),
      );
    }
  }
// تصميم الكارداااااااااات
  Widget animatedMealItem(
      Map<String, dynamic> meal,
      int index,
      Color primaryColor,
      Color onBackground,
      ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final backgroundGradient = isDark
        ? [const Color(0xFF1E1E1E), const Color(0xFF2C2C2C)]
        : [Colors.white, Colors.grey.shade100];

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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: backgroundGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.4)
                  : Colors.grey.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          leading: Icon(
            meal['taken'] ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: meal['taken'] ? Colors.green : primaryColor,
            size: 30,
          ),
          title: Text(
            meal['name'],
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if ((meal['calories'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Calories: ${meal['calories']}',
                    style: TextStyle(
                      color: textColor.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ),
              if ((meal['note'] ?? '').toString().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    'Note: ${meal['note']}',
                    style: TextStyle(
                      color: textColor.withOpacity(0.5),
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ),
          trailing: InkWell(
            onTap: () => confirmDeleteMeal(index),
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.delete_outline, color: Colors.red.shade400),
            ),
          ),
          onTap: () => toggleMealTaken(index),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
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
                        'Meals',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: primaryColor, // العنوان بالـ primaryColor فقط
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        child: Icon(Icons.add, size: 30, color: theme.colorScheme.onPrimary),
        onPressed: addMeal,
        elevation: 6,
      ),
      body: meals.isEmpty
          ? Center(
        child: Text(
          'You haven’t added any meals yet',
          style: TextStyle(fontSize: 18, color: textColor.withOpacity(0.6)),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: meals.length,
        itemBuilder: (context, index) {
          return animatedMealItem(meals[index], index, primaryColor, textColor);
        },
      ),
    );
  }
}
