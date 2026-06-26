// هذا الملف يحتوي على بيانات الأكل ومنطق الردود
import 'package:shared_preferences/shared_preferences.dart';

final Map<String, Map<String, dynamic>> foodItems = {
  // بروتينات
  "صدور دجاج مشوية": {
    "Calories": 165,
    "Protein": 31,
    "Fat": 3.6,
    "Carbs": 0,
  },
  "سلمون مشوي": {
    "Calories": 208,
    "Protein": 20,
    "Fat": 13,
    "Carbs": 0,
  },
  "لحمة مشوية": {
    "Calories": 250,
    "Protein": 26,
    "Fat": 17,
    "Carbs": 0,
  },
  "تونة معلبة": {
    "Calories": 132,
    "Protein": 28,
    "Fat": 1,
    "Carbs": 0,
  },
  "بيض مسلوق": {
    "Calories": 155,
    "Protein": 13,
    "Fat": 11,
    "Carbs": 1.1,
  },
  "صدور رومي مدخن": {
    "Calories": 135,
    "Protein": 29,
    "Fat": 1,
    "Carbs": 0,
  },
  "جبنة قريش": {
    "Calories": 98,
    "Protein": 11,
    "Fat": 4.3,
    "Carbs": 3.4,
  },
  "زبادي قليل الدسم": {
    "Calories": 63,
    "Protein": 5.3,
    "Fat": 1.5,
    "Carbs": 7,
  },
  "لبن خالي الدسم": {
    "Calories": 35,
    "Protein": 3.4,
    "Fat": 0.1,
    "Carbs": 5,
  },
  "زبدة فول سوداني": {
    "Calories": 588,
    "Protein": 25,
    "Fat": 50,
    "Carbs": 20,
  },

  // كاربوهيدرات
  "رز أبيض": {
    "Calories": 130,
    "Protein": 2.7,
    "Fat": 0.3,
    "Carbs": 28,
  },
  "بطاطا مشوية": {
    "Calories": 90,
    "Protein": 2,
    "Fat": 0.1,
    "Carbs": 21,
  },
  "مكرونة مسلوقة": {
    "Calories": 158,
    "Protein": 5.8,
    "Fat": 0.9,
    "Carbs": 30.9,
  },
  "خبز أبيض": {
    "Calories": 265,
    "Protein": 9,
    "Fat": 3.2,
    "Carbs": 49,
  },
  "فول مدمس": {
    "Calories": 110,
    "Protein": 7.3,
    "Fat": 0.5,
    "Carbs": 19.8,
  },
  "شوربة عدس": {
    "Calories": 101,
    "Protein": 7,
    "Fat": 3.5,
    "Carbs": 13,
  },

  // فواكه وخضار
  "تفاح": {
    "Calories": 52,
    "Protein": 0.3,
    "Fat": 0.2,
    "Carbs": 14,
  },
  "موز": {
    "Calories": 89,
    "Protein": 1.1,
    "Fat": 0.3,
    "Carbs": 23,
  },
  "سلطة خضار": {
    "Calories": 20,
    "Protein": 1,
    "Fat": 0.2,
    "Carbs": 4,
  },
  "خيار": {
    "Calories": 16,
    "Protein": 0.7,
    "Fat": 0.1,
    "Carbs": 3.6,
  },
  "طماطم": {
    "Calories": 18,
    "Protein": 0.9,
    "Fat": 0.2,
    "Carbs": 3.9,
  },

  // مأكولات شعبية ومشروبات
  "شاورما دجاج": {
    "Calories": 300,
    "Protein": 25,
    "Fat": 15,
    "Carbs": 20,
  },
  "كباب لحم": {
    "Calories": 220,
    "Protein": 28,
    "Fat": 10,
    "Carbs": 5,
  },
  "مندي دجاج": {
    "Calories": 350,
    "Protein": 30,
    "Fat": 20,
    "Carbs": 25,
  },
  "فلافل": {
    "Calories": 330,
    "Protein": 13,
    "Fat": 15,
    "Carbs": 35,
  },
  "حمص": {
    "Calories": 164,
    "Protein": 9,
    "Fat": 3,
    "Carbs": 27,
  },

  "عصير برتقال": {
    "Calories": 45,
    "Protein": 0.7,
    "Fat": 0.2,
    "Carbs": 10,
  },

  "شاي أخضر": {
    "Calories": 0,
    "Protein": 0,
    "Fat": 0,
    "Carbs": 0,
  },
  "لبن رايب": {
    "Calories": 59,
    "Protein": 3.3,
    "Fat": 3.3,
    "Carbs": 4.7,
  },

  // المزيد من الأكلات (تقدر تضيف بنفس التنسيق)

  "مسقعة": {
    "Calories": 120,
    "Protein": 4,
    "Fat": 8,
    "Carbs": 10,
  },
  "ورق عنب": {
    "Calories": 110,
    "Protein": 2,
    "Fat": 5,
    "Carbs": 12,
  },
  "مكرونة بالبشاميل": {
    "Calories": 320,
    "Protein": 15,
    "Fat": 20,
    "Carbs": 30,
  },

  "بيتزا مارجريتا": {
    "Calories": 270,
    "Protein": 12,
    "Fat": 10,
    "Carbs": 33,
  },


  "سمك مشوي": {
    "Calories": 200,
    "Protein": 22,
    "Fat": 12,
    "Carbs": 0,
  },
  "أرز بني": {
    "Calories": 112,
    "Protein": 2.6,
    "Fat": 0.9,
    "Carbs": 23,
  },

  "سمك مقلي": {
    "Calories": 280,
    "Protein": 20,
    "Fat": 18,
    "Carbs": 6,
  },
  "جمبري مشوي": {
    "Calories": 99,
    "Protein": 24,
    "Fat": 0.3,
    "Carbs": 0,
  },
  "كفتة لحم": {
    "Calories": 250,
    "Protein": 20,
    "Fat": 15,
    "Carbs": 8,
  },



  "ورق عنب محشي": {
    "Calories": 120,
    "Protein": 3,
    "Fat": 5,
    "Carbs": 12,
  },

  "شوربة دجاج": {
    "Calories": 150,
    "Protein": 10,
    "Fat": 7,
    "Carbs": 12,
  },

  "شاورما لحم": {
    "Calories": 320,
    "Protein": 30,
    "Fat": 20,
    "Carbs": 15,
  },
  "فول مدمس مع زيت الزيتون": {
    "Calories": 230,
    "Protein": 15,
    "Fat": 8,
    "Carbs": 20,
  },
  "كريب سادة": {
    "Calories": 120,
    "Protein": 3,
    "Fat": 4,
    "Carbs": 18,
  },
  "كريب بحشوة جبنة": {
    "Calories": 250,
    "Protein": 12,
    "Fat": 15,
    "Carbs": 20,
  },
  "باذنجان مشوي": {
    "Calories": 35,
    "Protein": 1,
    "Fat": 0.2,
    "Carbs": 8,
  },

  "عصير رمان": {
    "Calories": 54,
    "Protein": 1,
    "Fat": 0,
    "Carbs": 13,
  },
  "تمر": {
    "Calories": 282,
    "Protein": 2.5,
    "Fat": 0.4,
    "Carbs": 75,
  },
  "لحم مفروم مطبوخ": {
    "Calories": 250,
    "Protein": 25,
    "Fat": 17,
    "Carbs": 0,
  },
  "شيبس البطاطس": {
    "Calories": 536,
    "Protein": 7,
    "Fat": 35,
    "Carbs": 53,
  },
  "بسكويت": {
    "Calories": 502,
    "Protein": 6,
    "Fat": 20,
    "Carbs": 70,
  },
  "كيك شوكولاتة": {
    "Calories": 400,
    "Protein": 5,
    "Fat": 20,
    "Carbs": 55,
  },
  "آيس كريم فانيليا": {
    "Calories": 207,
    "Protein": 3.5,
    "Fat": 11,
    "Carbs": 24,
  },
  "سلطة فواكه": {
    "Calories": 90,
    "Protein": 1,
    "Fat": 0,
    "Carbs": 23,
  },

  "عصير تفاح": {
    "Calories": 46,
    "Protein": 0.1,
    "Fat": 0.1,
    "Carbs": 12,
  },

  "زيت الزيتون": {
    "Calories": 119,
    "Protein": 0,
    "Fat": 14,
    "Carbs": 0,
  },
  "شوكولاتة داكنة": {
    "Calories": 546,
    "Protein": 4.9,
    "Fat": 31,
    "Carbs": 61,
  },
  "لبن زبادي كامل الدسم": {
    "Calories": 61,
    "Protein": 3.5,
    "Fat": 3.3,
    "Carbs": 4.7,
  },
  "بطاطس مقلية": {
    "Calories": 312,
    "Protein": 3.4,
    "Fat": 15,
    "Carbs": 41,
  },
  "شوكولاتة بالحليب": {
    "Calories": 535,
    "Protein": 7,
    "Fat": 30,
    "Carbs": 59,
  },
  "بسكويت الشوفان": {
    "Calories": 470,
    "Protein": 8,
    "Fat": 22,
    "Carbs": 60,
  },
  "شوربة خضار": {
    "Calories": 70,
    "Protein": 2,
    "Fat": 1,
    "Carbs": 14,
  },
  "كعك باللوز": {
    "Calories": 450,
    "Protein": 9,
    "Fat": 25,
    "Carbs": 45,
  },
  "عسل": {
    "Calories": 304,
    "Protein": 0.3,
    "Fat": 0,
    "Carbs": 82,
  },
  "حمص الشام": {
    "Calories": 164,
    "Protein": 9,
    "Fat": 3,
    "Carbs": 27,
  },
  "سمك السلمون المدخن": {
    "Calories": 117,
    "Protein": 18,
    "Fat": 4,
    "Carbs": 0,
  },
  "لوبيا": {
    "Calories": 127,
    "Protein": 9,
    "Fat": 0.5,
    "Carbs": 22,
  },
  "عدس مسلوق": {
    "Calories": 116,
    "Protein": 9,
    "Fat": 0.4,
    "Carbs": 20,
  },
  "ذرة مسلوقة": {
    "Calories": 96,
    "Protein": 3.4,
    "Fat": 1.5,
    "Carbs": 21,
  },
  "زبادي يوناني": {
    "Calories": 59,
    "Protein": 10,
    "Fat": 0.4,
    "Carbs": 3.6,
  },
  "كعك العيد": {
    "Calories": 450,
    "Protein": 6,
    "Fat": 20,
    "Carbs": 60,
  },
  "بيتزا لحم": {
    "Calories": 285,
    "Protein": 14,
    "Fat": 12,
    "Carbs": 30,
  },

  "بيض مقلي": {
    "Calories": 190,
    "Protein": 13,
    "Fat": 14,
    "Carbs": 1,
  },
  "كشري": {
    "Calories": 380,
    "Protein": 13,
    "Fat": 10,
    "Carbs": 60,
  },


  "أرز بالشعيرية": {
    "Calories": 250,
    "Protein": 5,
    "Fat": 3,
    "Carbs": 50,
  },

  "بامية باللحم": {
    "Calories": 220,
    "Protein": 18,
    "Fat": 10,
    "Carbs": 10,
  },
  "مكرونة بشاميل": {
    "Calories": 420,
    "Protein": 15,
    "Fat": 25,
    "Carbs": 40,
  },
  "سمبوسك جبنة": {
    "Calories": 180,
    "Protein": 6,
    "Fat": 12,
    "Carbs": 15,
  },
  "سمبوسك لحم": {
    "Calories": 210,
    "Protein": 12,
    "Fat": 15,
    "Carbs": 18,
  },


  "محشي كوسا": {
    "Calories": 210,
    "Protein": 10,
    "Fat": 10,
    "Carbs": 20,
  },
  "محشي كرنب": {
    "Calories": 220,
    "Protein": 9,
    "Fat": 12,
    "Carbs": 18,
  },
  "طاجن بامية": {
    "Calories": 300,
    "Protein": 20,
    "Fat": 18,
    "Carbs": 10,
  },

  "حمص بطحينة": {
    "Calories": 270,
    "Protein": 10,
    "Fat": 20,
    "Carbs": 25,
  },

  "رز بالخلطة": {
    "Calories": 390,
    "Protein": 12,
    "Fat": 14,
    "Carbs": 50,
  },
  "خبز توست": {
    "Calories": 260,
    "Protein": 8,
    "Fat": 3,
    "Carbs": 48,
  },
  "بيتزا مارغريتا": {
    "Calories": 270,
    "Protein": 12,
    "Fat": 10,
    "Carbs": 35,
  },
  "ميني برجر": {
    "Calories": 300,
    "Protein": 18,
    "Fat": 20,
    "Carbs": 15,
  },

  "شوربة خضار بالكريمة": {
    "Calories": 180,
    "Protein": 5,
    "Fat": 12,
    "Carbs": 15,
  },

  "شاي بدون سكر": {
    "Calories": 2,
    "Protein": 0,
    "Fat": 0,
    "Carbs": 0,
  },

  "كابتشينو": {
    "Calories": 120,
    "Protein": 6,
    "Fat": 6,
    "Carbs": 10,
  },
  "سناك مكسرات": {
    "Calories": 600,
    "Protein": 20,
    "Fat": 55,
    "Carbs": 20,
  },
  "شوكولاتة باللوز": {
    "Calories": 550,
    "Protein": 8,
    "Fat": 35,
    "Carbs": 50,
  },
  "مربى الفراولة": {
    "Calories": 250,
    "Protein": 0.5,
    "Fat": 0,
    "Carbs": 60,
  },
  "عسل نحل": {
    "Calories": 310,
    "Protein": 0.3,
    "Fat": 0,
    "Carbs": 82,
  },
  "كاسترد": {
    "Calories": 140,
    "Protein": 3,
    "Fat": 6,
    "Carbs": 18,
  },
  "عصير مانجو": {
    "Calories": 60,
    "Protein": 0.8,
    "Fat": 0.4,
    "Carbs": 15,
  },
  "كوكيز": {
    "Calories": 480,
    "Protein": 5,
    "Fat": 20,
    "Carbs": 65,
  },

  "باذنجان مقلي": {
    "Calories": 220,
    "Protein": 2,
    "Fat": 18,
    "Carbs": 12,
  },
  "بطاطا مهروسة": {
    "Calories": 200,
    "Protein": 4,
    "Fat": 8,
    "Carbs": 28,
  },
  "عصير ليمون": {
    "Calories": 20,
    "Protein": 0,
    "Fat": 0,
    "Carbs": 7,
  },
  "موز مجفف": {
    "Calories": 350,
    "Protein": 3,
    "Fat": 2,
    "Carbs": 80,
  },
  "تمر مجفف": {
    "Calories": 280,
    "Protein": 2,
    "Fat": 0,
    "Carbs": 75,
  },
  "زيت جوز الهند": {
    "Calories": 117,
    "Protein": 0,
    "Fat": 14,
    "Carbs": 0,
  },
  "جزر مسلوق": {
    "Calories": 35,
    "Protein": 1,
    "Fat": 0,
    "Carbs": 8,
  },

  "ماء جوز الهند": {
    "Calories": 19,
    "Protein": 0.7,
    "Fat": 0.2,
    "Carbs": 4,
  },

  "أفوكادو": {
    "Calories": 160,
    "Protein": 2,
    "Fat": 15,
    "Carbs": 9,
  },

  "ملوخية": {
    "Calories": 120,
    "Protein": 6,
    "Fat": 4,
    "Carbs": 12,
  },


  "محشي ورق عنب": {
    "Calories": 200,
    "Protein": 8,
    "Fat": 10,
    "Carbs": 20,
  },

  "طاجن بامية باللحمة": {
    "Calories": 300,
    "Protein": 20,
    "Fat": 18,
    "Carbs": 10,
  },


  "صينية بطاطس": {
    "Calories": 350,
    "Protein": 6,
    "Fat": 20,
    "Carbs": 35,
  },
  "كفتة مشوية": {
    "Calories": 280,
    "Protein": 26,
    "Fat": 18,
    "Carbs": 5,
  },

  "شربة كوارع": {
    "Calories": 350,
    "Protein": 30,
    "Fat": 25,
    "Carbs": 5,
  },
  "فتة": {
    "Calories": 500,
    "Protein": 35,
    "Fat": 30,
    "Carbs": 40,
  },
  "حواوشي": {
    "Calories": 450,
    "Protein": 30,
    "Fat": 25,
    "Carbs": 35,
  },
  "كباب وكفتة": {
    "Calories": 300,
    "Protein": 27,
    "Fat": 18,
    "Carbs": 5,
  },
  "سجق بلدي": {
    "Calories": 340,
    "Protein": 20,
    "Fat": 28,
    "Carbs": 2,
  },

  "أرز باللبن": {
    "Calories": 180,
    "Protein": 6,
    "Fat": 5,
    "Carbs": 30,
  },

  "بسبوسة": {
    "Calories": 350,
    "Protein": 5,
    "Fat": 15,
    "Carbs": 50,
  },
  "زلابية": {
    "Calories": 300,
    "Protein": 3,
    "Fat": 18,
    "Carbs": 35,
  },
  "كنافة": {
    "Calories": 450,
    "Protein": 8,
    "Fat": 30,
    "Carbs": 40,
  },
  "بلح الشام": {
    "Calories": 350,
    "Protein": 5,
    "Fat": 15,
    "Carbs": 50,
  },

  // تابع بنفس الطريقة لغاية توصل 100 طبق
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
        "اكتب اسم أي أكلة تحب تعرف معلوماتها الغذائية وانا هعطيك قيم تقريبية لكل 100 جرام! 👨‍🍳👇";
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
