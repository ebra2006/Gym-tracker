import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, gender;
  double? weight, height;
  int? age;

  @override
  void initState() {
    super.initState();
    _checkIfFirstTime();
  }

  Future<void> _checkIfFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    if (!isFirstTime) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      await prefs.setString('name', name!);
      await prefs.setString('gender', gender!);
      await prefs.setDouble('weight', weight!);
      await prefs.setDouble('height', height!);
      await prefs.setInt('age', age!);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome to Gym Tracker"),
        centerTitle: true,
        backgroundColor: Color(0xFF64B5F6),  // تعديل اللون ليكون أهدأ
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Enter your details", style: TextStyle(fontSize: 24)),
              SizedBox(height: 20),

              // Name
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => name = value,
              ),

              // Gender dropdown
              DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Male', 'Female'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) =>
                value == null ? 'Please select your gender' : null,
                onChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),

              // Age
              TextFormField(
                decoration: InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your age' : null,
                onSaved: (value) => age = int.tryParse(value!),
              ),

              // Weight
              TextFormField(
                decoration: InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your weight' : null,
                onSaved: (value) => weight = double.tryParse(value!),
              ),

              // Height
              TextFormField(
                decoration: InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your height' : null,
                onSaved: (value) => height = double.tryParse(value!),
              ),

              SizedBox(height: 20),

              // Save button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF64B5F6),  // تعديل اللون ليكون أهدأ
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveData();
                  }
                },
                child: Text('Save and Proceed'),
              ),

              SizedBox(height: 20),

              // التنويه في أسفل الشاشة
              Text(
                "أنت الآن تستخدم النسخة التجريبية من تطبيق Gym Tracker. هذه النسخة موجهة لمجموعة محدودة من المستخدمين بهدف جمع اقتراحات حقيقية وتحسين تجربة الاستخدام قبل الإطلاق الرسمي على Google Play.\n\n"
                    "نقدر جدًا مشاركتك لنا في هذه المرحلة المهمة!\n"
                    "إذا كان لديك أي اقتراحات أو ملاحظات لتحسين التطبيق، لا تتردد في إرسالها لنا. شكراً لتفهمك!\n\n"
                    "للتواصل : ebrahimzaid02@gmail.com",
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 20),

              // "Powered by: Ibrahim Zaid" في أسفل الشاشة
              Text(
                "Powered by: Ibrahim Zaid",
                style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
