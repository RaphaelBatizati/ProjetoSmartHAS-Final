
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/wellness/presentation/providers/habit_providers.dart';

class InsightsPage extends ConsumerWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = ref.read(getAISuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: FutureBuilder(
        future: usecase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }
          final data = snapshot.data ?? [];
          if (data.isEmpty) {
            return const Center(child: Text('Sem sugestões no momento.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) {
              final s = data[i];
              return ListTile(
                leading: const Icon(Icons.insights),
                title: Text(s['title'] as String),
                subtitle: Text(s['reason'] as String),
                trailing: Text('${((s['score'] as num) * 100).toStringAsFixed(0)}%'),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: data.length,
          );
        },
      ),
    );
  }
}
