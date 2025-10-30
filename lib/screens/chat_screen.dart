import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;
  ChatMessage(this.role, this.content);
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage('user', text));
      _controller.clear();
      _sending = true;
    });
    try {
      final resp = await ApiClient.aiChat(text);
      String reply = '';
      if (resp.containsKey('answer')) {
        reply = resp['answer']?.toString() ?? '';
      } else {
        final choices = resp['choices'];
        if (choices is List && choices.isNotEmpty) {
          final msg = choices.first['message'];
          reply = msg?['content']?.toString() ?? '';
        } else {
          reply = 'Não foi possível interpretar a resposta.';
        }
      }
      setState(() => _messages.add(ChatMessage('assistant', reply)));
    } catch (e) {
      setState(() => _messages.add(ChatMessage('assistant', 'Erro: $e')));
    } finally {
      setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assistente (Dieta & Cálculos)')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final m = _messages[i];
                final align = m.role == 'user' ? Alignment.centerRight : Alignment.centerLeft;
                final color  = m.role == 'user' ? Colors.blue[100] : Colors.grey[200];
                return Align(
                  alignment: align,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m.content),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Pergunte sobre dieta, calorias, etc.',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _sending ? null : _send,
                  child: _sending ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}