import 'package:chatbotapp/provider/msg_provider.dart';
import 'package:chatbotapp/provider/settings_provider.dart';
import 'package:chatbotapp/screen/auth_screen.dart';
import 'package:chatbotapp/screen/dashboard_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// History'de DateFormat patlamasın diye gerekli
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Locale tarih/saat verilerini yükle (History ekranındaki DateFormat için)
  await initializeDateFormatting('tr_TR', null);
  Intl.defaultLocale = 'tr_TR';

  // Firebase
  await Firebase.initializeApp();

  // Ayarlar
  final settings = SettingsProvider();
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MessageProvider>(
          create: (_) => MessageProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>.value(
          value: settings,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Medikal Chatbot',
      theme: ThemeData.dark(),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          return const AuthScreen();
        }

        return const DashboardScreen();
      },
    );
  }
}
