
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/wellness/domain/entities/habit.dart';
import 'package:smarthas_flutter/features/wellness/presentation/providers/habit_providers.dart';

class HabitCard extends ConsumerWidget {
  final Habit habit;
  const HabitCard({super.key, required this.habit});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final complete = ref.read(completeHabitProvider);
    final reload = ref.read(habitListProvider.notifier).refresh;

    final progress = habit.targetPerDay == 0
        ? 0.0
        : habit.doneToday / habit.targetPerDay;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(habit.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress.clamp(0.0, 1.0)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Hoje: ${habit.doneToday}/${habit.targetPerDay}'),
                FilledButton.icon(
                  onPressed: habit.doneToday >= habit.targetPerDay
                      ? null
                      : () async {
                          await complete(habit.id);
                          await reload();
                        },
                  icon: const Icon(Icons.check),
                  label: const Text('Concluir'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
