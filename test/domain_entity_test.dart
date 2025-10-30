
import 'package:flutter_test/flutter_test.dart';
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';

void main() {
  test('Habit copyWith should preserve and override fields', () {
    final h = Habit(
      id: '1',
      title: 'Água',
      targetPerDay: 8,
      doneToday: 0,
      createdAt: DateTime(2024, 1, 1),
      isActive: true,
    );
    final h2 = h.copyWith(doneToday: 3);
    expect(h2.doneToday, 3);
    expect(h2.title, 'Água');
  });
}
