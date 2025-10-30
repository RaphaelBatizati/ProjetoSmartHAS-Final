
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';

class LocalHabitDataSource {
  static const _kKey = 'habits_v1';

  Future<List<Habit>> getHabits() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(Habit.fromJson).toList();
  }

  Future<void> saveHabits(List<Habit> habits) async {
    final prefs = await SharedPreferences.getInstance();
    final list = habits.map((h) => h.toJson()).toList();
    await prefs.setString(_kKey, jsonEncode(list));
  }
}
