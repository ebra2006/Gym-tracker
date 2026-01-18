// ... بداية الاستيراد كما هي
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';

class ChatRoomPage extends StatefulWidget {
  final String currentUser;
  final String chatWith;

  const ChatRoomPage({
    super.key,
    required this.currentUser,
    required this.chatWith,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final String baseUrl = "https://gym-backend-production-d6a4.up.railway.app";
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> messages = [];
  late String currentUser;
  Timer? _timer;
  bool isOtherUserTyping = false;
  bool autoScroll = true;
  bool isUserAtBottom = true;
  bool showJumpToBottomButton = false;
  int? lastMessageId;

  @override
  void initState() {
    super.initState();
    currentUser = widget.currentUser.toLowerCase();
    fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 2), (_) => fetchMessages());
    _controller.addListener(() => sendTypingStatus(_controller.text.isNotEmpty));

    _scrollController.addListener(() {
      if (!_scrollController.hasClients) return;
      final maxScroll = _scrollController.position.maxScrollExtent;
      final offset = _scrollController.offset;

      isUserAtBottom = maxScroll - offset < 100;

      final shouldShow = !isUserAtBottom;
      if (showJumpToBottomButton != shouldShow && mounted) {
        setState(() => showJumpToBottomButton = shouldShow);
      }

    });
  }

  Future<void> fetchMessages() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/messages"));
      if (response.statusCode == 200) {
        final all = jsonDecode(response.body);
        final me = currentUser;
        final other = widget.chatWith.toLowerCase();

        final filtered = all.where((msg) {
          final sender = (msg['sender'] ?? '').toString().toLowerCase();
          final receiver = (msg['receiver'] ?? '').toString().toLowerCase();
          return (sender == me && receiver == other) || (sender == other && receiver == me);
        }).toList();

        filtered.sort((a, b) =>
            DateTime.parse(a['timestamp']).compareTo(DateTime.parse(b['timestamp'])));

        final lastIdInFetched = filtered.isNotEmpty ? filtered.last['id'] as int : null;
        final isNew = lastMessageId != lastIdInFetched;

        if (isNew) {
          setState(() {
            messages = filtered;
            lastMessageId = lastIdInFetched;
          });

          if (isUserAtBottom) scrollToBottom();
        }
      }
    } catch (_) {}

    try {
      final typingRes = await http.get(Uri.parse("$baseUrl/typing?user=${widget.chatWith}"));
      if (typingRes.statusCode == 200) {
        final typing = jsonDecode(typingRes.body)['typing'] == true;
        if (typing != isOtherUserTyping) {
          setState(() => isOtherUserTyping = typing);
        }
      }
    } catch (_) {}
  }

  Future<void> scrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> sendMessage() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    final timestamp = DateTime.now().toIso8601String();

    await http.post(
      Uri.parse("$baseUrl/messages"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "sender": currentUser,
        "receiver": widget.chatWith.toLowerCase(),
        "content": content,
        "timestamp": timestamp,
      }),
    );

    _controller.clear();
    sendTypingStatus(false);
    isUserAtBottom = true;
    await fetchMessages();
  }

  Future<void> sendTypingStatus(bool isTyping) async {
    await http.post(
      Uri.parse("$baseUrl/typing"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user": currentUser, "typing": isTyping}),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: const [
        SizedBox(width: 10),
        Text("يكتب الآن...", style: TextStyle(fontSize: 13)),
        SizedBox(width: 8),
        TypingDots(),
      ],
    );
  }

  bool isNewDate(DateTime curr, DateTime? prev) {
    if (prev == null) return true;
    return curr.day != prev.day || curr.month != prev.month || curr.year != prev.year;
  }

  String getDateLabel(DateTime time) {
    final now = DateTime.now();
    if (time.day == now.day && time.month == now.month && time.year == now.year) {
      return "اليوم";
    } else if (time.difference(now).inDays == -1) {
      return "أمس";
    } else {
      return DateFormat.yMd().format(time);
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime? lastDate;
    return Scaffold(
      appBar: AppBar(title: Text("الدردشة مع ${widget.chatWith}")),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = (msg['sender'] ?? '').toString().toLowerCase() == currentUser;
                    final localTime = DateTime.parse(msg['timestamp']).toLocal();
                    final showDateLabel = isNewDate(localTime, lastDate);
                    lastDate = localTime;

                    return Column(
                      children: [
                        if (showDateLabel)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Text(
                              getDateLabel(localTime),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        Align(
                          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[100] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment:
                              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(msg['content'], style: const TextStyle(fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat.Hm().format(localTime),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
              if (isOtherUserTyping) _buildTypingIndicator(),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "اكتب رسالتك...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: sendMessage,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ✅ زر الطفو للنزول للأسفل
          AnimatedSlide(
            offset: showJumpToBottomButton ? Offset(0, 0) : Offset(0, 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: AnimatedOpacity(
              opacity: showJumpToBottomButton ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 16, bottom: 80),
                  child: GestureDetector(
                    onTap: () {
                      scrollToBottom();
                      setState(() => showJumpToBottomButton = false);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: const Icon(Icons.arrow_downward, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ),
            ),
          )

        ],
      ),
    );
  }
}

class TypingDots extends StatefulWidget {
  const TypingDots({super.key});
  @override
  State<TypingDots> createState() => _TypingDotsState();
}

class _TypingDotsState extends State<TypingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> dot1, dot2, dot3;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat();
    dot1 = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.3)));
    dot2 = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.2, 0.5)));
    dot3 = Tween<double>(begin: 0, end: 8).animate(
        CurvedAnimation(parent: _controller, curve: const Interval(0.4, 0.7)));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(dot1.value),
            const SizedBox(width: 3),
            _dot(dot2.value),
            const SizedBox(width: 3),
            _dot(dot3.value),
          ],
        );
      },
    );
  }

  Widget _dot(double height) {
    return Container(
      width: 6,
      height: 6 + height,
      decoration: const BoxDecoration(
        color: Colors.grey,
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
