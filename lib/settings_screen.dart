import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart'; // للوصول لل-notifiers
import 'exercises_screen.dart';
import 'weight_tracker_page.dart';
import 'start_screen.dart'; // استيراد صفحة StartScreen
import '../screens/feedback_page.dart';

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
                        'Settings',
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
            SwitchListTile(
              title: const Text('Dark Mode'),
              value: isDarkMode,
              activeColor: primaryColor,
              onChanged: toggleDarkMode,
            ),
            SwitchListTile(
              title: const Text('Use Purple Theme'),
              subtitle: const Text('Turn off to switch to Blue Theme'),
              value: isPurpleTheme,
              activeColor: primaryColor,
              onChanged: toggleColorTheme,
            ),
            const SizedBox(height: 24),
            

            _buildCustomTile(
              icon: Icons.feedback_outlined,
              label: 'إرسال ملاحظات',
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

                // هنا نتحقق بعد العودة من صفحة FeedbackPage وليس داخلها
                if (result == true) {
                  // تأخير بسيط لضمان انتهاء عملية العودة
                  await Future.delayed(const Duration(milliseconds: 300));

                  // عرض الـ SnackBar في الصفحة الحالية (SettingsScreen)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.email_outlined, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'شكرًا لملاحظاتك القيّمة! لقد تلقيناها بالفعل. سنعمل باستمرار على تحسين التطبيق لتقديم تجربة أفضل تليق بك 💪',
                              style: const TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Theme.of(context).primaryColor,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      margin: const EdgeInsets.all(16),
                      duration: const Duration(hours: 1),
                      action: SnackBarAction(
                        label: 'تم',
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

            // زر تعديل المعلومات الشخصية في أسفل الصفحة
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
              ),
              icon: const Icon(Icons.edit),
              label: const Text(
                'تعديل المعلومات الشخصية',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
                    const SnackBar(
                      content: Text('يجب إعادة تشغيل التطبيق لتطبيق التغييرات'),
                      duration: Duration(seconds: 5),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        splashColor: isDarkMode ? Colors.white24 : primaryColor.withOpacity(0.2),
        highlightColor: isDarkMode ? Colors.white10 : primaryColor.withOpacity(0.1),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: primaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: textColor.withOpacity(0.6)),
            ],
          ),
        ),
      ),
    );
  }
}
