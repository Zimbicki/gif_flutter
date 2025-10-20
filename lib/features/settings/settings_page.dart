// lib/features/settings/settings_page.dart
import 'package:flutter/material.dart';
import '../../core/models/settings_model.dart';
import '../../core/services/settings_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();
  late Future<Settings> _settingsFuture;

  // Variáveis para controlar os valores na UI
  late AppTheme _selectedTheme;
  late String _selectedRating;
  late int _selectedItemsPerPage;
  late bool _saveHistory;

  @override
  void initState() {
    super.initState();
    _settingsFuture = _loadAndSetInitialValues();
  }

  Future<Settings> _loadAndSetInitialValues() async {
    final settings = await _settingsService.loadSettings();
    setState(() {
      _selectedTheme = settings.theme;
      _selectedRating = settings.defaultRating;
      _selectedItemsPerPage = settings.itemsPerPage;
      _saveHistory = settings.saveHistory;
    });
    return settings;
  }

  Future<void> _saveSettings() async {
    final newSettings = Settings(
      theme: _selectedTheme,
      defaultRating: _selectedRating,
      itemsPerPage: _selectedItemsPerPage,
      saveHistory: _saveHistory,
    );
    await _settingsService.saveSettings(newSettings);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Configurações salvas! Algumas alterações podem exigir que o app seja reiniciado.')),
      );
      Navigator.of(context).pop(true); // Retorna 'true' para indicar que as configurações mudaram
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: FutureBuilder<Settings>(
        future: _settingsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildSettingsList();
        },
      ),
    );
  }

  Widget _buildSettingsList() {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        _buildSectionTitle('Aparência'),
        DropdownButtonFormField<AppTheme>(
          value: _selectedTheme,
          decoration: const InputDecoration(labelText: 'Tema'),
          items: const [
            DropdownMenuItem(value: AppTheme.light, child: Text('Claro')),
            DropdownMenuItem(value: AppTheme.dark, child: Text('Escuro')),
            DropdownMenuItem(value: AppTheme.system, child: Text('Padrão do Sistema')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedTheme = value);
          },
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('Busca'),
        DropdownButtonFormField<String>(
          value: _selectedRating,
          decoration: const InputDecoration(labelText: 'Classificação Padrão (Rating)'),
          items: const [
            DropdownMenuItem(value: 'g', child: Text('G (Livre)')),
            DropdownMenuItem(value: 'pg', child: Text('PG (Parental Guidance)')),
            DropdownMenuItem(value: 'pg-13', child: Text('PG-13 (Maiores de 13)')),
            DropdownMenuItem(value: 'r', child: Text('R (Restrito)')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedRating = value);
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          value: _selectedItemsPerPage,
          decoration: const InputDecoration(labelText: 'Resultados por Página'),
          items: const [
            DropdownMenuItem(value: 12, child: Text('12 GIFs')),
            DropdownMenuItem(value: 24, child: Text('24 GIFs')),
            DropdownMenuItem(value: 36, child: Text('36 GIFs')),
          ],
          onChanged: (value) {
            if (value != null) setState(() => _selectedItemsPerPage = value);
          },
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text('Salvar histórico de busca'),
          value: _saveHistory,
          onChanged: (value) {
            setState(() => _saveHistory = value);
          },
        ),
        const SizedBox(height: 32),
        FilledButton(
          onPressed: _saveSettings,
          child: const Text('Salvar'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}