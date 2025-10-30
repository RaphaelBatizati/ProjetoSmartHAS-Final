
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/recipe.dart';

abstract class NutritionRepository {
  Future<List<FoodItem>> getPantry();
  Future<void> addOrUpdate(FoodItem item);
  Future<void> remove(String id);
  Future<FoodItem?> findByBarcode(String barcode);
  Future<List<FoodItem>> healthySuggestionsFromHabits(List<Habit> habits, {String goal = 'general', String diet = 'omnivore'});
  Future<List<Recipe>> recipesForPantry(List<FoodItem> pantry);
}
