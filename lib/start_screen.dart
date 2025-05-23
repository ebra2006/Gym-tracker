import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StartScreen extends StatefulWidget {
  final VoidCallback onFinished;

  const StartScreen({super.key, required this.onFinished});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name, gender;
  double? weight, height;
  int? age;

  Future<void> _saveData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false);
      await prefs.setString('name', name!);
      await prefs.setString('gender', gender!);
      await prefs.setDouble('weight', weight!);
      await prefs.setDouble('height', height!);
      await prefs.setInt('age', age!);

      widget.onFinished(); // دا اللي بيعمل إعادة بناء لـ MyApp ويفتح MainScreen
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
        backgroundColor: const Color(0xFF64B5F6),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your details", style: TextStyle(fontSize: 24)),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your name' : null,
                onSaved: (value) => name = value,
              ),
              DropdownButtonFormField<String>(
                value: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
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
              TextFormField(
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your age' : null,
                onSaved: (value) => age = int.tryParse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your weight' : null,
                onSaved: (value) => weight = double.tryParse(value!),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Height (cm)'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter your height' : null,
                onSaved: (value) => height = double.tryParse(value!),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64B5F6),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    _saveData();
                  }
                },
                child: const Text('Save and Proceed'),
              ),
              const SizedBox(height: 20),
              const Text(
                "أنت الآن تستخدم النسخة التجريبية من تطبيق Gym Tracker...",
                style: TextStyle(fontSize: 14, color: Colors.black54, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              const Text(
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
