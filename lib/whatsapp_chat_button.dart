import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WhatsappChatButton extends StatelessWidget {
  final VoidCallback onOpenChat;

  const WhatsappChatButton({super.key, required this.onOpenChat});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onOpenChat,
      backgroundColor: const Color(0xFF25D366),
      tooltip: 'Assistente Smart HAS',
      child: const FaIcon(FontAwesomeIcons.whatsapp),
    );
  }
}
