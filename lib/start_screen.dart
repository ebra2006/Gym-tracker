import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';


class StartScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const StartScreen({super.key, required this.onFinished});

  @override
  StartScreenState createState() => StartScreenState();
}

class StartScreenState extends State<StartScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controller = TextEditingController();
  String? name, gender;
  double? weight, height;
  int? age;

  int selectedAge = 25;
  double selectedWeight = 70;
  double selectedHeight = 170;

  final genders = ['Male', 'Female'];

  int currentStep = 0; // حالة الخطوة الحالية

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      await prefs.setString('name', name ?? '');
      await prefs.setString('gender', gender ?? '');
      await prefs.setDouble('weight', selectedWeight);
      await prefs.setDouble('height', selectedHeight);
      await prefs.setInt('age', selectedAge);

      widget.onFinished();
    } catch (e) {
      if (!mounted) return; // إذا تم تفكيك الwidget، لا تعمل شيء
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  void _showNumberPicker({
    required String title,
    required int minValue,
    required int maxValue,
    required int currentValue,
    required ValueChanged<int> onChanged,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SizedBox(
          height: 250,
          child: CupertinoPicker(
            itemExtent: 32,
            scrollController:
            FixedExtentScrollController(initialItem: currentValue - minValue),
            onSelectedItemChanged: (index) {
              onChanged(index + minValue);
            },
            children: List<Widget>.generate(
              maxValue - minValue + 1,
                  (index) => Center(child: Text('${index + minValue}')),
            ),
          ),
        );
      },
    );
  }

  void _nextStep() {
    if (currentStep == 5) {
      if (_formKey.currentState!.validate()) {
        _formKey.currentState!.save();

        if (gender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your gender')),
          );
          return;
        }

        age = selectedAge;
        weight = selectedWeight;
        height = selectedHeight;

        _saveData();
      }
    } else {
      // التحقق من اسم المستخدم في الخطوة 1
      if (currentStep == 1) {
        if (name == null || name!.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter your name')),
          );
          return; // ما تتقدمش للخطوة التالية
        }
      }
      if (currentStep == 2) {
        if (gender == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select your gender')),
          );
          return;
        }
      }

      setState(() {
        currentStep++;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final textColor = theme.brightness == Brightness.dark ? Colors.white : Colors.black87;

    // محتوى كل خطوة
    Widget stepContent() {
      switch (currentStep) {
        case 0:
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Welcome to Gym Tracker!",
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "Gym Tracker is your ultimate companion for tracking workouts and improving your fitness performance.\n\n"
                      "You can log your reps and used weights easily to keep track of your progress.\n\n"
                      "Track your daily progress throughout the year with a detailed day-by-day performance view. "
                      "You can also log your meals and nutritional information using the built-in calorie calculator to organize your diet professionally.\n\n"
                      "The app includes a weight tracker that lets you log your weight daily and view your progress on a dedicated chart, "
                      "with a limit of one entry per day to keep your data accurate. "
                      "The workout library is continuously expanding and will be updated regularly with more exercises.\n\n"
                      "Gym Tracker supports both dark and light modes to provide a comfortable experience in any environment. "
                      "A streak system is also included to keep you motivated and encourage daily consistency.\n\n"
                      "Please note that the app is still under development. Continuous improvements and new features will be added based on your feedback and suggestions. "
                      "Our goal is to provide the best possible experience to help you achieve your health and fitness goals.\n\n"
                      "The app works completely offline, and no personal data is sent to or stored on external servers. "
                      "All information such as your name, age, height, and weight is used only locally on your device to improve your experience and provide personalized recommendations, "
                      "with full respect for your privacy.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    height: 1.6, // مسافة مريحة بين السطور
                  ),
                  textAlign: TextAlign.start, // مهم جداً لتفادي المسافات الغريبة
                )


              ],
            ),
          );

      // داخل switch case currentStep:
        case 1:
          bool canShowSnackBar = true;

          void showSnackBarWithDelay(String message) {
            if (canShowSnackBar) {
              canShowSnackBar = false;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(message)),
              );
              Future.delayed(const Duration(seconds: 7), () {
                canShowSnackBar = true;
              });
            }
          }

          bool hasRepeatedChar(String value, int count) {
            if (value.isEmpty) return false;
            int repeatCounter = 1;
            for (int i = 1; i < value.length; i++) {
              if (value[i] == value[i - 1]) {
                repeatCounter++;
                if (repeatCounter >= count) return true;
              } else {
                repeatCounter = 1;
              }
            }
            return false;
          }

          return StatefulBuilder(
            builder: (context, setState) {
              return TextFormField(
                controller: _controller,  // استخدم الكنترولر هنا فقط
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                style: TextStyle(color: textColor),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (hasRepeatedChar(value, 5)) {
                    return 'Please enter a valid name for a better user experience';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });

                  final clean = value.replaceAll(RegExp(r'[^a-zA-Z\u0600-\u06FF\s]'), '');

                  if (clean != value) {
                    _controller.value = TextEditingValue(
                      text: clean,
                      selection: TextSelection.collapsed(offset: clean.length),
                    );
                    showSnackBarWithDelay('Please enter a valid name without symbols or numbers for a better experience');
                  }

                  if (hasRepeatedChar(clean, 5)) {
                    showSnackBarWithDelay('Please enter a valid name and avoid repeating the same character 5 times or more');
                  }
                },
                onSaved: (value) => name = value,
              );
            },
          );





        case 2:
          return DropdownButtonFormField<String>(
            value: gender,
            decoration: InputDecoration(
              labelText: 'Gender',
              border: const OutlineInputBorder(),
            ),
            items: genders
                .map((g) => DropdownMenuItem<String>(
              value: g,
              child: Row(
                children: [
                  Icon(
                    g == 'Male' ? Icons.male : Icons.female,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    g,
                    style: TextStyle(color: textColor),
                  ),
                ],
              ),
            ))
                .toList(),
            validator: (value) =>
            value == null ? 'Please select your gender' : null,
            onChanged: (value) {
              setState(() {
                gender = value!;
              });
            },
          );


        case 3:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showNumberPicker(
                  title: "Select Age",
                  minValue: 10,
                  maxValue: 100,
                  currentValue: selectedAge,
                  onChanged: (val) {
                    setState(() {
                      selectedAge = val;
                    });
                  },
                ),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    '$selectedAge',
                    style: TextStyle(fontSize: 16, color: textColor),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Note: The app is currently not optimized for tablets. Tablet support will be available in a future update.",
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          );

        case 4:
          return InkWell(
            onTap: () => _showNumberPicker(
              title: "Select Weight (kg)",
              minValue: 30,
              maxValue: 200,
              currentValue: selectedWeight.toInt(),
              onChanged: (val) {
                setState(() {
                  selectedWeight = val.toDouble();
                });
              },
            ),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Weight (kg)',
                border: const OutlineInputBorder(),
              ),
              child: Text(
                '${selectedWeight.toInt()}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          );
        case 5:
          return InkWell(
            onTap: () => _showNumberPicker(
              title: "Select Height (cm)",
              minValue: 100,
              maxValue: 250,
              currentValue: selectedHeight.toInt(),
              onChanged: (val) {
                setState(() {
                  selectedHeight = val.toDouble();
                });
              },
            ),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Height (cm)',
                border: const OutlineInputBorder(),
              ),
              child: Text(
                '${selectedHeight.toInt()}',
                style: TextStyle(fontSize: 16, color: textColor),
              ),
            ),
          );
        default:
          return const SizedBox.shrink();
      }
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Builder(
          builder: (context) {
            final isDark = Theme.of(context).brightness == Brightness.dark;

            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      if (currentStep > 0)
                        InkWell(
                          borderRadius: BorderRadius.circular(100),
                          onTap: () {
                            setState(() {
                              currentStep--;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Icon(Icons.arrow_back, color: isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      if (currentStep == 0)
                        const SizedBox(width: 48), // يحجز مكان زر الرجوع لما مش ظاهر

                      const SizedBox(width: 8),

                      Expanded(
                        child: Center(
                          child: Text(
                            'Welcome to Gym Tracker',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ),

                      const SizedBox(width: 48), // يحافظ على التوازن
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // شريط التقدم
            LinearProgressIndicator(
              value: (currentStep + 1) / 6,
              color: primaryColor,
              backgroundColor: primaryColor.withAlpha((255 * 0.3).round()),

              minHeight: 6,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: Form(
                key: _formKey,
                child: stepContent(),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                currentStep == 5 ? 'Save and Proceed' : 'Next',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 12),
            Center(
              child: Text(
                "Powered by: Ibrahim Zaid",
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),

                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
