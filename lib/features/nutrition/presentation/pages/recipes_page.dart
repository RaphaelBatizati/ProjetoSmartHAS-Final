
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/recipe.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/providers/nutrition_providers.dart';

class RecipesPage extends ConsumerWidget {
  const RecipesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(pantryListProvider);
    final repo = ref.read(nutritionRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receitas')),
      body: pantryAsync.when(
        data: (pantry) => FutureBuilder<List<Recipe>>(
          future: repo.recipesForPantry(pantry),
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Erro: ${snap.error}'));
            }
            final list = snap.data ?? [];
            if (list.isEmpty) {
              return const Center(child: Text('Nenhuma receita compatível com sua despensa.'));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (_, i) {
                final r = list[i];
                return ExpansionTile(
                  title: Text(r.title),
                  subtitle: Text(r.tags.join(' • ')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ingredientes:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ...r.ingredients.map((ing) => Text('• $ing')),
                          const SizedBox(height: 12),
                          Text('Modo de preparo:', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          Text(r.instructions),
                        ],
                      ),
                    )
                  ],
                );
              },
              separatorBuilder: (_, __) => const Divider(),
              itemCount: list.length,
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
      ),
    );
  }
}
