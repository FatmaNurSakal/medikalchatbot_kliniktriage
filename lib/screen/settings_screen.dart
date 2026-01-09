import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatbotapp/provider/settings_provider.dart';
import 'package:chatbotapp/utils/util_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _geminiKeyCtrl;
  late final TextEditingController _openAIKeyCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<SettingsProvider>();
    _geminiKeyCtrl = TextEditingController(text: s.geminiApiKey);
    _openAIKeyCtrl = TextEditingController(text: s.openAIApiKey);
  }

  @override
  void dispose() {
    _geminiKeyCtrl.dispose();
    _openAIKeyCtrl.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    final isGemini = s.provider == AiProviderType.gemini;

    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(
              'AI Sağlayıcı',
              style: mTextStyle18(
                fontColor: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<AiProviderType>(
              initialValue: s.provider,
              items: const [
                DropdownMenuItem(
                  value: AiProviderType.gemini,
                  child: Text('Gemini'),
                ),
                DropdownMenuItem(
                  value: AiProviderType.openai,
                  child: Text('ChatGPT (OpenAI)'),
                ),
              ],
              onChanged: (v) async {
                if (v == null) return;
                await s.setProvider(v);
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // ------------------- API KEY -------------------
            Text(
              isGemini ? 'Gemini API Key' : 'OpenAI API Key',
              style: mTextStyle18(
                fontColor: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: isGemini ? _geminiKeyCtrl : _openAIKeyCtrl,
              obscureText: true,
              decoration: InputDecoration(
                hintText: isGemini
                    ? 'AI Studio API Key (AIza...)'
                    : 'OpenAI API Key (sk-...)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            ElevatedButton.icon(
              onPressed: () async {
                final key =
                    (isGemini ? _geminiKeyCtrl.text : _openAIKeyCtrl.text)
                        .trim();

                if (key.isEmpty) {
                  _snack('API Key boş olamaz.');
                  return;
                }

                if (isGemini) {
                  await s.setGeminiApiKey(key);
                } else {
                  await s.setOpenAIApiKey(key);
                }

                if (!context.mounted) return;
                _snack('API Key kaydedildi.');
              },
              icon: const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),

            const SizedBox(height: 20),

            // ------------------- MODEL -------------------
            Text(
              'Model',
              style: mTextStyle18(
                fontColor: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: isGemini ? s.geminiModel : s.openAIModel,
              items: isGemini
                  ? const [
                      DropdownMenuItem(
                        value: 'gemini-1.5-flash',
                        child: Text('gemini-1.5-flash'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-1.5-pro',
                        child: Text('gemini-1.5-pro'),
                      ),
                    ]
                  : const [
                      DropdownMenuItem(
                        value: 'gpt-4o-mini',
                        child: Text('gpt-4o-mini'),
                      ),
                      DropdownMenuItem(
                        value: 'gpt-4o',
                        child: Text('gpt-4o'),
                      ),
                      DropdownMenuItem(
                        value: 'gpt-4.1-mini',
                        child: Text('gpt-4.1-mini'),
                      ),
                    ],
              onChanged: (v) {
                if (v == null) return;
                if (isGemini) {
                  s.setGeminiModel(v);
                } else {
                  s.setOpenAIModel(v);
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isGemini
                    ? 'Gemini API Key, Google AI Studio üzerinden kullanıcı tarafından oluşturulup buraya girilir.'
                    : 'OpenAI API Key, OpenAI hesabından kullanıcı tarafından oluşturulup buraya girilir.',
                style: mTextStyle15(fontColor: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
