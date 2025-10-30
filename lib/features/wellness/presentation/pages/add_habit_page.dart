
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/wellness/presentation/providers/habit_providers.dart';

class AddHabitPage extends ConsumerStatefulWidget {
  const AddHabitPage({super.key});

  @override
  ConsumerState<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends ConsumerState<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  int _target = 1;

  @override
  Widget build(BuildContext context) {
    final addHabit = ref.read(addHabitProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Novo hábito')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Informe um título'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Meta/dia:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: _target,
                    items: List.generate(10, (i) => i + 1)
                        .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
                        .toList(),
                    onChanged: (v) => setState(() => _target = v ?? 1),
                  )
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  onPressed: () async {
                    if (_formKey.currentState?.validate() ?? false) {
                      await addHabit(_titleCtrl.text.trim(), _target);
                      if (mounted) Navigator.pop(context);
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
