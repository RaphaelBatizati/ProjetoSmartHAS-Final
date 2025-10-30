import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/recipe.dart';
import 'package:smarthas_flutter/features/nutrition/domain/services/recipe_engine.dart';

final recipesSuggestionsProvider = Provider<List<Recipe>>((ref) {
  final pantryAsync = ref.watch(pantryListProvider);
  return pantryAsync.maybeWhen(
    data: (items) => RecipeEngine.generateFromPantry(items),
    orElse: () => const <Recipe>[],
  );
});
