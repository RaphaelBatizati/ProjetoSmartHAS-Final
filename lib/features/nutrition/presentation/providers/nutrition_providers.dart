
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/nutrition/data/datasources/local_pantry_data_source.dart';
import 'package:smarthas_flutter/features/nutrition/data/datasources/seed_food_data_source.dart';
import 'package:smarthas_flutter/features/nutrition/data/datasources/profile_data_source.dart';
import 'package:smarthas_flutter/features/nutrition/data/repositories/nutrition_repository_impl.dart';
import 'package:smarthas_flutter/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart';
import 'package:smarthas_flutter/features/wellness/presentation/providers/habit_providers.dart';

final _localPantryProvider = Provider((ref) => LocalPantryDataSource());
final _seedProvider = Provider((ref) => SeedFoodDataSource());
final profileDSProvider = Provider((ref) => ProfileDataSource());

final nutritionRepositoryProvider = Provider<NutritionRepository>((ref) {
  return NutritionRepositoryImpl(local: ref.read(_localPantryProvider), seed: ref.read(_seedProvider));
});

final pantryListProvider = FutureProvider<List<FoodItem>>((ref) async {
  final repo = ref.read(nutritionRepositoryProvider);
  return repo.getPantry();
});

final foodSuggestionsProvider = FutureProvider.autoDispose<List<FoodItem>>((ref) async {
  final habitsAsync = ref.watch(habitListProvider);
  final profile = await ref.read(profileDSProvider).getProfile();
  final goal = profile['goal'] ?? 'general';
  final diet = profile['diet'] ?? 'omnivore';

  final repo = ref.read(nutritionRepositoryProvider);
  return habitsAsync.when(
    data: (habits) => repo.healthySuggestionsFromHabits(habits, goal: goal, diet: diet),
    loading: () async => <FoodItem>[],
    error: (e, _) async => <FoodItem>[],
  );
});
