
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/wellness/domain/repositories/habit_repository.dart';
import 'package:smarthas_flutter/features/wellness/data/datasources/local_habit_data_source.dart';
import 'package:smarthas_flutter/features/wellness/data/datasources/remote_habit_data_source.dart';

class HabitRepositoryImpl implements HabitRepository {
  final LocalHabitDataSource local;
  final RemoteHabitDataSource remote;
  HabitRepositoryImpl({required this.local, required this.remote});

  @override
  Future<void> addHabit(Habit habit) async {
    final current = await local.getHabits();
    final updated = List<Habit>.from(current)..add(habit);
    await local.saveHabits(updated);
  }

  @override
  Future<void> completeHabit(String id) async {
    final current = await local.getHabits();
    final updated = current.map((h) {
      if (h.id == id) {
        final newDone = (h.doneToday + 1).clamp(0, h.targetPerDay);
        return h.copyWith(doneToday: newDone);
      }
      return h;
    }).toList();
    await local.saveHabits(updated);
  }

  @override
  Future<List<Habit>> getHabits() => local.getHabits();

  @override
  Future<List<Map<String, dynamic>>> getAISuggestions() =>
      remote.getAISuggestions();
}
