
import 'package:flutter/material.dart';
import 'screens/chat_screen.dart';
import 'screens/profile_screen.dart';
import 'whatsapp_chat_button.dart';

void main() {
  runApp(const SmartHasApp());
}

class SmartHasApp extends StatelessWidget {
  const SmartHasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart HAS',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: const HomePage(),
      routes: {
        '/chat': (_) => const ChatScreen(),
        '/profile': (_) => const ProfileScreen(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart HAS')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/profile'),
              icon: const Icon(Icons.person),
              label: const Text('Perfil'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/chat'),
              icon: const Icon(Icons.chat),
              label: const Text('Assistente de Dieta'),
            ),
          ],
        ),
      ),
      floatingActionButton: WhatsappChatButton(
        onOpenChat: () => Navigator.pushNamed(context, '/chat'),
      ),
    );
  }
}
