import 'package:chatbotapp/provider/msg_provider.dart';
import 'package:chatbotapp/screen/chat_screen.dart';
import 'package:chatbotapp/screen/history_screen.dart';
import 'package:chatbotapp/screen/profile_screen.dart';
import 'package:chatbotapp/screen/settings_screen.dart';
import 'package:chatbotapp/screen/triage_screen.dart';
import 'package:chatbotapp/utils/app_constant.dart';
import 'package:chatbotapp/utils/util_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().loadHistory();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _openChatWithQuery(String query) {
    final q = query.trim();
    if (q.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(query: q)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = AppConstant.defaultQues[selectedIndex];
    final List questions = (selected['question'] as List);

    return Scaffold(
      appBar: AppBar(
        title: Text.rich(
          TextSpan(
            text: "Chat",
            style: mTextStyle25(fontColor: Colors.white),
            children: [
              TextSpan(
                text: "bot",
                style: mTextStyle25(fontColor: Colors.blueAccent),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(100),
              ),
              child: IconButton(
                icon: const Icon(Icons.face),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // New chat | Triage | History
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () async {
                      final mp = context.read<MessageProvider>();
                      final nav = Navigator.of(context); // await öncesi al

                      await mp.newChat();

                      if (!mounted) return; // State kontrolü

                      nav.push(
                        MaterialPageRoute(
                          builder: (_) => const ChatScreen(query: ''),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline),
                        const SizedBox(width: 4),
                        Text(
                          "New chat",
                          style: mTextStyle18(fontColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TriageScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.health_and_safety),
                        const SizedBox(width: 4),
                        Text(
                          "Triage",
                          style: mTextStyle18(fontColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                    child: Row(
                      children: [
                        const Icon(Icons.history),
                        const SizedBox(width: 4),
                        Text(
                          "History",
                          style: mTextStyle18(fontColor: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Search Box
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: searchController,
                    style: mTextStyle18(fontColor: Colors.white70),
                    onSubmitted: (_) => _openChatWithQuery(searchController.text),
                    maxLines: 6,
                    decoration: InputDecoration(
                      hintText: "Write a question!",
                      hintStyle: mTextStyle18(fontColor: Colors.white38),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(Icons.mic, color: Colors.white, size: 30),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () => _openChatWithQuery(searchController.text),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.blueAccent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 6,
                              ),
                              child: Icon(Icons.send),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Başlık + açıklama
            Text(
              "Hızlı Sorular",
              style: mTextStyle18(
                fontColor: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "En çok sorulan sağlık konularından seç ve hızlı başlat.",
              style: mTextStyle15(fontColor: Colors.white54),
            ),

            const SizedBox(height: 14),

            // Tabs
            SizedBox(
              height: 40,
              child: ListView.builder(
                itemCount: AppConstant.defaultQues.length,
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () => setState(() => selectedIndex = index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: index == selectedIndex
                            ? Border.all(width: 1, color: Colors.blueAccent)
                            : null,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 9),
                        child: Center(
                          child: Text(
                            AppConstant.defaultQues[index]["title"],
                            style: index == selectedIndex
                                ? mTextStyle18(fontColor: Colors.blueAccent)
                                : mTextStyle18(fontColor: Colors.white60),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Grid
            Expanded(
              child: GridView.builder(
                itemCount: questions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  crossAxisCount: 2,
                  childAspectRatio: 1.05,
                ),
                itemBuilder: (context, index) {
                  final Map<String, dynamic> data = questions[index];

                  return InkWell(
                    onTap: () => _openChatWithQuery(data['ques']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: data['color'],
                            ),
                            child: Icon(
                              data['icon'],
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Text(
                                (data['ques'] ?? '').toString(),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                                style: mTextStyle18(
                                  fontColor: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
