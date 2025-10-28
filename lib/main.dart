// lib/main.dart
import 'package:flutter/material.dart';
import 'app_widget.dart';
import 'core/services/settings_service.dart';

void main() async {
  // Garante que os bindings do Flutter foram inicializados
  WidgetsFlutterBinding.ensureInitialized();
  
  // Carrega as configurações antes de rodar o app
  final settings = await SettingsService().loadSettings();

  runApp(GiphyRandomApp(settings: settings));
}