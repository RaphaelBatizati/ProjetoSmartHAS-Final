
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/wellness/data/datasources/local_habit_data_source.dart';
import 'package:smarthas_flutter/features/wellness/data/datasources/remote_habit_data_source.dart';
import 'package:smarthas_flutter/features/wellness/data/repositories/habit_repository_impl.dart';
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/wellness/domain/usecases/add_habit.dart';
import 'package:smarthas_flutter/features/wellness/domain/usecases/complete_habit.dart';
import 'package:smarthas_flutter/features/wellness/domain/usecases/get_ai_suggestions.dart';
import 'package:smarthas_flutter/features/wellness/domain/usecases/get_habits.dart';

// Infra
final _localDSProvider = Provider((ref) => LocalHabitDataSource());
final _remoteDSProvider = Provider((ref) => RemoteHabitDataSource());
final habitRepositoryProvider = Provider((ref) => HabitRepositoryImpl(
      local: ref.read(_localDSProvider),
      remote: ref.read(_remoteDSProvider),
    ));

// Use cases
final getHabitsProvider =
    Provider((ref) => GetHabits(ref.read(habitRepositoryProvider)));
final addHabitProvider =
    Provider((ref) => AddHabit(ref.read(habitRepositoryProvider)));
final completeHabitProvider =
    Provider((ref) => CompleteHabit(ref.read(habitRepositoryProvider)));
final getAISuggestionsProvider =
    Provider((ref) => GetAISuggestions(ref.read(habitRepositoryProvider)));

// State
class HabitListNotifier extends StateNotifier<AsyncValue<List<Habit>>> {
  final GetHabits _getHabits;
  HabitListNotifier(this._getHabits) : super(const AsyncLoading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    try {
      final items = await _getHabits();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final habitListProvider =
    StateNotifierProvider<HabitListNotifier, AsyncValue<List<Habit>>>(
        (ref) => HabitListNotifier(ref.read(getHabitsProvider)));
