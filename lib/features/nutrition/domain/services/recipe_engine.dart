import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/recipe.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart' as fi;

String _norm(String s) => s.toLowerCase().trim();

int _countMatches(Iterable<String> pantryNames, Iterable<String> required) {
  final p = pantryNames.map(_norm).toList();
  int hits = 0;
  for (final r in required.map(_norm)) {
    if (p.any((n) => n.contains(r))) hits++;
  }
  return hits;
}

class RecipeEngine {
  static const _uuid = Uuid();

  static final List<_RecipeTemplate> _templates = [
    const _RecipeTemplate(
      title: 'Arroz com Feijão',
      requiredKeywords: ['arroz', 'feijão'],
      optionalKeywords: ['alho', 'cebola', 'óleo', 'sal'],
      category: 'Almoço',
      instructions:
          'Cozinhe o arroz como de costume. Em outra panela, refogue alho/cebola e adicione o feijão. Tempere e sirva junto.',
    ),
    const _RecipeTemplate(
      title: 'Omelete de Queijo',
      requiredKeywords: ['ovo', 'queijo'],
      optionalKeywords: ['leite', 'sal', 'pimenta', 'cebola'],
      category: 'Café/Lanche',
      instructions:
          'Bata os ovos, adicione queijo e temperos. Leve à frigideira untada e dobre ao firmar.',
    ),
    const _RecipeTemplate(
      title: 'Macarrão ao Molho de Tomate',
      requiredKeywords: ['macarrão', 'molho de tomate'],
      optionalKeywords: ['queijo', 'manjericão', 'alho', 'cebola', 'azeite', 'sal'],
      category: 'Almoço',
      instructions:
          'Cozinhe o macarrão. Aqueça o molho de tomate com alho/cebola. Misture e finalize com queijo/manjericão.',
    ),
    const _RecipeTemplate(
      title: 'Iogurte com Frutas',
      requiredKeywords: ['iogurte', 'banana|maçã|morango|mamão|uva'],
      optionalKeywords: ['aveia', 'mel', 'granola'],
      category: 'Lanche',
      instructions:
          'Misture iogurte com frutas picadas. Adicione aveia/mel/granola a gosto.',
    ),
    const _RecipeTemplate(
      title: 'Sanduíche Natural',
      requiredKeywords: ['pão', 'queijo|peito de peru|frango'],
      optionalKeywords: ['tomate', 'alface', 'maionese'],
      category: 'Lanche',
      instructions:
          'Monte o sanduíche com queijo ou proteína leve. Acrescente tomate/alface e um fio de maionese.',
    ),
  ];

  static List<Recipe> generateFromPantry(List<fi.FoodItem> pantry) {
    final names = pantry.map((e) => _norm(e.name)).toList();
    final out = <Recipe>[];

    for (final t in _templates) {
      final requirementSets = t.requiredKeywords.map((r) => r.split('|'));
      bool ok = true;
      int reqHits = 0;

      for (final alternatives in requirementSets) {
        final hit = alternatives.any((alt) => names.any((n) => n.contains(_norm(alt))));
        if (!hit) {
          ok = false;
          break;
        } else {
          reqHits++;
        }
      }
      if (!ok) continue;

      final optHits = _countMatches(names, t.optionalKeywords);
      final totalPossible = reqHits + t.optionalKeywords.length;
      final score = totalPossible == 0 ? 1.0 : (reqHits + optHits) / totalPossible;

      out.add(Recipe(
        id: _uuid.v4(),
        title: t.title,
        ingredients: _chooseIngredients(names, t),
        instructions: t.instructions,
        score: score.clamp(0.0, 1.0),
        category: t.category, tags: [],
      ));
    }

    out.addAll(_dynamicSalad(names));
    out.addAll(_dynamicFruitBowl(names));
    out.addAll(_dynamicStirFry(names));

    final seen = <String>{};
    final unique = <Recipe>[];
    for (final r in out) {
      if (seen.add(r.title.toLowerCase())) unique.add(r);
    }
    unique.sort((a, b) => b.score.compareTo(a.score));
    return unique;
  }

  static List<String> _chooseIngredients(List<String> pantryNames, _RecipeTemplate t) {
    final base = <String>[];
    for (final group in t.requiredKeywords) {
      final alts = group.split('|');
      final pick = pantryNames.firstWhere(
        (n) => alts.any((a) => n.contains(_norm(a))),
        orElse: () => alts.first,
      );
      base.add(pick);
    }
    for (final opt in t.optionalKeywords) {
      if (pantryNames.any((n) => n.contains(_norm(opt)))) base.add(opt);
    }
    return base;
  }

  static List<Recipe> _dynamicSalad(List<String> names) {
    final hasHorti = names.any((n) => n.contains('alface') || n.contains('tomate') || n.contains('cenoura') || n.contains('pepino'));
    if (!hasHorti) return const [];
    final ings = [
      if (names.any((n) => n.contains('alface'))) 'alface',
      if (names.any((n) => n.contains('tomate'))) 'tomate',
      if (names.any((n) => n.contains('cenoura'))) 'cenoura',
      if (names.any((n) => n.contains('pepino'))) 'pepino',
      if (names.any((n) => n.contains('azeite'))) 'azeite',
      if (names.any((n) => n.contains('sal'))) 'sal',
      if (names.any((n) => n.contains('vinagre'))) 'vinagre',
    ];
    final score = min(1.0, 0.5 + ings.length * 0.07);
    return [
      Recipe(
        id: _uuid.v4(),
        title: 'Salada Fresca da Despensa',
        ingredients: ings,
        instructions: 'Pique os vegetais, tempere com azeite, sal e vinagre. Sirva.',
        score: score,
        category: 'Acompanhamento',
      )
    ];
  }

  static List<Recipe> _dynamicFruitBowl(List<String> names) {
    final fruits = ['banana', 'maçã', 'morango', 'mamão', 'uva', 'pera', 'kiwi'];
    final hasFruit = names.any((n) => fruits.any((f) => n.contains(f)));
    if (!hasFruit) return const [];
    final ings = <String>[
      for (final f in fruits) if (names.any((n) => n.contains(f))) f,
      if (names.any((n) => n.contains('iogurte'))) 'iogurte',
      if (names.any((n) => n.contains('granola'))) 'granola',
      if (names.any((n) => n.contains('mel'))) 'mel',
    ];
    final score = min(1.0, 0.5 + ings.length * 0.06);
    return [
      Recipe(
        id: _uuid.v4(),
        title: 'Tigela de Frutas',
        ingredients: ings,
        instructions: 'Pique as frutas, adicione iogurte/granola/mel a gosto. Sirva gelado.',
        score: score,
        category: 'Lanche',
      )
    ];
  }

  static List<Recipe> _dynamicStirFry(List<String> names) {
    final hasProtein = names.any((n) => n.contains('frango') || n.contains('carne') || n.contains('tofu') || n.contains('peixe'));
    final hasVeg = names.any((n) => n.contains('pimentão') || n.contains('cenoura') || n.contains('brócolis'));
    if (!(hasProtein && hasVeg)) return const [];
    final ings = <String>[
      if (names.any((n) => n.contains('frango'))) 'frango',
      if (names.any((n) => n.contains('carne'))) 'carne',
      if (names.any((n) => n.contains('tofu'))) 'tofu',
      if (names.any((n) => n.contains('peixe'))) 'peixe',
      if (names.any((n) => n.contains('pimentão'))) 'pimentão',
      if (names.any((n) => n.contains('cenoura'))) 'cenoura',
      if (names.any((n) => n.contains('brócolis'))) 'brócolis',
      if (names.any((n) => n.contains('shoyu'))) 'shoyu',
      if (names.any((n) => n.contains('alho'))) 'alho',
      if (names.any((n) => n.contains('óleo'))) 'óleo',
    ];
    final score =  (0.6 + ings.length * 0.05).clamp(0.0, 1.0);
    return [
      Recipe(
        id: _uuid.v4(),
        title: 'Refogado Rápido',
        ingredients: ings,
        instructions: 'Salteie proteína e legumes com óleo/alho. Finalize com shoyu. Sirva com arroz.',
        score: score,
        category: 'Jantar',
      )
    ];
  }
}

class _RecipeTemplate {
  final String title;
  final List<String> requiredKeywords;
  final List<String> optionalKeywords;
  final String category;
  final String instructions;

  const _RecipeTemplate({
    required this.title,
    required this.requiredKeywords,
    required this.optionalKeywords,
    required this.category,
    required this.instructions,
  });
}
