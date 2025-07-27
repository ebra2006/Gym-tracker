import 'package:http/http.dart' as http;
import 'dart:convert';

Future<bool> isDeviceBanned(String deviceId) async {
  final url = Uri.parse("https://gym-backend-production-d6a4.up.railway.app/banned_devices");

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> bannedList = jsonDecode(response.body);
      return bannedList.contains(deviceId);
    } else {
      print("⚠️ Failed to check banned devices: ${response.body}");
      return false;
    }
  } catch (e) {
    print("❗ Error checking banned devices: $e");
    return false;
  }
}

Future<void> sendUsage({
  required String deviceId,
  required String page,
  required String eventType,
  required int duration,
}) async {
  final isBanned = await isDeviceBanned(deviceId);
  if (isBanned) {
    print("⛔ الجهاز محظور. لن يتم إرسال بيانات الاستخدام.");
    return;
  }

  final url = Uri.parse("https://gym-backend-production-d6a4.up.railway.app/track");
  final body = jsonEncode({
    "device_id": deviceId,
    "page": page,
    "event_type": eventType,
    "timestamp": DateTime.now().toIso8601String(),
    "duration": duration,
  });

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: body,
    );

    if (response.statusCode == 200) {
      print("✅ Usage sent successfully");
    } else {
      print("❌ Failed to send usage: ${response.body}");
    }
  } catch (e) {
    print("❗ Error sending usage: $e");
  }
}
