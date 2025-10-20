// lib/core/models/settings_model.dart
import 'package:flutter/material.dart';

// Usamos um enum para o tema para maior segurança de tipo.
enum AppTheme { light, dark, system }

class Settings {
  final AppTheme theme;
  final String defaultRating;
  final int itemsPerPage;
  final bool saveHistory;

  Settings({
    this.theme = AppTheme.dark,
    this.defaultRating = 'g',
    this.itemsPerPage = 24,
    this.saveHistory = true,
  });

  Settings copyWith({
    AppTheme? theme,
    String? defaultRating,
    int? itemsPerPage,
    bool? saveHistory,
  }) {
    return Settings(
      theme: theme ?? this.theme,
      defaultRating: defaultRating ?? this.defaultRating,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
      saveHistory: saveHistory ?? this.saveHistory,
    );
  }
}