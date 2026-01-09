import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:chatbotapp/model/message_model.dart';
import 'package:chatbotapp/provider/msg_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../utils/util_helper.dart';

// KENDİ PROJENDE SettingsProvider hangi path'teyse onu yaz
import 'package:chatbotapp/provider/settings_provider.dart';

class ChatScreen extends StatefulWidget {
  final String query;
  const ChatScreen({super.key, required this.query});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController chatBoxController = TextEditingController();

  /// Time format
  final DateFormat dateFormat = DateFormat().add_jm();

  @override
  void initState() {
    super.initState();

    /// New chat mantığı: query boş gelirse otomatik gönderme
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initial = widget.query.trim();
      if (initial.isEmpty) return;

      final settings = context.read<SettingsProvider>();
      Provider.of<MessageProvider>(context, listen: false).sendMessage(
        message: initial,
        settings: settings,
      );
    });
  }

  @override
  void dispose() {
    chatBoxController.dispose();
    super.dispose();
  }

  void _sendCurrentMessage() {
    final text = chatBoxController.text.trim();

    /// Boş mesaj göndermeyi engelle
    if (text.isEmpty) return;

    final settings = context.read<SettingsProvider>();

    FocusScope.of(context).unfocus();

    context.read<MessageProvider>().sendMessage(
          message: text,
          settings: settings,
        );

    chatBoxController.clear();
  }

  int _safeMillis(String ms) => int.tryParse(ms) ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/icon/robot.png", height: 30),
            Text.rich(
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
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blueAccent.shade200.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(100),
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        actions: [
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
                  // İstersen burayı profil sayfasına yönlendirelim
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          /// ---------------- Chat List ----------------------- ///
          Expanded(
            child: Consumer<MessageProvider>(
              builder: (_, provider, _) {
                /// fetchAllMessage / listMessage yerine activeMessages
                final List<MessageModel> listMsg = provider.activeMessages;

                return ListView.builder(
                  reverse: true,
                  itemCount: listMsg.length,
                  itemBuilder: (context, index) {
                    return listMsg[index].sendId == 0
                        ? userChatBox(listMsg[index])
                        : botChatBox(listMsg[index], index);
                  },
                );
              },
            ),
          ),

          /// ---------------- Chat box ----------------------- ///
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: chatBoxController,
              style: mTextStyle18(fontColor: Colors.white70),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendCurrentMessage(),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.mic, color: Colors.white),
                suffixIcon: InkWell(
                  onTap: _sendCurrentMessage,
                  child: const Icon(Icons.send, color: Colors.blueAccent),
                ),
                hintText: "Write a question!",
                hintStyle: mTextStyle18(fontColor: Colors.white38),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(21),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Right Side - User Chat Box
  Widget userChatBox(MessageModel msgModel) {
    final time = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(_safeMillis(msgModel.sendAt)),
    );

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(21),
            topRight: Radius.circular(21),
            bottomLeft: Radius.circular(21),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msgModel.msg,
              style: mTextStyle18(fontColor: Colors.white70),
            ),
            Text(
              time,
              style: mTextStyle11(
                fontColor: Colors.white38,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Left Side - Bot Chat Box
  Widget botChatBox(MessageModel msgModel, int index) {
    final time = dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(_safeMillis(msgModel.sendAt)),
    );

    final bool isRead = msgModel.isRead;
    final String msgText = msgModel.msg;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade300,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(21),
            topRight: Radius.circular(21),
            bottomRight: Radius.circular(21),
          ),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Bot Message
            isRead
                ? SelectableText(
                    msgText,
                    style: mTextStyle18(fontColor: Colors.black87),
                  )
                : DefaultTextStyle(
                    style: mTextStyle18(fontColor: Colors.black87),
                    child: AnimatedTextKit(
                      repeatForever: false,
                      displayFullTextOnTap: true,
                      isRepeatingAnimation: false,
                      onFinished: () {
                        context.read<MessageProvider>().updateMessageRead(index);
                      },
                      animatedTexts: [
                        TypewriterAnimatedText(
                          msgText,
                          textStyle: mTextStyle18(fontColor: Colors.black87),
                        ),
                      ],
                    ),
                  ),

            /// Timestamp + tools
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      "assets/icon/typing.png",
                      height: 30,
                      width: 30,
                    ),
                    InkWell(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: msgText));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              "Text copied to clipboard!",
                              style: mTextStyle18(fontColor: Colors.white70),
                            ),
                            backgroundColor:
                                Colors.blueAccent.withValues(alpha: 0.8),
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Icon(Icons.copy_rounded, color: Colors.black45),
                      ),
                    ),
                  ],
                ),
                Text(
                  time,
                  style: mTextStyle15(
                    fontColor: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
