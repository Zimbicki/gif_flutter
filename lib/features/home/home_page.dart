// lib/features/home/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/settings_model.dart'; 
import '../../core/services/favorites_service.dart';
import '../../core/services/giphy_service.dart';
import '../../core/services/settings_service.dart';
import '../favorites/favorites_page.dart';
import '../settings/settings_page.dart';
import 'widgets/gif_display.dart';

const String _historyKey = 'search_history';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _giphyService = GiphyService();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  // Variáveis de estado da UI
  bool _loading = false;
  List<dynamic> _gifs = [];
  String _rating = 'g';
  String? _error;

  // Debounce e Histórico
  Timer? _debounce;
  List<String> _searchHistory = [];
  bool _isHistoryVisible = false;

  // Favoritos
  final _favoritesService = FavoritesService();
  Set<String> _favoriteIds = {};

  // --- Variáveis para Configurações ---
  final _settingsService = SettingsService();
  late Settings _currentSettings;
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData(); // Função unificada para carregar tudo
    _searchFocusNode.addListener(() {
      setState(() {
        _isHistoryVisible = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    // Carrega as configurações primeiro
    final settings = await _settingsService.loadSettings();
    if (mounted) {
      setState(() {
        _currentSettings = settings;
        _rating = _currentSettings.defaultRating; // Aplica o rating padrão
        _settingsLoaded = true;
      });

      // Carrega o histórico somente se a opção estiver ativada
      if (_currentSettings.saveHistory) {
        await _loadSearchHistory();
      } else {
        // Se a opção estiver desativada, limpa o histórico
        setState(() => _searchHistory = []);
        await _saveSearchHistory(); // Salva a lista vazia para limpar o disco
      }

      await _loadFavorites();
      await _performSearch(query: '');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query: query);
    });
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList(_historyKey) ?? [];
    });
  }

  Future<void> _saveSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _searchHistory);
  }

  void _addToHistory(String term) {
    if (term.trim().isEmpty) return;

    // --- Aplica a configuração de salvar histórico ---
    if (!_currentSettings.saveHistory) return;

    _searchHistory.removeWhere((item) => item.toLowerCase() == term.toLowerCase());
    _searchHistory.insert(0, term);
    if (_searchHistory.length > 10) {
      _searchHistory = _searchHistory.sublist(0, 10);
    }
    _saveSearchHistory();
  }

  Future<void> _loadFavorites() async {
    final favorites = await _favoritesService.getFavorites();
    if (mounted) {
      setState(() {
        _favoriteIds = favorites.map((fav) => fav['id'] as String).toSet();
      });
    }
  }

  Future<void> _toggleFavorite(Map<String, dynamic> gifData) async {
    final gifId = gifData['id'] as String;
    final isCurrentlyFavorite = _favoriteIds.contains(gifId);

    if (isCurrentlyFavorite) {
      await _favoritesService.removeFavorite(gifId);
    } else {
      await _favoritesService.addFavorite(gifData);
    }

    setState(() {
      if (isCurrentlyFavorite) {
        _favoriteIds.remove(gifId);
      } else {
        _favoriteIds.add(gifId);
      }
    });
  }

  Future<void> _navigateToFavorites() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FavoritesPage()),
    );
    _loadFavorites();
  }

  // Navega para a página de configurações e recarrega ao voltar
  Future<void> _navigateToSettings() async {
    final settingsChanged = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );

    // Se a página de configurações retornou 'true', recarregamos tudo
    if (settingsChanged == true && mounted) {
      _loadInitialData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configurações aplicadas!')),
      );
    }
  }

  Future<void> _performSearch({String? query}) async {
    // Garante que as configurações foram carregadas antes de fazer a busca
    if (!_settingsLoaded) return;

    final searchTerm = query ?? _searchController.text;
    if (searchTerm.isNotEmpty) {
      _addToHistory(searchTerm);
    }
    _searchFocusNode.unfocus();
    setState(() => _loading = true);

    try {
      final results = await _giphyService.searchGifs(
        query: searchTerm,
        rating: _rating,
        // --- Aplica o número de itens por página ---
        limit: _currentSettings.itemsPerPage,
      );
      setState(() {
        _gifs = results;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _gifs = [];
      });
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onRatingChanged(String? newValue) {
    if (newValue == null) return;
    setState(() => _rating = newValue);
    _performSearch();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de GIF 2.0'),
        actions: [
          IconButton(
            tooltip: 'Favoritos',
            icon: const Icon(Icons.favorite),
            onPressed: _navigateToFavorites,
          ),
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings),
            onPressed: _navigateToSettings, // <--- ATUALIZADO
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(child: _buildContentArea()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: const InputDecoration(
                labelText: 'Procurar por GIFs',
                border: OutlineInputBorder(),
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _performSearch(),
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<String>(
            value: _rating,
            onChanged: _onRatingChanged,
            items: const [
              DropdownMenuItem(value: 'g', child: Text('G')),
              DropdownMenuItem(value: 'pg', child: Text('PG')),
              DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
              DropdownMenuItem(value: 'r', child: Text('R')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isHistoryVisible && _searchHistory.isNotEmpty) {
      return _buildHistoryList();
    }
    return _buildGifGrid();
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      itemCount: _searchHistory.length,
      itemBuilder: (context, index) {
        final term = _searchHistory[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(term),
          onTap: () {
            _searchController.text = term;
            _performSearch(query: term);
          },
        );
      },
    );
  }

  Widget _buildGifGrid() {
    if (!_settingsLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Erro: $_error', textAlign: TextAlign.center),
        ),
      );
    }
    if (_gifs.isEmpty) {
      return const Center(
        child: Text('Nenhum GIF encontrado.\nTente uma nova busca!'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _gifs.length,
      itemBuilder: (context, index) {
        final gifData = _gifs[index] as Map<String, dynamic>;
        final images = (gifData['images'] ?? {}) as Map<String, dynamic>;
        final fixedWidth =
            (images['fixed_width'] ?? {}) as Map<String, dynamic>;
        final url = fixedWidth['url'] as String?;
        final gifId = gifData['id'] as String;

        if (url == null) return const Card(child: Icon(Icons.broken_image));

        final analytics = (gifData['analytics'] ?? {}) as Map<String, dynamic>;
        final onload = (analytics['onload']?['url']) as String?;
        final onclick = (analytics['onclick']?['url']) as String?;

        return GifDisplay(
          url: url,
          analyticsOnLoadUrl: onload,
          analyticsOnClickUrl: onclick,
          onPing: _giphyService.pingAnalytics,
          isFavorite: _favoriteIds.contains(gifId),
          onToggleFavorite: () => _toggleFavorite(gifData),
        );
      },
    );
  }
}