
import 'package:flutter/material.dart';
import 'package:smarthas_flutter/core/theme/app_theme.dart';
import 'package:smarthas_flutter/features/wellness/presentation/pages/home_page.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/pages/pantry_page.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/pages/food_suggestions_page.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/pages/recipes_page.dart';
import 'package:smarthas_flutter/features/nutrition/presentation/pages/profile_page.dart';

class SmartHasApp extends StatefulWidget {
  const SmartHasApp({super.key});

  @override
  State<SmartHasApp> createState() => _SmartHasAppState();
}

class _SmartHasAppState extends State<SmartHasApp> {
  int _index = 0;
  final _pages = const [
    HomePage(),
    PantryPage(),
    FoodSuggestionsPage(),
    RecipesPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart HAS',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: Scaffold(
        body: _pages[_index],
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          destinations: const [
            NavigationDestination(icon: Icon(Icons.task_alt), label: 'Hábitos'),
            NavigationDestination(icon: Icon(Icons.kitchen), label: 'Despensa'),
            NavigationDestination(icon: Icon(Icons.eco), label: 'Sugestões'),
            NavigationDestination(icon: Icon(Icons.restaurant), label: 'Receitas'),
            NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
          ],
          onDestinationSelected: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}
