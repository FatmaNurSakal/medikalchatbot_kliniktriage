# 🏥 Medikal Chatbot & Klinik Triyaj Mobil Uygulaması (Flutter)

Bu proje, **mobil cihazlar için Medikal Chatbot ve Klinik Triyaj destekli** bir uygulamadır.  
Uygulama, kullanıcıların sağlıkla ilgili sorularını doğal dilde alır ve **LLM (ChatGPT veya Gemini) API** üzerinden yanıt üretir.
> ⚠️ **Tanı koymaz**; bilgilendirici ve yönlendirici bir klinik triyaj yaklaşımı hedefler.
---
## 🎯 Projenin Amacı
- Bu uygulama, kullanıcıların sağlık semptomları hakkında **bilinçlenmesini**, gereksiz acil başvuruların azaltılmasını ve **etik sınırlar içinde** yapay zekâ destekli bir klinik triyaj deneyimi sunmayı amaçlamaktadır.
---
## 🚀 Özellikler
- **Google ile giriş** (Firebase Authentication)
- **Chat ekranı**: Serbest metinle sağlık sorusu sorabilme
- **Hızlı sorular**: Klinik triyaj için hazır soru şablonları
- **AI sağlayıcı seçimi**: ChatGPT veya Gemini
- Kullanıcı kendi **API Key**’i ile çalıştırır (uygulama içinde saklanır)
---
## 🛠️ Teknolojiler
- **Flutter / Dart**
- **Firebase Authentication** (Google Sign-In)
- **HTTP API entegrasyonu** (ChatGPT / Gemini)
---
## ⚙️ Kurulum
### 1️⃣ Olası Derleme Hataları İçin Temizlik
```bash
flutter clean
```
### 2️⃣ Bağımlılıkları yükle
```bash
flutter pub get
```
### 3️⃣ Uygulamayı Çalıştır
```bash
flutter run
``` 
---
## 🔑 API Key Kullanımı (ChatGPT / Gemini)
- Uygulama merkezi bir API anahtarı kullanmaz.
- Her kullanıcı kendi API anahtarını tanımlar.

- Adımlar:
1. Ayarlar ekranına gir
2. Sağlayıcıyı seç: ChatGPT veya Gemini
3. Kendi API Key’ini ekle

> 🔒 **Güvenlik Notu**; API anahtarını kimseyle paylaşma..

> ⚠️ **Uyarı / Sorumluluk Reddi**:  
> Bu uygulama tıbbi tanı koymaz ve doktor yerine geçmez.  
> Acil durumlarda derhal **112 / acil servis** ile iletişime geçiniz.
---
## 📱 Uygulama Ekran Görüntüleri
<p align="center">
  <img src="https://github.com/user-attachments/assets/674288bd-efa8-458a-b06f-db46d3cc6336" width="220"/>
  <img src="https://github.com/user-attachments/assets/fc90868e-b3e1-4bb1-8ee0-3c1adb1f42f3" width="220"/>
  <img src="https://github.com/user-attachments/assets/a882f986-3e18-42a8-b243-ccf69b4e89d6" width="220"/>
</p>
<p align="center">
  <img src="https://github.com/user-attachments/assets/c3a58529-f610-462a-872e-742bd2d03667" width="220"/>
  <img src="https://github.com/user-attachments/assets/8d41b203-ba84-4b05-8042-7b9299420381" width="220"/>
</p
---
## 📜 Lisans
Bu proje **MIT Lisansı** ile paylaşılmaktadır.  
Detaylar için `LICENSE` dosyasına bakınız.
