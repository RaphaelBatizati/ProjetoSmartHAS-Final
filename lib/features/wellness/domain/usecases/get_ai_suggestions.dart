
import 'package:smarthas_flutter/features/wellness/domain/repositories/habit_repository.dart';

class GetAISuggestions {
  final HabitRepository repo;
  GetAISuggestions(this.repo);

  Future<List<Map<String, dynamic>>> call() => repo.getAISuggestions();
}
