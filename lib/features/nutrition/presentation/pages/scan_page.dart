
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:uuid/uuid.dart';
import 'package:smarthas_flutter/features/nutrition/domain/entities/food_item.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/providers/nutrition_providers.dart';

class ScanPage extends ConsumerStatefulWidget {
  const ScanPage({super.key});

  @override
  ConsumerState<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends ConsumerState<ScanPage> {
  bool _handled = false;

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(nutritionRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leitor de Barras')),
      body: MobileScanner(
        onDetect: (capture) async {
          if (_handled) return;
          final barcodes = capture.barcodes;
          if (barcodes.isEmpty) return;
          final raw = barcodes.first.rawValue;
          if (raw == null || raw.isEmpty) return;

          _handled = true;
          final found = await repo.findByBarcode(raw);
          if (!mounted) return;

          if (found != null) {
            _showConfirm(context, found);
          } else {
            _showManual(context, raw);
          }
        },
      ),
    );
  }

  void _showConfirm(BuildContext context, FoodItem item) {
    final repo = ref.read(nutritionRepositoryProvider);
    final qtyCtrl = TextEditingController(text: '1');
    DateTime? expiry;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(item.name, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('${item.category} • ${item.calories.toStringAsFixed(0)} kcal'),
            const SizedBox(height: 16),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantidade'),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: ctx,
                        firstDate: now,
                        lastDate: DateTime(now.year + 5),
                        initialDate: now,
                      );
                      if (picked != null) {
                        expiry = picked;
                      }
                    },
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Validade (opcional)'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  final qty = int.tryParse(qtyCtrl.text) ?? 1;
                  final save = item.copyWith(quantity: qty, expiry: expiry);
                  await repo.addOrUpdate(save);
                  if (mounted) Navigator.pop(ctx);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Adicionar à despensa'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).whenComplete(() => _handled = false);
  }

  void _showManual(BuildContext context, String barcode) {
    final repo = ref.read(nutritionRepositoryProvider);
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final catCtrl = TextEditingController(text: 'Outros');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 16,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Produto não encontrado', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              TextField(decoration: const InputDecoration(labelText: 'Nome'), controller: nameCtrl),
              TextField(decoration: const InputDecoration(labelText: 'Categoria'), controller: catCtrl),
              TextField(decoration: const InputDecoration(labelText: 'Quantidade'), controller: qtyCtrl, keyboardType: TextInputType.number),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final item = FoodItem(
                      id: const Uuid().v4(),
                      name: nameCtrl.text.trim().isEmpty ? 'Item $barcode' : nameCtrl.text.trim(),
                      barcode: barcode,
                      category: catCtrl.text.trim().isEmpty ? 'Outros' : catCtrl.text.trim(),
                      calories: 0, protein: 0, carbs: 0, fat: 0,
                      expiry: null,
                      quantity: int.tryParse(qtyCtrl.text) ?? 1,
                    );
                    await repo.addOrUpdate(item);
                    if (mounted) Navigator.pop(ctx);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text('Adicionar manualmente'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    ).whenComplete(() => _handled = false);
  }
}
