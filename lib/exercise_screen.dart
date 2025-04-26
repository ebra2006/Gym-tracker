import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseScreen extends StatefulWidget {
  @override
  _ExerciseScreenState createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final TextEditingController setsController = TextEditingController();
  final TextEditingController repsController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  int exerciseTime = 0;
  int restTime = 0;
  bool isResting = false;

  void saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt('exerciseTime', exerciseTime);
    prefs.setInt('restTime', restTime);
    prefs.setString('sets', setsController.text);
    prefs.setString('reps', repsController.text);
    prefs.setString('weight', weightController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercise Screen'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: setsController,
              decoration: InputDecoration(labelText: 'Enter Sets'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: repsController,
              decoration: InputDecoration(labelText: 'Enter Reps'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Enter Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveData,
              child: Text('Save Set'),
            ),
          ],
        ),
      ),
    );
  }
}
