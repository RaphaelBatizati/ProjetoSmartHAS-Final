import 'package:flutter/material.dart';
import 'package:smarthas_flutter/smarthas_api.dart';

class SmartHasDemoScreen extends StatefulWidget {
  const SmartHasDemoScreen({super.key});

  @override
  State<SmartHasDemoScreen> createState() => _SmartHasDemoScreenState();
}

class _SmartHasDemoScreenState extends State<SmartHasDemoScreen> {
  final api = SmartHasApi(baseUrl: 'http://10.0.2.2:8080'); // Emulador → host
  String output = 'Pressione um botão para testar.';
  bool loading = false;

  Future<void> _safeRun(Future<void> Function() op) async {
    setState(() => loading = true);
    try { await op(); }
    catch (e) { setState(() => output = 'Erro: $e'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart HAS – Fase 6 Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(output),
            const SizedBox(height: 16),
            if (loading) const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => _safeRun(() async {
                    final v = await api.avgConsumption(sensorId: 1, days: 3);
                    setState(() => output = 'Avg kWh (3d) sensor 1: $v');
                  }),
                  child: const Text('Avg Consumption'),
                ),
                ElevatedButton(
                  onPressed: () => _safeRun(() async {
                    final v = await api.formatAlert(sensorId: 1, hours: 24);
                    setState(() => output = 'Alert JSON: $v');
                  }),
                  child: const Text('Format Alert'),
                ),
                ElevatedButton(
                  onPressed: () => _safeRun(() async {
                    await api.runAlerts(powerThresh: 900, tempThresh: 70);
                    setState(() => output = 'P_REGISTER_ALERTS executado.');
                  }),
                  child: const Text('Run Alerts'),
                ),
                ElevatedButton(
                  onPressed: () => _safeRun(() async {
                    await api.generateReport(userId: 1, days: 3);
                    setState(() => output = 'Resumo de consumo gerado.');
                  }),
                  child: const Text('Generate Report'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Dica: ajuste a baseUrl conforme seu ambiente. '
              'No emulador Android use 10.0.2.2 para acessar o host.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}