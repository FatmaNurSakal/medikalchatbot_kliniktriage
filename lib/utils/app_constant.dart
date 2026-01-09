import 'dart:math';
import 'package:flutter/material.dart';

class AppConstant {
  static final _r = Random();

  static Color _c() => Colors.primaries[_r.nextInt(Colors.primaries.length)];

  static final List<Map<String, dynamic>> defaultQues = [
    // -------------------- 1) Semptomlar --------------------
    {
      "title": "Semptom",
      "question": [
        {
          "icon": Icons.thermostat,
          "color": _c(),
          "ques": "Ateşim var: evde ne yapmalıyım, ne zaman acile gitmeliyim?"
        },
        {
          "icon": Icons.sick,
          "color": _c(),
          "ques": "2 gündür ateş + boğaz ağrısı var, ne yapmalıyım?"
        },
        {
          "icon": Icons.air,
          "color": _c(),
          "ques": "Öksürük ve nefes darlığı hangi durumda acildir?"
        },
        {
          "icon": Icons.monitor_heart,
          "color": _c(),
          "ques": "Göğüs ağrısı ne zaman tehlikelidir?"
        },
        {
          "icon": Icons.psychology,
          "color": _c(),
          "ques": "Baş dönmesi neden olur, ne zaman doktora gitmeliyim?"
        },
        {
          "icon": Icons.local_hospital,
          "color": _c(),
          "ques": "Şiddetli baş ağrısı: migren mi acil bir durum mu?"
        },
        {
          "icon": Icons.water_drop,
          "color": _c(),
          "ques": "İshal/kusma var: sıvı kaybını nasıl anlarım, ne yapmalıyım?"
        },
        {
          "icon": Icons.healing,
          "color": _c(),
          "ques": "Karın ağrısı ne zaman tehlikelidir? Acil belirtiler nelerdir?"
        },
      ]
    },

    // -------------------- 2) Hızlı Triage --------------------
    {
      "title": "Triage",
      "question": [
        {
          "icon": Icons.health_and_safety,
          "color": _c(),
          "ques":
              "Şikayetlerime göre aciliyet değerlendir (ACİL / BUGÜN / 24-48s / RUTİN)."
        },
        {
          "icon": Icons.warning_amber,
          "color": _c(),
          "ques": "Acil uyarı işaretleri (kırmızı bayraklar) nelerdir?"
        },
        {
          "icon": Icons.call,
          "color": _c(),
          "ques": "Hangi durumda 112 aranmalı? Net örneklerle anlat."
        },
        {
          "icon": Icons.medical_information,
          "color": _c(),
          "ques": "Nefes darlığı varsa evde ilk yardım olarak ne yapılır, ne yapılmaz?"
        },
      ]
    },

    // -------------------- 3) Üst Solunum / Grip --------------------
    {
      "title": "Grip/Soğuk",
      "question": [
        {
          "icon": Icons.coronavirus,
          "color": _c(),
          "ques": "Grip mi soğuk algınlığı mı? Belirtilerle nasıl ayırt ederim?"
        },
        {
          "icon": Icons.masks,
          "color": _c(),
          "ques": "Boğaz ağrısı için evde işe yarayan yöntemler neler?"
        },
        {
          "icon": Icons.sanitizer,
          "color": _c(),
          "ques": "Ne zaman antibiyotik gerekir? Hangi durumda gerekmez?"
        },
        {
          "icon": Icons.bedtime,
          "color": _c(),
          "ques": "Ateşte güvenli ilaç kullanımı: parasetamol/ibuprofen nasıl alınır? (Genel bilgi)"
        },
      ]
    },

    // -------------------- 4) Mide-Bağırsak --------------------
    {
      "title": "Mide-Bağırsak",
      "question": [
        {
          "icon": Icons.restaurant,
          "color": _c(),
          "ques": "Mide bulantısı/kusma var: ne yemeliyim, ne içmeliyim?"
        },
        {
          "icon": Icons.no_food,
          "color": _c(),
          "ques": "Gıda zehirlenmesi belirtileri neler? Ne zaman doktora gitmeliyim?"
        },
        {
          "icon": Icons.local_drink,
          "color": _c(),
          "ques": "İshalde tehlike belirtileri (dehidratasyon) nasıl anlaşılır?"
        },
        {
          "icon": Icons.heart_broken,
          "color": _c(),
          "ques": "Reflü için beslenme önerileri nelerdir?"
        },
      ]
    },

    // -------------------- 5) Kalp / Tansiyon --------------------
    {
      "title": "Kalp/Tansiyon",
      "question": [
        {
          "icon": Icons.favorite,
          "color": _c(),
          "ques": "Tansiyonum kaç olmalı? Yüksek/düşük olursa ne yapmalıyım?"
        },
        {
          "icon": Icons.monitor_heart,
          "color": _c(),
          "ques": "Çarpıntı neden olur? Hangi durumda acildir?"
        },
        {
          "icon": Icons.directions_walk,
          "color": _c(),
          "ques": "Eforla gelen göğüs ağrısı ne anlatır? Riskli belirtiler neler?"
        },
        {
          "icon": Icons.bloodtype,
          "color": _c(),
          "ques": "Kol/çeneye vuran ağrı, terleme, nefes darlığı: kalp krizi belirtisi olabilir mi?"
        },
      ]
    },

    // -------------------- 6) Cilt / Alerji --------------------
    {
      "title": "Cilt/Alerji",
      "question": [
        {
          "icon": Icons.bug_report,
          "color": _c(),
          "ques": "Kurdeşen/döküntü oldu: alerji mi? Ne zaman acile gitmeliyim?"
        },
        {
          "icon": Icons.face_retouching_natural,
          "color": _c(),
          "ques": "Yüz/dudak şişmesi tehlikeli mi? Anafilaksi belirtileri neler?"
        },
        {
          "icon": Icons.waves,
          "color": _c(),
          "ques": "Güneş yanığına evde ne iyi gelir, ne kötüleştirir?"
        },
        {
          "icon": Icons.healing,
          "color": _c(),
          "ques": "Yara/enfeksiyon şüphesi: kızarıklık, sıcaklık, ağrı artarsa ne yapmalıyım?"
        },
      ]
    },

    // -------------------- 7) Ağrı / Ortopedi --------------------
    {
      "title": "Ağrı/Ortopedi",
      "question": [
        {
          "icon": Icons.back_hand,
          "color": _c(),
          "ques": "Bel-boyun ağrısı: evde güvenli egzersiz ve dikkat edilmesi gerekenler?"
        },
        {
          "icon": Icons.directions_run,
          "color": _c(),
          "ques": "Spor sonrası diz/ayak bileği ağrısı: burkulma mı? Ne zaman röntgen gerekir?"
        },
        {
          "icon": Icons.accessibility_new,
          "color": _c(),
          "ques": "Kas ağrısı ile sinir sıkışması nasıl ayırt edilir?"
        },
        {
          "icon": Icons.emergency,
          "color": _c(),
          "ques": "Şiddetli ağrı + uyuşma + güç kaybı olursa acil mi?"
        },
      ]
    },

    // -------------------- 8) Ruh Sağlığı / Uyku --------------------
    {
      "title": "Zihin/Uyku",
      "question": [
        {
          "icon": Icons.bedtime,
          "color": _c(),
          "ques": "Uyku kalitesini artırmak için bilimsel öneriler nelerdir?"
        },
        {
          "icon": Icons.psychology_alt,
          "color": _c(),
          "ques": "Kaygı/panik atağı nasıl ayırt ederim? Ne zaman profesyonel destek almalıyım?"
        },
        {
          "icon": Icons.self_improvement,
          "color": _c(),
          "ques": "Stres yönetimi için kısa ve uygulanabilir teknikler öner."
        },
        {
          "icon": Icons.timer,
          "color": _c(),
          "ques": "Uykusuzluk kaç gün sürerse doktora görünmeliyim?"
        },
      ]
    },

    // -------------------- 9) Günlük Yaşam --------------------
    {
      "title": "Yaşam",
      "question": [
        {
          "icon": Icons.water,
          "color": _c(),
          "ques": "Günde ne kadar su içmeliyim? Fazlası zararlı mı?"
        },
        {
          "icon": Icons.directions_run,
          "color": _c(),
          "ques": "Yeni başlayanlar için güvenli egzersiz planı önerir misin?"
        },
        {
          "icon": Icons.fastfood,
          "color": _c(),
          "ques": "Sağlıklı kilo verme için temel öneriler: nereden başlamalıyım?"
        },
        {
          "icon": Icons.vaccines,
          "color": _c(),
          "ques": "Vitamin/mineral eksikliği belirtileri neler olabilir? Ne zaman test yaptırılır?"
        },
      ]
    },
  ];
}
