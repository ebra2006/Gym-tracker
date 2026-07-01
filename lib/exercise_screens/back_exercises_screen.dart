import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../workout_details_screen.dart';

class BackExercisesScreen extends StatefulWidget {
  const BackExercisesScreen({super.key});

  @override
  State<BackExercisesScreen> createState() => _BackExercisesScreenState();
}

class _BackExercisesScreenState extends State<BackExercisesScreen> {
  final List<String> baseWorkouts = const [
    'lat pulldown',
    'close grip lat pulldown',
    'wide grip lat pulldown',
    'pull-ups',
    'chin-ups',
    'seated cable row',
    'barbell row',
    'dumbbell row',
    't-bar row',
    'machine row',
    'straight arm pulldown',
    'face pull',
    'deadlift',
    'rack pull',
    'back extension',
  ];

  List<String> customWorkouts = [];
  List<String> favoriteWorkouts = [];
  List<String> recentWorkouts = [];

  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  String gender = 'Male';
  List<Map<String, String>> categories = [];

  @override
  void initState() {
    super.initState();
    _loadCustomWorkouts();
    _loadFavorites();
    _loadRecent();
    _loadGenderAndSetCategories();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _loadCustomWorkouts() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      customWorkouts = prefs.getStringList('customBackWorkouts') ?? [];
    });
  }

  void _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      favoriteWorkouts = prefs.getStringList('favoriteBackWorkouts') ?? [];
    });
  }

  void _loadRecent() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentWorkouts = prefs.getStringList('recentBackWorkouts') ?? [];
    });
  }

  Future<void> _loadGenderAndSetCategories() async {
    final prefs = await SharedPreferences.getInstance();
    gender = prefs.getString('gender') ?? 'Male';

    if (gender == 'Male') {
      categories = [
        {'name': 'lat pulldown', 'image': 'assets/female/lat pulldown.jpg'},
        {
          'name': 'seated cable row',
          'image': 'assets/female/Seated Caple Row.jpg',
        },
        {'name': 'barbell row', 'image': 'assets/female/Barbell Row.jpg'},
        {'name': 'dumbbell row', 'image': 'assets/female/Dumbell Row.jpg'},
        {'name': 'pull-ups', 'image': 'assets/female/pull-ups.jpg'},
        {'name': 'deadlift', 'image': 'assets/female/Deadlift.jpg'},
      ];
    } else {
      categories = [
        {'name': 'lat pulldown', 'image': 'assets/female/lat pulldowngirl.jpg'},
        {
          'name': 'seated cable row',
          'image': 'assets/female/Seated Caple Rowgirl.jpg',
        },
        {'name': 'barbell row', 'image': 'assets/female/Barbell Rowgirl.jpg'},
        {'name': 'dumbbell row', 'image': 'assets/female/Dumbell Rowgirl.jpg'},
        {'name': 'pull-ups', 'image': 'assets/female/pull-upsgirl.jpg'},
        {'name': 'deadlift', 'image': 'assets/female/Deadliftgirl.jpg'},
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
    });

    await prefs.setStringList('favoriteBackWorkouts', favoriteWorkouts);
  }

  void _addToRecent(String name) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      recentWorkouts.remove(name);
      recentWorkouts.insert(0, name);

      if (recentWorkouts.length > 10) {
        recentWorkouts = recentWorkouts.sublist(0, 10);
      }
    });

    await prefs.setStringList('recentBackWorkouts', recentWorkouts);
  }

  void _addCustomWorkout(String workout) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      customWorkouts.add(workout);
    });

    await prefs.setStringList('customBackWorkouts', customWorkouts);
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

                await prefs.setStringList('customBackWorkouts', customWorkouts);

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

  String getWorkoutImage(String name) {
    final category = categories.firstWhere(
          (cat) => cat['name']?.toLowerCase() == name.toLowerCase(),
      orElse: () => {'name': '', 'image': ''},
    );

    return category['image'] ?? '';
  }

  List<String> get allWorkouts {
    final Set<String> all = {...baseWorkouts, ...customWorkouts};
    return all.toList();
  }

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
        final isCustom = customWorkouts.contains(name);
        final image = isCustom ? '' : getWorkoutImage(name);

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

  List<Map<String, dynamic>> get filteredWorkouts {
    final query = searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return orderedWorkouts;
    }

    return orderedWorkouts.where((item) {
      final name = item['name'].toString().toLowerCase();
      return name.contains(query);
    }).toList();
  }

  void _openWorkoutDetails(String name) {
    _addToRecent(name);

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return WorkoutDetailsScreen(categoryName: name);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutQuart,
            reverseCurve: Curves.easeInQuart,
          );

          final slide = Tween<Offset>(
            begin: const Offset(0.08, 0.0),
            end: Offset.zero,
          ).animate(curved);

          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: slide,
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _showAddCustomWorkoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newWorkout = '';

        return AlertDialog(
          title: const Text("Add Custom Workout"),
          content: TextField(
            autofocus: true,
            maxLength: 40,
            inputFormatters: [
              FilteringTextInputFormatter.allow(
                RegExp(r'[a-zA-Z0-9\s\u0600-\u06FF]'),
              ),
            ],
            decoration: const InputDecoration(
              hintText: "Workout name",
              counterText: '',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
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
                        'Back Exercises',
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
            TextField(
              controller: searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: "Search exercise",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      searchQuery = '';
                      searchController.clear();
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                itemCount: filteredWorkouts.length + 1,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  if (index < filteredWorkouts.length) {
                    final item = filteredWorkouts[index];
                    final name = item['name'].toString();
                    final isCustom = item['isCustom'] ?? false;

                    return _WorkoutCard(
                      name: name,
                      image: item['image']?.toString() ?? '',
                      isCustom: isCustom,
                      isFavorite: favoriteWorkouts.contains(name),
                      onTap: () => _openWorkoutDetails(name),
                      onFavoriteTap: () => _toggleFavorite(name),
                      onDeleteTap:
                      isCustom ? () => _removeCustomWorkout(name) : null,
                    );
                  }

                  return _AddWorkoutCard(
                    onTap: _showAddCustomWorkoutDialog,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final String name;
  final String image;
  final bool isCustom;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onDeleteTap;

  const _WorkoutCard({
    required this.name,
    required this.image,
    required this.isCustom,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    required this.onDeleteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withAlpha((0.3 * 255).round()),
        highlightColor: Colors.white.withAlpha((0.1 * 255).round()),
        onTap: onTap,
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              if (!isCustom && image.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                )
              else
                Builder(
                  builder: (context) {
                    final isDark =
                        Theme.of(context).brightness == Brightness.dark;
                    final bgColor = Theme.of(context).scaffoldBackgroundColor;
                    final iconColor = isDark ? Colors.white : Colors.black87;
                    final haloColor = isDark
                        ? Colors.white.withAlpha(26)
                        : Colors.black.withAlpha(26);

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
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
                      message: 'Favorite',
                      waitDuration: const Duration(milliseconds: 200),
                      showDuration: const Duration(milliseconds: 400),
                      preferBelow: false,
                      child: IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.white,
                        ),
                        onPressed: onFavoriteTap,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCustom && onDeleteTap != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(
                      Icons.delete,
                      color: Colors.redAccent,
                    ),
                    onPressed: onDeleteTap,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddWorkoutCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddWorkoutCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        splashColor: Colors.white.withAlpha(77),
        highlightColor: Colors.white.withAlpha(26),
        onTap: onTap,
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
}