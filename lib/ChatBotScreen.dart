import 'package:flutter/material.dart';
import 'ChatBotLogic.dart';

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late ChatBotLogic chatBotLogic;

  @override
  void initState() {
    super.initState();
    chatBotLogic = ChatBotLogic();
    chatBotLogic.init();
  }

  void sendMessage(String message) {
    chatBotLogic.sendMessage(message, updateUI);
  }

  void updateUI() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("جيماوي - المدرب الشخصي"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatBotLogic.messages.length,
                itemBuilder: (context, index) {
                  return Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Align(
                      alignment: chatBotLogic.messages[index]["sender"] == "جيماوي"
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: chatBotLogic.messages[index]["sender"] == "جيماوي"
                              ? Colors.blueAccent
                              : Colors.greenAccent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          chatBotLogic.messages[index]["text"]!,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      sendMessage("نعم");
                    },
                    child: Text("نعم"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
