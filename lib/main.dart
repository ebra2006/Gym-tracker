import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'start_screen.dart';
import 'main_screen.dart';

// نوتيفايزر للتحكم بوضع الثيم (داكن/فاتح)
final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);

// نوتيفايزر للتحكم بلون الثيم (بنفسجي / أزرق)
final ValueNotifier<bool> isPurpleThemeNotifier = ValueNotifier(true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final isPurpleTheme = prefs.getBool('isPurpleTheme') ?? true;

  themeModeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  isPurpleThemeNotifier.value = isPurpleTheme;

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isFirstTime;

  @override
  void initState() {
    super.initState();
    _loadFirstTime();
  }

  Future<void> _loadFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder2<ThemeMode, bool>(
      firstNotifier: themeModeNotifier,
      secondNotifier: isPurpleThemeNotifier,
      builder: (context, themeMode, isPurple, _) {
        // بناء ثيمات لايت ودارك مع ألوان مختلفة حسب اختيار المستخدم
        final lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: isPurple ? Colors.deepPurple : Colors.blue,
          appBarTheme: AppBarTheme(
            backgroundColor: isPurple ? Colors.deepPurple : Colors.blue,
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: isPurple ? Colors.deepPurple : Colors.blue,
            brightness: Brightness.light,
          ),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: isPurple ? Colors.deepPurple : Colors.blue[700],
          appBarTheme: AppBarTheme(
            backgroundColor: isPurple ? Colors.deepPurple : Colors.blue[700],
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: isPurple ? Colors.deepPurple : Colors.blue,
            brightness: Brightness.dark,
          ),
        );

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gym Tracker',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          home: isFirstTime == null
              ? const Scaffold(body: Center(child: CircularProgressIndicator()))
              : isFirstTime!
              ? StartScreen(onFinished: _loadFirstTime)
              : const MainScreen(),
        );
      },
    );
  }
}

// Helper widget لدمج 2 ValueListenableBuilder مع بعض
class ValueListenableBuilder2<A, B> extends StatelessWidget {
  final ValueNotifier<A> firstNotifier;
  final ValueNotifier<B> secondNotifier;
  final Widget Function(BuildContext, A, B, Widget?) builder;

  const ValueListenableBuilder2({
    Key? key,
    required this.firstNotifier,
    required this.secondNotifier,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<A>(
      valueListenable: firstNotifier,
      builder: (context, firstValue, _) {
        return ValueListenableBuilder<B>(
          valueListenable: secondNotifier,
          builder: (context, secondValue, child) {
            return builder(context, firstValue, secondValue, child);
          },
        );
      },
    );
  }
}
