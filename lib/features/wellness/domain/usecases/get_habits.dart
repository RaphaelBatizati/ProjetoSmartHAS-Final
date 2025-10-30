
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/wellness/domain/repositories/habit_repository.dart';

class GetHabits {
  final HabitRepository repo;
  GetHabits(this.repo);

  Future<List<Habit>> call() => repo.getHabits();
}
