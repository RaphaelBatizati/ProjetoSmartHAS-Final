import 'package:http/http.dart' as http;

class SmartHasApi {
  final String baseUrl;
  SmartHasApi({required this.baseUrl});

  Future<double> avgConsumption({required int sensorId, int days = 3}) async {
    final uri = Uri.parse('$baseUrl/db/avg-consumption?sensorId=$sensorId&days=$days');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return double.tryParse(resp.body) ?? 0.0;
    }
    throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
  }

  Future<String> formatAlert({required int sensorId, int hours = 24}) async {
    final uri = Uri.parse('$baseUrl/db/format-alert?sensorId=$sensorId&hours=$hours');
    final resp = await http.get(uri);
    if (resp.statusCode == 200) {
      return resp.body;
    }
    throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
  }

  Future<void> runAlerts({int powerThresh = 900, int tempThresh = 70}) async {
    final uri = Uri.parse('$baseUrl/db/run-alerts?powerThresh=$powerThresh&tempThresh=$tempThresh');
    final resp = await http.post(uri);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
  }

  Future<void> generateReport({required int userId, int days = 3}) async {
    final uri = Uri.parse('$baseUrl/db/generate-report?userId=$userId&days=$days');
    final resp = await http.post(uri);
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}: ${resp.body}');
    }
  }
}