
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:smarthas_flutter/features/nutrition/domain/entities/recipe.dart';

class SeedFoodDataSource {
  Future<Map<String, dynamic>> _foodsMap() async {
    final raw = await rootBundle.loadString('assets/seed/foods.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _recipesMap() async {
    final raw = await rootBundle.loadString('assets/seed/recipes.json');
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>?> findFoodByBarcode(String barcode) async {
    final map = await _foodsMap();
    final list = (map['foods'] as List).cast<Map<String, dynamic>>();
    for (final f in list) {
      if ((f['barcode'] as String) == barcode) return f;
    }
    return null;
  }

  Future<List<Recipe>> getAllRecipes() async {
    final map = await _recipesMap();
    final list = (map['recipes'] as List).cast<Map<String, dynamic>>();
    return list.map(Recipe.fromJson).toList();
  }
}
