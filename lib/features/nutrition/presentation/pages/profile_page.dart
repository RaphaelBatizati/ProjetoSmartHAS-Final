
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/providers/nutrition_providers.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  String _goal = 'general';
  String _diet = 'omnivore';
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    () async {
      final p = await ref.read(profileDSProvider).getProfile();
      setState(() {
        _goal = p['goal'] ?? 'general';
        _diet = p['diet'] ?? 'omnivore';
        _loaded = true;
      });
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil & Objetivos')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Objetivo', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _goal,
                    items: const [
                      DropdownMenuItem(value: 'general', child: Text('Saúde geral')),
                      DropdownMenuItem(value: 'weight_loss', child: Text('Emagrecimento')),
                      DropdownMenuItem(value: 'muscle_gain', child: Text('Ganho de massa')),
                    ],
                    onChanged: (v) => setState(() => _goal = v ?? 'general'),
                  ),
                  const SizedBox(height: 16),
                  Text('Dieta', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    value: _diet,
                    items: const [
                      DropdownMenuItem(value: 'omnivore', child: Text('Onívoro')),
                      DropdownMenuItem(value: 'vegetarian', child: Text('Vegetariano')),
                      DropdownMenuItem(value: 'vegan', child: Text('Vegano')),
                    ],
                    onChanged: (v) => setState(() => _diet = v ?? 'omnivore'),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save),
                      label: const Text('Salvar preferências'),
                      onPressed: () async {
                        await ref.read(profileDSProvider).saveProfile(_goal, _diet);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Preferências salvas!')),
                          );
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
