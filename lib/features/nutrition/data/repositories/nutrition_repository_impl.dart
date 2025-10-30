
import 'package:uuid/uuid.dart';
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/recipe.dart';
import 'package:smarthas_flutter/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:smarthas_flutter/features/nutrition/data/datasources/local_pantry_data_source.dart';
import 'package:smarthas_flutter/features/nutrition/data/datasources/seed_food_data_source.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  final LocalPantryDataSource local;
  final SeedFoodDataSource seed;
  NutritionRepositoryImpl({required this.local, required this.seed});

  @override
  Future<void> addOrUpdate(FoodItem item) async {
    final pantry = await local.getPantry();
    final idx = pantry.indexWhere((e) => e.id == item.id);
    if (idx >= 0) {
      pantry[idx] = item;
    } else {
      pantry.add(item.copyWith(id: const Uuid().v4()));
    }
    await local.savePantry(pantry);
  }

  @override
  Future<FoodItem?> findByBarcode(String barcode) async {
    final data = await seed.findFoodByBarcode(barcode);
    if (data == null) return null;
    return FoodItem(
      id: const Uuid().v4(),
      name: data['name'] as String,
      barcode: data['barcode'] as String,
      category: data['category'] as String,
      calories: (data['cal'] as num).toDouble(),
      protein: (data['protein'] as num).toDouble(),
      carbs: (data['carbs'] as num).toDouble(),
      fat: (data['fat'] as num).toDouble(),
      expiry: null,
      quantity: 1,
    );
  }

  @override
  Future<List<FoodItem>> getPantry() => local.getPantry();

  @override
  Future<void> remove(String id) async {
    final pantry = await local.getPantry();
    pantry.removeWhere((e) => e.id == id);
    await local.savePantry(pantry);
  }

  @override
  Future<List<FoodItem>> healthySuggestionsFromHabits(List<Habit> habits, {String goal = 'general', String diet = 'omnivore'}) async {
    final List<FoodItem> suggestions = [];
    String norm(String s) => s.toLowerCase();

    final titles = habits.map((h) => norm(h.title)).toList();

    final hasHydration = titles.any((t) => t.contains('água') || t.contains('agua') || t.contains('hidrata'));
    final hasExercise = titles.any((t) => t.contains('exerc') || t.contains('treino') || t.contains('caminh'));
    final hasSleep = titles.any((t) => t.contains('sono') || t.contains('dormir'));

    final List<Map<String, dynamic>> pool = [
      // base proteicas
      {'name': 'Peito de Frango', 'cal': 165.0, 'protein': 31.0, 'carbs': 0.0, 'fat': 3.6, 'cat': 'Proteínas', 'animal': true, 'dairy': false},
      {'name': 'Atum', 'cal': 116.0, 'protein': 26.0, 'carbs': 0.0, 'fat': 1.0, 'cat': 'Proteínas', 'animal': true, 'dairy': false},
      {'name': 'Iogurte Grego', 'cal': 59.0, 'protein': 10.0, 'carbs': 3.6, 'fat': 0.4, 'cat': 'Laticínios', 'animal': false, 'dairy': true},
      // hidratação
      if (hasHydration) ...[
        {'name': 'Melancia', 'cal': 30.0, 'protein': 0.6, 'carbs': 8.0, 'fat': 0.2, 'cat': 'Frutas', 'animal': false, 'dairy': false},
        {'name': 'Pepino', 'cal': 16.0, 'protein': 0.7, 'carbs': 3.6, 'fat': 0.1, 'cat': 'Vegetais', 'animal': false, 'dairy': false},
        {'name': 'Água de Coco', 'cal': 19.0, 'protein': 0.7, 'carbs': 3.7, 'fat': 0.2, 'cat': 'Bebidas', 'animal': false, 'dairy': false},
      ],
      // sono
      if (hasSleep) ...[
        {'name': 'Aveia', 'cal': 389.0, 'protein': 16.9, 'carbs': 66.3, 'fat': 6.9, 'cat': 'Grãos', 'animal': false, 'dairy': false},
        {'name': 'Leite Morno', 'cal': 42.0, 'protein': 3.4, 'carbs': 5.0, 'fat': 1.0, 'cat': 'Laticínios', 'animal': false, 'dairy': true},
        {'name': 'Banana', 'cal': 89.0, 'protein': 1.1, 'carbs': 22.8, 'fat': 0.3, 'cat': 'Frutas', 'animal': false, 'dairy': false},
      ],
    ];

    for (final f in pool) {
      final isAnimal = (f['animal'] as bool);
      final isDairy = (f['dairy'] as bool);

      if (diet == 'vegan' && (isAnimal || isDairy)) continue;
      if (diet == 'vegetarian' && isAnimal) continue;

      // Goal adjustments (simples): para muscle_gain preferir proteína; para weight_loss preferir baixa caloria
      if (goal == 'muscle_gain' && (f['protein'] as num) < 8) continue;
      if (goal == 'weight_loss' && (f['cal'] as num) > 200) continue;

      suggestions.add(FoodItem(
        id: const Uuid().v4(),
        name: f['name'] as String,
        barcode: null,
        category: f['cat'] as String,
        calories: (f['cal'] as num).toDouble(),
        protein: (f['protein'] as num).toDouble(),
        carbs: (f['carbs'] as num).toDouble(),
        fat: (f['fat'] as num).toDouble(),
        expiry: null,
        quantity: 1,
      ));
    }

    // Se não tem exercício nos hábitos, ainda assim manter sugestões gerais
    if (hasExercise) {
      suggestions.sort((a, b) => b.protein.compareTo(a.protein));
    }

    return suggestions;
  }

  @override
  Future<List<Recipe>> recipesForPantry(List<FoodItem> pantry) async {
    final recipes = await seed.getAllRecipes();
    final names = pantry.map((e) => e.name.toLowerCase()).toList();

    bool hasIngredient(String recipeIngredient) {
      final r = recipeIngredient.toLowerCase();
      return names.any((p) => p.contains(r.split(' (')[0]) || r.contains(p));
    }

    final out = <Recipe>[];
    for (final r in recipes) {
      final ok = r.ingredients.every(hasIngredient);
      if (ok) out.add(r);
    }
    return out;
  }
}
