// lib/features/home/home_page.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/settings_model.dart'; 
import '../../core/services/favorites_service.dart';
import '../../core/services/giphy_service.dart';
import '../../core/services/settings_service.dart';
import '../../core/widgets/skeleton_loader.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/gradient_app_bar.dart';
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
      _snack('Removido dos favoritos');
    } else {
      await _favoritesService.addFavorite(gifData);
      _snack('Adicionado aos favoritos ❤️');
    }

    setState(() {
      if (isCurrentlyFavorite) {
        _favoriteIds.remove(gifId);
      } else {
        _favoriteIds.add(gifId);
      }
    });
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
      appBar: const GradientAppBar(
        title: '🎬 GIF Gallery',
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => _performSearch(),
          child: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildContentArea()),
            ],
          ),
        ),
      ),
      floatingActionButton: _gifs.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _performSearch(),
              tooltip: 'Buscar novamente',
              child: const Icon(Icons.refresh),
            ).animate().scale(delay: 600.ms)
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                labelText: 'Procurar GIFs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch(query: '');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) => _performSearch(),
            ),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2, end: 0),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: _rating,
              onChanged: _onRatingChanged,
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down),
              items: const [
                DropdownMenuItem(value: 'g', child: Text('G')),
                DropdownMenuItem(value: 'pg', child: Text('PG')),
                DropdownMenuItem(value: 'pg-13', child: Text('PG-13')),
                DropdownMenuItem(value: 'r', child: Text('R')),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideX(begin: 0.2, end: 0),
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
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: _searchHistory.length,
        itemBuilder: (context, index) {
          final term = _searchHistory[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.history, size: 20),
              ),
              title: Text(term),
              trailing: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  setState(() {
                    _searchHistory.removeAt(index);
                    _saveSearchHistory();
                  });
                },
              ),
              onTap: () {
                _searchController.text = term;
                _performSearch(query: term);
              },
            ),
          )
              .animate(delay: (index * 50).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: -0.2, end: 0);
        },
      ),
    );
  }

  Widget _buildGifGrid() {
    if (!_settingsLoaded) {
      return const SkeletonLoader();
    }
    if (_loading) {
      return const SkeletonLoader();
    }
    if (_error != null) {
      return EmptyState(
        title: 'Oops! Algo deu errado',
        message: _error!,
        icon: Icons.error_outline,
        onAction: () => _performSearch(),
        actionLabel: 'Tentar novamente',
      );
    }
    if (_gifs.isEmpty) {
      return EmptyState(
        title: 'Nenhum GIF encontrado',
        message: _searchController.text.isEmpty
            ? 'Digite algo para começar a busca!'
            : 'Tente outros termos de busca',
        icon: Icons.search_off,
        onAction: _searchController.text.isEmpty ? null : () {
          _searchController.clear();
          _performSearch(query: '');
        },
        actionLabel: 'Limpar busca',
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        childAspectRatio: 1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
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