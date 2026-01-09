import 'package:chatbotapp/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import '../utils/util_helper.dart';

enum TriageLevel { red, orange, yellow, green }

class _TriageResult {
  final TriageLevel level;
  final String label; // ACIL / BUGÜN / 24-48s / RUTİN
  final String colorName; // Kırmızı / Turuncu / Sarı / Yeşil
  final Color color;
  final String reason;

  const _TriageResult({
    required this.level,
    required this.label,
    required this.colorName,
    required this.color,
    required this.reason,
  });
}

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final _complaintCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();

  bool _pregnant = false;
  String _sex = 'Belirtmek istemiyor';
  String _duration = 'Bugün başladı';
  int _pain = 0;

  final Map<String, bool> _redFlags = <String, bool>{
    'Nefes darlığı / boğulma hissi': false,
    'Göğüs ağrısı / baskı': false,
    'Bayılma / bilinç değişikliği': false,
    'Konuşma bozukluğu / yüz-kol bacakta güçsüzlük': false,
    'Şiddetli alerjik reaksiyon bulguları (dil-dudak şişmesi vb.)': false,
    'Kontrolsüz kanama / ciddi travma': false,
    'Şiddetli karın ağrısı + ateş / kusma': false,
  };

  @override
  void dispose() {
    _complaintCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  int? _age() {
    final t = _ageCtrl.text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  List<String> _selectedRedFlags() {
    return _redFlags.entries.where((e) => e.value).map((e) => e.key).toList();
  }

  // 1) KURAL TABANLI ÖN TRIAGE (UI’da renk göstermek için)
  _TriageResult _computePreTriage() {
    final complaint = _complaintCtrl.text.trim();
    final age = _age();
    final flags = _selectedRedFlags();

    if (flags.isNotEmpty) {
      return _TriageResult(
        level: TriageLevel.red,
        label: 'ACİL',
        colorName: 'Kırmızı',
        color: Colors.redAccent,
        reason: 'Acil uyarı işareti seçildi: ${flags.first}',
      );
    }

    if (_pain >= 8) {
      return const _TriageResult(
        level: TriageLevel.orange,
        label: 'BUGÜN',
        colorName: 'Turuncu',
        color: Colors.deepOrangeAccent,
        reason: 'Ağrı şiddeti çok yüksek (8-10).',
      );
    }

    if (_pregnant && complaint.isNotEmpty) {
      return const _TriageResult(
        level: TriageLevel.orange,
        label: 'BUGÜN',
        colorName: 'Turuncu',
        color: Colors.deepOrangeAccent,
        reason: 'Hamilelikte semptomlar daha yakından değerlendirilmelidir.',
      );
    }

    if (age != null && (age < 2 || age >= 65) && _pain >= 6) {
      return const _TriageResult(
        level: TriageLevel.orange,
        label: 'BUGÜN',
        colorName: 'Turuncu',
        color: Colors.deepOrangeAccent,
        reason: 'Riskli yaş grubu + belirgin ağrı (6+).',
      );
    }

    if (_pain >= 5) {
      return const _TriageResult(
        level: TriageLevel.yellow,
        label: '24-48s',
        colorName: 'Sarı',
        color: Colors.amber,
        reason: 'Orta düzey ağrı (5-7).',
      );
    }

    if (_duration == '3-7 gün' || _duration == '1-4 hafta') {
      return const _TriageResult(
        level: TriageLevel.yellow,
        label: '24-48s',
        colorName: 'Sarı',
        color: Colors.amber,
        reason: 'Şikayet birkaç gündür devam ediyor.',
      );
    }

    return const _TriageResult(
      level: TriageLevel.green,
      label: 'RUTİN',
      colorName: 'Yeşil',
      color: Colors.greenAccent,
      reason: 'Kırmızı bayrak yok, semptomlar hafif.',
    );
  }

  // StringBuffer return etme -> String döndür
  String _buildPrompt(_TriageResult pre) {
    final complaint = _complaintCtrl.text.trim();
    final ageText = _ageCtrl.text.trim();
    final flags = _selectedRedFlags().map((e) => '- $e').toList();

    final buffer = StringBuffer()
      ..writeln('Aşağıdaki klinik triage formunu değerlendir.')
      ..writeln('Teşhis koyma. Aciliyet seviyesini (ACİL / BUGÜN / 24-48s / RUTİN) belirle ve gerekçeni yaz.')
      ..writeln('Sonra net aksiyon önerileri ver (evde izlem, aile hekimi, acil vb.).')
      ..writeln('Cevapta şu formatı kullan:')
      ..writeln('1) Triage Seviyesi: ...')
      ..writeln('2) Renk: ...')
      ..writeln('3) Gerekçe (kısa madde madde)')
      ..writeln('4) Ne yapmalıyım? (adım adım)')
      ..writeln('5) Ne zaman acil? (kırmızı bayraklar)')
      ..writeln('---')
      ..writeln('ÖN DEĞERLENDİRME (kural tabanlı): ${pre.label} (${pre.colorName})')
      ..writeln('Ön gerekçe: ${pre.reason}')
      ..writeln('---')
      ..writeln('Şikayet: $complaint')
      ..writeln('Yaş: ${ageText.isEmpty ? 'Bilinmiyor' : ageText}')
      ..writeln('Cinsiyet: $_sex')
      ..writeln('Hamilelik: ${_pregnant ? 'Evet' : 'Hayır / Bilinmiyor'}')
      ..writeln('Süre: $_duration')
      ..writeln('Ağrı (0-10): $_pain')
      ..writeln('Acil uyarı işaretleri:')
      ..writeln(flags.isEmpty ? '- Yok' : flags.join('\n'));

    return buffer.toString();
  }

  Future<void> _startTriage() async {
    final complaint = _complaintCtrl.text.trim();
    if (complaint.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen şikayetini yaz.')),
      );
      return;
    }

    final nav = Navigator.of(context); // await öncesi
    final pre = _computePreTriage();
    final prompt = _buildPrompt(pre);

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Triage Özeti'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: pre.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${pre.label} (${pre.colorName})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Ön gerekçe: ${pre.reason}'),
            const SizedBox(height: 10),
            const Text('Devam edince yapay zekâ detaylı değerlendirecek.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text('Devam'),
          ),
        ],
      ),
    );

    if (!mounted) return;
    if (ok != true) return;

    nav.push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(query: prompt),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sexItems = <String>['Belirtmek istemiyor', 'Kadın', 'Erkek'];
    final pre = _computePreTriage();

    return Scaffold(
      appBar: AppBar(title: const Text('Klinik Triage')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ÜST BİLGİ + ÖN DEĞERLENDİRME
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bu form aciliyet değerlendirmesi içindir. Tanı yerine yönlendirme sağlar.\nAcil durumlarda 112.',
                    style: mTextStyle15(fontColor: Colors.white54),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(color: pre.color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ön Değerlendirme: ${pre.label} (${pre.colorName})',
                          style: mTextStyle15(
                            fontColor: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(pre.reason, style: mTextStyle15(fontColor: Colors.white54)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text('Şikayet', style: mTextStyle18(fontColor: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _complaintCtrl,
              maxLines: 3,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Örn: 2 gündür ateş + boğaz ağrısı',
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageCtrl,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Yaş',
                      filled: true,
                      fillColor: Colors.white10,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _sex,
                    isExpanded: true,
                    selectedItemBuilder: (ctx) => sexItems
                        .map((e) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    items: sexItems
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _sex = v ?? _sex),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hamilelik (varsa işaretle)',
                      style: mTextStyle18(fontColor: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.95,
                    child: Switch(
                      value: _pregnant,
                      onChanged: (v) => setState(() => _pregnant = v),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Text('Süre', style: mTextStyle18(fontColor: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _duration,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'Bugün başladı', child: Text('Bugün başladı')),
                DropdownMenuItem(value: '1-2 gün', child: Text('1-2 gün')),
                DropdownMenuItem(value: '3-7 gün', child: Text('3-7 gün')),
                DropdownMenuItem(value: '1-4 hafta', child: Text('1-4 hafta')),
                DropdownMenuItem(value: '1 aydan uzun', child: Text('1 aydan uzun')),
              ],
              onChanged: (v) => setState(() => _duration = v ?? _duration),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white10,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text('Ağrı (0-10): $_pain', style: mTextStyle18(fontColor: Colors.white, fontWeight: FontWeight.bold)),
            Slider(
              value: _pain.toDouble(),
              min: 0,
              max: 10,
              divisions: 10,
              label: _pain.toString(),
              onChanged: (v) => setState(() => _pain = v.round()),
            ),

            const SizedBox(height: 12),

            Text('Acil uyarı işaretleri', style: mTextStyle18(fontColor: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),

            ..._redFlags.keys.map((k) {
              return CheckboxListTile(
                value: _redFlags[k] ?? false,
                onChanged: (v) => setState(() => _redFlags[k] = v ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  k,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: mTextStyle15(fontColor: Colors.white70),
                ),
              );
            }),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startTriage,
                icon: const Icon(Icons.health_and_safety),
                label: const Text('Triage Başlat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
