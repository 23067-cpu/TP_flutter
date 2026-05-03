<div dir="rtl" align="right">

# 📝 Bloc-Notes App — Stockage Local & Communication API

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

هذا المستودع يحتوي على التطبيق الشامل الخاص بـ **TP Bloc-Notes** لمقرر تطوير تطبيقات الهاتف المحمول. تم تطوير التطبيق لدمج تقنيات التخزين المحلي (Local Storage) والاتصال بخوادم خارجية (REST API) للعمل في كلتا الحالتين (متصل/غير متصل).

---

## 🎯 الأهداف التي تم تحقيقها (TP Requirements)
التطبيق يغطي جميع الشروط المطلوبة في الـ TP بنسبة 100%:
1. **الجزء الأول - SharedPreferences:** 
   تم ضمان بقاء الملاحظات محلياً حتى بعد إغلاق التطبيق كلياً وإعادة تشغيله.
2. **الجزء الثاني - API REST:**
   تم ربط التطبيق بواجهة برمجة تطبيقات لإجراء عمليات الجلب (`GET`)، الإنشاء (`POST`)، والحذف (`DELETE`) للبيانات.
3. **الجزء الثالث - المزامنة (Local + Distant):**
   التطبيق يتعرف تلقائياً على حالة الاتصال بالإنترنت (`Offline/Online`)، ويُعدل واجهة المستخدم لعرض إمكانيات مزامنة السيرفر فقط عند توفر الشبكة.

---

## 🛠️ الحزم المستخدمة (Packages)
- `shared_preferences: ^2.5.5` - للتخزين المحلي (Key-Value).
- `http: ^1.6.0` - للاتصال بـ REST API وتنفيذ الطلبات.
- `connectivity_plus: ^7.1.1` - لاكتشاف حالة الشبكة بشكل ديناميكي (Online/Offline).

---

## 📁 بنية الملفات (File Structure)
تم تنظيم المشروع ليتبع أفضل الممارسات في كتابة كود نظيف وقابل للقراءة:
```text
my_app_flutter/
├── lib/
│   ├── main.dart               # نقطة الانطلاق وإعداد الـ Theme والـ SharedPreferences
│   ├── models/
│   │   └── note.dart           # نموذج الملاحظة يحتوي على (id, title, content) مع دوال (toJson/fromJson)
│   ├── services/
│   │   ├── note_service.dart   # إدارة التخزين المحلي للملاحظات (load, save, add, delete, update)
│   │   └── api_service.dart    # إدارة طلبات السيرفر (getAllNotes, createNote, deleteNote)
│   └── pages/
│       ├── home_page.dart      # واجهة الملاحظات المحلية مع مراقبة حالة الاتصال عبر connectivity_plus
│       └── api_notes_page.dart # واجهة مخصصة لعرض وإدارة الملاحظات القادمة من الـ API
```

---

## ⚙️ الوظائف الأساسية (Functions)
- `_loadNotes()` و `_saveNotes()`: في `NoteService` لضمان حفظ واسترجاع قائمة الملاحظات من ذاكرة الجهاز.
- `toJson()` و `fromJson()`: في `note.dart` لتهيئة البيانات لتكون جاهزة للتخزين كـ String أو الإرسال عبر الإنترنت كـ JSON.
- `getAllNotes()` و `createNote()` و `deleteNote()`: في `ApiService` للتعامل مع السيرفر وتطبيق الـ Try/Catch للتعامل مع أخطاء الاتصال.
- `_checkConnectivity()`: مستمع مستمر يعرض أيقونة خضراء (متصل) أو حمراء (مفصول) في الـ AppBar.

---

## 🚀 طريقة تشغيل المشروع
1. تأكد من توفر بيئة عمل **Flutter** على جهازك.
2. قم باستنساخ المستودع:
   ```bash
   git clone https://github.com/23067-cpu/TP_flutter.git
   ```
3. ادخل لمسار التطبيق وحمّل الحزم:
   ```bash
   cd TP_flutter/my_app_flutter
   flutter pub get
   ```
4. لتشغيل التطبيق واختبار جميع الخصائص باحترافية، يُفضل تشغيله كبرنامج Windows للحفاظ على بيانات الذاكرة المحلية أو على جهاز Android حقيقي:
   ```bash
   flutter run -d windows
   ```

*(ملاحظة: إذا شغلت التطبيق على Chrome في وضع Debug، فإن الذاكرة المحلية تُحذف بمجرد إغلاق المتصفح)*

</div>
