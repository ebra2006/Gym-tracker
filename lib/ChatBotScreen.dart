import 'package:flutter/material.dart';
import 'dart:math'; // لإضافة العشوائية
import 'ChatBotLogic.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late ChatBotLogic chatBotLogic;
  bool showButton = true;
  List<Map<String, String>> pendingMessages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    chatBotLogic = ChatBotLogic();
    _sendWelcomeMessage();
  }

  void _sendWelcomeMessage() {
    _addBotMessage("أهلا بيك 👋، جاهز تاخد نصيحتين جامدين النهارده؟ 💪🍏");
  }

  void sendMessage(String message) {
    setState(() {
      chatBotLogic.messages.add({
        "sender": "مستخدم",
        "text": message,
        "time": DateTime.now().toString(),
      });
    });

    if (message == "نعم") {
      Future.delayed(Duration(milliseconds: 300), () {
        _sendTips();
      });
    }
  }

  void _sendTips() async {
    var tips = chatBotLogic.getDailyTips();

    // ترتيب النصائح
    pendingMessages = [
      {
        "sender": "جيماوي",
        "text": "نصيحة تغذية 🍏:\n${tips['nutrition']}",
        "time": DateTime.now().toString(),
      },
      {
        "sender": "جيماوي",
        "text": "نصيحة تمرين 🏋️:\n${tips['training']}",
        "time": DateTime.now().toString(),
      },
      {
        "sender": "جيماوي",
        "text": "هل ترغب في المزيد من النصائح؟ 💪🍏",
        "time": DateTime.now().toString(),
      },
    ];

    setState(() {
      showButton = true; // يظهر الزر بعد النصيحة
    });

    _showMessagesSequentially();
  }

  Future<void> _showMessagesSequentially() async {
    if (isTyping) return;
    isTyping = true;

    for (var message in pendingMessages) {
      await _addBotMessage(message['text']!);
      await Future.delayed(Duration(milliseconds: 500));
    }

    isTyping = false;
  }

  Future<void> _addBotMessage(String fullText) async {
    String currentText = "";

    Map<String, String> message = {
      "sender": "جيماوي",
      "text": currentText,
      "time": DateTime.now().toString(),
    };

    setState(() {
      chatBotLogic.messages.add(message);
    });

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 30));
      setState(() {
        message["text"] = fullText.substring(0, i + 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جيماوي - المدرب الشخصي"),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.deepPurple
            : Colors.deepPurple.shade400,
        foregroundColor: Colors.white, // << هنا تخلي النص والأيقونات بيضاء دايمًا
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  reverse: false,
                  itemCount: chatBotLogic.messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessage(chatBotLogic.messages[index]);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: showButton
                      ? ElevatedButton(
                    onPressed: () {
                      sendMessage("نعم");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.teal
                          : Colors.deepPurple,
                    ),
                    child: Text(
                      "نعم",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                      : SizedBox(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, String> message) {
    bool isBotMessage = message["sender"] == "جيماوي";
    String messageText = message["text"] ?? "";
    String? timeString = message["time"];
    DateTime time = timeString != null ? DateTime.tryParse(timeString) ?? DateTime.now() : DateTime.now();
    String formattedTime = "${time.hour}:${time.minute.toString().padLeft(2, '0')}";

    Color botColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.deepPurple.shade300
        : Colors.deepPurple.shade400;
    Color userColor = Theme.of(context).brightness == Brightness.dark
        ? Colors.teal.shade300
        : Colors.teal.shade400;

    return Align(
      alignment: isBotMessage ? Alignment.centerLeft : Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isBotMessage)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.deepPurple,
                child: Icon(Icons.smart_toy, color: Colors.white, size: 16),
              ),
            ),
          Flexible(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBotMessage ? botColor : userColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    messageText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    formattedTime,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          if (!isBotMessage)
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, color: Colors.white, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
