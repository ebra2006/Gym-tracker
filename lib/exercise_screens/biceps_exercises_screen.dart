import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../workout_details_screen.dart';
import 'package:flutter/services.dart';

class BicepsExercisesScreen extends StatefulWidget {
  const BicepsExercisesScreen({super.key});

  @override
  State<BicepsExercisesScreen> createState() => _BicepsExercisesScreenState();
}

class _BicepsExercisesScreenState extends State<BicepsExercisesScreen> {
  // التمارين الأساسية (يمكن تعديلها)
  final List<String> baseWorkouts = const [
    'Biceps',
  ];

// بيانات التمارين
  List<String> customWorkouts = [];
  List<String> favoriteWorkouts = [];
  List<String> recentWorkouts = [];

  String gender = 'Male'; // افتراضيًا ذكر
  List<Map<String, String>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts();
    _loadFavorites();
    _loadRecent();
    _loadGenderAndSetCategories();
  }

  void _loadCustomWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts = prefs.getStringList('customBicepsWorkouts') ?? [];
    });
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteWorkouts = prefs.getStringList('favoriteBicepsWorkouts') ?? [];
    });
  }

  void _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentWorkouts = prefs.getStringList('recentBicepsWorkouts') ?? [];
    });
  }

  Future<void> _loadGenderAndSetCategories() async {
    final prefs = await SharedPreferences.getInstance();
    gender = prefs.getString('gender') ?? 'Male';

    if (gender == 'Male') {
      categories = [
        {'name': 'Biceps', 'image': 'assets/images/biceps.png'},
      ];
    } else {
      categories = [
        {'name': 'Biceps', 'image': 'assets/female/biceps.png'},
      ];
    }

    setState(() {});
  }

  void _toggleFavorite(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (favoriteWorkouts.contains(name)) {
        favoriteWorkouts.remove(name);
      } else {
        favoriteWorkouts.add(name);
      }
      prefs.setStringList('favoriteBicepsWorkouts', favoriteWorkouts);
    });
  }

  void _addToRecent(String name) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentWorkouts.remove(name);
      recentWorkouts.insert(0, name);
      if (recentWorkouts.length > 10) {
        recentWorkouts = recentWorkouts.sublist(0, 10);
      }
      prefs.setStringList('recentBicepsWorkouts', recentWorkouts);
    });
  }

  void _addCustomWorkout(String workout) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts.add(workout);
    });
    prefs.setStringList('customBicepsWorkouts', customWorkouts);
  }

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
                  customWorkouts.remove(workout);
                });

                await prefs.setStringList('customBicepsWorkouts', customWorkouts);

                if (!context.mounted) return;

                Navigator.of(context).pop();
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

// صورة التمرين الأساسي حسب اسمه (للعرض فقط) من قائمة categories
  String getWorkoutImage(String name) {
    final category = categories.firstWhere(
          (cat) => cat['name'] == name,
      orElse: () => {'name': '', 'image': ''},
    );
    return category['image'] ?? '';
  }
//هنا اخرها





  // جمع كل التمارين الأساسية + المخصصة بدون تكرار
  List<String> get allWorkouts {
    // نضم التمارين الأساسية والمخصصة، ونتأكد من عدم تكرار اسم
    final Set<String> all = {...baseWorkouts, ...customWorkouts};
    return all.toList();
  }

  // ترتيب التمارين حسب: مفضلة > حديثة > باقي التمارين
  List<Map<String, dynamic>> get orderedWorkouts {
    final favs = favoriteWorkouts.where((w) => allWorkouts.contains(w)).toList();
    final recents = recentWorkouts
        .where((w) => allWorkouts.contains(w) && !favs.contains(w))
        .toList();
    final others = allWorkouts
        .where((w) => !favs.contains(w) && !recents.contains(w))
        .toList();

    List<Map<String, dynamic>> mapFromNames(List<String> names) {
      return names.map((name) {
        bool isCustom = customWorkouts.contains(name);
        String image = isCustom ? '' : getWorkoutImage(name);
        return {
          'name': name,
          'isCustom': isCustom,
          'image': image,
        };
      }).toList();
    }

    return [
      ...mapFromNames(favs),
      ...mapFromNames(recents),
      ...mapFromNames(others),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                        'Biceps Exercises',
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
        child: GridView.builder(
          // عدد الكروت = عدد التمارين المرتبة + كارد الإضافة
          itemCount: orderedWorkouts.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            if (index < orderedWorkouts.length) {
              final item = orderedWorkouts[index];
              final name = item['name'];
              final isCustom = item['isCustom'] ?? false;

              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withAlpha((0.3 * 255).round()),
                  highlightColor: Colors.white.withAlpha((0.1 * 255).round()),

                  onTap: () {
                    _addToRecent(name);
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return WorkoutDetailsScreen(categoryName: name);
                        },
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(1.0, 0.0),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          );
                        },
                      ),
                    );
                  },//زر اضافة تمارين مخصصة
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        if (!isCustom && item['image'] != '')
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              item['image'],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        else
                          Builder(
                            builder: (context) {
                              final isDark = Theme.of(context).brightness == Brightness.dark;
                              final bgColor = Theme.of(context).scaffoldBackgroundColor;
                              final iconColor = isDark ? Colors.white : Colors.black87;
                              final haloColor = isDark ? Colors.white.withAlpha(26) : Colors.black.withAlpha(26);


                              return Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: haloColor,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Icon(
                                      Icons.fitness_center,
                                      size: 48,
                                      color: iconColor,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        Container(
                          alignment: Alignment.bottomCenter,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: Theme.of(context).brightness == Brightness.dark
                                  ? [
                                Colors.transparent,
                                Colors.black.withAlpha(153),
                              ]
                                  : [
                                Colors.transparent,
                                Colors.grey.withAlpha(64),
                              ],

                            ),
                          ),

                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Tooltip(
                                message: 'المفضلة',
                                waitDuration: const Duration(milliseconds: 200),
                                showDuration: const Duration(milliseconds: 400),


                                preferBelow: false,  // خليها تظهر فوق الأيقونة
                                child: IconButton(
                                  icon: Icon(
                                    favoriteWorkouts.contains(name) ? Icons.star : Icons.star_border,
                                    color: favoriteWorkouts.contains(name) ? Colors.amber : Colors.white,
                                  ),
                                  onPressed: () => _toggleFavorite(name),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),


                            ],
                          ),
                        ),
                        if (isCustom)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => _removeCustomWorkout(name),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                      ],
                    ),
                  ),


                ),
              );
            } else {
              // كارد إضافة تمرين جديد (آخر كارد)
              return Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withAlpha(77),        // 0.3 * 255 ≈ 77
                  highlightColor: Colors.white.withAlpha(26),     // 0.1 * 255 ≈ 26

                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        String newWorkout = '';
                        return AlertDialog(
                          title: const Text("Add Custom Workout"),
                          content: TextField(
                            autofocus: true,
                            maxLength: 40, // أقصى طول اسم التمرينة هو 20 حرف أو رقم
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\u0600-\u06FF]')),
                            ],
                            decoration: const InputDecoration(
                              hintText: "Workout name",
                              counterText: '', // يخفي عداد الحروف أسفل الحقل
                            ),
                            onChanged: (value) {
                              newWorkout = value;
                            },
                          ),


                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: () {
                                if (newWorkout.trim().isNotEmpty) {
                                  _addCustomWorkout(newWorkout.trim());
                                  Navigator.of(context).pop();
                                }
                              },
                              child: const Text("Add"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add,
                        size: 48,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
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
