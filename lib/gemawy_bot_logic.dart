// هذا الملف يحتوي على بيانات الأكل ومنطق الردود
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, Map<String, dynamic>> foodItems = {
  // بروتينات
  "صدور دجاج مشوية 🍗": {
    "Calories": 165,
    "Protein": 31,
    "Fat": 3.6,
    "Carbs": 0,
  },
  "سلمون مشوي 🐟": {
    "Calories": 208,
    "Protein": 20,
    "Fat": 13,
    "Carbs": 0,
  },
  "لحمة مشوية 🥩": {
    "Calories": 250,
    "Protein": 26,
    "Fat": 17,
    "Carbs": 0,
  },
  "تونة معلبة 🐟": {
    "Calories": 132,
    "Protein": 28,
    "Fat": 1,
    "Carbs": 0,
  },
  "بيض مسلوق 🥚": {
    "Calories": 155,
    "Protein": 13,
    "Fat": 11,
    "Carbs": 1.1,
  },
  "صدور رومي مدخنة 🦃": {
    "Calories": 135,
    "Protein": 29,
    "Fat": 1,
    "Carbs": 0,
  },
  "جبنة قريش 🧀": {
    "Calories": 98,
    "Protein": 11,
    "Fat": 4.3,
    "Carbs": 3.4,
  },
  "زبادي قليل الدسم 🍶": {
    "Calories": 63,
    "Protein": 5.3,
    "Fat": 1.5,
    "Carbs": 7,
  },
  "لبن خالي الدسم 🥛": {
    "Calories": 35,
    "Protein": 3.4,
    "Fat": 0.1,
    "Carbs": 5,
  },
  "زبدة فول سوداني 🥜": {
    "Calories": 588,
    "Protein": 25,
    "Fat": 50,
    "Carbs": 20,
  },

  // كاربوهيدرات
  "رز أبيض 🍚": {
    "Calories": 130,
    "Protein": 2.7,
    "Fat": 0.3,
    "Carbs": 28,
  },
  "بطاطا مشوية 🥔": {
    "Calories": 90,
    "Protein": 2,
    "Fat": 0.1,
    "Carbs": 21,
  },
  "مكرونة مسلوقة 🍝": {
    "Calories": 158,
    "Protein": 5.8,
    "Fat": 0.9,
    "Carbs": 30.9,
  },
  "خبز أبيض 🍞": {
    "Calories": 265,
    "Protein": 9,
    "Fat": 3.2,
    "Carbs": 49,
  },
  "فول مدمس 🫘": {
    "Calories": 110,
    "Protein": 7.3,
    "Fat": 0.5,
    "Carbs": 19.8,
  },
  "شوربة عدس 🍲": {
    "Calories": 101,
    "Protein": 7,
    "Fat": 3.5,
    "Carbs": 13,
  },

  // فواكه وخضار
  "تفاح 🍎": {
    "Calories": 52,
    "Protein": 0.3,
    "Fat": 0.2,
    "Carbs": 14,
  },
  "موز 🍌": {
    "Calories": 89,
    "Protein": 1.1,
    "Fat": 0.3,
    "Carbs": 23,
  },
  "سلطة خضار 🥗": {
    "Calories": 20,
    "Protein": 1,
    "Fat": 0.2,
    "Carbs": 4,
  },
  "خيار 🥒": {
    "Calories": 16,
    "Protein": 0.7,
    "Fat": 0.1,
    "Carbs": 3.6,
  },
  "طماطم 🍅": {
    "Calories": 18,
    "Protein": 0.9,
    "Fat": 0.2,
    "Carbs": 3.9,
  },
};

// دالة لجلب اسم المستخدم من SharedPreferences (async)
Future<String> getUserName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('name') ?? "صديقي";
}

// دالة الردود تكون async وتستدعي getUserName
Future<String> getBotResponse(String userInput) async {
  final userName = await getUserName();

  if (userInput.isEmpty) {
    return "مرحبًا $userName في Gymee Assistant! 🧠🥗\n\n"
        "اكتب اسم أي أكلة تحب تعرف معلوماتها الغذائية لكل 100 جرام! 👨‍🍳👇";
  }

  final food = foodItems[userInput];
  if (food != null) {
    return "📋 معلومات ${userInput}:\n\n"
        "🔸 السعرات الحرارية: ${food['Calories']} كالوري\n"
        "🔸 البروتين: ${food['Protein']} جرام\n"
        "🔸 الدهون: ${food['Fat']} جرام\n"
        "🔸 الكاربوهيدرات: ${food['Carbs']} جرام\n";
  } else {
    return "معذرةً $userName، مش لاقي بيانات للأكلة دي 😅. انتظر حتى يتم اضافتها في تحديث قادم!";
  }
}
