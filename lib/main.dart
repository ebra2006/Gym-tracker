import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // ✅ ScreenUtil Import
import 'start_screen.dart';
import 'main_screen.dart';
import 'screens/feedback_page.dart';

final ValueNotifier<ThemeMode> themeModeNotifier = ValueNotifier(ThemeMode.light);
final ValueNotifier<bool> isPurpleThemeNotifier = ValueNotifier(true);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final isPurpleTheme = prefs.getBool('isPurpleTheme') ?? false;

  themeModeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;
  isPurpleThemeNotifier.value = isPurpleTheme;

  runApp(
    ScreenUtilInit( // ✅ ScreenUtilInit هنا
      designSize: Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isFirstTime;
  bool isTrialExpired = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final expiryDate = DateTime(2028, 10, 1);

    setState(() {
      isTrialExpired = now.isAfter(expiryDate);
      isFirstTime = prefs.getBool('isFirstTime') ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const softNeonPurple = Color(0xFF9C27B0);

    return ValueListenableBuilder2<ThemeMode, bool>(
      firstNotifier: themeModeNotifier,
      secondNotifier: isPurpleThemeNotifier,
      builder: (context, themeMode, isPurple, _) {
        final lightTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          primaryColor: isPurple ? softNeonPurple : Colors.blue,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: isPurple ? softNeonPurple : Colors.blue,
            foregroundColor: Colors.white,
          ),
          colorScheme: ColorScheme.light(
            primary: isPurple ? softNeonPurple : Colors.blue,
          ),
        );

        final darkTheme = ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primaryColor: isPurple ? softNeonPurple : Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            foregroundColor: Colors.white,
          ),
          cardColor: const Color(0xFF1C1C1C),
          inputDecorationTheme: const InputDecorationTheme(
            fillColor: Color(0xFF1E1E1E),
            filled: true,
            border: OutlineInputBorder(),
            hintStyle: TextStyle(color: Colors.white54),
          ),
          colorScheme: ColorScheme.dark(
            primary: isPurple ? softNeonPurple : Colors.blue,
          ),
        );

        Widget homeScreen;
        if (isTrialExpired) {
          homeScreen = const TrialExpiredScreen();
        } else if (isFirstTime == null) {
          homeScreen = const Scaffold(body: Center(child: CircularProgressIndicator()));
        } else if (isFirstTime!) {
          homeScreen = StartScreen(onFinished: _loadInitialData);
        } else {
          homeScreen = const MainScreen();
        }

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Gym Tracker',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeMode,
          builder: (context, widget) {
            final mediaQuery = MediaQuery.of(context);
            return MediaQuery(
              data: mediaQuery.copyWith(textScaleFactor: 1.0), // ✅ هنا تثبيت تأثير إعدادات تكبير الخط
              child: widget!,
            );
          },
          home: homeScreen,
        );
      },
    );
  }
}

// ✅ شاشة انتهاء النسخة
class TrialExpiredScreen extends StatelessWidget {
  const TrialExpiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_clock, size: 80, color: isDark ? Colors.white70 : Colors.black54),
              const SizedBox(height: 24),
              Text(
                'انتهت صلاحية النسخة التجريبية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'للاستمرار باستخدام التطبيق، يرجى التواصل مع المطور لطلب النسخة الجديدة.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeedbackPage()),
                  );
                },
                icon: const Icon(Icons.feedback),
                label: const Text('التواصل مع المطور'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ✅ تعريف ValueListenableBuilder2 لحل المشكلة
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
