// lib/main.dart
import 'package:flutter/material.dart';
import 'app_widget.dart';
import 'core/models/settings_model.dart'; // Importa o modelo
import 'core/services/settings_service.dart'; // Importa o serviço

void main() async {
  // Garante que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega as configurações antes de rodar o app
  final settings = await SettingsService().loadSettings();

  runApp(GiphyRandomApp(settings: settings)); // Passa as configurações para o widget
}