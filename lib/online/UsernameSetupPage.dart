import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_page.dart';

class UsernameSetupPage extends StatefulWidget {
  const UsernameSetupPage({super.key});

  @override
  State<UsernameSetupPage> createState() => _UsernameSetupPageState();
}

class _UsernameSetupPageState extends State<UsernameSetupPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _isLoginMode = true;

  final String baseUrl = "https://gym-backend-production-d6a4.up.railway.app";

  Future<bool> authenticate(String username, String password, bool login) async {
    final endpoint = login ? "/login" : "/register";
    final response = await http.post(
      Uri.parse("$baseUrl$endpoint"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": username.toLowerCase(),
        "password": password,
      }),
    );
    return response.statusCode == 200;
  }

  Future<void> saveCredentialsLocally(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
  }

  Future<void> _submit() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = "يرجى إدخال الاسم وكلمة المرور");
      return;
    }

    if (!_isLoginMode && password.length < 6) {
      setState(() => _error = "كلمة المرور يجب أن تكون 6 أحرف على الأقل");
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final success = await authenticate(username, password, _isLoginMode);
    if (success) {
      await saveCredentialsLocally(username, password);
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } else {
      setState(() {
        _error = _isLoginMode
            ? "فشل تسجيل الدخول. تحقق من البيانات."
            : "فشل إنشاء الحساب. الاسم ربما مستخدم.";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? "تسجيل الدخول" : "إنشاء حساب جديد"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _isLoginMode
                  ? "ادخل بياناتك لتسجيل الدخول"
                  : "ادخل اسم مستخدم وكلمة مرور للتسجيل",
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: "اسم المستخدم",
                border: const OutlineInputBorder(),
                errorText: _error,
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "كلمة المرور",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isLoginMode ? "تسجيل الدخول" : "إنشاء الحساب"),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLoginMode = !_isLoginMode;
                  _error = null;
                });
              },
              child: Text(_isLoginMode
                  ? "ليس لديك حساب؟ أنشئ حسابًا"
                  : "هل لديك حساب؟ سجّل الدخول"),
            ),
          ],
        ),
      ),
    );
  }
}
