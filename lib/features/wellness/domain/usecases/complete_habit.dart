
import 'package:smarthas_flutter/features/wellness/domain/repositories/habit_repository.dart';

class CompleteHabit {
  final HabitRepository repo;
  CompleteHabit(this.repo);

  Future<void> call(String id) => repo.completeHabit(id);
}
