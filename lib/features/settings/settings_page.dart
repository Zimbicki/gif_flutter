// lib/features/settings/settings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/models/settings_model.dart';
import '../../core/services/settings_service.dart';
import '../../core/widgets/gradient_app_bar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _settingsService = SettingsService();
  late Future<Settings> _settingsFuture;

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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Configurações salvas com sucesso!')),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      
      // Aguarda um pouco antes de voltar para dar tempo de ver o snackbar
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const GradientAppBar(
        title: '⚙️ Configurações',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSettingCard(
            title: '🎨 Aparência',
            children: [
              _buildThemeSelector(),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 16),
          
          _buildSettingCard(
            title: '🔍 Busca',
            children: [
              _buildRatingSelector(),
              const SizedBox(height: 16),
              _buildItemsPerPageSelector(),
              const SizedBox(height: 16),
              _buildHistorySwitch(),
            ],
          ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 32),
          
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.save),
              label: const Text('Salvar Configurações'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).scale(),
        ],
      ),
    );
  }

  Widget _buildSettingCard({required String title, required List<Widget> children}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildThemeSelector() {
    return Column(
      children: [
        RadioListTile<AppTheme>(
          title: const Text('☀️ Claro'),
          value: AppTheme.light,
          groupValue: _selectedTheme,
          onChanged: (value) {
            if (value != null) setState(() => _selectedTheme = value);
          },
        ),
        RadioListTile<AppTheme>(
          title: const Text('🌙 Escuro'),
          value: AppTheme.dark,
          groupValue: _selectedTheme,
          onChanged: (value) {
            if (value != null) setState(() => _selectedTheme = value);
          },
        ),
        RadioListTile<AppTheme>(
          title: const Text('📱 Sistema'),
          value: AppTheme.system,
          groupValue: _selectedTheme,
          onChanged: (value) {
            if (value != null) setState(() => _selectedTheme = value);
          },
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return DropdownButtonFormField<String>(
      value: _selectedRating,
      decoration: const InputDecoration(
        labelText: 'Classificação Padrão',
        prefixIcon: Icon(Icons.shield),
      ),
      items: const [
        DropdownMenuItem(value: 'g', child: Text('G (Livre)')),
        DropdownMenuItem(value: 'pg', child: Text('PG (Parental Guidance)')),
        DropdownMenuItem(value: 'pg-13', child: Text('PG-13 (Maiores de 13)')),
        DropdownMenuItem(value: 'r', child: Text('R (Restrito)')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedRating = value);
      },
    );
  }

  Widget _buildItemsPerPageSelector() {
    return DropdownButtonFormField<int>(
      value: _selectedItemsPerPage,
      decoration: const InputDecoration(
        labelText: 'Resultados por Página',
        prefixIcon: Icon(Icons.grid_view),
      ),
      items: const [
        DropdownMenuItem(value: 12, child: Text('12 GIFs')),
        DropdownMenuItem(value: 24, child: Text('24 GIFs')),
        DropdownMenuItem(value: 36, child: Text('36 GIFs')),
        DropdownMenuItem(value: 48, child: Text('48 GIFs')),
      ],
      onChanged: (value) {
        if (value != null) setState(() => _selectedItemsPerPage = value);
      },
    );
  }

  Widget _buildHistorySwitch() {
    return SwitchListTile(
      title: const Text('Salvar histórico de busca'),
      subtitle: const Text('Manter registro das suas pesquisas'),
      secondary: const Icon(Icons.history),
      value: _saveHistory,
      onChanged: (value) {
        setState(() => _saveHistory = value);
      },
    );
  }
}