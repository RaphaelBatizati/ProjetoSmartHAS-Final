import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:uuid/uuid.dart';

import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/pages/scan_page.dart';

class PantryPage extends ConsumerWidget {
  const PantryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(pantryListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Despensa')),
      body: pantryAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Sua despensa está vazia.\n\nUse “Adicionar” para ler o código de barras/QR '
                      'ou incluir itens manualmente.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final it = items[index];
              final expireText = it.expiry != null
                  ? 'Vence: ${it.expiry!.toLocal().toString().split(' ').first}'
                  : 'Sem validade';
              return ListTile(
                title: Text(it.name),
                subtitle: Text('${it.category} • Qtd: ${it.quantity} • $expireText'),
                trailing: it.barcode != null
                    ? const Icon(Icons.qr_code_2)
                    : const Icon(Icons.edit_note),
              );
            },
          );
        },
        error: (e, st) => Center(child: Text('Erro ao carregar: $e')),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddOptions(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Adicionar'),
      ),
    );
  }

  void _openAddOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('Ler código de barras / QR'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanPage()),
                  );
                  ref.invalidate(pantryListProvider);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Adicionar manualmente'),
                onTap: () {
                  Navigator.pop(ctx);
                  _showManual(context, ref);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showManual(BuildContext context, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final caloriesCtrl = TextEditingController();
    final proteinCtrl = TextEditingController();
    final carbsCtrl = TextEditingController();
    final fatCtrl = TextEditingController();

    final categories = <String>[
      'Grãos',
      'Laticínios',
      'Hortifruti',
      'Carnes',
      'Bebidas',
      'Enlatados',
      'Snacks',
      'Padaria',
      'Condimentos',
      'Outros',
    ];
    String selectedCategory = categories.last;
    DateTime? expiry;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Adicionar item manualmente',
                    style: Theme.of(ctx).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome do produto',
                      prefixIcon: Icon(Icons.shopping_bag_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    items: categories
                        .map((c) => DropdownMenuItem<String>(
                      value: c,
                      child: Text(c),
                    ))
                        .toList(),
                    onChanged: (val) {
                      if (val == null) return;
                      setSheetState(() => selectedCategory = val);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Categoria',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: qtyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Quantidade',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: false),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: caloriesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Calorias (kcal) (opcional)',
                      prefixIcon: Icon(Icons.local_fire_department_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: proteinCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Proteínas (g) (opcional)',
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: carbsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Carboidratos (g) (opcional)',
                      prefixIcon: Icon(Icons.energy_savings_leaf_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: fatCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Gorduras (g) (opcional)',
                      prefixIcon: Icon(Icons.oil_barrel_outlined),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
                          initialDate: DateTime.now(),
                          helpText: 'Selecionar validade',
                        );
                        if (picked != null) {
                          setSheetState(() {
                            expiry = DateTime(picked.year, picked.month, picked.day);
                          });
                        }
                      },
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        expiry == null
                            ? 'Validade (opcional)'
                            : 'Vence: ${expiry!.toLocal().toString().split(' ').first}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final qty = int.tryParse(qtyCtrl.text) ?? 1;

                        final calories = double.tryParse(
                          caloriesCtrl.text.replaceAll(',', '.'),
                        ) ??
                            0.0;
                        final protein = double.tryParse(
                          proteinCtrl.text.replaceAll(',', '.'),
                        ) ??
                            0.0;
                        final carbs = double.tryParse(
                          carbsCtrl.text.replaceAll(',', '.'),
                        ) ??
                            0.0;
                        final fat = double.tryParse(
                          fatCtrl.text.replaceAll(',', '.'),
                        ) ??
                            0.0;

                        if (name.isEmpty) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Informe o nome do produto.')),
                          );
                          return;
                        }
                        if (qty <= 0) {
                          ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Quantidade deve ser maior que zero.')),
                          );
                          return;
                        }

                        try {
                          final repo = ref.read(nutritionRepositoryProvider);
                          final item = FoodItem(
                            id: const Uuid().v4(),
                            name: name,
                            category: selectedCategory,
                            quantity: qty,
                            expiry: expiry,
                            calories: calories,
                            protein: protein,
                            carbs: carbs,
                            fat: fat,
                            barcode: null,
                          );

                          await repo.addOrUpdate(item);
                          ref.invalidate(pantryListProvider);

                          if (ctx.mounted) Navigator.pop(ctx);
                        } catch (e, st) {
                          // ignore: avoid_print
                          print('Erro ao salvar item: $e\n$st');
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(content: Text('Erro ao salvar: $e')),
                            );
                          }
                        }
                      },
                      child: const Text('Salvar'),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
