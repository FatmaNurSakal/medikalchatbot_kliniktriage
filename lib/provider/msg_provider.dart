import 'dart:convert';
import 'dart:io';

import 'package:chatbotapp/data/remote/api_helper.dart';
import 'package:chatbotapp/model/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageProvider extends ChangeNotifier {
  final ApiHelper _api = ApiHelper();

  /// sessionId -> messages (0 index = en yeni)
  final Map<String, List<MessageModel>> _sessions = <String, List<MessageModel>>{};

  String? _activeSessionId;
  String? get activeSessionId => _activeSessionId;

  /// Aktif sohbet mesajları
  List<MessageModel> get activeMessages {
    final sid = _activeSessionId;
    if (sid == null) return const <MessageModel>[];
    return _sessions[sid] ?? const <MessageModel>[];
  }

  /// Sohbet id listesi (en güncel en üstte)
  List<String> get sessionIds {
    final ids = _sessions.keys.toList();
    ids.sort((a, b) => _lastTimeOf(b).compareTo(_lastTimeOf(a)));
    return ids;
  }

  int _lastTimeOf(String id) {
    final list = _sessions[id];
    if (list == null || list.isEmpty) return 0;

    // newest at 0
    final String t = list.first.sendAt;
    return int.tryParse(t) ?? 0;
  }

  String _uid() => FirebaseAuth.instance.currentUser?.uid ?? 'guest';
  String _prefsKey() => 'chat_sessions_${_uid()}';

  // -------------------- Persist --------------------

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey());
    if (raw == null || raw.isEmpty) return;

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) return;

    _sessions.clear();

    decoded.forEach((sessionId, value) {
      if (value is! List) return;

      final items = <MessageModel>[];
      for (final e in value) {
        if (e is Map<String, dynamic>) {
          items.add(MessageModel.fromJson(e));
        }
      }
      _sessions[sessionId] = items;
    });

    if (_sessions.isNotEmpty) {
      _activeSessionId = sessionIds.first;
    }

    notifyListeners();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{};

    _sessions.forEach((id, list) {
      map[id] = list.map((m) => m.toJson()).toList();
    });

    await prefs.setString(_prefsKey(), jsonEncode(map));
  }

  // -------------------- Sessions --------------------

  Future<String> newChat() async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    _sessions[id] = <MessageModel>[];
    _activeSessionId = id;
    await _saveHistory();
    notifyListeners();
    return id;
  }

  void openChat(String sessionId) {
    _activeSessionId = sessionId;
    notifyListeners();
  }

  Future<void> clearChat(String sessionId) async {
    _sessions.remove(sessionId);

    if (_activeSessionId == sessionId) {
      _activeSessionId = _sessions.isEmpty ? null : sessionIds.first;
    }

    await _saveHistory();
    notifyListeners();
  }

  // -------------------- History helpers (Başlık / Alt başlık) --------------------

  /// History ekranında kullanıcı dostu başlık üretir
  String sessionTitle(String sessionId) {
    final list = _sessions[sessionId];
    if (list == null || list.isEmpty) return 'Yeni sohbet';

    // newest at 0. Kullanıcı mesajı (sendId=0) bul.
    final userMsg = list.firstWhere(
      (m) => m.sendId == 0 && m.msg.trim().isNotEmpty,
      orElse: () => list.first,
    );

    final text = userMsg.msg.trim();
    if (text.isEmpty) return 'Yeni sohbet';

    return text.length > 40 ? '${text.substring(0, 40)}…' : text;
  }

  /// History ekranında daha anlaşılır alt bilgi
  /// Örn: "Son mesaj: 09 Oca 13:40"
  String sessionSubtitle(String sessionId) {
    final list = _sessions[sessionId];
    if (list == null || list.isEmpty) return '';

    final String t = list.first.sendAt;
    final ms = int.tryParse(t);
    if (ms == null) return '';

    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final fmt = DateFormat('dd MMM HH:mm', 'tr_TR');
    return 'Son mesaj: ${fmt.format(dt)}';
  }

  // -------------------- UI helpers --------------------

  void updateMessageRead(int index) {
    final sid = _activeSessionId;
    if (sid == null) return;

    final list = _sessions[sid];
    if (list == null) return;

    if (index < 0 || index >= list.length) return;

    list[index].isRead = true;
    notifyListeners();
  }

  // -------------------- Send message --------------------

  Future<void> sendMessage({
    required String message,
    dynamic settings,
  }) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty) return;

    if (_activeSessionId == null) {
      await newChat();
    }

    final sessionId = _activeSessionId!;
    final now = DateTime.now().millisecondsSinceEpoch.toString();

    // user message (en üste)
    _sessions[sessionId]!.insert(
      0,
      MessageModel(
        msg: trimmed,
        sendAt: now,
        sendId: 0,
        isRead: true,
      ),
    );
    notifyListeners();

    // settings'ten değerleri tipini bozmadan çek
    final dynamic providerValue = _safe(() => settings?.provider);
    final String apiKeyValue =
        _safe(() => settings?.apiKey)?.toString().trim() ?? '';

    try {
      dynamic data;

      // 1) Yeni imza: provider/apiKey/userMessage
      try {
        data = await (_api as dynamic).sendMsgApi(
          provider: providerValue,
          apiKey: apiKeyValue,
          userMessage: trimmed,
        );
      } on NoSuchMethodError {
        // 2) Eski imza: msg:
        data = await (_api as dynamic).sendMsgApi(msg: trimmed);
      }

      // Response parse
      // Gemini formatı:
      // data['candidates'][0]['content']['parts'][0]['text']
      // OpenAI formatı farklı olacağı için ayrıca fallback ekledim.
      final String botText =
          (data is Map<String, dynamic> ? _extractBotText(data) : null) ??
              'Yanıt alınamadı.';

      _sessions[sessionId]!.insert(
        0,
        MessageModel(
          msg: botText.trim(),
          sendAt: DateTime.now().millisecondsSinceEpoch.toString(),
          sendId: 1,
          isRead: false,
        ),
      );

      await _saveHistory();
      notifyListeners();
    } catch (e) {
      // İSTEDİĞİN KISIM: HttpException prefix temizliği + kullanıcı dostu mesaj
      final String text = _prettyErrorText(e);

      _sessions[sessionId]!.insert(
        0,
        MessageModel(
          msg: text,
          sendAt: DateTime.now().millisecondsSinceEpoch.toString(),
          sendId: 1,
          isRead: true,
        ),
      );

      await _saveHistory();
      notifyListeners();
    }
  }

  /// Gemini + OpenAI gibi farklı cevap formatlarını tek yerde toparla
  String? _extractBotText(Map<String, dynamic> data) {
    // Gemini
    final geminiText = data['candidates']?[0]?['content']?['parts']?[0]?['text']
        ?.toString();
    if (geminiText != null && geminiText.trim().isNotEmpty) return geminiText;

    // OpenAI (chat.completions): choices[0].message.content
    final openAiText = data['choices']?[0]?['message']?['content']?.toString();
    if (openAiText != null && openAiText.trim().isNotEmpty) return openAiText;

    // Bazı formatlar: choices[0].text
    final altText = data['choices']?[0]?['text']?.toString();
    if (altText != null && altText.trim().isNotEmpty) return altText;

    return null;
  }

  /// Hata metnini kullanıcıya göster
  String _prettyErrorText(Object e) {
    if (e is HttpException) return e.message;

    // e.toString() bazen "HttpException: ..." döndürüyor, temizleyelim
    var text = e.toString();

    // En yaygın prefix
    if (text.startsWith('HttpException: ')) {
      text = text.replaceFirst('HttpException: ', '');
    }

    // Bazı durumlarda "Exception: " da gelebilir
    if (text.startsWith('Exception: ')) {
      text = text.replaceFirst('Exception: ', '');
    }

    return text.trim().isEmpty ? 'Bir hata oluştu.' : text.trim();
  }

  /// property okumak için
  dynamic _safe(dynamic Function() fn) {
    try {
      return fn();
    } catch (_) {
      return null;
    }
  }
}
