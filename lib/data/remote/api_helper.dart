import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:chatbotapp/data/remote/urls.dart';
import 'package:http/http.dart' as http;

/// ⚠️ Eğer bu enum başka bir dosyada da tanımlıysa
/// type çakışması yaşarsın. En doğrusu bunu tek bir dosyaya taşıyıp
/// her yerde oradan import etmek.
//enum AiProviderType { gemini, openai }
import 'package:chatbotapp/core/ai_provider_type.dart';

class ApiHelper {
  Future<Map<String, dynamic>> sendMsgApi({
    required AiProviderType provider,
    required String apiKey,
    required String userMessage,
    String? systemPrompt,
  }) async {
    // API KEY KONTROLÜ (kullanıcı dostu mesaj)
    if (apiKey.trim().isEmpty) {
      throw const HttpException(
        "🔑 API anahtarı girilmemiş.\n\n"
        "Lütfen Ayarlar > API Anahtarı bölümüne girip kendi API anahtarını ekle ve tekrar dene.",
      );
    }

    // Boş mesaj kontrolü (opsiyonel ama iyi)
    if (userMessage.trim().isEmpty) {
      throw const HttpException(
        "✍️ Mesaj boş görünüyor.\n\n"
        "Lütfen bir soru yazarak tekrar dene.",
      );
    }

    try {
      late final http.Response response;

      switch (provider) {
        case AiProviderType.gemini:
          response = await _postGemini(
            apiKey: apiKey,
            userMessage: userMessage,
            systemPrompt: systemPrompt,
          );
          break;

        case AiProviderType.openai:
          response = await _postOpenAi(
            apiKey: apiKey,
            userMessage: userMessage,
            systemPrompt: systemPrompt,
          );
          break;
      }

      log('Status Code: ${response.statusCode}');
      log('Response Body: ${response.body}');

      final Map<String, dynamic> data = _safeJsonMap(response.body);

      // Başarılı HTTP
      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Bazı API'ler 200 dönüp body içinde error verebiliyor
        final err = _extractErrorMessage(data, provider);
        if (err != null && err.trim().isNotEmpty) {
          throw HttpException(err);
        }
        return data;
      }

      // Hatalı HTTP
      final err = _extractErrorMessage(data, provider);
      if (err != null && err.trim().isNotEmpty) {
        throw HttpException(err);
      }

      throw HttpException(
        "Sunucu hatası: HTTP ${response.statusCode}\n\n"
        "Lütfen daha sonra tekrar dene.",
      );
    } on HttpException {
      // Kendi fırlattığımız kullanıcı mesajını bozmayalım
      rethrow;
    } on SocketException {
      throw const HttpException(
        "📶 İnternet bağlantısı yok gibi görünüyor.\n\n"
        "Bağlantını kontrol edip tekrar dene.",
      );
    } on FormatException {
      throw const HttpException(
        "⚠️ Sunucudan beklenmeyen bir cevap geldi.\n\n"
        "Lütfen daha sonra tekrar dene.",
      );
    } catch (e) {
      // hata
      throw HttpException("Beklenmeyen bir hata oluştu: $e");
    }
  }

  // -------------------------
  // GEMINI
  // -------------------------
  Future<http.Response> _postGemini({
    required String apiKey,
    required String userMessage,
    String? systemPrompt,
  }) async {
    final uri = Uri.parse('${Urls.geminiBaseUrl}?key=$apiKey');

    final String mergedText = [
      if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
        'SİSTEM TALİMATI:\n$systemPrompt\n\n---\n',
      userMessage,
    ].join('');

    final body = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {"text": mergedText}
          ]
        }
      ]
    };

    return http.post(
      uri,
      headers: const {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );
  }

  // -------------------------
  // OPENAI
  // -------------------------
  Future<http.Response> _postOpenAi({
    required String apiKey,
    required String userMessage,
    String? systemPrompt,
  }) async {
    final uri = Uri.parse(Urls.openAiBaseUrl);

    final body = {
      "model": "gpt-4o-mini",
      "temperature": 0.2,
      "messages": [
        if (systemPrompt != null && systemPrompt.trim().isNotEmpty)
          {"role": "system", "content": systemPrompt},
        {"role": "user", "content": userMessage},
      ],
    };

    return http.post(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $apiKey",
      },
      body: jsonEncode(body),
    );
  }

  // -------------------------
  // HELPERS
  // -------------------------

  /// JSON decode güvenli Map döndürür
  Map<String, dynamic> _safeJsonMap(String body) {
    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;
    return {"raw": decoded};
  }

  /// Provider’a göre olası error mesajlarını çekmeye çalışır.
  /// - Gemini: { error: { message: "..." } }
  /// - OpenAI: { error: { message: "..." } } veya farklı formatlar
  String? _extractErrorMessage(Map<String, dynamic> data, AiProviderType provider) {
    // Ortak: error.message
    final err = data['error'];
    if (err is Map<String, dynamic>) {
      final msg = err['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg;
    }

    // OpenAI bazen başka şekilde dönebilir; güvenli kontrol
    if (provider == AiProviderType.openai) {
      final message = data['message']?.toString();
      if (message != null && message.trim().isNotEmpty) return message;
    }

    return null;
  }
}
