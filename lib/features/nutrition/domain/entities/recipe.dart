class Recipe {
  final String id;
  final String title;
  final List<String> ingredients;
  final String instructions;
  final List<String> tags;
  /// Score from 0.0 to 1.0 representing how well this recipe matches the pantry/user.
  final double score;
  /// High-level category such as 'Almoço', 'Jantar', 'Lanche' etc.
  final String category;

  const Recipe({
    required this.id,
    required this.title,
    required this.ingredients,
    required this.instructions,
    this.tags = const [],
    required this.score,
    required this.category,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
        id: json['id'] as String,
        title: json['title'] as String,
        ingredients: (json['ingredients'] as List).cast<String>(),
        instructions: json['instructions'] as String,
        tags: (json['tags'] as List?)?.cast<String>() ?? const [],
        score: (json['score'] is num) ? (json['score'] as num).toDouble() : 0.0,
        category: (json['category'] as String?) ?? 'Geral',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'ingredients': ingredients,
        'instructions': instructions,
        'tags': tags,
        'score': score,
        'category': category,
      };
}