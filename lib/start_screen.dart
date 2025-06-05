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
                  "مرحبًا بك في Gym Tracker!",
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  "تطبيق Gym Tracker هو رفيقك المثالي لمتابعة التمارين وتحسين أدائك الرياضي. "
                      "يُمكّنك من تسجيل عدد العدات، الأوزان المستخدمة، وإدارة الوقت باستخدام مؤقت متكامل. "
                      "يحتوي التطبيق على سبحة إلكترونية تساعدك خلال فترات الراحة، كما يتيح لك إضافة تمارين مخصصة تناسب احتياجاتك. "
                      "يمكنك تتبع تقدمك اليومي على مدار السنة بسهولة من خلال عرض أداء كل يوم. "
                      "بالإضافة إلى ذلك، يوفر التطبيق إمكانية تسجيل وجباتك ومعلوماتها الغذائية، مع حاسبة سعرات حرارية مدمجة تساعدك على تنظيم نظامك الغذائي بشكل احترافي. "
                      "يتميز التطبيق أيضاً بشخصية ذكية افتراضية اسمها 'Gymee' تقدم لك نصائح غذائية وتمرينات مخصصة، مع خطط جاهزة لتعزيز تجربتك. "
                      "كما يمكن لـ Gymee مساعدتك في معرفة معلومات غذائية عن الأطعمة، وهذه الميزة تحت التطوير وسيتم إضافة المزيد من الأطعمة باستمرار. "
                      "يوفر التطبيق خاصية متتبع الوزن، حيث يمكنك إدخال وزنك يومياً ورؤية تطورك عبر رسم بياني مخصص، مع الحفاظ على إدخال وزن واحد فقط يومياً. "
                      "تحتوي المكتبة الرياضية على تمارين متنوعة تحت التطوير وسيتم تحديثها دورياً لإضافة المزيد من التمارين. "
                      "يدعم التطبيق الوضعين الداكن والفاتح، مع إمكانية تغيير الثيم بين اللون الأزرق والبنفسجي لتعزيز تجربة المستخدم والتخصيص. "
                      "كما يحتوي على معرض صور لشخصية Gymee التي تشرح ميزات التطبيق بطريقة تفاعلية، بالإضافة إلى ميزة الاستريك التي تحافظ على حماسك وتشجعك على الالتزام بالتمرين يومياً. "
                      "\n\n"
                      "يُشار إلى أن التطبيق لا يزال في مرحلة التطوير، وسيتم إضافة تحسينات وتحديثات مستمرة بناءً على آرائكم واقتراحاتكم. "
                      "هدفنا هو تقديم أفضل تجربة لمساعدتك على تحقيق أهدافك الصحية والرياضية.",
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                  textAlign: TextAlign.justify,
                ),
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
                    return 'الرجاء كتابة اسم صحيح لتجربة مستخدم افضل';
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
                    showSnackBarWithDelay('الرجاء كتابة اسم صحيح بدون رموز او ارقام لتجربة مستخدم افضل');
                  }

                  if (hasRepeatedChar(clean, 5)) {
                    showSnackBarWithDelay('الرجاء كتابة الاسم صحيح لتجربة مستخدم افضل و عدم تكرار نفس الحرف 5 مرات أو أكثر');
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
              child: Text(g, style: TextStyle(color: textColor)),
            ))
                .toList(),
            validator: (value) => value == null ? 'Please select your gender' : null,
            onChanged: (value) {
              setState(() {
                gender = value;
              });
            },
          );
        case 3:
          return InkWell(
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
                      if (currentStep > 0)
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          color: theme.iconTheme.color,
                          onPressed: () {
                            setState(() {
                              currentStep--;
                            });
                          },
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      if (currentStep == 0)
                        const SizedBox(width: 48), // عشان يحل مكان زر الرجوع
                      const Spacer(),
                      Text(
                        'Welcome to Gym Tracker',
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

            const SizedBox(height: 20),

            Center(
              child: Text(
                "أنت الآن تستخدم النسخة التجريبية من تطبيق Gym Tracker...",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withAlpha((255 * 0.6).round()),

                ),
                textAlign: TextAlign.center,
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
