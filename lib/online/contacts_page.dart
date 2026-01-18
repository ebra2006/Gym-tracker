import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'chat_room_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key});

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final String baseUrl = "https://gym-backend-production-d6a4.up.railway.app";
  String currentUser = "";
  List<String> allUsers = [];
  List<String> filteredUsers = [];
  List<String> recentChats = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsernameAndUsers();
    searchController.addListener(_filterUsers);
  }

  Future<void> _loadUsernameAndUsers() async {
    final prefs = await SharedPreferences.getInstance();
    currentUser = prefs.getString('username') ?? "";

    // تحميل المستخدمين من السيرفر
    final response = await http.get(Uri.parse("$baseUrl/users"));
    if (response.statusCode == 200) {
      final List users = jsonDecode(response.body);
      setState(() {
        allUsers = users
            .map((u) => u['username'] as String)
            .where((u) => u != currentUser)
            .toList();
        filteredUsers = [];
      });

    }

    // تحميل الشاتات الأخيرة
    final saved = prefs.getStringList('recent_chats') ?? [];
    setState(() => recentChats = saved);
  }

  void _filterUsers() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((user) => user.contains(query)).toList();
    });
  }

  Future<void> _saveRecentChat(String user) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentChats.remove(user); // ← منع التكرار
      recentChats.insert(0, user); // ← أضف في البداية
    });
    await prefs.setStringList('recent_chats', recentChats);
  }

  Future<void> _deleteRecentChat(String user) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      recentChats.remove(user);
    });
    await prefs.setStringList('recent_chats', recentChats);
  }

  void _openChat(String chatWith) async {
    await _saveRecentChat(chatWith);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomPage(
          currentUser: currentUser,
          chatWith: chatWith,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSearching = searchController.text.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text("💬 الدردشات")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "بحث عن المستخدم...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          if (!isSearching && recentChats.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("الدردشات الأخيرة", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

          if (!isSearching)
            Expanded(
              child: ListView.builder(
                itemCount: recentChats.length,
                itemBuilder: (context, index) {
                  final user = recentChats[index];
                  return ListTile(
                    title: Text(user),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openChat(user),
                    onLongPress: () => _confirmDelete(user),
                  );
                },
              ),
            ),

          if (isSearching)
            Expanded(
              child: ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    title: Text(user),
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _openChat(user),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(String user) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("حذف جهة الاتصال؟"),
        content: Text("هل تريد حذف $user من قائمة الدردشات؟"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("إلغاء"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRecentChat(user);
            },
            child: const Text("حذف", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
