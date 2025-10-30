// lib/features/indicators/indicator_page.dart
import 'package:flutter/material.dart';
import 'package:smarthas_flutter/core/api_client.dart';

class IndicatorPage extends StatefulWidget {
  const IndicatorPage({super.key});

  @override
  State<IndicatorPage> createState() => _IndicatorPageState();
}

class _IndicatorPageState extends State<IndicatorPage> {
  final api = ApiClient(); // 10.0.2.2 -> backend local
  String output = '';
  bool loading = false;

  Future<void> _run() async {
    setState(() { loading = true; output = 'Executando...'; });
    try {
      final kcal = await api.dailyCalories(1, '2025-09-20');
      final bmi  = await api.bmiSummary(1);
      final rep  = await api.consumptionReport(1, '2025-09-18', '2025-09-22');
      final alert = await api.postReading(1001, 160.0);
      setState(() {
        output = 'kcal=$kcal\n$bmi\nreport(dias)=${rep.length}\nalertId=${alert['alertId']}';
      });
    } catch (e) {
      setState(() { output = 'Erro: $e'; });
    } finally {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicadores (Oracle + Spring)')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: loading ? null : _run,
              child: Text(loading ? 'Rodando...' : 'Executar testes'),
            ),
            const SizedBox(height: 12),
            Expanded(child: SingleChildScrollView(child: Text(output))),
          ],
        ),
      ),
    );
  }
}
