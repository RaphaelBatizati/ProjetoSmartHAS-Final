
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/providers/nutrition_providers.dart';

class FoodSuggestionsPage extends ConsumerWidget {
  const FoodSuggestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(foodSuggestionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sugestões Saudáveis')),
      body: asyncList.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Sem sugestões no momento. Ajuste seus hábitos ou perfil.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemBuilder: (_, i) {
              final f = items[i];
              return ListTile(
                leading: const Icon(Icons.eco),
                title: Text(f.name),
                subtitle: Text('${f.category} • ${f.calories.toStringAsFixed(0)} kcal • Prot: ${f.protein}g'),
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: items.length,
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
