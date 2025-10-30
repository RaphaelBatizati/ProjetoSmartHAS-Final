
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart';

class LocalPantryDataSource {
  static const _kKey = 'pantry_v1';

  Future<List<FoodItem>> getPantry() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    return list.map(FoodItem.fromJson).toList();
  }

  Future<void> savePantry(List<FoodItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_kKey, jsonEncode(list));
  }
}
