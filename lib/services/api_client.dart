import 'dart:convert';
import 'package:http/http.dart' as http;

/// API base. Em emulador Android use 10.0.2.2 ou configure via --dart-define=API_BASE_URL
class ApiClient {
  static String baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8080');

  static Future<Map<String, dynamic>> aiChat(String prompt) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/ai/chat'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'prompt': prompt}),
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> upsertProfile(Map<String, dynamic> profile) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/profile/upsert'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(profile),
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final resp = await http.get(Uri.parse('$baseUrl/api/profile/$userId'));
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> calcCalories(int age, double weightKg) async {
    final resp = await http.post(
      Uri.parse('$baseUrl/api/diet/calc'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'age': age, 'weightKg': weightKg}),
    );
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }
}