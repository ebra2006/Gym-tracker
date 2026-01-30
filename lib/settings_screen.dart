import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // للوصول لل-notifiers
import 'exercises_screen.dart';
import 'weight_tracker_page.dart';
import 'start_screen.dart'; // استيراد صفحة StartScreen
import '../screens/feedback_page.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isDarkMode = false;
  bool isPurpleTheme = true;

  @override
  void initState() {
    super.initState();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      isPurpleTheme = prefs.getBool('isPurpleTheme') ?? true;
    });
  }

  Future<void> toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isDarkMode = value);
    await prefs.setBool('isDarkMode', value);
    themeModeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleColorTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => isPurpleTheme = value);
    await prefs.setBool('isPurpleTheme', value);
    isPurpleThemeNotifier.value = value;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black87;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back, size: 24.w),
                        color: theme.iconTheme.color,
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.all(4.w),
                        constraints: BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: primaryColor,
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Divider(height: 1.h, thickness: 1.h),
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'Dark Mode',
                style: TextStyle(fontSize: 16.sp),
              ),
              value: isDarkMode,
              activeColor: primaryColor,
              onChanged: toggleDarkMode,
            ),
           // SwitchListTile(
             // title: Text(
              //  'Use Purple Theme',
              //  style: TextStyle(fontSize: 16.sp),
            //  ),
             // subtitle: Text(
               // 'Turn off to switch to Blue Theme',
               // style: TextStyle(fontSize: 12.sp),
             // ),
             // value: isPurpleTheme,
             // activeColor: primaryColor,
             // onChanged: toggleColorTheme,
            // ),
            SizedBox(height: 24.h),
            _buildCustomTile(
              icon: Icons.feedback_outlined,
              label: 'Send Feedback',
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const FeedbackPage(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );

                if (result == true) {
                  await Future.delayed(const Duration(milliseconds: 300));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.email_outlined, color: Colors.white, size: 20.w),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              'Thank you for your valuable feedback! We’ve already received it. We will keep working to improve the app and provide you with a better experience 💪',
                              style: TextStyle(color: Colors.white, fontSize: 14.sp),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      margin: EdgeInsets.all(16.w),
                      duration: const Duration(hours: 1),
                      action: SnackBarAction(
                        label: 'Done',
                        textColor: Colors.white,
                        onPressed: () {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        },
                      ),
                    ),
                  );
                }
              },
              primaryColor: primaryColor,
              textColor: textColor,
              isDarkMode: theme.brightness == Brightness.dark,
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: Size.fromHeight(50.h),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 4,
              ),
              icon: Icon(Icons.edit, size: 20.w),
              label: Text(
                'Edit Personal Information',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => StartScreen(
                      onFinished: () {
                        Navigator.pop(context);
                      },
                    ),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      final scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                      );
                      final fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                      );
                      return FadeTransition(
                        opacity: fadeAnimation,
                        child: ScaleTransition(
                          scale: scaleAnimation,
                          child: child,
                        ),
                      );
                    },
                  ),
                ).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('يجب إعادة تشغيل التطبيق لتطبيق التغييرات', style: TextStyle(fontSize: 14.sp)),
                      duration: const Duration(seconds: 5),
                    ),
                  );
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomTile({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color primaryColor,
    required Color textColor,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        splashColor: isDarkMode ? Colors.white24 : primaryColor.withOpacity(0.2),
        highlightColor: isDarkMode ? Colors.white10 : primaryColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              Icon(icon, color: primaryColor, size: 24.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16.w, color: textColor.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
