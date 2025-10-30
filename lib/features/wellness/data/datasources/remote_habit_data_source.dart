
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class RemoteHabitDataSource {
  // Simula uma "IA" simples com seed de sugestões em assets.
  Future<List<Map<String, dynamic>>> getAISuggestions() async {
    final raw = await rootBundle.loadString('assets/seed/suggestions.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return (map['suggestions'] as List).cast<Map<String, dynamic>>();
  }
}
