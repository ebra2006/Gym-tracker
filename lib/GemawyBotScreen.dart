import 'package:flutter/material.dart';
import 'gemawy_bot_logic.dart'; // لوجيك البوت
import 'package:intl/intl.dart'; // حساب الوقت
import 'dart:async'; // للتايمرز

class GemawyBotScreen extends StatefulWidget {
  @override
  _GemawyBotScreenState createState() => _GemawyBotScreenState();
}

class _GemawyBotScreenState extends State<GemawyBotScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _showOptions = true;
  bool _showRestartButton = false;
  String _searchQuery = '';
  String _typingText = '';
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _simulateTyping(getBotResponse(''));
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a');
    return formatter.format(now);
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add({'sender': 'user', 'message': text, 'time': _getCurrentTime()});
      _isTyping = true;
      _showOptions = false;
      _showRestartButton = false;
    });

    Future.delayed(Duration(milliseconds: 500), () {
      String botResponse = getBotResponse(text);
      _simulateTyping(botResponse);
      if (botResponse.isNotEmpty) {
        setState(() {
          _showRestartButton = true;
        });
      }
    });
  }

  void _simulateTyping(String fullText) {
    _typingText = '';
    _isTyping = true;
    _typingTimer?.cancel();
    int charIndex = 0;

    _typingTimer = Timer.periodic(Duration(milliseconds: 30), (timer) {
      if (charIndex < fullText.length) {
        setState(() {
          _typingText += fullText[charIndex];
        });
        charIndex++;
      } else {
        timer.cancel();
        _addBotMessage(_typingText);
      }
    });
  }

  void _addBotMessage(String botMessage) {
    setState(() {
      _isTyping = false;
      _typingText = '';
      _messages.add({'sender': 'bot', 'message': botMessage, 'time': _getCurrentTime()});
    });
  }

  void _restartConversation() {
    setState(() {
      _messages.clear();
      _showOptions = true;
      _showRestartButton = false;
      _searchQuery = '';
      _simulateTyping(getBotResponse(''));
    });
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isUserMessage = message['sender'] == 'user';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUserMessage
                ? Colors.blueAccent
                : (isDarkMode ? Colors.grey[800]! : Colors.blueGrey[100]!),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message['message']!,
                style: TextStyle(
                  color: isUserMessage ? Colors.white : (isDarkMode ? Colors.white : Colors.black),
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 5),
              Text(
                message['time']!,
                style: TextStyle(
                  color: isUserMessage ? Colors.white70 : (isDarkMode ? Colors.white54 : Colors.black54),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () => _sendMessage(label),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        margin: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildOptions() {
    List<String> filteredFoods = foodItems.keys
        .where((foodName) => foodName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return _showOptions
        ? Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: '🔎 ابحث عن أكلة...',
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[700] : Colors.grey[200],
              contentPadding: EdgeInsets.symmetric(horizontal: 15),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredFoods.map((foodName) {
              return _buildOptionButton(foodName);
            }).toList(),
          ),
        ),
      ],
    )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // ✅ علشان الكيبورد ميسببش مشاكل
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey[850] : Colors.grey[100],
      appBar: AppBar(
        title: Text("🤖 Gemawy Nutrition Bot"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white, // << هنا تخلي النص والأيقونات بيضاء دايمًا
        elevation: 5,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true, // عشان الجديد ينزل تحت
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(), // ✅ علشان ميحصلش Scroll مرتين
                      padding: EdgeInsets.only(top: 10),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          return _buildMessage(_messages[index]);
                        } else {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.grey[800]!
                                      : Colors.blueGrey[100]!,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  _typingText,
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    _buildOptions(), // ✅ هي دي اللي كانت بتعمل Overflow مع الكيبورد
                    if (_showRestartButton)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: _restartConversation,
                          child: Text("🔄 ابدأ من جديد"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                            textStyle: TextStyle(fontSize: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
