
import 'package:uuid/uuid.dart';
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/wellness/domain/repositories/habit_repository.dart';

class AddHabit {
  final HabitRepository repo;
  AddHabit(this.repo);

  Future<void> call(String title, int targetPerDay) async {
    final id = const Uuid().v4();
    final habit = Habit(
      id: id,
      title: title,
      targetPerDay: targetPerDay,
      doneToday: 0,
      createdAt: DateTime.now(),
      isActive: true,
    );
    await repo.addHabit(habit);
  }
}
