import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool notificationsEnabled = false;

  final List<int> intervals = [
    60,
    90,
    120,
    180,
    240,
  ];

  int selectedInterval = 120;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedInterval = prefs.getInt("water_interval") ?? 120;

    setState(() {
      notificationsEnabled =
          prefs.getBool("water_enabled") ?? false;

      selectedInterval = intervals.contains(savedInterval)
          ? savedInterval
          : 120;
    });
  }

  Future<void> saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "water_enabled",
      notificationsEnabled,
    );

    await prefs.setInt(
      "water_interval",
      selectedInterval,
    );

    if (notificationsEnabled) {
      await NotificationService.scheduleWaterReminders(
        selectedInterval,
      );
    } else {
      await NotificationService.cancelAll();
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Settings saved successfully ✅"),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

  }

  String intervalText(int value) {
    switch (value) {
      case 60:
        return "1 Hour";
      case 90:
        return "1.5 Hours";
      case 120:
        return "2 Hours";
      case 180:
        return "3 Hours";
      case 240:
        return "4 Hours";
      default:
        return "$value Minutes";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(


      appBar: PreferredSize(
        preferredSize: Size.fromHeight(56.h),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 4.h,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          size: 24.w,
                        ),
                        color: theme.iconTheme.color,
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.all(4.w),
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        'Notification Settings',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.primaryColor,
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
                child: Divider(
                  height: 1.h,
                  thickness: 1.h,
                ),
              ),
            ],
          ),
        ),
      ),



      body: Padding(
        padding: EdgeInsets.all(18.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: SwitchListTile(
                value: notificationsEnabled,
                activeColor: theme.primaryColor,
                title: Text(
                  "Enable Water Reminder",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Receive periodic reminders to drink water.",
                ),
                onChanged: (value) {
                  setState(() {
                    notificationsEnabled = value;
                  });
                },
              ),
            ),

            SizedBox(height: 24.h),

            Text(
              "Reminder Interval",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: 12.h),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: DropdownButton<int>(
                  value: selectedInterval,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: intervals.map((value) {
                    return DropdownMenuItem(
                      value: value,
                      child: Text(
                        intervalText(value),
                        style: TextStyle(
                          fontSize: 16.sp,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: notificationsEnabled
                      ? (value) {
                    setState(() {
                      selectedInterval = value!;
                    });
                  }
                      : null,
                ),
              ),
            ),

            SizedBox(height: 25.h),

            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Preview",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    notificationsEnabled
                        ? "You will receive a reminder every ${intervalText(selectedInterval)}."
                        : "Notifications are disabled.",
                    style: TextStyle(
                      fontSize: 15.sp,
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: Text(
                  "Save Settings",
                  style: TextStyle(
                    fontSize: 16.sp,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),


                onPressed: () async {
                  if (notificationsEnabled) {
                    final granted =
                    await NotificationService.requestPermission();

                    if (!granted) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Notifications are disabled. Go to Settings > Apps > Gym Tracker > Notifications and enable them.",
                          ),
                          duration: Duration(seconds: 5),
                        ),
                      );

                      return;
                    }
                  }

                  await saveSettings();
                },



              ),
            ),
          ],
        ),
      ),
    );
  }
}