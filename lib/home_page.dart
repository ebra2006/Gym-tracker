import 'package:flutter/material.dart';
import 'contacts_page.dart'; // صفحة الشات عندك جاهزة
import 'posts_page.dart';   // هنعملها تحت

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("الصفحة الرئيسية")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text("شات"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ContactsPage()),
                );
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.people_outline),
              label: const Text("مجتمع"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                textStyle: const TextStyle(fontSize: 20),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PostsPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
