// lib/app_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/navigation/main_navigation.dart';
import 'core/models/settings_model.dart';
import 'core/theme/app_theme.dart' as theme;

class GiphyRandomApp extends StatelessWidget {
  final Settings settings;

  const GiphyRandomApp({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    // Converte nosso enum para o ThemeMode do Flutter
    final themeMode = switch (settings.theme) {
      AppTheme.light => ThemeMode.light,
      AppTheme.dark => ThemeMode.dark,
      AppTheme.system => ThemeMode.system,
    };

    // Configura a UI do sistema (status bar, etc)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'GIF Gallery',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: theme.AppTheme.lightTheme,
      darkTheme: theme.AppTheme.darkTheme,
      home: const MainNavigation(),
    );
  }
}