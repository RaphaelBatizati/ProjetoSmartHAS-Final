
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileDataSource {
  static const _kKey = 'profile_v1';

  Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return {'goal': 'general', 'diet': 'omnivore'};
    final map = (jsonDecode(raw) as Map).cast<String, dynamic>();
    return {'goal': map['goal'] as String? ?? 'general', 'diet': map['diet'] as String? ?? 'omnivore'};
  }

  Future<void> saveProfile(String goal, String diet) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kKey, jsonEncode({'goal': goal, 'diet': diet}));
  }
}
