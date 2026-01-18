import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;


class Comment {
  final int id;
  final int userId;
  final int postId;
  final String content;
  final String timestamp;
  final String username;

  Comment({
    required this.id,
    required this.userId,
    required this.postId,
    required this.content,
    required this.timestamp,
    required this.username,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    id: json['id'],
    userId: json['user_id'],
    postId: json['post_id'],
    content: json['content'],
    timestamp: json['timestamp'],
    username: json['username'] ?? 'مجهول',
  );
}

class Post {
  final int id;
  final int userId;
  String content;
  final String timestamp;
  final String username;
  int likesCount;
  bool likedByUser;
  List<Comment> comments;

  Post({
    required this.id,
    required this.userId,
    required this.content,
    required this.timestamp,
    required this.username,
    required this.likesCount,
    required this.likedByUser,
    required this.comments,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'],
    userId: json['user_id'],
    content: json['content'],
    timestamp: json['timestamp'],
    username: json['username'] ?? 'مجهول',
    likesCount: json['likes_count'] ?? 0,
    likedByUser: json['liked_by_user'] ?? false,
    comments: (json['comments'] as List<dynamic>? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
  );
}

class PostsPage extends StatefulWidget {
  const PostsPage({Key? key}) : super(key: key);

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final String baseUrl = "https://gym-backend-production-d6a4.up.railway.app";

  String? username;
  int? userId;
  late WebSocketChannel channel;
  bool loading = true;
  bool posting = false;
  List<Post> posts = [];

  final TextEditingController _postController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initUserAndPosts();
    channel = WebSocketChannel.connect(
      Uri.parse("wss://gym-backend-production-d6a4.up.railway.app/ws/posts"),
    );

    channel.stream.listen((data) {
      final decoded = jsonDecode(data);
      final action = decoded['action'];

      print("📥 WebSocket Received: $decoded"); // 🟡 أضف دي للتجريب

      if ([
        'new_post',
        'delete_post',
        'edit_post',
        'new_comment',
        'edit_comment',
        'delete_comment',
        'like',
        'unlike'
      ].contains(action)) {
        _fetchPosts(); // ✅ بيجيب كل البوستات والتعليقات من جديد
      }
    });


  }

  Future<void> _initUserAndPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final storedUsername = prefs.getString('username');

    if (storedUsername == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    username = storedUsername;

    // جلب userId من السيرفر عبر اسم المستخدم
    final usersResp = await http.get(Uri.parse("$baseUrl/users"));
    if (usersResp.statusCode != 200) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final usersList = jsonDecode(usersResp.body) as List<dynamic>;
    final userObj = usersList.firstWhere(
          (u) => (u['username'] as String).toLowerCase() == username!.toLowerCase(),
      orElse: () => null,
    );
    if (userObj == null) {
      if (mounted) Navigator.of(context).pop();
      return;
    }
    userId = userObj['id'];

    await _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (userId == null) return;

    setState(() => loading = true);

    final resp = await http.get(Uri.parse("$baseUrl/posts?current_user_id=$userId"));
    if (resp.statusCode == 200) {
      final List<dynamic> data = jsonDecode(resp.body);

      posts = data.map((p) => Post.fromJson(p)).toList();
    } else {
      posts = [];
    }

    setState(() => loading = false);
  }

  Future<void> _addPost() async {
    if (posting || userId == null) return;
    final content = _postController.text.trim();
    if (content.isEmpty) return;

    setState(() => posting = true);

    final resp = await http.post(
      Uri.parse("$baseUrl/posts"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"user_id": userId, "content": content}),
    );

    if (resp.statusCode == 200) {
      _postController.clear();
      await _fetchPosts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في إضافة البوست")),
      );
    }

    setState(() => posting = false);
  }

  bool userHasPostedToday() {
    if (posts.isEmpty) return false;
    return posts.any((p) => p.userId == userId);
  }

  Future<void> _toggleLike(Post post) async {
    if (userId == null) return;

    final url = "$baseUrl/likes";
    final body = jsonEncode({"user_id": userId, "post_id": post.id});

    final resp = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (resp.statusCode == 200) {
      setState(() {
        post.likedByUser = !post.likedByUser;
        post.likesCount += post.likedByUser ? 1 : -1;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في تعديل اللايك")),
      );
    }
  }


  Future<void> _addComment(Post post, String commentText) async {
    if (userId == null || commentText.trim().isEmpty) return;

    final resp = await http.post(
      Uri.parse("$baseUrl/comments"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "user_id": userId,
        "post_id": post.id,
        "content": commentText.trim(),
      }),
    );

    if (resp.statusCode == 200) {
      // إعادة تحميل التعليقات للبوست
      final commentJson = jsonDecode(resp.body);
      final newComment = Comment.fromJson(commentJson);
      setState(() {
        post.comments.add(newComment);
      });
    }
  }


  Future<void> _deleteComment(Post post, Comment comment) async {
    final resp = await http.delete(
      Uri.parse("$baseUrl/comments/${comment.id}?user_id=$userId"),
    );

    if (resp.statusCode == 200) {
      setState(() {
        post.comments.remove(comment);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("فشل في حذف التعليق")),
      );
    }
  }
// تعديل الكومنت وحدفه
  Future<void> _editComment(Post post, Comment comment) async {
    final TextEditingController editController = TextEditingController(text: comment.content);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل التعليق"),
        content: TextField(
          controller: editController,
          maxLines: 3,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("إلغاء")),
          ElevatedButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isEmpty) return;

              final resp = await http.put(
                Uri.parse("$baseUrl/comments/${comment.id}?user_id=$userId"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"content": newContent}),
              );

              if (resp.statusCode == 200) {
                setState(() {
                  final index = post.comments.indexWhere((c) => c.id == comment.id);
                  if (index != -1) {
                    post.comments[index] = Comment(
                      id: comment.id,
                      userId: comment.userId,
                      postId: comment.postId,
                      content: newContent,
                      timestamp: comment.timestamp,
                      username: comment.username,
                    );
                  }
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("فشل في تعديل التعليق")),
                );
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }



  Future<void> _editPost(Post post) async {
    final TextEditingController editController = TextEditingController(text: post.content);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تعديل البوست"),
        content: TextField(
          controller: editController,
          maxLines: 4,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("إلغاء"),
          ),
          ElevatedButton(
            onPressed: () async {
              final newContent = editController.text.trim();
              if (newContent.isEmpty) return;
              final resp = await http.put(
                Uri.parse("$baseUrl/posts/${post.id}?user_id=$userId"),
                headers: {"Content-Type": "application/json"},
                body: jsonEncode({"content": newContent}),
              );
              if (resp.statusCode == 200) {
                setState(() {
                  post.content = newContent;
                });
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("فشل في تعديل البوست")),
                );
              }
            },
            child: const Text("حفظ"),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePost(Post post) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("تأكيد الحذف"),
        content: const Text("هل تريد حذف هذا البوست؟"),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text("إلغاء")),
          ElevatedButton(onPressed: () => Navigator.of(context).pop(true), child: const Text("حذف")),
        ],
      ),
    );

    if (confirm == true) {
      final resp = await http.delete(Uri.parse("$baseUrl/posts/${post.id}?user_id=$userId"));
      if (resp.statusCode == 200) {
        setState(() {
          posts.remove(post);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في حذف البوست")),
        );
      }
    }
  }

  void _showCommentsDialog(Post post) {
    final TextEditingController commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("التعليقات", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            post.comments.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text("لا توجد تعليقات بعد"),
            )
                : SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: post.comments.length,
                itemBuilder: (context, i) {
                  final comment = post.comments[i];

                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.person, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(comment.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  if (comment.userId == userId) // 👈 زري الحذف والتعديل لمستخدم التعليق فقط
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18),
                                          onPressed: () => _editComment(post, comment),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 18),
                                          onPressed: () => _deleteComment(post, comment),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(comment.content),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                },
              ),
            ),
            const Divider(),
            TextField(
              controller: commentController,
              decoration: InputDecoration(
                hintText: "أضف تعليق...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    final text = commentController.text.trim();
                    if (text.isEmpty) return;
                    await _addComment(post, text);
                    commentController.clear();
                    Navigator.pop(context);
                    _showCommentsDialog(post); // إعادة عرض التعليقات المحدثة
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    channel.sink.close();
    _postController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("مجتمع البوستات اليومية"),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchPosts,
        child: Column(
          children: [
            if (!userHasPostedToday())
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _postController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        labelText: "أضف بوست جديد",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: posting ? null : _addPost,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: posting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : const Text("نشر", style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            const Divider(),
            Expanded(
              child: posts.isEmpty
                  ? const Center(child: Text("لا توجد بوستات حتى الآن"))
                  : ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final post = posts[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // رأس البوست (اسم المستخدم والوقت)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                post.username,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                post.timestamp.split("T").first, // تاريخ فقط
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // محتوى البوست
                          Text(
                            post.content,
                            style: const TextStyle(fontSize: 15),
                          ),
                          const SizedBox(height: 12),

                          // أزرار اللايك والتعليقات والتعديل والحذف
                          Row(
                            children: [
                              // لايك
                              InkWell(
                                onTap: () => _toggleLike(post),
                                child: Row(
                                  children: [
                                    Icon(
                                      post.likedByUser ? Icons.favorite : Icons.favorite_border,
                                      color: post.likedByUser ? Colors.red : Colors.grey,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(post.likesCount.toString()),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 20),

                              // تعليقات
                              InkWell(
                                onTap: () => _showCommentsDialog(post),
                                child: Row(
                                  children: const [
                                    Icon(Icons.comment_outlined, size: 20, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text("تعليقات"),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              // تعديل وحذف (للمستخدم فقط)
                              if (post.userId == userId) ...[
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  tooltip: "تعديل البوست",
                                  onPressed: () => _editPost(post),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  tooltip: "حذف البوست",
                                  onPressed: () => _deletePost(post),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
