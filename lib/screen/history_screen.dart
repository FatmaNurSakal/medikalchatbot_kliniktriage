import 'package:chatbotapp/provider/msg_provider.dart';
import 'package:chatbotapp/screen/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final p = context.watch<MessageProvider>();
    final ids = p.sessionIds;

    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: ids.isEmpty
          ? const Center(child: Text('Henüz sohbet yok.'))
          : ListView.separated(
              itemCount: ids.length,

              // Lint fix: Dart 3 wildcard parametreler (aynı isim kullanılabilir)
              separatorBuilder: (_, _) => const Divider(height: 1),

              itemBuilder: (itemCtx, i) {
                final id = ids[i];

                // Kullanıcı dostu başlık & alt yazı
                final title = p.sessionTitle(id);
                final subtitle = p.sessionSubtitle(id);

                return ListTile(
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: subtitle.isEmpty
                      ? null
                      : Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                  onTap: () {
                    context.read<MessageProvider>().openChat(id);

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => const ChatScreen(query: ''),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      // await öncesi al
                      final mp = context.read<MessageProvider>();
                      final nav = Navigator.of(context);

                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (dialogCtx) => AlertDialog(
                          title: const Text('Sohbet silinsin mi?'),
                          content: Text(
                            'Bu sohbet kalıcı olarak silinecek.\n\nBaşlık: $title',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogCtx, false),
                              child: const Text('Vazgeç'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(dialogCtx, true),
                              child: const Text('Sil'),
                            ),
                          ],
                        ),
                      );

                      if (!mounted) return;

                      if (ok == true) {
                        await mp.clearChat(id);

                        // (Opsiyonel) Hepsi silindiyse geri dön
                        if (mounted && mp.sessionIds.isEmpty) {
                          nav.pop();
                        }
                      }
                    },
                  ),
                );
              },
            ),
    );
  }
}
