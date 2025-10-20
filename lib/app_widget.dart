// lib/app_widget.dart
import 'package:flutter/material.dart';
import 'features/home/home_page.dart';
import 'core/models/settings_model.dart'; // Importa o modelo

class GiphyRandomApp extends StatelessWidget {
  final Settings settings; // Recebe as configurações

  const GiphyRandomApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    // Converte nosso enum para o ThemeMode do Flutter
    final themeMode = switch (settings.theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      AppTheme.system => ThemeMode.system,
    };

    return MaterialApp(
      title: 'Buscador aleatório de GIF 2.0',
      debugShowCheckedModeBanner: false,
      // Aplica o tema
      themeMode: themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: Colors.teal,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
      ),
      home: const HomePage(),
    );
  }
}