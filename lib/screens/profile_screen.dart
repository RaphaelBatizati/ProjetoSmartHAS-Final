import 'package:flutter/material.dart';
import '../services/api_client.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();

  int? _userId;
  bool _saving = false;
  String? _calcPreview;

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(()=> _saving = true);
    try {
      final payload = {
        'userId': _userId,
        'name': _name.text.trim(),
        'age': int.tryParse(_age.text),
        'weightKg': double.tryParse(_weight.text.replaceAll(',', '.')),
        'targetCalories': int.tryParse(_target.text),
      };
      final resp = await ApiClient.upsertProfile(payload);
      if (resp['userId'] != null) {
        _userId = (resp['userId'] as num).toInt();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil salvo!')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro: $e')));
    } finally {
      setState(()=> _saving = false);
    }
  }

  Future<void> _calc() async {
    final age = int.tryParse(_age.text) ?? 30;
    final weight = double.tryParse(_weight.text.replaceAll(',', '.')) ?? 70.0;
    final r = await ApiClient.calcCalories(age, weight);
    setState(() {
      _calcPreview = "BMR estimado: ${r['bmrEstimate']} kcal/dia\n${r['suggestion']}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil & Meta de Dieta')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Nome'),
              validator: (v)=> (v==null || v.trim().isEmpty) ? 'Informe o nome' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _age,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Idade'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _weight,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _target,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Meta de Calorias (kcal/dia)'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar Perfil'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _calc,
                  icon: const Icon(Icons.calculate),
                  label: const Text('Calcular BMR'),
                ),
              ],
            ),
            if (_calcPreview != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(_calcPreview!),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}