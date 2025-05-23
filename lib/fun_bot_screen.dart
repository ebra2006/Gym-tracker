import 'package:flutter/material.dart';
import 'fun_bot_logic.dart'; // استيراد منطق البوت

class FunBotScreen extends StatefulWidget {
  @override
  _FunBotScreenState createState() => _FunBotScreenState();
}

class _FunBotScreenState extends State<FunBotScreen> {
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _showOptions = true;
  bool _showRestartButton = false; // متغير لإظهار زر إعادة المحادثة

  @override
  void initState() {
    super.initState();
    _addBotMessage(getBotResponse('')); // أول رسالة ترحيب مع الاختيارات
  }

  void _sendMessage(String text) {
    setState(() {
      _messages.add({'sender': 'user', 'message': text});
      _isTyping = true;
      _showOptions = false;
      _showRestartButton = false; // إخفاء زر إعادة المحادثة أثناء إرسال الرسالة
    });

    Future.delayed(Duration(seconds: 1), () {
      String botResponse = getBotResponse(text);
      _addBotMessage(botResponse);
      // إظهار زر إعادة المحادثة بعد الرد من البوت
      if (botResponse.isNotEmpty) {
        setState(() {
          _showRestartButton = true;
        });
      }
    });
  }

  void _addBotMessage(String botMessage) {
    setState(() {
      _isTyping = false;
      _messages.add({'sender': 'bot', 'message': botMessage});
    });
  }

  void _restartConversation() {
    setState(() {
      _messages.clear();
      _showOptions = true; // إعادة الاختيارات
      _showRestartButton = false; // إخفاء الزر بعد إعادة المحادثة
      _addBotMessage('أهلاً بيك، أنا جيماوي! 🏋️‍♂️💪\n\n'
          'أنا هنا علشان أساعدك تختار الجدول التمريني الأنسب ليك، وهنبدأ باختيار عدد الأيام اللي تقدر تتمرن فيهم خلال الأسبوع! 😊\n\n'
          'اختار الأنسب ليك:\n\n'
          'A. يوم واحد\n'
          'B. يومين\n'
          'C. 3 أيام\n'
          'D. 4 أيام\n'
          'E. 5 أيام\n'
          'F. 6 أيام\n\n'
          'اختار عدد الأيام وأنا هجهزلك خطة تدريبية مخصصة حسب اختياراتك! 🏆');
    });
  }


  Widget _buildMessage(Map<String, String> message) {
    bool isUserMessage = message['sender'] == 'user';
    return Align(
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.blueAccent : Colors.deepPurple[200],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Text(
          message['message']!,
          style: TextStyle(
            color: isUserMessage ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.deepPurple, // تحديد اللون هنا بدلاً من primary
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        ),
        onPressed: () => _sendMessage(label),
        child: Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildOptions() {
    return _showOptions
        ? Column(
      children: [
        _buildOptionButton('1 يوم'),
        _buildOptionButton('يومين'),
        _buildOptionButton('3 أيام'),
        _buildOptionButton('4 أيام'),
        _buildOptionButton('5 أيام'),
        _buildOptionButton('6 أيام'),
      ],
    )
        : SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Personal Trainer ChatBot"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white, // << هنا تخلي النص والأيقونات بيضاء دايمًا
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(top: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 10),
                  Text("جيماوي يكتب..."),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: _buildOptions(),
          ),
          // إضافة زر لإعادة المحادثة عند الحاجة
          if (_showRestartButton)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: _restartConversation,
                child: Text("إعادة المحادثة"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple, // تحديد اللون هنا بدلاً من primary
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                  textStyle: TextStyle(fontSize: 18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
