import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'gemawy_bot_logic.dart'; // لوجيك البوت
import 'package:intl/intl.dart'; // حساب الوقت
import 'dart:async'; // للتايمرز
import 'package:string_similarity/string_similarity.dart';
import 'package:flutter/services.dart';


class GemawyBotScreen extends StatefulWidget {
  @override
  _GemawyBotScreenState createState() => _GemawyBotScreenState();
}

class _GemawyBotScreenState extends State<GemawyBotScreen> with TickerProviderStateMixin {
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;
  bool _showOptions = true;
  String _searchQuery = '';
  String _typingText = '';
  Timer? _typingTimer;

  late TextEditingController _searchController;
  late FlutterTts _flutterTts;

  // إضافة للتحكم في أنيميشن الرسائل
  late final List<AnimationController> _userMessageAnimControllers;

  String _getGreetingByTime() {
    int hour = DateTime.now().hour;
    if (hour >= 0 && hour < 4)
      return "اظن الوقت اتأخر !!، خلي بالك تاخد راحة كويسة وتنام عدد ساعات مناسبة عشان صحتك! 🌙";
    else if (hour >= 4 && hour < 12)
      return "صباح الخير، أتمنى لك بداية يوم مشرقة ومليانة حيوية! ☀️";
    else if (hour >= 12 && hour < 18)
      return "نهارك سعيد! خليك نشيط واستمتع بيومك! ☀️";
    else
      return "مساء الخير، استغل الوقت ده في راحة تستاهلها علشان بكرة تبدأ بقوة. 🌙";
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _flutterTts = FlutterTts();
    _userMessageAnimControllers = [];

    // إضافة رسالة ترحيبية حسب الوقت عند بداية الشاشة
    _messages.add({
      'sender': 'bot',
      'message': _getGreetingByTime(),
      'time': _getCurrentTime(),
    });

    // استدعاء رد البوت الابتدائي بشكل async
    _initBotResponse();
  }

  Future<void> _initBotResponse() async {
    String response = await getBotResponse('');
    _simulateTyping(response);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _searchController.dispose();
    _flutterTts.stop();
    for (var controller in _userMessageAnimControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final formatter = DateFormat('hh:mm a');
    return formatter.format(now);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (_messages.isNotEmpty && _messages.last['sender'] == 'user') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('الرجاء الانتظار حتى ينهي Gymee الكتابة')),
      );
      return;
    }

    final input = text.trim().toLowerCase();

    String matchedOption = '';
    double bestScore = 0.0;

    for (var option in foodItems.keys) {
      final optionLower = option.toLowerCase();
      final similarity = optionLower.similarityTo(input);
      if (similarity > bestScore) {
        bestScore = similarity;
        matchedOption = option;
      }
    }

    if (bestScore < 0.5) {
      matchedOption = '';
    }

    setState(() {
      // أضف رسالة المستخدم مع أنيميشن
      _messages.add({'sender': 'user', 'message': text.trim(), 'time': _getCurrentTime()});
      _showOptions = false; // تخفي الاختيارات بعد الضغط على اختيار أو إرسال رسالة

      final animController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 400),
      );
      _userMessageAnimControllers.add(animController);
      animController.forward();
    });

    _searchController.clear();  // مسح النص بعد الإرسال

    await Future.delayed(Duration(milliseconds: 500));

    String botResponse;
    if (matchedOption.isNotEmpty) {
      botResponse = await getBotResponse(matchedOption);
    } else {
      botResponse = await getBotResponse(text);
    }
    _simulateTyping(botResponse);
  }


  void _simulateTyping(String fullText) {
    _typingText = '';
    _isTyping = true;
    _typingTimer?.cancel();
    int charIndex = 0;

    _typingTimer = Timer.periodic(Duration(milliseconds: 1), (timer) {
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

  Future<void> _speakText(String text) async {
    String textWithoutEmojis = text.replaceAll(RegExp(
        r'[\u{1F600}-\u{1F64F}'  // Emoticons
        r'\u{1F300}-\u{1F5FF}'   // Symbols & Pictographs
        r'\u{1F680}-\u{1F6FF}'   // Transport & Map symbols
        r'\u{2600}-\u{26FF}'     // Misc symbols
        r'\u{2700}-\u{27BF}'
        r'\u{1F900}-\u{1F9FF}'   // Supplemental Symbols and Pictographs
        r'\u{1FA70}-\u{1FAFF}'   // Symbols and Pictographs Extended-A
        r'\u{200D}'              // Zero Width Joiner
        r'\u{23E9}-\u{23EF}'     // Miscellaneous Technical
        r'\u{25B6}\u{25C0}'      // Play/Stop buttons
        r'\u{2934}-\u{2935}'     // Arrows
        r'\u{2B05}-\u{2B07}'     // Arrows
        r'\u{2B1B}-\u{2B1C}'     // Squares
        r'\u{2B50}'              // Star
        r'\u{2B55}'              // Heavy large circle
        r'\u{3030}\u{303D}'      // Wavy dash, part alternates
        r'\u{3297}\u{3299}]+',
        unicode: true), '');

    await _flutterTts.setLanguage("ar-SA");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);

    List<dynamic> voices = await _flutterTts.getVoices;

    Map<String, String>? maleVoice;

    for (var voice in voices) {
      if (voice is Map) {
        String? name = voice['name']?.toString().toLowerCase();
        String? lang = (voice['locale'] ?? voice['lang'])?.toString().toLowerCase();

        if (name != null && lang != null) {
          if (name.contains('male') && lang.contains('ar')) {
            maleVoice = voice.map((key, value) => MapEntry(key.toString(), value.toString()));
            break;
          }
        }
      }
    }

    if (maleVoice != null) {
      await _flutterTts.setVoice(maleVoice);
    }

    await _flutterTts.speak(textWithoutEmojis);
  }

  Widget _buildMessage(Map<String, String> message, [AnimationController? animController]) {
    bool isUserMessage = message['sender'] == 'user';
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    double maxWidth = MediaQuery.of(context).size.width * 0.7;

    Widget messageContent = Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isUserMessage
                ? Colors.blueAccent
                : (isDarkMode ? Colors.grey[800]! : Colors.blueGrey[100]!),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment:
            isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                message['message']!,
                style: TextStyle(
                  color: isUserMessage
                      ? Colors.white
                      : (isDarkMode ? Colors.white : Colors.black),
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    message['time']!,
                    style: TextStyle(
                      color: isUserMessage
                          ? Colors.white70
                          : (isDarkMode ? Colors.white54 : Colors.black54),
                      fontSize: 12,
                    ),
                  ),
                  if (!isUserMessage)
                    Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () {
                          _speakText(message['message']!);
                        },
                        child: Icon(
                          Icons.volume_up,
                          size: 20,
                          color: isDarkMode ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (isUserMessage && animController != null) {
      return SizeTransition(
        sizeFactor: CurvedAnimation(parent: animController, curve: Curves.easeOut),
        axisAlignment: 1,
        child: messageContent,
      );
    } else {
      return messageContent;
    }
  }

  Widget _buildOptionButton(String label) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return OutlinedButton(
      onPressed: () {
        _sendMessage(label);
        setState(() {
          _showOptions = false; // تخفي الاختيارات بعد الضغط على زر
        });
      },
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: isDark ? Colors.white : Colors.black,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
// مساحة الاختيارات445464

  Widget _buildOptions() {
    if (!_showOptions || _searchQuery.isEmpty) {
      return SizedBox.shrink();
    }

    List<String> filteredFoods = foodItems.keys
        .where((foodName) => foodName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 140, // لا يتجاوز هذا الارتفاع
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filteredFoods.map((foodName) {
              return _buildOptionButton(foodName);
            }).toList(),
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      //المسؤول عن لون الصفحة في الدارك مود
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Colors.transparent,
          child: Stack(
            children: [
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        color: Theme.of(context).iconTheme.color,
                        onPressed: () => Navigator.of(context).pop(),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(),
                      ),
                      const Spacer(),
                      Text(
                        'Gymee Assistant',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor
                        ),
                      ),
                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Divider(height: 1, thickness: 1),
              ),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.only(top: 10),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _messages.length) {
                          final msg = _messages[index];
                          if (msg['sender'] == 'user') {
                            // ربط أنيميشن لكل رسالة مستخدم
                            final animIndex = index < _userMessageAnimControllers.length ? index : null;
                            final animController = animIndex != null ? _userMessageAnimControllers[animIndex] : null;
                            return _buildMessage(msg, animController);
                          } else {
                            return _buildMessage(msg);
                          }
                        } else {
                          double maxWidth = MediaQuery.of(context).size.width * 0.7;
                          bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: maxWidth),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDarkMode ? Colors.grey[800] : Colors.blueGrey[100],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  _typingText,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: isDarkMode ? Colors.white : Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),

            // اختيارات الاقتراحات
            _buildOptions(),

            // شريط الادخال
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 12),
              child: Row(
                children: [
                  Expanded(
                    child:
                    // شريط الادخال
                    TextField(
                      controller: _searchController,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(20),
                        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\u0600-\u06FF\s]')),
                        FilteringTextInputFormatter.deny(RegExp(r'[؟?,;؛٫]')),
                      ],


                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                          _showOptions = val.isNotEmpty;
                        });
                      },
                      onSubmitted: (val) {
                        _sendMessage(val);
                      },
                      decoration: InputDecoration(
                        hintText: 'ابحث عن اي اكلة ',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                      ),
                    ),

                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      _sendMessage(_searchController.text);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    child: Icon(Icons.send),
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
