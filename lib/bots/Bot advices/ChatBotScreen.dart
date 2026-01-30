import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

import 'ChatBotLogic.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum ChatMode {
  initialChoice,
  tips,
  trainingPlans,
  ended,
}

class ChatBotScreen extends StatefulWidget {
  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  late ChatBotLogic chatBotLogic;
  final Random random = Random();

  List<Map<String, String>> messages = [];
  ChatMode chatMode = ChatMode.initialChoice;

  final ScrollController _scrollController = ScrollController();

  bool isTyping = false;
  bool userInteracting = false;

  Timer? scrollCheckTimer;
  double lastScrollPosition = 0;
  bool autoScrollEnabled = true;

  final List<String> funReplies = [
    "عايز كمان؟ قول بس! 💬",
    "دي نصيحة مجانية من عندي، استغلها! 😉",
    "خلينا نكمل، انت قدها! 🔥",
    "النشاط هو سر النجاح، يلا بينا! 💪✨",
    "مشوار الألف ميل بيبدأ بخطوة، مستعد؟ 🚶‍♂️🏆",
    "خليك دايمًا متحفز، وأنا معاك! 🤜🤛",
    "لو حسيت بالتعب، فكر بالهدف الكبير! 🎯💡",
    "جسمك هيشكرك على كل ثانية مجهود! ⏱️❤️",
    "النجاح مش صدفة، هو تعب وصبر! 🏅💥",
    "تعالى نرفع سقف طموحاتنا سوا! 🚀💫",
    "مع كل تمرين، انت بتقرب لهدفك! 🏋️‍♂️🔥",
    "خليك قوي، دايمًا في تطور! 🌟👊",
    "الصبر والمثابرة هما سر التقدم! ⏳⚡",
    "بتعبك النهاردة، بتفوز بكرة! 🏆💪",
    "مافيش مستحيل مع الإرادة! 🚫❌🔥",
    "كل يوم فرصة جديدة تبدأ بيها صح! ☀️💥",
    "التحدي هو بداية النجاح، استعد! 🥇🔥",
    "حافظ على خطوتك، النجاح في الانتظار! 🏃‍♂️💨",
    "مع كل تعب، فيه قوة جديدة جواك! 💪⚡",
    "عيونك على الهدف؟ خليها دايمًا كده! 🎯👀",
    "التغيير مش سهل، بس يستاهل كل التعب! 🔄❤️",
    "انت بطل قصتك، فاكتبها صح! 📖👑",
    "التمرين مش بس جسم، ده عقل وروح كمان! 🧠💥",
    "النجاح بيبدأ من قرار صغير: هتبدأ إمتى؟ ⏰🚀",
    "كل عرق بينزل هو خطوة لقدام! 💧➡️🏆",
    "خليك دايمًا قد التحدي! 💥🛡️",
    "بتعب النهاردة، بتعيش أحلى بكرة! 🌞💪",
    "الحركة هي الحياة، خليك دايمًا متحرك! 🔄🌟",
    "كل تمرين بيخلي جسمك أقوى وأذكى! 🧠💪",
  ];


  // هنا تضيف الدالة _speakText
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false; // نتابع حالة الصوت

  Future<void> _speakText(String text) async {
    if (_isPlaying) {
      await _flutterTts.stop();
      _isPlaying = false;
      return;
    }

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

    // تابع الحالة
    _flutterTts.setStartHandler(() {
      _isPlaying = true;
    });

    _flutterTts.setCompletionHandler(() {
      _isPlaying = false;
    });

    _flutterTts.setCancelHandler(() {
      _isPlaying = false;
    });

    await _flutterTts.speak(textWithoutEmojis);
  }


// دالة لجلب اسم المستخدم من SharedPreferences (async)
  Future<String> getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('name') ?? "صديقي";
  }

  @override
  void initState() {
    super.initState();
    chatBotLogic = ChatBotLogic();
    _startConversation();

    _scrollController.addListener(_scrollListener);

    scrollCheckTimer = Timer.periodic(Duration(milliseconds: 800), (_) {
      if ((lastScrollPosition - _scrollController.position.pixels).abs() < 0.5) {
        if (autoScrollEnabled) {
          setState(() {
            autoScrollEnabled = false;
          });
        }
      } else {
        if (!autoScrollEnabled) {
          setState(() {
            autoScrollEnabled = true;
          });
        }
      }
      lastScrollPosition = _scrollController.position.pixels;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    scrollCheckTimer?.cancel();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.isScrollingNotifier.value) {
      if (autoScrollEnabled) {
        setState(() {
          autoScrollEnabled = false;
        });
      }
    }
  }

// تعديل هنا ليشمل اسم المستخدم في الترحيب
  Future<void> _startConversation() async {
    final userName = await getUserName();

    // رسالة الترحيب بالوقت + الاسم
    await _addBotMessage(_getGreetingByTime(userName));

    await _addBotMessage(
        "أنا Gymee، المدرب الشخصي بتاعك!\n$userName\nتحب تاخد نصايح عن التغذية والتمرين؟ ولا تحب خطط تمرين جاهزة؟ 😊\nأنا جاهز أساعدك في أي وقت!"
    );


    setState(() {
      chatMode = ChatMode.initialChoice;
    });
  }

// رسالة ترحيبية حسب الوقت + اسم المستخدم
  String _getGreetingByTime(String userName) {
    int hour = DateTime.now().hour;

    if (hour >= 0 && hour < 4)
      return "اظن الوقت اتأخر!! يا $userName\nخلي بالك تاخد راحة كويسة وتنام عدد ساعات مناسبة عشان صحتك! 🌙";
    else if (hour >= 4 && hour < 12)
      return "صباح الخير يا $userName 🌞\nأتمنى لك بداية يوم مشرقة ومليانة حيوية!";
    else if (hour >= 12 && hour < 18)
      return "نهارك سعيد يا ! $userName☀️\nخليك نشيط واستمتع بيومك!";
    else
      return "مساء الخير يا $userName 🌙\nاستغل الوقت ده في راحة تستاهلها علشان بكرة تبدأ بقوة.";
  }






  Future<void> _addBotMessage(String fullText) async {
    isTyping = true;
    String currentText = "";

    Map<String, String> message = {
      "sender": "gymee",
      "text": currentText,
      "time": DateTime.now().toString(),
    };

    setState(() {
      messages.add(message);
    });

    for (int i = 0; i < fullText.length; i++) {
      await Future.delayed(Duration(milliseconds: 3));
      currentText = fullText.substring(0, i + 1);
      messages[messages.length - 1]["text"] = currentText;

      if (i % 4 == 0 || i == fullText.length - 1) {
        setState(() {});
        _maybeScrollToBottom();
      }
    }

    _maybeScrollToBottom(finalScroll: true);
    isTyping = false;
  }

  void _maybeScrollToBottom({bool finalScroll = false}) {
    if (!autoScrollEnabled) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        final double targetScroll =
            _scrollController.position.maxScrollExtent + 40;
        _scrollController.animateTo(
          targetScroll,
          duration: finalScroll
              ? Duration(milliseconds: 350)
              : Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _giveNutritionTip() async {
    String tip = chatBotLogic.getRandomNutritionTip();
    String funReply = funReplies[random.nextInt(funReplies.length)];
    await _addBotMessage("نصيحة تغذية 🍏:\n$tip\n\n$funReply");
  }

  Future<void> _giveTrainingTip() async {
    String tip = chatBotLogic.getRandomTrainingTip();
    String funReply = funReplies[random.nextInt(funReplies.length)];
    await _addBotMessage("نصيحة تمرين 🏋️:\n$tip\n\n$funReply");
  }

  Future<void> _giveTrainingPlan(String plan) async {
    String planDetails = getTrainingPlanDetails(plan);
    await _addBotMessage("خطة تمرين لعدد أيام: $plan\n\n$planDetails");
  }

  void _onOptionSelected(String option) async {
    if (isTyping) return;

    switch (chatMode) {
      case ChatMode.initialChoice:
        if (option == "نصايح") {
          await _addBotMessage("تعالى نختار سوا! 😄 عايز نصيحة في التغذية ولا التمرين؟");
          setState(() {
            chatMode = ChatMode.tips;
          });
        } else if (option == "خطط تمرينية") {
          await _addBotMessage("حلو! قولي كام يوم في الأسبوع تقدر تتمرن فيهم:"

          );
          setState(() {
            chatMode = ChatMode.trainingPlans;
          });
        }
        break;

      case ChatMode.tips:
        if (option == "نصيحة تغذية") {
          await _giveNutritionTip();
        } else if (option == "نصيحة تمرين") {
          await _giveTrainingTip();
        } else if (option == "رجوع") {
          await _addBotMessage("رجعنا للقائمة الرئيسية! مستني اختيارك 😉");
          setState(() {
            chatMode = ChatMode.initialChoice;
          });
        } else if (option == "خلاص") {
          await _addBotMessage("تمام، لو احتجت نصائح تانية، أنا هنا دايمًا! 💪😊");
          setState(() {
            chatMode = ChatMode.ended;
          });
        }
        break;

      case ChatMode.trainingPlans:
        if (["1 يوم", "يومين", "3 أيام", "4 أيام", "5 أيام", "6 أيام"]
            .contains(option)) {
          await _giveTrainingPlan(option);
        } else if (option == "رجوع") {
          await _addBotMessage("رجعنا للاختيار الرئيسي.");
          setState(() {
            chatMode = ChatMode.initialChoice;
          });
        } else if (option == "خلاص") {
          await _addBotMessage("تمام، لو احتجت خطط تانية، أنا موجود! 💪😊");
          setState(() {
            chatMode = ChatMode.ended;
          });
        }
        break;

      case ChatMode.ended:
      // لا تفاعل بعد انتهاء المحادثة
        break;
    }
  }

  Widget _buildOptions() {
    if (isTyping) return SizedBox.shrink();

    ButtonStyle buttonStyle(MaterialColor color) => ElevatedButton.styleFrom(
      backgroundColor: color.shade100,
      foregroundColor: color.shade700,
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    );

    switch (chatMode) {
      case ChatMode.initialChoice:
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _onOptionSelected("نصايح"),
              child: Text("نصايح"),
              style: buttonStyle(Colors.deepPurple),
            ),
            ElevatedButton(
              onPressed: () => _onOptionSelected("خطط تمرينية"),
              child: Text("خطط تمرينية"),
              style: buttonStyle(Colors.blue),
            ),
          ],
        );

      case ChatMode.tips:
        return Wrap(
          spacing: 12,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => _onOptionSelected("نصيحة تغذية"),
              child: Text("نصيحة تغذية"),
              style: buttonStyle(Colors.green),
            ),
            ElevatedButton(
              onPressed: () => _onOptionSelected("نصيحة تمرين"),
              child: Text("نصيحة تمرين"),
              style: buttonStyle(Colors.orange),
            ),
            ElevatedButton(
              onPressed: () => _onOptionSelected("رجوع"),
              child: Text("رجوع"),
              style: buttonStyle(Colors.grey),
            ),
            ElevatedButton(
              onPressed: () => _onOptionSelected("خلاص"),
              child: Text("خلاص"),
              style: buttonStyle(Colors.red),
            ),
          ],
        );

      case ChatMode.trainingPlans:
        return Wrap(
          spacing: 10,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            ...["1 يوم", "يومين", "3 أيام", "4 أيام", "5 أيام", "6 أيام"].map(
                  (day) => ElevatedButton(
                onPressed: () => _onOptionSelected(day),
                child: Text(day),
                style: buttonStyle(Colors.blueGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () => _onOptionSelected("رجوع"),
              child: Text("رجوع"),
              style: buttonStyle(Colors.grey),
            ),
            ElevatedButton(
              onPressed: () => _onOptionSelected("خلاص"),
              child: Text("خلاص"),
              style: buttonStyle(Colors.red),
            ),
          ],
        );

      case ChatMode.ended:
        return FutureBuilder<String>(
          future: getUserName(), // دالة استدعاء الاسم
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              final userName = snapshot.data ?? '';
              return Center(
                child: Text(
                  "$userName نورتنا يا\n!💪🤗Remember Gymee always with you !",
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),

              );
            }
          },
        );

    }
  }
//الرسايل بتاعت البوت
  Widget _buildMessageBubble(Map<String, String> message) {
    bool isUser = message["sender"] == "user";

    final borderRadiusUser = BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(18),
      bottomRight: Radius.circular(6),
    );
    final borderRadiusBot = BorderRadius.only(
      topLeft: Radius.circular(18),
      topRight: Radius.circular(18),
      bottomLeft: Radius.circular(6),
      bottomRight: Radius.circular(18),
    );

    final theme = Theme.of(context);

    // هنا نحدد لون النص للبوت حسب الثيم:
    Color botTextColor = theme.brightness == Brightness.dark
        ? Colors.white
        : Theme.of(context).primaryColor;

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints:
        BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isUser
                ? theme.colorScheme.primary.withOpacity(0.15)
                : theme.colorScheme.surfaceVariant,
            borderRadius: isUser ? borderRadiusUser : borderRadiusBot,
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
            isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SelectableText(
                message["text"] ?? "",
                style: TextStyle(
                  color: isUser
                      ? theme.colorScheme.onPrimaryContainer
                      : botTextColor,
                  fontSize: 15,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // فقط للبوت وبشرط عدم الكتابة الآن
              if (!isUser && !isTyping)
                Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: () {
                      // تشغيل النص بالصوت
                      _speakText(message["text"] ?? "");
                    },
                    child: Icon(
                      Icons.volume_up,
                      size: 24,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // إضافة ويدجت يظهر "gymee يكتب..." أثناء الكتابة
  Widget _buildTypingIndicator() {
    if (!isTyping) return SizedBox.shrink();

    return Container(
      alignment: Alignment.centerLeft,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        "gymee يكتب...",
        style: TextStyle(
          color: Theme.of(context).primaryColor,

          fontStyle: FontStyle.italic,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onPanDown: (_) {
        if (!autoScrollEnabled) {
          setState(() {
            autoScrollEnabled = true;
          });
        }
      },
      child: Scaffold(
        backgroundColor: theme.colorScheme.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            color: Colors.transparent, // نفس لون Settings (شفاف)
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
                          color: Theme.of(context).iconTheme.color, // من الـ theme
                          onPressed: () => Navigator.of(context).pop(),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        const Spacer(),
                        Text(
                          'Gymee Coach',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor, // نفس طريقة Settings
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


        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                controller: _scrollController,
                itemCount: messages.length + 1,
                itemBuilder: (context, index) {
                  if (index == messages.length) {
                    return _buildTypingIndicator();
                  }
                  return _buildMessageBubble(messages[index]);
                },
              ),
            ),
            SizedBox(height: 6),
            _buildOptions(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
