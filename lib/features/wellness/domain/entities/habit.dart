
class Habit {
  final String id;
  final String title;
  final int targetPerDay;
  final int doneToday;
  final DateTime createdAt;
  final bool isActive;

  const Habit({
    required this.id,
    required this.title,
    required this.targetPerDay,
    required this.doneToday,
    required this.createdAt,
    required this.isActive,
  });

  Habit copyWith({
    String? id,
    String? title,
    int? targetPerDay,
    int? doneToday,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      targetPerDay: targetPerDay ?? this.targetPerDay,
      doneToday: doneToday ?? this.doneToday,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as String,
      title: json['title'] as String,
      targetPerDay: json['targetPerDay'] as int,
      doneToday: json['doneToday'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'targetPerDay': targetPerDay,
        'doneToday': doneToday,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };
}
