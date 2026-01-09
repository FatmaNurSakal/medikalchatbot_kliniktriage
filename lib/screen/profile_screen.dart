import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();

    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundImage: (user?.photoURL != null) ? NetworkImage(user!.photoURL!) : null,
              child: (user?.photoURL == null) ? const Icon(Icons.person, size: 36) : null,
            ),
            const SizedBox(height: 12),
            Text(user?.displayName ?? 'İsim yok', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(user?.email ?? 'Email yok'),
            const SizedBox(height: 6),
            Text('UID: ${user?.uid ?? '-'}', style: const TextStyle(color: Colors.white54)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Google hesabından çıkış yap'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
