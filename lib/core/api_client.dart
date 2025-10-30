// lib/core/api_client.dart
import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ApiClient {
  final String baseUrl;
  ApiClient({this.baseUrl = 'http://10.0.2.2:8080'});

  Future<double> dailyCalories(int userId, String day) async {
    final uri = Uri.parse('$baseUrl/api/indicators/$userId/daily-calories?day=$day');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Erro ${res.statusCode}: ${res.body}');
    return double.parse(res.body);
  }

  Future<String> bmiSummary(int userId) async {
    final uri = Uri.parse('$baseUrl/api/indicators/$userId/bmi-summary');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Erro ${res.statusCode}: ${res.body}');
    return res.body;
  }

  Future<List<dynamic>> consumptionReport(int userId, String start, String end) async {
    final uri = Uri.parse('$baseUrl/api/reports/$userId/consumption?start=$start&end=$end');
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('Erro ${res.statusCode}: ${res.body}');
    return jsonDecode(res.body) as List<dynamic>;
  }

  Future<Map<String, dynamic>> postReading(int sensorId, double value) async {
    final uri = Uri.parse('$baseUrl/api/sensors/$sensorId/reading?value=$value');
    final res = await http.post(uri);
    if (res.statusCode != 200) throw Exception('Erro ${res.statusCode}: ${res.body}');
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}
