
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/wellness/presentation/providers/habit_providers.dart';
import 'package:smarthas_flutter/features/wellness/presentation/widgets/habit_card.dart';
import 'package:smarthas_flutter/features/wellness/presentation/pages/add_habit_page.dart';
import 'package:smarthas_flutter/features/wellness/presentation/pages/insights_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart HAS'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const InsightsPage()),
            ),
          )
        ],
      ),
      body: habits.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'Você ainda não tem hábitos. Adicione seu primeiro!',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) => HabitCard(habit: items[i]),
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemCount: items.length,
          );
        },
        error: (e, _) => Center(child: Text('Erro: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddHabitPage()),
        ).then((_) => ref.read(habitListProvider.notifier).refresh()),
        child: const Icon(Icons.add),
      ),
    );
  }
}
