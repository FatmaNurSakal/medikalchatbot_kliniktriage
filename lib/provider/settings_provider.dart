export 'package:chatbotapp/core/ai_provider_type.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chatbotapp/core/ai_provider_type.dart';

class SettingsProvider extends ChangeNotifier {
  static const _kProvider = 'ai_provider';
  static const _kGeminiKey = 'gemini_api_key';
  static const _kOpenAIKey = 'openai_api_key';
  static const _kGeminiModel = 'gemini_model';
  static const _kOpenAIModel = 'openai_model';

  AiProviderType _provider = AiProviderType.gemini;

  String _geminiApiKey = '';
  String _openAIApiKey = '';

  String _geminiModel = 'gemini-1.5-flash';
  String _openAIModel = 'gpt-4o-mini';

  AiProviderType get provider => _provider;

  String get providerLabel =>
      _provider == AiProviderType.gemini ? 'Gemini' : 'ChatGPT';

  String get geminiApiKey => _geminiApiKey;
  String get openAIApiKey => _openAIApiKey;

  String get geminiModel => _geminiModel;
  String get openAIModel => _openAIModel;

  String get apiKey =>
      _provider == AiProviderType.gemini ? _geminiApiKey : _openAIApiKey;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final providerStr = prefs.getString(_kProvider) ?? 'gemini';
    _provider =
        (providerStr == 'openai') ? AiProviderType.openai : AiProviderType.gemini;

    _geminiApiKey = prefs.getString(_kGeminiKey) ?? '';
    _openAIApiKey = prefs.getString(_kOpenAIKey) ?? '';

    _geminiModel = prefs.getString(_kGeminiModel) ?? 'gemini-1.5-flash';
    _openAIModel = prefs.getString(_kOpenAIModel) ?? 'gpt-4o-mini';

    notifyListeners();
  }

  Future<void> setProvider(AiProviderType value) async {
    _provider = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kProvider,
      value == AiProviderType.openai ? 'openai' : 'gemini',
    );
    notifyListeners();
  }

  Future<void> setGeminiApiKey(String key) async {
    _geminiApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGeminiKey, key);
    notifyListeners();
  }

  Future<void> setOpenAIApiKey(String key) async {
    _openAIApiKey = key;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOpenAIKey, key);
    notifyListeners();
  }

  Future<void> setGeminiModel(String model) async {
    _geminiModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kGeminiModel, model);
    notifyListeners();
  }

  Future<void> setOpenAIModel(String model) async {
    _openAIModel = model;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kOpenAIModel, model);
    notifyListeners();
  }
}
