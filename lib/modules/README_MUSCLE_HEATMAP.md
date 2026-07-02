# Muscle Heat Map Architecture

## Overview

هذا الموديول مسؤول عن:

- حساب إجهاد العضلات (Fatigue)
- حساب التعافي (Recovery)
- رسم Heat Map على الجسم
- عرض تفاصيل كل عضلة
- ربط التمارين بالعضلات

---

# Folder Structure

```
muscle_heatmap/
├─ data/
│  ├─ exercise_database.dart
│  ├─ body_front.dart
│  └─ body_back.dart
│
├─ models/
│  ├─ muscle_group.dart
│  ├─ muscle_category.dart
│  ├─ muscle_definition.dart
│  ├─ exercise_muscle.dart
│  ├─ muscle_info.dart
│  ├─ muscle_status.dart
│  └─ body_part.dart
│
├─ repositories/
│  └─ muscle_repository.dart
│
├─ services/
│  ├─ workout_sync_service.dart
│  └─ recovery_engine.dart
│
├─ utils/
│  ├─ recovery_rules.dart
│  ├─ muscle_color.dart
│  ├─ muscle_slug_mapper.dart
│  ├─ category_mapper.dart
│  └─ category_recovery_summary.dart
│
├─ widgets/
│  ├─ human_body_widget.dart
│  ├─ body_painter.dart
│  ├─ muscle_status_card.dart
│  └─ muscle_status_list.dart
│
└─ screens/
   ├─ muscle_heatmap_screen.dart
   ├─ muscle_detail_screen.dart
   └─ muscle_debug_screen.dart
```

---

# File Responsibilities

## data/

### exercise_database.dart

قاعدة بيانات جميع التمارين.

كل تمرين يحتوي على:

- Primary / Secondary / Minor muscles
- Activation (%) لكل عضلة

أي تعديل علمي على استهداف التمارين يتم هنا.

---

### body_front.dart

بيانات SVG للجسم الأمامي.

---

### body_back.dart

بيانات SVG للجسم الخلفي.

---

# models/

## muscle_group.dart

تعريف جميع العضلات المستخدمة داخل النظام.

أي عضلة جديدة يجب إضافتها هنا أولاً.

---

## muscle_category.dart

تقسيم العضلات إلى:

- Chest
- Back
- Arms
- Legs
- Core

---

## muscle_definition.dart

تعريف العضلة:

- الاسم
- الوصف
- التصنيف
- Recovery Time
- SVG IDs

---

## exercise_muscle.dart

Model خاص بالتمرين.

يحتوي على:

- Activation لكل عضلة
- Compound / Isolation
- Movement Pattern
- Level

---

## muscle_info.dart

الناتج النهائي بعد الحساب.

يحتوي على:

- Fatigue
- Recovery
- Remaining Time
- Last Exercise
- Last Workout
- Status

---

## muscle_status.dart

تعريف حالات العضلة.

مثال:

- Ready
- Recovering
- Inactive

---

## body_part.dart

يربط كل جزء في الـ SVG بالـ slug الخاص به.

---

# repositories/

## muscle_repository.dart

مسؤول عن:

- SharedPreferences
- حفظ البيانات
- تحميل البيانات
- دمج Fatigue الجديد مع الحالي

أي تعديل في طريقة التخزين يتم هنا.

---

# services/

## workout_sync_service.dart

أهم ملف في النظام.

وظيفته:

- استقبال التمرين
- قراءة بياناته من ExerciseDatabase
- تطبيق PerSetDose
- تطبيق RepFactor
- إرسال النتائج إلى Repository

أي تعديل في جرعة التمرين يتم هنا.

---

## recovery_engine.dart

مسؤول عن:

- حساب Fatigue الحالي
- حساب Recovery
- حساب Remaining Time
- تحديث العضلة بمرور الوقت

أي تعديل في منطق التعافي يتم هنا.

---

# utils/

## recovery_rules.dart

تعريف Recovery Time لكل عضلة.

---

## muscle_color.dart

تحويل قيمة Fatigue إلى لون.

مثال:

Green

↓

Yellow

↓

Orange

↓

Red

---

## muscle_slug_mapper.dart

ربط SVG Slug بالعضلة.

---

## category_mapper.dart

ربط التصنيفات بالعضلات.

---

## category_recovery_summary.dart

تلخيص حالة كل Category.

---

# widgets/

## human_body_widget.dart

الـ Widget الرئيسي.

يقوم بـ:

- تحميل البيانات
- تشغيل Recovery Engine
- رسم الجسم
- عرض القائمة

---

## body_painter.dart

رسم العضلات بالألوان.

---

## muscle_status_card.dart

عرض معلومات العضلة داخل القائمة.

---

## muscle_status_list.dart

عرض جميع العضلات.

---

# screens/

## muscle_heatmap_screen.dart

الشاشة الرئيسية للـ Heat Map.

---

## muscle_detail_screen.dart

تفاصيل عضلة واحدة.

---

## muscle_debug_screen.dart

شاشة اختبار النظام.

---

# Data Flow

```
WorkoutDetailsScreen
        │
        ▼
WorkoutSyncService
        │
        ▼
ExerciseDatabase
        │
        ▼
PerSetDose
        │
        ▼
RepFactor
        │
        ▼
MuscleRepository
        │
        ▼
SharedPreferences
        │
        ▼
HumanBodyWidget
        │
        ▼
RecoveryEngine
        │
        ▼
MuscleInfo
        │
        ├────────► MuscleStatusCard
        │
        └────────► BodyPainter
                         │
                         ▼
                 MuscleColor
```

---

# Development Guide

## تعديل استهداف التمارين

اذهب إلى:

```
exercise_database.dart
```

---

## تعديل جرعة التمرين

اذهب إلى:

```
workout_sync_service.dart
```

---

## تعديل طريقة التعافي

اذهب إلى:

```
recovery_engine.dart
```

---

## تعديل ألوان الـ Heat Map

اذهب إلى:

```
muscle_color.dart
```

---

## إضافة عضلة جديدة

يجب تعديل الملفات التالية:

1. muscle_group.dart
2. muscle_definition.dart
3. recovery_rules.dart
4. muscle_slug_mapper.dart
5. exercise_database.dart
6. body_front.dart أو body_back.dart

---

# Design Principles

- Exercise Activation ثابت ويعبر عن استهداف التمرين للعضلة.
- Fatigue يتراكم مع كل Set.
- Recovery ينخفض تدريجيًا مع مرور الوقت.
- عدد المجموعات يُحسب من خلال تكرار حفظ الـ Set.
- عدد العدات يعدل تأثير كل Set باستخدام RepFactor.
- لا يتم استخدام الوزن أو RPE في الإصدار الحالي.
- جميع الحسابات تقريبية وتهدف لتقديم تقدير واقعي للمستخدم، وليست نموذجًا فسيولوجيًا دقيقًا.