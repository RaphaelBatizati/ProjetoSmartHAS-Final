
class FoodItem {
  final String id;
  final String name;
  final String? barcode;
  final String category;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime? expiry;
  final int quantity;

  const FoodItem({
    required this.id,
    required this.name,
    this.barcode,
    required this.category,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.expiry,
    required this.quantity,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? barcode,
    String? category,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    DateTime? expiry,
    int? quantity,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      expiry: expiry ?? this.expiry,
      quantity: quantity ?? this.quantity,
    );
  }

  factory FoodItem.fromJson(Map<String, dynamic> json) => FoodItem(
        id: json['id'] as String,
        name: json['name'] as String,
        barcode: json['barcode'] as String?,
        category: json['category'] as String,
        calories: (json['calories'] as num).toDouble(),
        protein: (json['protein'] as num).toDouble(),
        carbs: (json['carbs'] as num).toDouble(),
        fat: (json['fat'] as num).toDouble(),
        expiry: json['expiry'] == null ? null : DateTime.parse(json['expiry'] as String),
        quantity: json['quantity'] as int,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'barcode': barcode,
        'category': category,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'expiry': expiry?.toIso8601String(),
        'quantity': quantity,
      };
}
