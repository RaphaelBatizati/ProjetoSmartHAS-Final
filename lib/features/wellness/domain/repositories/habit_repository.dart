
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';

abstract class HabitRepository {
  Future<List<Habit>> getHabits();
  Future<void> addHabit(Habit habit);
  Future<void> completeHabit(String id);
  Future<List<Map<String, dynamic>>> getAISuggestions();
}
