// lib/core/services/settings_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsService {
  // Chaves para salvar os dados
  static const _themeKey = 'app_theme';
  static const _ratingKey = 'default_rating';
  static const _itemsPerPageKey = 'items_per_page';
  static const _saveHistoryKey = 'save_history';

  /// Carrega as configurações salvas do dispositivo.
  Future<Settings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carrega o tema, convertendo de String para AppTheme
    final themeName = prefs.getString(_themeKey) ?? AppTheme.dark.name;
    final theme = AppTheme.values.firstWhere((e) => e.name == themeName);

    // Carrega as outras configurações com valores padrão
    final rating = prefs.getString(_ratingKey) ?? 'g';
    final itemsPerPage = prefs.getInt(_itemsPerPageKey) ?? 24;
    final saveHistory = prefs.getBool(_saveHistoryKey) ?? true;

    return Settings(
      theme: theme,
      defaultRating: rating,
      itemsPerPage: itemsPerPage,
      saveHistory: saveHistory,
    );
  }

  /// Salva um novo objeto de configurações no dispositivo.
  Future<void> saveSettings(Settings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, settings.theme.name);
    await prefs.setString(_ratingKey, settings.defaultRating);
    await prefs.setInt(_itemsPerPageKey, settings.itemsPerPage);
    await prefs.setBool(_saveHistoryKey, settings.saveHistory);
  }
}