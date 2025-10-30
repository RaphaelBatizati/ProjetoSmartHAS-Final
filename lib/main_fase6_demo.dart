import 'package:flutter/material.dart';
import 'package:smarthas_flutter/smarthas_demo_screen.dart';

void main() {
  runApp(const SmartHasApp());
}

class SmartHasApp extends StatelessWidget {
  const SmartHasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart HAS',
      home: SmartHasDemoScreen(),
    );
  }
}